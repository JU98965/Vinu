//
//  CGAffineTransform.swift
//  Vinu
//
//  Created by 신정욱 on 11/13/24.
//

import UIKit

extension CGAffineTransform {
    func getOrientation() -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        let tfA = self.a
        let tfB = self.b
        let tfC = self.c
        let tfD = self.d
        
        if tfA == 0 && tfB == 1.0 && tfC == -1.0 && tfD == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if tfA == 0 && tfB == -1.0 && tfC == 1.0 && tfD == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if tfA == 1.0 && tfB == 0 && tfC == 0 && tfD == 1.0 {
            assetOrientation = .up
        } else if tfA == -1.0 && tfB == 0 && tfC == 0 && tfD == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }
    
#warning("나중에 isPortrait없이 처리 가능하게 변경하기")
    var orientation: UIImage.Orientation {
        let tfA = self.a
        let tfB = self.b
        let tfC = self.c
        let tfD = self.d
        
        if tfA == 0 && tfB == 1.0 && tfC == -1.0 && tfD == 0 {
            return .right
        } else if tfA == 0 && tfB == -1.0 && tfC == 1.0 && tfD == 0 {
            return .left
        } else if tfA == 1.0 && tfB == 0 && tfC == 0 && tfD == 1.0 {
            return .up
        } else if tfA == -1.0 && tfB == 0 && tfC == 0 && tfD == -1.0 {
            return .down
        } else {
            return .up
        }
    }
}
