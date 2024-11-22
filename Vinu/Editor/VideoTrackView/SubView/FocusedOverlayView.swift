//
//  FocusedOverlayView.swift
//  Vinu
//
//  Created by 신정욱 on 10/16/24.
//

import UIKit
import SnapKit

final class FocusedOverlayView: UIView {
    let strokeWidth: CGFloat
    let radius: CGFloat
    
    // MARK: - Components
    let strokeView = {
        let view = UIView()
        view.backgroundColor = .tintBlue
        return view
    }()
    
    let leftHandleView = {
        let view = UIView()
        view.backgroundColor = .backWhite
        view.smoothCorner(radius: 7.5 / 2)
        view.dropShadow(radius: 3, opacity: 0.25)
        return view
    }()
    
    let rightHandleView = {
        let view = UIView()
        view.backgroundColor = .backWhite
        view.smoothCorner(radius: 7.5 / 2)
        view.dropShadow(radius: 3, opacity: 0.25)
        return view
    }()
    
    // MARK: - Life Cycle
    init(strokeWidth: CGFloat, radius: CGFloat) {
        self.strokeWidth = strokeWidth
        self.radius = radius
        
        super.init(frame: .zero)
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        makeStrokeMask()
    }
    
    // MARK: - Auto Layout
    private func setAutoLayout() {
        addSubview(strokeView)
        addSubview(leftHandleView)
        addSubview(rightHandleView)
        
        strokeView.snp.makeConstraints { $0.edges.equalToSuperview() }
        leftHandleView.snp.makeConstraints {
            $0.leading.verticalEdges.equalToSuperview().inset(7.5)
            $0.width.equalTo(7.5)
        }
        rightHandleView.snp.makeConstraints {
            $0.trailing.verticalEdges.equalToSuperview().inset(7.5)
            $0.width.equalTo(7.5)
        }
    }
    
    // MARK: - Mask Layer
    private func makeStrokeMask() {
        let totalPath = UIBezierPath()
        
        let outerPath = UIBezierPath(roundedRect: strokeView.bounds, cornerRadius: radius)
        
        let innerRect = CGRect(
            x: strokeWidth,
            y: strokeWidth,
            width: strokeView.bounds.width - (strokeWidth * 2),
            height: strokeView.bounds.height - (strokeWidth * 2))
        let innerPath = UIBezierPath(roundedRect: innerRect, cornerRadius: radius - strokeWidth)

        totalPath.append(outerPath)
        totalPath.append(innerPath)

        let maskLayer = CAShapeLayer()
        maskLayer.path = totalPath.cgPath
        maskLayer.fillRule = .evenOdd // 겹치는 부분은 투명 처리
        strokeView.layer.mask = maskLayer
    }
}

#Preview(traits: .fixedLayout(width: 300, height: 64)) {
    FocusedOverlayView(strokeWidth: 2, radius: 7.5)
}
