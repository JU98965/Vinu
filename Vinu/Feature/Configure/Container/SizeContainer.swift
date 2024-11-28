//
//  SizeContainer.swift
//  Vinu
//
//  Created by 신정욱 on 11/19/24.
//

import UIKit
import SnapKit

final class SizeContainer: UIView {
    // MARK: - Components
    let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        return sv
    }()
    
    let sizeLabel = {
        let label = PaddingUILabel(padding: UIEdgeInsets(horizontal: 15))
        label.text = String(localized: "화면 비율")
        label.textColor = .textGray
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    let sizeCV = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: .init())
        cv.register(ConfigureCardCell.self, forCellWithReuseIdentifier: ConfigureCardCell.identifier)
        cv.setSinglelineLayout(
            spacing: 15,
            itemSize: CGSize(width: 64, height: 96),
            sectionInset: UIEdgeInsets(horizontal: 15))
        cv.allowsSelection = true
        cv.backgroundColor = .clear
        return cv
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
        mainVStack.addArrangedSubview(sizeLabel)
        mainVStack.addArrangedSubview(sizeCV)
        
        // self.snp.makeConstraints { $0.size.equalTo(300) } // 디버깅 용
        mainVStack.snp.makeConstraints { $0.edges.equalToSuperview() }
        sizeCV.snp.makeConstraints { $0.height.equalTo(96) }
    }
}

#Preview(traits: .fixedLayout(width: 300, height: 300)) {
    SizeContainer()
}
