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
        mainHStack.addArrangedSubview(popButton)
        mainHStack.addArrangedSubview(UIView()) // 스페이서 용도
        mainHStack.addArrangedSubview(exportButton)
        
        mainHStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(horizontal: 15)) }
        popButton.snp.makeConstraints { $0.size.equalTo(35) }
        exportButton.snp.makeConstraints { $0.size.equalTo(35) }
    }
}

#Preview(traits: .fixedLayout(width: 300, height: 64)) {
    EditorVC()
}
