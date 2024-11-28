//
//  Array+ThumbnailData.swift
//  Vinu
//
//  Created by 신정욱 on 10/1/24.
//


import UIKit

extension Array where Element == ThumbnailData {
    var sectionData: [ThumbnailSectionData] {
        [ThumbnailSectionData(items: self)]
    }
}

extension Array where Element == ThumbnailSectionData {
    var items: [ThumbnailData] {
        self.first?.items ?? [ThumbnailData]()
    }
}
