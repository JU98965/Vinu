//
//  PreviewPlayerDelegate.swift
//  Vinu
//
//  Created by 신정욱 on 9/18/24.
//

import UIKit
import AVFoundation

// @objc 붙였기 때문에 클래스 전용 프로토콜
@objc protocol PreviewPlayerDelegate {
    @objc optional func didChangeStatus(status: Int)
    @objc optional func didChangeRate(rate: Float)
    @objc optional func didChangeTimeControlStatus(timeControlStatus: Int)
    @objc optional func didChangeElapsedTime(elapsedTime: CMTime)
    @objc optional func didChangePlayerItemStatus(status: Int)
}
