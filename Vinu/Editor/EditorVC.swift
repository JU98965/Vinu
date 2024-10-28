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
    let videoPlayerView = VideoPlayerView()
    
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
        view.addSubview(videoPlayerView)
        view.addSubview(videoTrackView)
        view.addSubview(button)
        
        videoPlayerView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(400)
        }
        videoTrackView.snp.makeConstraints {
            $0.top.equalTo(videoPlayerView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(60)
        }
        button.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(50)
        }
    }
    
    // MARK: - Binding
    private func setBinding() {
        guard let editorVM else { return }
        
        
        
        let input = EditorVM.Input(
            progress: videoPlayerView.progress.asObservable(),
            currentTimeRanges: videoTrackView.currentTimeRanges.asObservable())
        
        let output = editorVM.transform(input: input)

        // 플레이어와 아이템 바인딩 (플레이어에 연결되기 전까지 아이템은 .unkwon 상태)
        output.playerItem
            .bind(to: videoPlayerView.playerItemIn)
            .disposed(by: bag)
        
        // 비디오 트랙뷰 데이터 바인딩 (재생시간, 썸네일 이미지 등)
        output.trackModels
            .bind(to: videoTrackView.sourceIn)
            .disposed(by: bag)

        
//        // 영상 진행률에 따라서 스크롤 뷰의 오프셋 변경
//        output.playerProgress
//            .bind(with: self, onNext: { owner, progress in
//                let width = owner.trackScroll.contentSize.width
//                let inset = owner.trackScroll.contentInset.left
//                // 인셋도 계산에 반영
//                owner.trackScroll.contentOffset.x = width * progress - inset
//            })
//            .disposed(by: bag)
//        
//        // 영상 탐색
//        output.seek
//            .bind(with: self) { owner, seekSource in
//                let centerPoint = CGPoint(x: owner.trackScroll.bounds.midX, y: owner.trackScroll.bounds.midY)
//                // print("indexPathForItem", owner.videoClipCV.indexPathForItem(at: centerPoint))
//                
//                let contentSize = owner.trackScroll.contentSize.width
//                let contentOffset = seekSource.0.x + owner.trackScroll.contentInset.left
//                let duration = seekSource.1.duration.seconds
//                
//                let seconds = Double(contentOffset / contentSize * duration)
//                let targetTime = CMTime(seconds: seconds , preferredTimescale: 30)
//                owner.player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
//            }
//            .disposed(by: bag)
//
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
