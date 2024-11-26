//
//  NavigationConsoleView.swift
//  Vinu
//
//  Created by 신정욱 on 11/26/24.
//

import UIKit
import SnapKit

final class NavigationConsoleView: UIView {
    
    // MARK: - Components
    let mainHStack = UIStackView()
    
    let popButtonContainer = {
        let sv = UIStackView()
        sv.isLayoutMarginsRelativeArrangement = true
        sv.directionalLayoutMargins = NSDirectionalEdgeInsets(edges: 5)
        sv.backgroundColor = .white
        sv.smoothCorner(radius: 7.5)
        sv.dropShadow(radius: 7.5, opacity: 0.025)
        return sv
    }()
    
    let popButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .tintBlue
        config.image = UIImage(named: "home_icon")?
            .withTintColor(.white)
            .resizeImage(newWidth: 24)
        let button = UIButton(configuration: config)
        button.smoothCorner(radius: 7.5)
        return button
    }()
    
    let exportButtonContainer = {
        let sv = UIStackView()
        sv.isLayoutMarginsRelativeArrangement = true
        sv.directionalLayoutMargins = NSDirectionalEdgeInsets(edges: 5)
        sv.backgroundColor = .white
        sv.smoothCorner(radius: 7.5)
        sv.dropShadow(radius: 7.5, opacity: 0.025)
        return sv
    }()
    
    let exportButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .tintBlue
        config.image = UIImage(named: "export_icon")?
            .withTintColor(.white)
            .resizeImage(newWidth: 24)
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
        mainHStack.addArrangedSubview(popButtonContainer)
        mainHStack.addArrangedSubview(UIView()) // 스페이서 용도
        mainHStack.addArrangedSubview(exportButtonContainer)
        popButtonContainer.addArrangedSubview(popButton)
        exportButtonContainer.addArrangedSubview(exportButton)
        
        mainHStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(horizontal: 15)) }
        popButtonContainer.snp.makeConstraints { $0.size.equalTo(50) }
        exportButtonContainer.snp.makeConstraints { $0.size.equalTo(50) }
    }
}

#Preview(traits: .fixedLayout(width: 300, height: 64)) {
    EditorVC()
}
