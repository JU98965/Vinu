//
//  ConfigureCardCell.swift
//  Vinu
//
//  Created by 신정욱 on 9/25/24.
//

import UIKit
import SnapKit

final class ConfigureCardCell: UICollectionViewCell {
    static let identifier = "ConfigureCardCell"
    
    // MARK: - Components
    let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.smoothCorner(radius: 64 / 4)
        sv.clipsToBounds = true
        return sv
    }()
    
    let imageView = {
        let view = UIImageView()
        view.tintColor = .textGray
        view.contentMode = .scaleAspectFit
        view.image = UIImage(systemName: "2.square")
        return view
    }()
    
    let sizeLabel = {
        let label = UILabel()
        label.text = "16:9" // temp
        label.textColor = .textGray
        label.font = .boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setAutoLayout()
    }

    // 이미, 모든 구성 요소를 즉시 초기화시키고 있기 때문에 prepareForReuse는 필요 없을지도?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        contentView.addSubview(mainVStack)
        mainVStack.addArrangedSubview(imageView)
        mainVStack.addArrangedSubview(sizeLabel)
            
        mainVStack.snp.makeConstraints { $0.edges.equalToSuperview() }
        sizeLabel.snp.makeConstraints { $0.height.equalTo(32) }
    }
    
    // MARK: - Configure Components
    func configure(itemData: ConfigureCardCellData) {
        imageView.image = itemData.image
        sizeLabel.text = itemData.title
        
        // 선택 여부에 따라 이펙트를 그리거나 지우기
        if itemData.isSelected {
            imageView.tintColor = .tintSoda
            sizeLabel.textColor = .tintSoda
            
            mainVStack.backgroundColor = .white
            contentView.dropShadow(radius: 8, opacity: 0.01)
        } else {
            imageView.tintColor = .textGray
            sizeLabel.textColor = .textGray
            
            mainVStack.backgroundColor = .clear
            contentView.layer.shadowOpacity = 0
        }
    }
}

#Preview(traits: .fixedLayout(width: 64, height: 96)) {
    UINavigationController(rootViewController: ConfigureVC())
//    ConfigureCardCell()
}
