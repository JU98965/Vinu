//
//  GradientButton.swift
//  Vinu
//
//  Created by 신정욱 on 11/5/24.
//

import UIKit

final class GradientButton: UIButton {
    private var isSet = false
    
    // MARK: - Components
    let gradientLayer = CAGradientLayer()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isSet {
            isSet.toggle()
            setGradient()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 그라디언트 설정
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

#Preview {
    UINavigationController(rootViewController: MainVC())
}
