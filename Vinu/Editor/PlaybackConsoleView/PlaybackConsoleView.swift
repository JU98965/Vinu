//
//  PlaybackConsoleView.swift
//  Vinu
//
//  Created by 신정욱 on 10/29/24.
//

import UIKit
import SnapKit

final class PlaybackConsoleView: UIView {

    // MARK: - Components
    let mainHStack = {
        let sv = UIStackView()
        sv.distribution = .fillEqually
        sv.backgroundColor = .white
        sv.smoothCorner(radius: 7.5)
        sv.dropShadow(radius: 7.5, opacity: 0.05)
        return sv
    }()
    
    let elapsedTimeLabel = {
        let label = PaddingUILabel(padding: UIEdgeInsets(left: 15))
        label.text = "00:00 / 00:00" // temp
        label.textColor = .textGray
        return label
    }()
    
    let playbackButton = {
        let image = UIImage(systemName: "play.fill")
        let button = UIButton(configuration: .plain())
        button.setImage(image, for: .normal)
        button.tintColor = .black
        return button
    }()
    
    let scaleHStack = UIStackView()
    
    let scaleImageBack = UIView()
    let scaleImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "magnifier_icon")?
            .withTintColor(.textGray)
            .resizeImage(newWidth: 18)
        return view
    }()
    
    let scaleLabel = {
        let label = PaddingUILabel(padding: UIEdgeInsets(right: 15))
        label.text = "x0.00"
        label.textAlignment = .right
        label.textColor = .textGray
        return label
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
        mainHStack.addArrangedSubview(elapsedTimeLabel)
        mainHStack.addArrangedSubview(playbackButton)
        mainHStack.addArrangedSubview(scaleHStack)
        scaleHStack.addArrangedSubview(scaleImageBack)
        scaleHStack.addArrangedSubview(scaleLabel)
        scaleImageBack.addSubview(scaleImageView)
        
        mainHStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(horizontal: 15)) }
        scaleImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(3)
        }
    }
}

#Preview {
    EditorVC()
}
