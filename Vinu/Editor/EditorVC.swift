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
        sv.distribution = .fill
        return sv
    }()
    
    let videoPlayerView = VideoPlayerView()
    
    let playbackConsoleView = PlaybackConsoleView()
    
    let videoTrackView = VideoTrackView()

    let button = {
        let button = UIButton(configuration: .plain())
        button.setTitle("재생", for: .normal)
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .chuLightGray
        
        setAutoLayout()
        setBinding()
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        view.addSubview(mainVStack)
        mainVStack.addArrangedSubview(videoPlayerView)
        mainVStack.addArrangedSubview(playbackConsoleView)
        mainVStack.addArrangedSubview(videoTrackView)
        mainVStack.addArrangedSubview(button)

        mainVStack.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        playbackConsoleView.snp.makeConstraints { $0.height.equalTo(60) }
        videoTrackView.snp.makeConstraints { $0.height.equalTo(60) }
    }
    
    // MARK: - Binding
    private func setBinding() {
        guard let editorVM else { return }

        let input = EditorVM.Input(
            progress: videoPlayerView.progress.asObservable(),
            currentTimeRanges: videoTrackView.currentTimeRanges.asObservable(),
            scrollProgress: videoTrackView.scrollProgress.asObservable())
        
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
                let inset = trackScrollView.contentInset.left // 인셋도 계산에 반영

                trackScrollView.contentOffset.x = width * progress - inset
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

        // MARK: - temp
        button
            .rx.tap
            .bind(with: self) { owner, _ in
                owner.button.isSelected.toggle()
                
                if owner.button.isSelected {
                    owner.videoPlayerView.player.play()
                } else {
                    owner.videoPlayerView.player.pause()
                }
            }
            .disposed(by: bag)
    }
}

#Preview {
    EditorVC()
}
