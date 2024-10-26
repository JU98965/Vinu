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
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }()
    
    let removeImageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "multiply.circle.fill")
        view.tintColor = .white
        return view
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        contentView.addSubview(imageView)
        contentView.addSubview(removeImageView)
        
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        removeImageView.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(4)
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
