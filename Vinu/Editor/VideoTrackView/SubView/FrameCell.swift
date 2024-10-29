//
//  FrameCell.swift
//  Vinu
//
//  Created by 신정욱 on 10/2/24.
//

import UIKit
import SnapKit

final class FrameCell: UICollectionViewCell {
    static let identifier = "FrameCell"
    
    // MARK: - Component
    let imageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.backgroundColor = .chuLightGray
        return view
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutoLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}

#Preview(traits: .fixedLayout(width: 100, height: 100)) {
    FrameCell()
}
