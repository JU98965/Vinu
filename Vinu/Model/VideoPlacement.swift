//
//  VideoPlacement.swift
//  Vinu
//
//  Created by 신정욱 on 11/13/24.
//


import UIKit

enum VideoPlacement: CaseIterable {
    case aspectFit
    case aspectFill
    
    var localizedString: String {
        switch self {
        case .aspectFit:
            String(localized: "끼움")
        case .aspectFill:
            String(localized: "채움")
        }
    }
    
    var image: UIImage? {
        switch self {
        case .aspectFit:
            UIImage(named: "aspect_fit")
        case .aspectFill:
            UIImage(named: "aspect_fill")
        }
    }
}
