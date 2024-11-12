//
//  VideoMetadata.swift
//  Vinu
//
//  Created by 신정욱 on 10/2/24.
//

import UIKit
import AVFoundation

struct VideoMetadata {
    let asset: AVAsset
    let assetVideoTrack: AVAssetTrack
    let assetAudioTrack: AVAssetTrack?
    let duration: CMTime
    let naturalSize: CGSize
    let preferredTransform: CGAffineTransform
    // ConfigureVM의 fetchVideoMetadataArr(_:)메서드에서 할당 직전 nil체크가 이루어짐
    var image: UIImage!
}
