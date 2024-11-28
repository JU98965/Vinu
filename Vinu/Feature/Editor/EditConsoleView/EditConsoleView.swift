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
    let mainHStack = {
        let sv = UIStackView()
        sv.spacing = 15
        return sv
    }()
    
    let hdrButton = {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .tintBlue
        config.attributedTitle = AttributedString(
            String(localized: "HDR"),
            attributes: AttributeContainer([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]))
        let button = UIButton(configuration: config)
        button.smoothCorner(radius: 7.5)
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
        mainHStack.addArrangedSubview(UIView())

        mainHStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(horizontal: 15)) }
        hdrButton.snp.makeConstraints { $0.height.equalTo(30) }
    }
}

#Preview(traits: .fixedLayout(width: 300, height: 64)) {
    EditorVC()
}
