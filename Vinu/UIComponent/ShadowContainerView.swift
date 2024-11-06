//
//  ShadowContainerView.swift
//  Vinu
//
//  Created by 신정욱 on 11/6/24.
//

import UIKit

final class ShadowContainerView: UIStackView {
    private var smoothCornerRadius_: CGFloat = 0
    
    // MARK: - Life Cycle
    init(containing view: UIView, radius: CGFloat, opacity: Float) {
        super.init(frame: .zero)
        
        // 어레인지 서브뷰로 추가
        // 이 클래스를 쓰는 경우는 clipsToBounds가 필요한 경우가 대부분이라 clipsToBounds 활성화
        view.clipsToBounds = true
        self.addArrangedSubview(view)
        
        // 기본적인 그림자 설정
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = radius
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure Components
    // 사전에 모서리를 둥글게 만들지 못하는 경우, 나중에라도 설정 가능하게 하는 로직
    var smoothCornerRadius: CGFloat {
        get { smoothCornerRadius_ }
        set {
            smoothCornerRadius_ = newValue
            self.arrangedSubviews.forEach { view in
                view.layer.cornerRadius = newValue
                view.layer.cornerCurve = .continuous
            }
        }
    }
}
