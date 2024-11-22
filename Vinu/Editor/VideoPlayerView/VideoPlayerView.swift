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
    let controlStatus = PublishSubject<AVPlayer.TimeControlStatus>()
    
    // MARK: - Components
    let mainContainerView = {
        let view = UIView()
        view.smoothCorner(radius: 7.5)
        view.clipsToBounds = true
        return view
    }()
    
    let backContainerView = UIView()
    
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialLight))
    
    let frontContainerView = UIView()
    
    let player = PreviewPlayer()
    
    var backPlayerLayer: AVPlayerLayer?

    var frontPlayerLayer: AVPlayerLayer?
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutoLayout()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        // 플레이어 컨테이너 뷰의 서브 뷰로 또 다른 플레이어 컨테이너가 있으면 있으면 한 플레이어가 나머지 플레이어를 덮어버림
        self.addSubview(mainContainerView)
        mainContainerView.addSubview(backContainerView)
        mainContainerView.addSubview(blurView)
        mainContainerView.addSubview(frontContainerView)
        
        mainContainerView.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(horizontal: 15)) }  
        backContainerView.snp.makeConstraints { $0.edges.equalToSuperview() }
        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }
        frontContainerView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    // MARK: - Binding
    private func setBinding() {

        let input = VideoPlayerVM.Input(
            playerItemIn: playerItemIn.asObservable(),
            itemStatus: player.rx.playerItemStatus,
            controlStatus: player.rx.timeControlStatus,
            elapsedTime: player.rx.elapsedTime)
        
        let output = videoPlayerVM.transform(input: input)
        
        // 외부에서 받아온 아이템을 플레이어에 바인딩 (플레이어에 연결되기 전까지 아이템은 .unkwon 상태)
        output.playerItem
            .bind(to: player.rx.replaceCurrentItem)
            .disposed(by: bag)
        
        // 아이템이 재생 가능 상태가 되면 플레이어를 구성
        output.configure
            .bind(with: self) { owner, _ in
                owner.backPlayerLayer = AVPlayerLayer(player: owner.player)
                owner.backPlayerLayer?.videoGravity = .resizeAspectFill
                owner.backPlayerLayer?.frame = owner.backContainerView.bounds
                
                owner.frontPlayerLayer = AVPlayerLayer(player: owner.player)
                owner.frontPlayerLayer?.videoGravity = .resizeAspect
                owner.frontPlayerLayer?.frame = owner.frontContainerView.bounds
                
                if let playerLayer = owner.frontPlayerLayer,
                   let playerBackLayer = owner.backPlayerLayer {
                    owner.backContainerView.layer.addSublayer(playerBackLayer)
                    owner.frontContainerView.layer.addSublayer(playerLayer)
                    
                    // 무음 모드를 무시하고 avplayer에서 소리가 나게 하기
                    do {
                        try AVAudioSession.sharedInstance().setCategory(.playback)
                    } catch(let error) {
                        print(error.localizedDescription)
                    }
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
        
        // 비디오 플레이어의 재생 상태를 외부에 전달
        output.controlStatus
            .bind(to: controlStatus)
            .disposed(by: bag)
    }
}
