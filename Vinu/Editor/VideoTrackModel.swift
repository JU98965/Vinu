//
//  VideoTrackModel.swift
//  Vinu
//
//  Created by 신정욱 on 10/28/24.
//


import UIKit
import AVFoundation

struct VideoTrackModel {
    let image: CGImage
    private let duration: CMTime
    private let originalWidth_: CGFloat
    private var startPoint_: CGFloat
    private var endPoint_: CGFloat
    var scale: CGFloat
    
    init(image: CGImage, duration: CMTime) {
        self.image = image
        self.duration = duration
        self.originalWidth_ = duration.seconds * 60
        self.startPoint_ = 0
        self.endPoint_ = duration.seconds * 60
        self.scale = 1.0
    }
    
    // 트림 전 원본 넓이 (스케일의 영향은 받음)
    var originalWidth: CGFloat {
        originalWidth_ * scale
    }
    
    // 시작 지점 오프셋 좌표
    var startPoint: CGFloat {
        get { startPoint_ * scale }
        set { startPoint_ = newValue / scale }
    }
    
    // 종료 지점 오프셋 좌표
    var endPoint: CGFloat {
        get { endPoint_ * scale }
        set { endPoint_ = newValue / scale }
    }
    
    // 종료 지점에서 시작 지점 빼면 그게 현재 넓이
    var currentWidth: CGFloat {
        endPoint - startPoint
    }
    
    // 시작, 종료 오프셋을 원본 넓이로 나누고, 그 백분율을 전체 시간에 곱하면 특정 시점 획득이 가능
    var newTimeRange: CMTimeRange {
        let start = CMTime(
            seconds: startPoint_ / originalWidth_ * duration.seconds,
            preferredTimescale: 30)
        
        let end = CMTime(
            seconds: endPoint_ / originalWidth_ * duration.seconds,
            preferredTimescale: 30)
        
        return CMTimeRange(start: start, end: end)
    }
}
