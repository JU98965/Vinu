//
//  ThumbnailCell.swift
//  Vinu
//
//  Created by 신정욱 on 9/18/24.
//

import UIKit
import SnapKit

final class ThumbnailCell: UICollectionViewCell {
    static let identifier = "ThumbnailCell"
        
    // MARK: - Components
    let imageView = {
        let view = UIImageView()
        view.image = UIImage(named: "main_view_image")
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    let selectedOverlayView = {
        let view = SelectedOverlayView()
        view.isHidden = true
        return view
    }()
    
    let durationLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11, weight: .semibold)
        label.text = "12:34" // temp
        label.textColor = .white
        label.dropShadow(radius: 3, opacity: 0.75)
        return label
    }()

    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true

        setAutoLayout()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        durationLabel.text = ""
        selectedOverlayView.numberTagLabel.text = ""
        selectedOverlayView.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        contentView.addSubview(imageView)
        contentView.addSubview(selectedOverlayView)
        contentView.addSubview(durationLabel)
        
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        selectedOverlayView.snp.makeConstraints { $0.edges.equalToSuperview() }
        durationLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(1.5)
            $0.trailing.equalToSuperview().inset(3)
        }
    }
    
    // MARK: - Configure Components
    func configure(thumbnailData: ThumbnailData) {
        // 썸네일 바인딩
        thumbnailData.asset.fetchImage { [weak self] responseImage in
            guard let responseImage, let self else { return }
            imageView.image = responseImage
        }
        
        // 재생시간 바인딩, 0초로 나오면 안되니까 ceil처리
        let duration = Int(ceil(thumbnailData.asset.duration))
        durationLabel.text = String(format: "%02d:%02d", duration.cutMinute, duration.cutSecond)
        
        // 선택 시 바인딩
        if let number = thumbnailData.selectNumber {
            selectedOverlayView.numberTagLabel.text = String(number)
            selectedOverlayView.isHidden = false
        }
    }
}

#Preview(traits: .fixedLayout(width: 100, height: 100)) {
    ThumbnailCell()
}
