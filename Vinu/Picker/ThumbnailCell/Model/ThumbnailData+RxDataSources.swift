//
//  ThumbnailData+RxDataSources.swift
//  Vinu
//
//  Created by 신정욱 on 10/2/24.
//

import UIKit
import Photos
import Differentiator

extension ThumbnailData: Equatable, IdentifiableType {
    // 이게 달라지면 rx데이터소스에서 insert처리
    var identity: UUID { self.id }
    
    // 이게 false면 rx데이터소스에서 reload처리
    static func == (lhs: ThumbnailData, rhs: ThumbnailData) -> Bool {
        lhs.id == rhs.id && lhs.selectNumber == rhs.selectNumber
    }
}

struct ThumbnailSectionData: AnimatableSectionModelType {
    var items: [ThumbnailData]
    var identity: String = "NoneSection"
    
    init(original: ThumbnailSectionData, items: [ThumbnailData]) {
        self = original
        self.items = items
    }
    
    init(items: [ThumbnailData]){
        self.items = items
    }
}
