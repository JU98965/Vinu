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
        let exportButtonTitle: Observable<String>
        let popToRootView: Observable<Void>
        let popThisView: Observable<Void>
        let disableColor: Observable<UIColor>
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
        // 홈 화면으로 돌아간다는 신호를 전달하기 위한 서브젝트
        let popToRootView = PublishSubject<Void>()
        // 이전 화면으로 돌아간다는 신호를 전달하기 위한 서브젝트
        let popThisView = PublishSubject<Void>()
        // exporter가 비활성화 됐을 때 비활성화 색상을 전달하기 위한 서브젝트
        let disableColor = PublishSubject<UIColor>()

        
        // 예상 파일 크기 받아오기
        let estimatedFileSizeText = estimatedFileSizeText()
            .observe(on: MainScheduler.instance)
        
        // 익스포터가 nil이면 내보내기 버튼 활성화 조차 안되게
        let isExportButtonEnabled = exporter
            .map { $0 != nil }
        
        // exporter의 상태가 변하면 값을 방출
        let exporterStatus = exporter
            .compactMap { $0 }
            .flatMapLatest { exporter in
                return exporter
                    .rx.observeWeakly(AVAssetExportSession.Status.self, "status")
                    .compactMap { $0 }
            }
            .observe(on: MainScheduler.instance) // observeWeakly는 메인스레드에서 실행 안되는 듯
            .share(replay: 1)

        // 상태에 따라 버튼 타이틀 변경
        let exportButtonTitle = exporterStatus
            .flatMapLatest(getButtonTitle(status:))

        // 내보내기 버튼이 눌렸을 때 exporter 상태 별 액션
        input.exportButtonTap
            .withLatestFrom(exporterStatus)
            .bind(with: self, onNext: { owner, status in
                switch status {
                case .unknown, .waiting:
                    // 대기 중, 버튼 눌리면 내보내기 실행
                    owner.export()
                case .exporting:
                    // 내보내기 중, 버튼 눌리면 작업 취소
                    owner.cancelExporting()
                case .completed:
                    // 내보내기 완료, 버튼 눌리면 홈 화면으로 돌아가기
                    popToRootView.onNext(())
                case .failed, .cancelled:
                    // 내보내기 실패 or 취소, 버튼 눌리면 지금 뷰는 닫기
                    popThisView.onNext(())
                @unknown default:
                    print(#function, "예외 발생")
                }
            })
            .disposed(by: bag)
        
        // 내보내기가 시작됐을 때 진행률 가져오기
        let progress = exporterStatus
            .compactMap { $0 == .exporting ? () : nil }
            .flatMapLatest(getPeriodicProgress)
            .share(replay: 1)
        
        // 진행률 퍼센트 텍스트 전달
        let progressText = progress
            .map { "\(Int($0 * 100))%" }
        
        // exporter의 상태가 변할 때마다 상태 텍스트를 ProgressStateView에 전달
        let statusText = exporterStatus
            .flatMapLatest(getStatusText(status:))
        
        // exporter가 비활성화 됐을 때 비활성화 된 색상을 전달
        exporterStatus
            .filter { $0 == .cancelled || $0 == .failed }
            .map { _ in UIColor.textGray }
            .bind(to: disableColor)
            .disposed(by: bag)
        
        return Output(
            estimatedFileSizeText: estimatedFileSizeText,
            isExportButtonEnabled: isExportButtonEnabled,
            progress: progress,
            progressText: progressText,
            statusText: statusText,
            exportButtonTitle: exportButtonTitle,
            popToRootView: popToRootView.asObservable(),
            popThisView: popThisView.asObservable(),
            disableColor: disableColor.asObservable())
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
    
    private func cancelExporting() {
        self.exporter?.cancelExport()
        self.exportTimer?.invalidate()
        print("내보내기 취소")
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
            case .unknown, .waiting:
                observer.onNext(String(localized: "대기중"))
            case .exporting:
                observer.onNext(String(localized: "내보내는 중"))
            case .completed:
                observer.onNext(String(localized: "내보내기 완료"))
            case .failed:
                observer.onNext(String(localized: "내보내기 실패"))
            case .cancelled:
                observer.onNext(String(localized: "작업 취소됨"))
            @unknown default:
                print(#function, "예외 발생")
            }
            
            return Disposables.create()
        }
    }
    
    private func getButtonTitle(status: AVAssetExportSession.Status) -> Observable<String> {
        Observable.create { observer in
            
            /// completed, failed, cancelled
            /// 위 상태가 되면 재시도 불가, 인스턴스 다시 만들어야 함
            /// 재시도 하고 싶다면 창을 닫고 다시 열도록 유도하는 게 나을 듯
            
            switch status {
            case .unknown, .waiting:
                observer.onNext(String(localized: "내보내기"))
            case .exporting:
                observer.onNext(String(localized: "취소"))
            case .completed:
                observer.onNext(String(localized: "홈으로 돌아가기"))
            case .failed, .cancelled:
                observer.onNext(String(localized: "닫기"))
            @unknown default:
                print(#function, "예외 발생")
            }
            
            return Disposables.create()
        }
    }
    
    
}
