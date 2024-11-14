//
//  EditConsoleView.swift
//  Vinu
//
//  Created by 신정욱 on 11/14/24.
//

import UIKit
import SnapKit

final class EditConsoleView: UIView {
    
    // MARK: - Components
    let mainHStack = UIStackView()
    
    let hdrButton = {
        let button = UIButton(configuration: .plain())
        button.setTitle("HDR", for: .normal)
        return button
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        self.addSubview(mainHStack)
        mainHStack.addArrangedSubview(hdrButton)
        mainHStack.addArrangedSubview(UIView()) // 스페이서 용도
        
        mainHStack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

#Preview(traits: .fixedLayout(width: 300, height: 64)) {
    EditConsoleView()
}
