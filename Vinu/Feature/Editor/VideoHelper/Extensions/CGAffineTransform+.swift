//
//  CGAffineTransform.swift
//  Vinu
//
//  Created by 신정욱 on 11/13/24.
//

import UIKit

extension CGAffineTransform {
    var orientation: UIImage.Orientation {
        let tfA = self.a
        let tfB = self.b
        let tfC = self.c
        let tfD = self.d
        
        if tfA == 0 && tfB == 1.0 && tfC == -1.0 && tfD == 0 {
            return .right
        } else if tfA == 0 && tfB == -1.0 && tfC == 1.0 && tfD == 0 {
            return .left
        } else if tfA == -1.0 && tfB == 0 && tfC == 0 && tfD == -1.0 {
            return .down
        } else {
            return .up
        }
    }
}
