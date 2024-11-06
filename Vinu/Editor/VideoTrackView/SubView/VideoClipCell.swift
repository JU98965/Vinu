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
    // 일단 빈 배열로 초기화 후 나중에 데이터 바인딩 (릴레이 하나만 있으니까 뷰모델은 사용하지 않음)
    let frameImagesIn = BehaviorRelay<[UIImage]>(value: [])

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
        // 모든 수치가 정해져 있어 layoutsubview 시점에 초기화 시켜줄 필요 없음
        cv.setSinglelineLayout(spacing: .zero, itemSize: .init(width: 64, height: 64))
        return cv
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        setAutoLayout()
        setBinding()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        contentView.addSubview(frameCV)
        frameCV.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(right: 4)) }
    }
    
    // MARK: - Binding
    private func setBinding() {
        frameImagesIn
            .bind(to: frameCV.rx.items(cellIdentifier: FrameCell.identifier, cellType: FrameCell.self)) { index, item, cell in
                cell.imageView.image = item
            }
            .disposed(by: bag)
    }
}

#Preview(traits: .fixedLayout(width: 300, height: 100)) {
    VideoClipCell()
}
