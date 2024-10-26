//
//  VideoClipCellVM.swift
//  Vinu
//
//  Created by 신정욱 on 10/3/24.
//

import UIKit
import RxSwift
import RxCocoa

final class VideoClipCellVM {
    
    struct Input {
    }
    
    struct Output {
        let frameImages: Observable<VideoClip.FrameImages>
    }
    
    private let bag = DisposeBag()
    let frameImages: VideoClip.FrameImages
    
    init(frameImages: VideoClip.FrameImages) {
        self.frameImages = frameImages
    }
    
    func transform(input: Input) -> Output {
        // let frameImages = BehaviorSubject(value: frameImages)
        let frameImages = Observable.just(frameImages)
            .share(replay: 1)

        
        return Output(
            frameImages: frameImages)
    }
}
