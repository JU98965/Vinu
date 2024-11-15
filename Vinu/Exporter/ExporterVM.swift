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
    
    private let exporter: AVAssetExportSession?
    private let bag = DisposeBag()
    
    init(_ configuration: ExporterConfiguration) {
        self.exporter = AVAssetExportSession(configuration)
    }

    func transform(input: Input) -> Output {
        let exporterStatus = BehaviorSubject(value: AVAssetExportSession.Status.unknown)
        
        // 예상 파일 크기 받아오기
        let estimatedFileSizeText = estimatedFileSizeText()
            .observe(on: MainScheduler.instance)
        
        // 익스포터가 nil이면 내보내기 버튼 활성화 조차 안되게
        let isExportButtonEnabled = Observable.just(exporter != nil)
        
        // 내보내기 버튼 눌리면 내보내기 작업 실행
        input.exportButtonTap
            .flatMapLatest(export)
            .observe(on: MainScheduler.instance)
            .bind(to: exporterStatus)
            .disposed(by: bag)
        
        // 내보내기 작업 완료 후, 결과 텍스트 전달
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
        
        // getPeriodicProgress가 1.0까지 반환하지 못했을 때 exporterStatus를 참고해서 1.0 반환
        let completedProgressFactor = exporterStatus
            .map { status -> Double? in
                status == .completed ? 1.0 : nil
            }
        
        // iOS18 이상은 진행률 확인 가능
        let progressFactor = input.exportButtonTap
            .flatMapLatest(getPeriodicProgress)
            .observe(on: MainScheduler.instance)

        // 진행률을 사용할 수 있는 iOS버전일 경우 label로 전달
        let progressText = Observable
            .merge(progressFactor, completedProgressFactor)
            .map { progress -> String? in
                guard let progress else { return nil }
                let baseString = String(localized: "진행률: ")
                return baseString + "\(Int(progress * 100))%"
            }
        
        return Output(
            estimatedFileSizeText: estimatedFileSizeText,
            isExportButtonEnabled: isExportButtonEnabled,
            progressText: progressText,
            statusText: statusText)
    }
    
    // MARK: - Methods
    // 예상 파일 크기 받아오기
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
    
    // 내보내기 버튼 눌리면 내보내기 작업 실행
    private func export() -> Observable<AVAssetExportSession.Status> {
        Observable.create { observer in
            Task {
                guard let exporter = self.exporter,
                      let outputURL = exporter.outputURL
                else { observer.onNext(.failed); return }
                
                // 작업물 내보내기
                await exporter.export()
                
                // outputURL이 유효하지 않다면 생성 실패 처리
                guard UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputURL.path)
                else { observer.onNext(.failed); return }
                // 내보낸 작업물 앨범에 저장
                UISaveVideoAtPathToSavedPhotosAlbum(outputURL.path, self, nil, nil)

                observer.onNext(exporter.status)
            }
            
            return Disposables.create()
        }
    }
    
    // iOS18 이상은 진행률 확인 가능
    private func getPeriodicProgress() -> Observable<Double?> {
        Observable.create { observer in
            Task {
                guard
                    #available(iOS 18, *),
                    let exporter = self.exporter
                else { observer.onNext(nil); return }
                
                for await state in exporter.states(updateInterval: 0.5) {
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
