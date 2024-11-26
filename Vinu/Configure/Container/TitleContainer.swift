//
//  TitleContainer.swift
//  Vinu
//
//  Created by 신정욱 on 11/19/24.
//

import UIKit
import SnapKit

final class TitleContainer: UIView {
    
    // MARK: - Components
    let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        sv.isLayoutMarginsRelativeArrangement = true
        sv.directionalLayoutMargins = NSDirectionalEdgeInsets(horizontal: 15)
        return sv
    }()
    
    let titleLabel = {
        let label = UILabel()
        label.text = String(localized: "프로젝트 제목")
        label.textColor = .textGray
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    let titleTFBack = {
        let sv = UIStackView()
        sv.backgroundColor = .white
        sv.isLayoutMarginsRelativeArrangement = true
        sv.directionalLayoutMargins = NSDirectionalEdgeInsets(horizontal: 8, vertical: 4)
        sv.smoothCorner(radius: 7.5)
        sv.dropShadow(radius: 8, opacity: 0.01)
        return sv
    }()
    
    let titleTF = {
        let tf = UITextField()
        tf.placeholder = String(localized: "2024년 10월 9일") // Temp
        tf.returnKeyType = .done // 키보드 리턴키를 "완료"로 변경
        tf.clearButtonMode = .whileEditing
        tf.borderStyle = .none
        return tf
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
        self.addSubview(mainVStack)
        mainVStack.addArrangedSubview(titleLabel)
        mainVStack.addArrangedSubview(titleTFBack)
        titleTFBack.addArrangedSubview(titleTF)

        // self.snp.makeConstraints { $0.size.equalTo(300) } // 디버깅 용
        mainVStack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

#Preview(traits: .fixedLayout(width: 300, height: 300)) {
    TitleContainer()
}
