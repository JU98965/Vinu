//
//  ThumbnailData.swift
//  Vinu
//
//  Created by 신정욱 on 9/18/24.
//

import UIKit
import Photos
import Differentiator

struct ThumbnailData {
    let id: UUID
    let asset: PHAsset
    var selectNumber: Int?
}

extension ThumbnailData: Equatable, IdentifiableType {
    // 이게 달라지면 rx데이터소스에서 insert처리
    var identity: UUID { self.id }
    
    // 이게 false면 rx데이터소스에서 reload처리
    static func == (lhs: ThumbnailData, rhs: ThumbnailData) -> Bool {
        lhs.id == rhs.id && lhs.selectNumber == rhs.selectNumber
    }
}
