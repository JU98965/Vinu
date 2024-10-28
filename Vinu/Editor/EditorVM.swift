//
//  EditorVM.swift
//  Vinu
//
//  Created by 신정욱 on 9/24/24.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa

final class EditorVM {
    
    struct Input {
        let progress: Observable<Double>
        let currentTimeRanges: Observable<[CMTimeRange]>
//        let playerItemStatus: Observable<AVPlayerItem.Status>
//        let playerTimeControllStatus: Observable<AVPlayer.TimeControlStatus>
//        let playerElapsedTime: Observable<CMTime>
    }
    
    struct Output {
        let playerItem: Observable<AVPlayerItem>
        let trackModels: Observable<[VideoTrackModel]>
//        let playerItemStatus: Observable<AVPlayerItem.Status>
//        let playerProgress: Observable<Double>
//        let frameImages: Observable<[VideoClip.FrameImages]>
        
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
        let originalPlayerItem = Observable.just(helper.makePlayerItem())
            .share(replay: 1)
        
        // 트랙 뷰에 들어갈 데이터 준비
        let trackModels = Observable.just(videoClips)
            .map { videoClips in
                videoClips.map { VideoTrackModel(image: $0.image, duration: $0.metadata.duration) }
            }
            .share(replay: 1)
        
//        let seek = input.didChangeContentOffset
//            .withLatestFrom(input.playerTimeControllStatus) { ($0.contentOffset, $1) }
//            .filter { _, status in status == .paused }
//            .map { $0.0 }
//            .withLatestFrom(playerItem) { ($0, $1) }
//            .share(replay: 1)

        return Output(
            playerItem: originalPlayerItem,
            trackModels: trackModels)
    }
}


