//
//  VideoResolution.swift
//  Vinu
//
//  Created by 신정욱 on 11/13/24.
//


import UIKit

enum VideoResolution: String, CaseIterable {
    case portrait1080x1920 = "9:16"
    case landscape1920x1080 = "16:9"
    case portrait1440x1920 = "3:4"
    case landscape1920x1440 = "4:3"
    case portrait1280x2560 = "1:2"
    case landscape2560x1280 = "2:1"

    var cgSize: CGSize {
        switch self {
        case .portrait1080x1920:
            CGSize(width: 1080, height: 1920)
        case .landscape1920x1080:
            CGSize(width: 1920, height: 1080)
        case .portrait1440x1920:
            CGSize(width: 1440, height: 1920)
        case .landscape1920x1440:
            CGSize(width: 1920, height: 1440)
        case .portrait1280x2560:
            CGSize(width: 1280, height: 2560)
        case .landscape2560x1280:
            CGSize(width: 2560, height: 1280)
        }
    }
}