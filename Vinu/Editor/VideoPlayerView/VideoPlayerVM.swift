//
//  VideoPlayerVM.swift
//  Vinu
//
//  Created by 신정욱 on 10/28/24.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa

final class VideoPlayerVM {
    
    struct Input {
        let playerItemIn: Observable<AVPlayerItem>
        let itemStatus: Observable<AVPlayerItem.Status>
        let controlStatus: Observable<AVPlayer.TimeControlStatus>
        let elapsedTime: Observable<CMTime>
    }
    
    struct Output {
        let playerItem: Observable<AVPlayerItem>
        let configure: Observable<Void>
        let progress: Observable<Double>
        let controlStatus: Observable<AVPlayer.TimeControlStatus>
    }
    
    private let bag = DisposeBag()
    
    func transform(input: Input) -> Output {
        // 상태는 플레이어가 가질거라, 받아온 그대로 전달만 하는게 맞을듯
        let playerItem = input.playerItemIn
            .share(replay: 1)
        
        // 아이템이 재생 가능 상태가 되면, 이제 플레이어를 구성해도 된다는 신호만 전달
        let configure = input.itemStatus
            .filter { $0 == .readyToPlay }
            .map { _ in }
        
        // 현재 경과시간을 바탕으로 진행률 계산 후 외부에 전달
        let progress = input.elapsedTime
            .withLatestFrom(playerItem) { elapsed, playerItem in
                let total = playerItem.duration.seconds
                let elapsed = elapsed.seconds
                return elapsed / total
            }
            .startWith(0)
            .share(replay: 1)
        
        // 비디오 플레이어의 재생 상태를 외부에 전달
        let controlStatus = input.controlStatus
            .share(replay: 1)
                
        return Output(
            playerItem: playerItem,
            configure: configure,
            progress: progress,
            controlStatus: controlStatus)
    }
}
