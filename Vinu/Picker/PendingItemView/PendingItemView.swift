//
//  PendingItemView.swift
//  Vinu
//
//  Created by 신정욱 on 11/8/24.
//

import UIKit
import SnapKit

final class PendingItemView: UIView {
    
    // MARK: - Components
    let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.backgroundColor = .backWhite
        sv.dropShadow(radius: 8, opacity: 0.05, offset: CGSize(width: 0, height: -8))
        return sv
    }()
    
    let clipLabel = {
        let label = PaddingUILabel(padding: .init(edges: 15))
        label.font = .boldSystemFont(ofSize: 14)
        label.text = String(localized: "0개 클립 선택됨") // temp
        label.textColor = .textGray
        return label
    }()
    
    let pendingCV = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: .init())
        cv.register(PendingCell.self, forCellWithReuseIdentifier: PendingCell.identifier)
        cv.setSinglelineLayout(
            spacing: 10,
            itemSize: CGSize(width: 64, height: 64),
            sectionInset: UIEdgeInsets(horizontal: 15))
        cv.showsHorizontalScrollIndicator = false
        cv.allowsSelection = true
        cv.backgroundColor = .clear
        return cv
    }()
    
    let bottomShadowCover = {
        let view = UIView()
        view.backgroundColor = .backWhite
        return view
    }()
    
    let nextButtonBack = {
        let sv = UIStackView()
        sv.backgroundColor = .backWhite
        sv.smoothCorner(radius: 64 / 3)
        sv.clipsToBounds = true
        return sv
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)        
        setAutoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        self.addSubview(mainVStack)
        self.addSubview(bottomShadowCover)
        mainVStack.addArrangedSubview(clipLabel)
        mainVStack.addArrangedSubview(pendingCV)
        mainVStack.addSubview(nextButtonBack)

        mainVStack.snp.makeConstraints {
            $0.edges.equalToSuperview()
            // $0.width.equalTo(380) // 디버깅용
        }
        pendingCV.snp.makeConstraints { $0.height.equalTo(64) }
        bottomShadowCover.snp.makeConstraints {
            $0.height.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            // 메인 스택뷰 밑에 이어붙여서 스택뷰 아래쪽으로 삐져나오는 그림자 가리기
            $0.top.equalTo(mainVStack.snp.bottom)
        }
        nextButtonBack.snp.makeConstraints {
            $0.trailing.equalToSuperview().multipliedBy(0.9)
            $0.centerY.equalTo(mainVStack.snp.top)
            $0.size.equalTo(64)
        }
    }
}

#Preview {
    PendingItemView()
}
