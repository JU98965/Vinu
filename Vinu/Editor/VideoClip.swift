//
//  VideoClip.swift
//  Vinu
//
//  Created by 신정욱 on 10/2/24.
//

import UIKit
import AVFoundation

struct VideoClip {
    
    struct Metadata {
        let asset: AVAsset
        let assetVideoTrack: AVAssetTrack
        let assetAudioTrack: AVAssetTrack?
        let duration: CMTime
        let naturalSize: CGSize
        let preferredTransform: CGAffineTransform
    }

    let metadata: Metadata
    let image: UIImage
}
