//
//  EditorVM.swift
//  Vinu
//
//  Created by 신정욱 on 9/24/24.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation

final class EditorVM {
    
    struct Input {
        let playerItemStatus: Observable<AVPlayerItem.Status>
        let playerTimeControllStatus: Observable<AVPlayer.TimeControlStatus>
        let playerElapsedTime: Observable<CMTime>
    }
    
    struct Output {
        let playerItem: Observable<AVPlayerItem>
        let playerItemStatus: Observable<AVPlayerItem.Status>
        let playerProgress: Observable<Double>
        let frameImages: Observable<[VideoClip.FrameImages]>
        
//        let initalWidths: Observable<[CGFloat]>
//        let changeWidths: Observable<[CGFloat]>
//        let seek: Observable<(CGPoint, AVPlayerItem)>
    }
    
    let bag = DisposeBag()
    let videoClips: [VideoClip]
    let helper: VideoHelper

    init(_ videoClips: [VideoClip]) throws {
        self.videoClips = videoClips
        
        let metadata = videoClips.map { $0.metadata }
        self.helper = try VideoHelper(metadataArr: metadata, exportSize: CGSize(width: 1080, height: 1920))
    }
    
    func transform(input: Input) -> Output {
        // AVAsset들을 AVMutableComposition으로 병합
        let playerItem = Observable
            .just(helper.makePlayerItem())
            .share(replay: 1)
        
        // 트랙 뷰에 들어갈 이미지 묶음들
        let frameImages = Observable
            .just({
                videoClips.map { $0.frameImages }
            }())
            .share(replay: 1)
        
        // 현재 트랙 뷰 사이즈를 저정하는 서브젝트
        let currentWidths = BehaviorSubject<[CGFloat]>(value: {
            videoClips.map { CGFloat($0.metadata.duration.seconds * 60) }
        }())
        
        // 현재 영상 진행률
        let playerProgress = input.playerElapsedTime
            .withLatestFrom(playerItem) { elapsed, playerItem in
                let total = playerItem.duration.seconds
                let elapsed = elapsed.seconds
                return elapsed / total
            }

        // 핀치 제스처의 스케일에 따라서 트랙뷰 너비 변경
//        let changeWidths =  input.trackPinchGesture
//            .withLatestFrom(currentWidths) { gesture, originalWidth in
//                let newWidth = originalWidth.map { $0 * gesture.scale }
//                gesture.scale = 1
//                return newWidth
//            }
//            .do(onNext: { width in
//                // 바뀐 넓이 업데이트
//                currentWidths.onNext(width)
//            })
//            .share(replay: 1)
        
//        let seek = input.didChangeContentOffset
//            .withLatestFrom(input.playerTimeControllStatus) { ($0.contentOffset, $1) }
//            .filter { _, status in status == .paused }
//            .map { $0.0 }
//            .withLatestFrom(playerItem) { ($0, $1) }
//            .share(replay: 1)

        return Output(
            playerItem: playerItem,
            playerItemStatus: input.playerItemStatus,
            playerProgress: playerProgress,
            frameImages: frameImages)
    }
}


