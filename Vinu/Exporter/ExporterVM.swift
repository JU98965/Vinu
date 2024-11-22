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
        let progress: Observable<Float>
        let progressText: Observable<String>
        let statusText: Observable<String>
        let exportButtonConfig: Observable<ExportButtonStatus>
        let backMainView: Observable<Void>
    }
    
    private let exporter: AVAssetExportSession?
    private var exportTimer: Timer?
    private let bag = DisposeBag()
    
    init(_ configuration: ExporterConfiguration) {
        self.exporter = AVAssetExportSession(configuration)
    }

    func transform(input: Input) -> Output {
        // exporter객체를 스트림 차원에서 관리하기 위한 서브젝트
        let exporter = BehaviorSubject(value: exporter).asObservable()

        // exporter의 상태가 변하면 값을 방출
        let exporterStatus = exporter
            .compactMap { $0 }
            .flatMapLatest {
                $0.rx.observeWeakly(AVAssetExportSession.Status.self, "status")
                    .compactMap { $0 }
            }
            .observe(on: MainScheduler.instance) // observeWeakly는 메인스레드에서 실행 안되는 듯
            .share(replay: 1)
        
        // exporter 상태에 따라서 내보내기 버튼의 상태도 바뀜
        let exportButtonConfig = exporterStatus
            .map { ExportButtonStatus(expoterStatus: $0) }
        
        // 예상 파일 크기 받아오기
        let estimatedFileSizeText = estimatedFileSizeText()
            .observe(on: MainScheduler.instance)
        
        // 익스포터가 nil이면 내보내기 버튼 활성화 조차 안되게
        let isExportButtonEnabled = exporter
            .map { $0 != nil }

        // 내보내기 버튼 눌리면 내보내기 작업 실행
        input.exportButtonTap
            .withLatestFrom(exporterStatus)
            .filter { $0 == .unknown || $0 == .waiting }
            .bind(with: self) { owner, _ in owner.export() }
            .disposed(by: bag)
        
        // 내보내기 완료, 실패 후 홈 화면으로 돌아가기
        let backMainView = input.exportButtonTap
            .withLatestFrom(exporterStatus) { _, status -> AVAssetExportSession.Status in status }
            .compactMap {
                if $0 == .completed || $0 == .failed {
                    return ()
                } else {
                    return nil
                }
            }

        // exporter의 상태에 따라 텍스트 전달
        let statusText = exporterStatus
            .flatMapLatest(getStatusText(status:))
        
        // .exporting 상태일 때 진행률 가져오기
        let progress = exporterStatus
            .compactMap { $0 == .exporting ? () : nil }
            .flatMapLatest(getPeriodicProgress)
            .share(replay: 1)
        
        // 진행률 텍스트 전달
        let progressText = progress
            .map { "\(Int($0 * 100))%" }
        
        return Output(
            estimatedFileSizeText: estimatedFileSizeText,
            isExportButtonEnabled: isExportButtonEnabled,
            progress: progress,
            progressText: progressText,
            statusText: statusText,
            exportButtonConfig: exportButtonConfig,
            backMainView: backMainView)
    }
    
    // MARK: - Methods
    // 예상 파일 크기 받아오기
    private func estimatedFileSizeText() -> Observable<String> {
        Observable.create { observer in
            Task {
                let fileLength = try? await self.exporter?.estimatedOutputFileLengthInBytes
                
                if let fileLength {
                    let text = ByteCountFormatter.string(fromByteCount: fileLength, countStyle: .file)
                    observer.onNext(text)
                } else {
                    let text = String(localized: "알 수 없음")
                    observer.onNext(text)
                }
            }
            
            return Disposables.create()
        }
    }
    
    private func export() {
        Task {
            guard let exporter = self.exporter, let outputURL = exporter.outputURL else { return }
            // 작업물 내보내기
            await exporter.export()
            // 내보낸 작업물 앨범에 저장
            UISaveVideoAtPathToSavedPhotosAlbum(outputURL.path, self, nil, nil)
        }
    }
    
    private func getPeriodicProgress() -> Observable<Float> {
        Observable.create { [weak self] observer in
            guard let self, let exporter else { return Disposables.create() }
            
            self.exportTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                // 타이머는 메인 런루프에서 밖에 안 돎, 데이터 레이스 안일어날 듯?
                let progress = exporter.progress
                observer.onNext(progress)
                
                // progress가 1.0에 다다르면 타이머 정지
                if progress == 1.0 { timer.invalidate() }
            }
            
            return Disposables.create { self.exportTimer?.invalidate() }
        }
    }
    
    private func getStatusText(status: AVAssetExportSession.Status) -> Observable<String> {
        Observable.create { observer in
            switch status {
            case .exporting:
                observer.onNext(String(localized: "내보내는 중"))
            case .completed:
                observer.onNext(String(localized: "내보내기 완료"))
            case .failed:
                observer.onNext(String(localized: "내보내기 실패"))
            case .cancelled:
                observer.onNext(String(localized: "취소됨"))
            default:
                observer.onNext(String(localized: "대기중"))
            }
            
            return Disposables.create()
        }
    }
}
