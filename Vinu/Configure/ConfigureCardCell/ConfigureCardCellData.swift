//
//  ConfigureCardCellData.swift
//  Vinu
//
//  Created by 신정욱 on 11/9/24.
//

import UIKit

protocol ConfigureCardCellData {
    var image: UIImage? { get }
    var title: String { get }
    var isSelected: Bool { get set }
}

struct RatioCardData: ConfigureCardCellData {
    let image: UIImage?
    let title: String
    var isSelected = false
    let size: VideoSize
}

struct PlacementCardData: ConfigureCardCellData {
    let image: UIImage?
    let title: String
    var isSelected = false
    let placement: VideoPlacement
}
