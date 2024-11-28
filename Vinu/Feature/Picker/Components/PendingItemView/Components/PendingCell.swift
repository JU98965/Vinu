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
        view.smoothCorner(radius: 7.5)
        return view
    }()
    
    let overrayView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.25)
        view.smoothCorner(radius: 7.5)
        return view
    }()
    
    let removeImageBack = {
        let view = UIStackView()
        view.backgroundColor = .tintBlue
        view.isLayoutMarginsRelativeArrangement = true
        view.directionalLayoutMargins = NSDirectionalEdgeInsets(edges: 4)
        view.dropShadow(radius: 3, opacity: 0.1)
        return view
    }()
     
    let removeImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "x_icon")?.withTintColor(.white)
        return view
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.dropShadow(radius: 1.5, opacity: 0.1)
        contentView.smoothCorner(radius: 7.5)
        
        setAutoLayout()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        removeImageBack.smoothCorner(radius: removeImageBack.bounds.height / 2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        contentView.addSubview(imageView)
        contentView.addSubview(overrayView)
        contentView.addSubview(removeImageBack)
        removeImageBack.addArrangedSubview(removeImageView)
        
        contentView.snp.makeConstraints { $0.edges.equalToSuperview().inset(3) }
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        overrayView.snp.makeConstraints { $0.edges.equalToSuperview() }
        removeImageBack.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(-3)
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
