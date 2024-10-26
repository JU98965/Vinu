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
        view.contentMode = .scaleAspectFill
        return view
    }()

    let selectBack = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.75)
        view.isHidden = true
        return view
    }()
    
    let durationLabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "--:--" // temp
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = .zero
        label.layer.shadowOpacity = 1
        label.layer.shadowRadius = 4
        label.clipsToBounds = false
        return label
    }()
    
    let selectLine = {
        let view = InnerStrokeView(strokeWidth: 1.5, radius: 8)
        view.contentView.backgroundColor = .black.withAlphaComponent(0.5)
        view.isHidden = true
        return view
    }()
    
    let numberTagLabel = {
        let label = UILabel()
        label.text = "0" // temp
        label.font = .boldSystemFont(ofSize: 54)
        label.textColor = .black.withAlphaComponent(0.5)
        label.isHidden = true
        return label
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 8
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true
        contentView.backgroundColor = .chuLightGray
        
        setAutoLayout()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        selectLine.setNeedsDisplay()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        durationLabel.text = ""
        selectLine.isHidden = true
        numberTagLabel.isHidden = true
        selectBack.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        contentView.addSubview(imageView)
        contentView.addSubview(selectBack)
        contentView.addSubview(durationLabel)
        contentView.addSubview(selectLine)
        contentView.addSubview(numberTagLabel)
        
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        selectBack.snp.makeConstraints { $0.edges.equalToSuperview() }
        durationLabel.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview().inset(UIEdgeInsets(bottom: 3, right: 5))
        }
        selectLine.snp.makeConstraints { $0.edges.equalToSuperview() }
        numberTagLabel.snp.makeConstraints { $0.center.equalToSuperview() }
    }
    
    // MARK: - Configure Components
    func configure(thumbnailData: ThumbnailData) {
        // 썸네일 바인딩
        thumbnailData.asset.fetchImage { [weak self] responseImage in
            guard let responseImage, let self else { return }
            imageView.image = responseImage
        }
        
        // 재생시간 바인딩
        let duration = Int(thumbnailData.asset.duration)
        durationLabel.text = String(format: "%02d:%02d", duration.cutMinute, duration.cutSecond)
        
        // 선택 시 바인딩
        if let number = thumbnailData.selectNumber {
            numberTagLabel.text = String(number)
            numberTagLabel.isHidden = false
            selectLine.isHidden = false
            selectBack.isHidden = false
        }
    }
}

#Preview(traits: .fixedLayout(width: 128, height: 128)) {
    ThumbnailCell()
}
