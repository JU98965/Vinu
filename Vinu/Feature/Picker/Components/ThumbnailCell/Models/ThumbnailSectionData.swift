//
//  ThumbnailSectionData.swift
//  Vinu
//
//  Created by 신정욱 on 10/2/24.
//

import UIKit
import Photos
import Differentiator

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
