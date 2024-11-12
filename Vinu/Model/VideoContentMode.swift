//
//  VideoContentMode.swift
//  Vinu
//
//  Created by 신정욱 on 11/13/24.
//


import UIKit

enum VideoContentMode: CaseIterable {
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
}