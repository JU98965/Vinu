//
//  ExporterVM.swift
//  Vinu
//
//  Created by 신정욱 on 11/12/24.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa

final class ExporterVM {
    
    struct Input {
        let exportButtonTap: Observable<Void>
    }
    
    struct Output {
        let estimatedFileSizeText: Observable<String>
        let isExportButtonEnabled: Observable<Bool>
        let progressText: Observable<String?>
        let statusText: Observable<String>
    }
    
    private let configuration: ExporterConfiguration
    private let exporter: AVAssetExportSession?
    private let bag = DisposeBag()
    
    init(_ configuration: ExporterConfiguration) {
        self.configuration = configuration
        self.exporter = AVAssetExportSession(configuration)
    }

    func transform(input: Input) -> Output {
        let exporterStatus = BehaviorSubject(value: AVAssetExportSession.Status.unknown)
        
        let estimatedFileSizeText = estimatedFileSizeText()
            .observe(on: MainScheduler.instance)
        
        let isExportButtonEnabled = Observable.just(exporter != nil)
        
        input.exportButtonTap
            .flatMapLatest(export)
            .observe(on: MainScheduler.instance)
            .bind(to: exporterStatus)
            .disposed(by: bag)
        
        let progressText = input.exportButtonTap
            .flatMapLatest(getPeriodicProgress)
            .map { progress -> String? in
                guard let progress else { return nil }
                let baseString = String(localized: "진행률: ")
                return baseString + String(format: "%01d%", progress)
            }
            .observe(on: MainScheduler.instance)
        
        let statusText = exporterStatus
            .map { status in
                switch status {
                case .exporting:
                    return String(localized: "내보내는 중")
                case .completed:
                    return String(localized: "내보내기 완료")
                case .failed:
                    return String(localized: "내보내기 실패")
                case .cancelled:
                    return String(localized: "취소됨")
                default:
                    return String(localized: "대기중")
                }
            }
        
        
        
        return Output(
            estimatedFileSizeText: estimatedFileSizeText,
            isExportButtonEnabled: isExportButtonEnabled,
            progressText: progressText,
            statusText: statusText)
    }
        
    private func estimatedFileSizeText() -> Observable<String> {
        Observable.create { observer in
            Task {
                let fileLength = try? await self.exporter?.estimatedOutputFileLengthInBytes
                let baseString = String(localized: "예상 크기: ")
                
                if let fileLength {
                    let text = baseString + ByteCountFormatter.string(fromByteCount: fileLength, countStyle: .file)
                    observer.onNext(text)
                } else {
                    let text = baseString + String(localized: "알 수 없음")
                    observer.onNext(text)
                }
            }
            
            return Disposables.create()
        }
    }
    
    
    private func export() -> Observable<AVAssetExportSession.Status> {
        Observable.create { observer in
            Task {
                guard let exporter = self.exporter,
                      let outputURL = exporter.outputURL
                else { observer.onNext(.failed); return }
                
                // 작업물 내보내기
                await exporter.export()
                // 내보낸 작업물 앨범에 저장 (저장 가능 여부는 ExportSession생성 단계에서 이미 확인함)
                UISaveVideoAtPathToSavedPhotosAlbum(outputURL.path, self, nil, nil)

                observer.onNext(exporter.status)
            }
            
            return Disposables.create()
        }
    }
    
    private func getPeriodicProgress() -> Observable<Double?> {
        Observable.create { observer in
            Task {
                guard
                    #available(iOS 18, *),
                    let exporter = self.exporter
                else { observer.onNext(nil); return }
                
                for await state in exporter.states(updateInterval: 1.0) {
                    switch state {
                    case .pending:
                        print("pending")
                    case .waiting:
                        print("waiting")
                    case .exporting(progress: let progress):
                        print("exporting", progress.fractionCompleted)
                        observer.onNext(progress.fractionCompleted)
                    @unknown default:
                        print("default")
                    }
                }
            }
            
            return Disposables.create()
        }
    }
}
