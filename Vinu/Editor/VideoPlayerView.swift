//
//  VideoPlayerView.swift
//  Vinu
//
//  Created by 신정욱 on 10/28/24.
//

import UIKit
import AVFoundation
import SnapKit
import RxSwift
import RxCocoa

final class VideoPlayerView: UIView {
    private let videoPlayerVM = VideoPlayerVM()
    
    private let bag = DisposeBag()
    
    let playerItemIn = PublishSubject<AVPlayerItem>()
    let progress = PublishSubject<Double>()
    
    // MARK: - Components
//    let previewPlayerView = {
//        let view = UIView()
//        view.backgroundColor = .white
//        return view
//    }()
    
    let player = PreviewPlayer()
    
    var playerLayer: AVPlayerLayer?
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
//        setAutoLayout()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
//        self.addSubview(previewPlayerView)
//        previewPlayerView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    // MARK: - Binding
    private func setBinding() {
        // 플레이어의 재생 상태(재생, 정지 등) 변화를 뷰모델에 전달
        let timeControllStatus = player.rx.observeWeakly(AVPlayer.TimeControlStatus.self, "timeControlStatus")
            .compactMap { $0 }
            .share(replay: 1)
        
        let input = VideoPlayerVM.Input(
            playerItemIn: playerItemIn.asObservable(),
            itemStatus: player.rx.playerItemStatus,
            timeControllStatus: timeControllStatus,
            elapsedTime: player.rx.elapsedTime)
        
        let output = videoPlayerVM.transform(input: input)
        
        // 외부에서 받아온 아이템을 플레이어에 바인딩 (플레이어에 연결되기 전까지 아이템은 .unkwon 상태)
        output.playerItem
            .bind(to: player.rx.replaceCurrentItem)
            .disposed(by: bag)
        
        // 아이템이 재생 가능 상태가 되면 플레이어를 구성
        output.configure
            .bind(with: self) { owner, _ in
                owner.playerLayer = AVPlayerLayer(player: owner.player)
                owner.playerLayer?.videoGravity = .resizeAspect
                owner.playerLayer?.frame = owner.bounds
                
                if let playerLayer = owner.playerLayer {
                    owner.layer.addSublayer(playerLayer)
                    // 로딩 후 즉시 탐색을 위해 재생 및 정지
                    owner.player.play()
                    owner.player.pause()
                }
            }
            .disposed(by: bag)
        
        // 진행률을 외부에 전달
        output.progress
            .bind(to: progress)
            .disposed(by: bag)
    }
}
