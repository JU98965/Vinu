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
    
    let selectBack = {
        let view = UIView()
        view.backgroundColor = .white.withAlphaComponent(0.5)
        view.isHidden = true
        return view
    }()
    
    let numberTagBackShadow = {
        let sv = UIStackView()
        sv.dropShadow(radius: 1.5, opacity: 0.15)
        return sv
    }()
    
    let numberTagBack = {
        let view = GradientView()
        view.backgroundColor = .tintSoda
        view.clipsToBounds = true
        return view
    }()
    
    let numberTagLabel = {
        let label = UILabel()
        label.text = "0" // temp
        label.font = .boldSystemFont(ofSize: 72)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = .backWhite
        return label
    }()
    
    let durationLabelBackShadow = {
        let sv = UIStackView()
        sv.dropShadow(radius: 1.5, opacity: 0.15)
        // sv.layer.compositingFilter = "hardLightBlendMode"
        return sv
    }()
    
    let durationLabelBack = {
        let view = UIView()
        view.backgroundColor = .backWhite
        view.smoothCorner(radius: 5)
        view.clipsToBounds = true
        return view
    }()
    
    let durationLabel = {
        let label = UILabel()
        label.textColor = .textGray
        label.text = "12:34" // temp
        label.font = .systemFont(ofSize: 10, weight: .semibold)
        return label
    }()


    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .chuLightGray
        self.contentView.clipsToBounds = true
        self.dropShadow(radius: 1.5, opacity: 0.1)
        
        setAutoLayout()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        durationLabel.text = ""
        numberTagLabel.text = ""
        selectBack.isHidden = true
        setCornerRadiuses()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // cell들은 이 시점에 그려주는게 좋은 듯
        setCornerRadiuses()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        contentView.addSubview(imageView)
        imageView.addSubview(selectBack)
        selectBack.addSubview(numberTagBackShadow)
        numberTagBackShadow.addArrangedSubview(numberTagBack)
        numberTagBack.addSubview(numberTagLabel)
        
        contentView.addSubview(durationLabelBackShadow)
        durationLabelBackShadow.addArrangedSubview(durationLabelBack)
        durationLabelBack.addSubview(durationLabel)

        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        selectBack.snp.makeConstraints { $0.edges.equalToSuperview() }
        numberTagBackShadow.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalToSuperview().multipliedBy(0.4)
        }
        numberTagLabel.snp.makeConstraints { $0.edges.equalToSuperview().inset(5) }
        
        durationLabelBackShadow.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(5)
        }
        durationLabel.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(horizontal: 2.5, vertical: 1.25)) }
    }
    
    // 각 뷰들의 모서리 곡률을 뷰의 넓이에 맞춰서 처리
    private func setCornerRadiuses() {
        self.contentView.smoothCorner(radius: self.bounds.width / 3)
        numberTagBack.smoothCorner(radius: numberTagBackShadow.bounds.width / 2)
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
            numberTagLabel.text = String(number)
            selectBack.isHidden = false
            numberTagBack.isHidden = false
            numberTagLabel.isHidden = false
        }
    }
}

#Preview(traits: .fixedLayout(width: 100, height: 100)) {
    ThumbnailCell()
}
