//
//  VideoMakingOption.swift
//  Vinu
//
//  Created by 신정욱 on 11/13/24.
//


import UIKit
import Photos

struct VideoMakingOption {
    let metadataArr: [VideoMetadata]
    let size: VideoSize
    let placement: VideoPlacement
    var trimmedTimeRanges: [CMTimeRange]
    var isHDRAllowed: Bool
}
