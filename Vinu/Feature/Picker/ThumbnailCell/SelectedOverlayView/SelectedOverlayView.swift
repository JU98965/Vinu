//
//  SelectedOverlayView.swift
//  Vinu
//
//  Created by 신정욱 on 11/8/24.
//

import UIKit
import SnapKit

final class SelectedOverlayView: UIView {
    private let once = OnlyOnce()
    
    // MARK: - Components
    let selectBack = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        return view
    }()
    
    let numberTagBackShadow = {
        let sv = UIStackView()
        sv.dropShadow(radius: 3, opacity: 0.1)
        return sv
    }()
    
    let numberTagBack = {
        let view = UIView()
        view.backgroundColor = .backWhite
        view.clipsToBounds = true
        return view
    }()
    
    let numberTagLabel = {
        let label = UILabel()
        label.text = "0" // temp
        label.font = .boldSystemFont(ofSize: 72)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = .tintBlue
        return label
    }()

    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutoLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        once.excute {
            layoutIfNeeded()
            numberTagBack.smoothCorner(radius: numberTagBackShadow.bounds.width / 2)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        self.addSubview(selectBack)
        selectBack.addSubview(numberTagBackShadow)
        numberTagBackShadow.addArrangedSubview(numberTagBack)
        numberTagBack.addSubview(numberTagLabel)
        
        selectBack.snp.makeConstraints { $0.edges.equalToSuperview() }
        numberTagBackShadow.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalToSuperview().multipliedBy(0.4)
        }
        numberTagLabel.snp.makeConstraints { $0.edges.equalToSuperview().inset(5) }
    }
}

#Preview {
    SelectedOverlayView()
}
