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
        // view.image = UIImage(named: "main_view_image")
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    let selectBack = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
        view.isHidden = true
        // view.layer.compositingFilter = "screenBlendMode"
        return view
    }()
    
    let numberTagBack = {
        let view = GradientButton()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .tintSoda
        view.setFaintShadowTemplate(radius: 10)
        view.isHidden = true
        return view
    }()
    
    let numberTagLabel = {
        let label = UILabel()
        label.text = "0" // temp
        label.font = .boldSystemFont(ofSize: 72)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = .white
        label.isHidden = true
        return label
    }()
    
    let durationLabelBack = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.layer.cornerCurve = .continuous
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
        self.contentView.layer.cornerRadius = 5
        self.contentView.layer.cornerCurve = .continuous
        self.contentView.clipsToBounds = true
        self.contentView.backgroundColor = .chuLightGray
        
        setAutoLayout()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        durationLabel.text = ""
        numberTagLabel.text = ""
        selectBack.isHidden = true
        numberTagBack.isHidden = true
        numberTagLabel.isHidden = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setNumberTagRadius()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        contentView.addSubview(imageView)
        contentView.addSubview(durationLabelBack)
        imageView.addSubview(selectBack)
        selectBack.contentView.addSubview(numberTagBack)
        numberTagBack.addSubview(numberTagLabel)
        durationLabelBack.addSubview(durationLabel)

        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        selectBack.snp.makeConstraints { $0.edges.equalToSuperview() }
        numberTagBack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalToSuperview().multipliedBy(0.33)
        }
        numberTagLabel.snp.makeConstraints { $0.edges.equalToSuperview().inset(5) }
        durationLabelBack.snp.makeConstraints { $0.trailing.bottom.equalToSuperview().inset(5) }
        durationLabel.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(horizontal: 5, vertical: 2.5)) }
    }
    
    private func setNumberTagRadius() {
        numberTagBack.cornerRadius = numberTagBack.frame.width / 2
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
