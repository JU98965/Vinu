//
//  ShadowButtonBase.swift
//  Vinu
//
//  Created by 신정욱 on 11/5/24.
//

import UIKit
import SnapKit

final class ShadowButtonBase: UIView {
    private var isSet = false
    
    // MARK: - Components
    let shadowView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0
        view.layer.shadowOffset = .zero
        view.layer.shadowRadius = 5
        view.layer.cornerRadius = 5
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    let containerView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }()
    
    let button: UIButton
    
    let gradientLayer = CAGradientLayer()
    
    // MARK: - Life Cycle
    init(_ button: UIButton = UIButton(configuration: .filled())) {
        self.button = button
        
        super.init(frame: .zero)
        setAutoLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !isSet {
            isSet.toggle()
            layoutIfNeeded()
            setGradient()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        self.addSubview(shadowView)
        shadowView.addSubview(containerView)
        containerView.addSubview(button)
        
        shadowView.snp.makeConstraints {
//            $0.size.equalTo(100)
//            $0.center.equalToSuperview()
            $0.edges.equalToSuperview()
        }
        containerView.snp.makeConstraints { $0.edges.equalToSuperview() }
        button.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    // 그라데이션 설정
    private func setGradient() {
        let colors = [
            UIColor.white.withAlphaComponent(0.5).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor,
        ]
        
        gradientLayer.frame = button.bounds
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 1, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.locations = [0.0, 1.0]
        
        button.layer.addSublayer(gradientLayer)
    }
}
    
#Preview {
    ShadowButtonBase()
}
