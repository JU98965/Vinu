//
//  UIView.swift
//  Vinu
//
//  Created by 신정욱 on 11/5/24.
//

import UIKit

extension UIView {
    func setFaintShadowTemplate(radius: CGFloat = 10) {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.25
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = radius
    }
    
    func setSmoothCornerTemplate(value: CGFloat) {
        self.layer.cornerRadius = value
        self.layer.cornerCurve = .continuous
    }
}
