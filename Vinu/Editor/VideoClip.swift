//
//  VideoClip.swift
//  Vinu
//
//  Created by 신정욱 on 10/2/24.
//

import Foundation
import AVFoundation

struct VideoClip {
    typealias FrameImages = [CGImage]
    
    struct Metadata {
        let asset: AVAsset
        let assetVideoTrack: AVAssetTrack
        let assetAudioTrack: AVAssetTrack
        let duration: CMTime
        let naturalSize: CGSize
        let preferredTransform: CGAffineTransform
    }

    let metadata: Self.Metadata
    let frameImages: FrameImages
}


