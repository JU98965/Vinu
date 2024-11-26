//
//  EditorVC.swift
//  Vinu
//
//  Created by 신정욱 on 9/24/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import AVFoundation

final class EditorVC: UIViewController {
    var editorVM: EditorVM?
    private let bag = DisposeBag()
    
    // MARK: - Components
    let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 15
        return sv
    }()
    
    let navigationConsoleView = NavigationConsoleView()
    
    let videoPlayerView = {
        let view = VideoPlayerView()
        view.dropShadow(radius: 7.5, opacity: 0.05)
        return view
    }()
    
    let editConsoleView = EditConsoleView()
    
    let playbackConsoleView = PlaybackConsoleView()
    
    let videoTrackView = VideoTrackView()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backWhite
        
        setAutoLayout()
        setBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 영상 선택창에서 다시 돌아올 때 네비게이션 바를 숨김
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        // 다른 창으로 넘어갈 때 숨겼던 네비게이션 바를 표시
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        view.addSubview(mainVStack)
        mainVStack.addArrangedSubview(navigationConsoleView)
        mainVStack.addArrangedSubview(videoPlayerView)
        mainVStack.addArrangedSubview(editConsoleView)
        mainVStack.addArrangedSubview(playbackConsoleView)
        mainVStack.addArrangedSubview(videoTrackView)

        mainVStack.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide).inset(UIEdgeInsets(vertical: 15)) }
        playbackConsoleView.snp.makeConstraints { $0.height.equalTo(50) }
        videoTrackView.snp.makeConstraints { $0.height.equalTo(78) }
    }
    
    // MARK: - Binding
    private func setBinding() {
        guard let editorVM else { return }

        let input = EditorVM.Input(
            progress: videoPlayerView.progress.asObservable(),
            timeRanges: videoTrackView.timeRanges.asObservable(),
            scrollProgress: videoTrackView.scrollProgress.asObservable(),
            scaleFactor: videoTrackView.scaleFactor.asObservable(),
            controlStatus: videoPlayerView.controlStatus.asObservable(),
            playbackTap: playbackConsoleView.playbackButton.rx.tap.asObservable(),
            hdrTap: editConsoleView.hdrButton.rx.tap.asObservable(),
            exportTap: navigationConsoleView.exportButton.rx.tap.asObservable(),
            popTap: navigationConsoleView.popButton.rx.tap.asObservable())
        
        let output = editorVM.transform(input: input)

        // 플레이어와 아이템 바인딩 (플레이어에 연결되기 전까지 아이템은 .unkwon 상태)
        output.playerItem
            .bind(to: videoPlayerView.playerItemIn)
            .disposed(by: bag)
        
        // 비디오 트랙뷰 데이터 바인딩 (재생시간, 썸네일 이미지 등)
        output.trackViewData
            .bind(to: videoTrackView.sourceIn)
            .disposed(by: bag)
        
        // 영상 진행률에 따라서 트랙 뷰의 콘텐츠 오프셋 변경
        output.progress
            .bind(with: self) { owner, progress in
                let trackScrollView = owner.videoTrackView.scrollView
                
                let width = trackScrollView.contentSize.width
                let horizontalSpacerWidth = owner.view.window?.windowScene?.screen.bounds.width ?? .zero
                // 스페이서 만큼의 넓이를 제외해야 실질적인 콘텐츠 사이즈를 얻을 수 있음
                let actualWidth = width - horizontalSpacerWidth

                trackScrollView.contentOffset.x = actualWidth * progress
            }
            .disposed(by: bag)
        
        // 트랙뷰의 스크롤에 따라서 비디오 탐색
        output.seekingPoint
            .bind(with: self) { owner, time in
                let player = owner.videoPlayerView.player
                // 재생 중일 때도 트랙의 콘텐츠 오프셋은 변하니까 정지중일 경우에만 탐색할 수 있어야 함
                guard player.timeControlStatus == .paused else { return }
                player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
            }
            .disposed(by: bag)
        
        // 트랙뷰의 콘텐츠 오프셋 변경에 따라서 경과 시간 텍스트 바인딩
        output.elapsedTimeText
            .bind(to: playbackConsoleView.elapsedTimeLabel.rx.text)
            .disposed(by: bag)
        
        // 확대 배율을 텍스트로 바꿔서 콘솔에 전달
        output.scaleFactorText
            .bind(to: playbackConsoleView.scaleLabel.rx.text)
            .disposed(by: bag)
        
        // 재생 버튼을 누를 때마다 재생 or 정지
        output.shouldPlay
            .bind(with: self) { owner, shouldPlay in
                if shouldPlay {
                    owner.videoPlayerView.player.play()
                } else {
                    owner.videoPlayerView.player.pause()
                }
            }
            .disposed(by: bag)
        
        // 재생 상태에 따라 버튼의 이미지를 변경
        output.playbackImage
            .bind(to: playbackConsoleView.playbackButton.rx.image())
            .disposed(by: bag)
        
        // 내보내기 버튼을 누르면 화면 전환
        output.presentExportVC
            .bind(with: self) { owner, configration in
                let vc = ExporterVC()
                vc.exporterVM = ExporterVM(configration)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: bag)
        
        // hdr활성화 여부에 따라 버튼 상태 변경
        output.isHDRAllowed
            .bind(with: self) { owner, isAllowed in
                let button = owner.editConsoleView.hdrButton
                if isAllowed {
                    button.configuration?.baseForegroundColor = .tintBlue
                } else {
                    button.configuration?.baseForegroundColor = .textGray
                }
            }
            .disposed(by: bag)
        
        // 홈 화면으로 돌아가기 전 확인 얼럿 표시
        output.displayPopAlert
            .bind(with: self) { owner, _ in
                owner.alertPopThisView()
            }
            .disposed(by: bag)
    }
}

#Preview {
    UINavigationController(rootViewController: EditorVC()
)
}
