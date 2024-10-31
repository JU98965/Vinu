//
//  TrimHandleView.swift
//  Vinu
//
//  Created by 신정욱 on 10/16/24.
//

import UIKit
import SnapKit

final class TrimHandleView: UIView {
    let width: CGFloat
    let radius: CGFloat
    
    // MARK: - Components
    let contentView = UIView()
    
    // MARK: - Life Cycle
    init(strokeWidth: CGFloat, radius: CGFloat) {
        self.width = strokeWidth
        self.radius = radius
        
        super.init(frame: .zero)
        contentView.backgroundColor = .black
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        makeMask(view: contentView)
    }
    
    // MARK: - Auto Layout
    private func setAutoLayout() {
        addSubview(contentView)
        contentView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    // MARK: - Mask Layer
    private func makeMask(view: UIView) {
        let totalPath = UIBezierPath()
        
        let outerPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: .zero)
        
        let innerRect = CGRect(
            x: width,
            y: width,
            width: view.bounds.width - width * 2,
            height: view.bounds.height - width * 2)
        let innerPath = UIBezierPath(roundedRect: innerRect, cornerRadius: radius - width)
        

        totalPath.append(outerPath)
        totalPath.append(innerPath)

        let maskLayer = CAShapeLayer()
        maskLayer.path = totalPath.cgPath
        maskLayer.fillRule = .evenOdd // 겹치는 부분은 투명 처리
        view.layer.mask = maskLayer
    }
}

#Preview(traits: .fixedLayout(width: 300, height: 100)) {
    TrimHandleView(strokeWidth: 4, radius: 8)
}
