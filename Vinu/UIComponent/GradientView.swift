//
//  GradientView.swift
//  Vinu
//
//  Created by 신정욱 on 11/7/24.
//

import UIKit

final class GradientView: UIView {
    private let once = OnlyOnce()
    
    // MARK: - Components
    let gradientLayer = CAGradientLayer()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        once.excute { setGradient() }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layer
    private func setGradient() {
        let colors = [
            UIColor.white.withAlphaComponent(0.0).cgColor,
            UIColor.white.withAlphaComponent(0.3).cgColor,
        ]
        
        gradientLayer.type = .radial
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.locations = [0.3, 1.0]
        
        self.layer.addSublayer(gradientLayer)
    }
}
