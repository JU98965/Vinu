//
//  VideoTrackScrollViewDelegate.swift
//  Vinu
//
//  Created by 신정욱 on 10/4/24.
//

import UIKit

@objc protocol VideoTrackScrollViewDelegate {
    @objc optional func didChangeContentOffset(object: VideoTrackScrollView)
}
