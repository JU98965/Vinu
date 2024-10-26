//
//  VideoClipCell.swift
//  Vinu
//
//  Created by 신정욱 on 9/30/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class VideoClipCell: UICollectionViewCell {
    static let identifier = "VideoClipCell"
    
    private let bag = DisposeBag()

    // MARK: - Components
    let frameCV = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: .init())
        cv.register(FrameCell.self, forCellWithReuseIdentifier: FrameCell.identifier)
        cv.showsHorizontalScrollIndicator = false
        cv.isScrollEnabled = false
        cv.layer.cornerRadius = 8
        cv.layer.cornerCurve = .continuous
        cv.clipsToBounds = true
        cv.backgroundColor = .chuTint
        return cv
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        setAutoLayout()
        setCollectionViewLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Method Injection
    func configure(_ images: VideoClip.FrameImages) {
        setBinding(images)
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        contentView.addSubview(frameCV)
        frameCV.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(right: 4)) }
    }
    
    private func setCollectionViewLayout() {
        // 모든 수치가 정해져 있기 때문에 layoutSubviews에 배치될 필요는 없음
        frameCV.setSinglelineLayout(spacing: .zero, width: 60, height: 60)
    }
    
    // MARK: - Binding
    private func setBinding(_ images: VideoClip.FrameImages) {
        Observable.just(images)
            .bind(to: frameCV.rx.items(cellIdentifier: FrameCell.identifier, cellType: FrameCell.self)) { index, item, cell in
                cell.imageView.image = UIImage(cgImage: item)
            }
            .disposed(by: bag)
    }
}

#Preview(traits: .fixedLayout(width: 300, height: 100)) {
    VideoClipCell()
}
