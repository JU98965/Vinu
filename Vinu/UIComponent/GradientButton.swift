//
//  GradientButton.swift
//  Vinu
//
//  Created by 신정욱 on 11/5/24.
//

import UIKit

final class GradientButton: UIButton {
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
        
        // 추후 그라디언트 객체에 접근하기 위해 이름 붙여주기
        gradientLayer.name = "gradientLayer"
        gradientLayer.type = .radial
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.locations = [0.3, 1.0]
        
        self.layer.addSublayer(gradientLayer)
    }
    
    // clipsToBounds 안쓰고 모서리 둥글게 만들기 위한 눈물의 x꼬쇼
    var cornerRadius: CGFloat? { didSet { setCornerRadius() } } // 저장 속성이긴 한데 일단 메서드 관점에서 배치
    override var bounds: CGRect { didSet { setCornerRadius() } }
    
    private func setCornerRadius() {
        guard let cornerRadius, bounds != .zero else { return }
        
        // UIBezierPath의 곡선은 기본적으로 Continuous 곡선를 사용한다고 함
        let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius)
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath

        if let sublayers = self.layer.sublayers,
           let gradientLayer = sublayers.first(where: { $0.name == "gradientLayer" }) {
            // 서브레이어가 이미 등록 되었고, gradientLayer 객체에 접근 가능하다면 둥근 모서리 마스크를 적용
            gradientLayer.mask = maskLayer
        } else {
            // 서브레이어가 아직 등록 전이고, gradientLayer 객체에 바로 접근해서 둥근 모서리 마스크를 적용
            self.gradientLayer.mask = maskLayer
        }
        
        // 일반 레이어에도 둥근 모서리 적용
        self.layer.cornerRadius = cornerRadius
        self.layer.cornerCurve = .continuous
    }
}

#Preview {
    ThumbnailCell()
}
