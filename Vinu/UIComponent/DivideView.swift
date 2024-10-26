//
//  DivideView.swift
//  Vinu
//
//  Created by 신정욱 on 9/24/24.
//

import UIKit
import SnapKit

final class DivideView: UIView {
    let lineWidth: CGFloat
    
    let line = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    init(lineWidth: CGFloat, lineColor: UIColor) {
        self.lineWidth = lineWidth
        self.line.backgroundColor = lineColor
        
        super.init(frame: .zero)
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setAutoLayout() {
        self.addSubview(line)
        
        line.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(lineWidth)
        }
    }
}

#Preview(traits: .fixedLayout(width: 100, height: 100)) {
    DivideView(lineWidth: 5, lineColor: .black)
}
