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
        sv.distribution = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.directionalLayoutMargins = NSDirectionalEdgeInsets(edges: 5)
        sv.backgroundColor = .white
        sv.smoothCorner(radius: 7.5)
        sv.dropShadow(radius: 7.5, opacity: 0.05)
        return sv
    }()
    
    let hdrButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .tintBlue
        config.baseForegroundColor = .white
        config.attributedTitle = AttributedString(
            String(localized: "HDR"),
            attributes: AttributeContainer([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]))
        let button = UIButton(configuration: config)
        button.smoothCorner(radius: 7.5)
        return button
    }()
    
    let exportButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .tintBlue
        config.image = UIImage(named: "export_icon")?
            .withTintColor(.white)
            .resizeImage(newWidth: 16)
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
        mainHStack.addArrangedSubview(UIView()) // 스페이서 용도
        mainHStack.addArrangedSubview(exportButton)
        
        mainHStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(horizontal: 15)) }
    }
}

#Preview(traits: .fixedLayout(width: 300, height: 64)) {
    EditorVC()
}
