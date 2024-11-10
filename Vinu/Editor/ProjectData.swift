//
//  ProjectData.swift
//  Vinu
//
//  Created by 신정욱 on 10/16/24.
//

import UIKit
import Photos

struct ProjectData {
    let title: String
    let phAssets: [PHAsset]
    let exportSize: CGSize
    let date: Date
}

struct NewProjectData {
    let title: String
    let exportSize: CGSize
    let videoClips: [VideoClip]
}
