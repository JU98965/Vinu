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

extension ConfigureCardCell {
    struct RatioData: ConfigureCardCellData {
        let image: UIImage?
        let title: String
        var isSelected = false
        let exportSize: CGSize
    }
    
    struct PlacementData: ConfigureCardCellData {
        let image: UIImage?
        let title: String
        var isSelected = false
        let placement: ConfigureData.Placement
    }
}
