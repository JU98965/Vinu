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
        let scrollProgress: Observable<CGFloat>
    }
    
    struct Output {
        let playerItem: Observable<AVPlayerItem>
        let trackModels: Observable<[VideoTrackModel]>
        let progress: Observable<Double>
        let seekingPoint: Observable<CMTime>
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

        let originalPlayerItem = Observable.just(helper.makePlayerItem())
            .share(replay: 1)
        
        // 트랙 뷰에 들어갈 데이터 준비
        /// Observable.just()신중하게 써야겠다... 이 스트림 밑으로 BehaviorSubject건 퍼블리쉬건 싹 다 complet되어버림
        let trackModels = BehaviorSubject(value: videoClips)
            .map { videoClips in
                videoClips.map { VideoTrackModel(image: $0.image, duration: $0.metadata.duration) }
            }
            .share(replay: 1)
        
        let progress = input.progress
            .share(replay: 1)
        
        let seekingPoint = input.scrollProgress
            .withLatestFrom(originalPlayerItem) { progress, item in
                let timePointInFloat = progress * item.duration.seconds
                return CMTime(seconds: timePointInFloat, preferredTimescale: 30)
            }
            .distinctUntilChanged()
            .share(replay: 1)

        return Output(
            playerItem: originalPlayerItem,
            trackModels: trackModels,
            progress: progress,
            seekingPoint: seekingPoint)
    }
}


