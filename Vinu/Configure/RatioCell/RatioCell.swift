//
//  RatioCell.swift
//  Vinu
//
//  Created by 신정욱 on 9/25/24.
//

import UIKit
import SnapKit

final class RatioCell: UICollectionViewCell {
    static let identifier = "RatioCell"
    
    // MARK: - Components
    let stackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        return sv
    }()
    
    let imageView = {
        let view = UIImageView()
        view.tintColor = .darkGray
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let ratioLabel = {
        let label = UILabel()
        label.text = "16:9" // temp
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .chuLightGray
        contentView.layer.cornerRadius = .chu16
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true
        setAutoLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        ratioLabel.text = ""
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(ratioLabel)
            
        stackView.snp.makeConstraints { $0.edges.equalToSuperview() }
        ratioLabel.snp.makeConstraints { $0.height.equalTo(50) }
    }
}

#Preview(traits: .fixedLayout(width: 128, height: 128)) {
    RatioCell()
}
