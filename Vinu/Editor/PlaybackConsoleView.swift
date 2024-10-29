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
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.backgroundColor = .lightGray
        return sv
    }()
    
    let elapsedTimeLabel = {
        let label = UILabel()
        label.text = "00:00" // temp
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    let playbackButton = {
        let image = UIImage(systemName: "play.fill")
        
        let button = UIButton(configuration: .plain())
        button.setImage(image, for: .normal)
        button.tintColor = .black
        return button
    }()
    
    let scaleLabel = {
        let label = UILabel()
        label.text = "1.0x"
        label.textAlignment = .center
        label.textColor = .black
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
        addSubview(mainHStack)
        mainHStack.addArrangedSubview(elapsedTimeLabel)
        mainHStack.addArrangedSubview(playbackButton)
        mainHStack.addArrangedSubview(scaleLabel)
        
        mainHStack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
