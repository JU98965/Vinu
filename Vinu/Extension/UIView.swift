//
//  UIView.swift
//  Vinu
//
//  Created by 신정욱 on 11/5/24.
//

import UIKit

extension UIView {
    func dropShadow(radius: CGFloat, opacity: Float, offset: CGSize = .zero) {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
    }
    
    func smoothCorner(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.cornerCurve = .continuous
    }
}
