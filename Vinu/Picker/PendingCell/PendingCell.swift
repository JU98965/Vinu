//
//  PendingCell.swift
//  Vinu
//
//  Created by 신정욱 on 9/20/24.
//

import UIKit
import SnapKit

final class PendingCell: UICollectionViewCell {
    static let identifier = "PendingCell"

    // MARK: - Components
    let imageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .chuLightGray
        view.clipsToBounds = true
        view.smoothCorner(radius: 5)
        return view
    }()
    
    let removeImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "multiply.circle.fill")
        view.tintColor = .white
        view.layer.compositingFilter = "hardLightBlendMode"
        view.dropShadow(radius: 1, opacity: 0.1)
        return view
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.dropShadow(radius: 1.5, opacity: 0.1)
        contentView.smoothCorner(radius: 5)
        
        setAutoLayout()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
//        contentView.smoothCorner(radius: contentView.bounds.height / 3)
//        imageView.smoothCorner(radius: imageView.bounds.height / 3)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        contentView.addSubview(imageView)
        contentView.addSubview(removeImageView)
        
        contentView.snp.makeConstraints {
            $0.size.equalToSuperview()
            $0.center.equalToSuperview()
        }
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        removeImageView.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.size.equalTo(16)
        }
    }
    
    // MARK: - Configure Components
    func configure(thumbnailData: ThumbnailData) {
        thumbnailData.asset.fetchImage { [weak self] responseImage in
            guard let responseImage else { return }
            self?.imageView.image = responseImage
        }
    }
}

#Preview(traits: .fixedLayout(width: 64, height: 64)) {
    PendingCell()
}
