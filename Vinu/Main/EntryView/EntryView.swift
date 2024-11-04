//
//  EntryView.swift
//  Vinu
//
//  Created by 신정욱 on 11/5/24.
//

import UIKit
import SnapKit

final class EntryView: UIView {
    // MARK: - Components
    let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = .chu16
        return sv
    }()
    
    let buttonHStack = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 5
        return sv
    }()
    
    let mergeButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .tintSoda
        config.baseForegroundColor = .white
        config.title = String(localized: "비디오 병합")
        config.image = UIImage(systemName: "arrow.trianglehead.merge")?.resizeImage(newWidth: 50).withTintColor(.white)
        config.imagePlacement = .top
        config.imagePadding = 5
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 5
        button.layer.cornerCurve = .continuous
        button.clipsToBounds = true
        return ShadowButtonBase(button)
    }()
    
    let extractButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .tintIvory
        config.baseForegroundColor = .white
        config.title = String(localized: "음원 추출")
        config.image = UIImage(systemName: "square.and.arrow.up.fill")?.resizeImage(newWidth: 50).withTintColor(.white)
        config.imagePlacement = .top
        config.imagePadding = 5
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = 5
        button.layer.cornerCurve = .continuous
        button.clipsToBounds = true
        return ShadowButtonBase(button)
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .backWhite
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        self.addSubview(mainVStack)
        mainVStack.addArrangedSubview(buttonHStack)
        buttonHStack.addArrangedSubview(mergeButton)
        buttonHStack.addArrangedSubview(extractButton)
                
        mainVStack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(25)
        }
    }
    
}

#Preview {
    EntryView()
}
