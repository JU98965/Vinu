//
//  TrackIndicatorView.swift
//  Vinu
//
//  Created by 신정욱 on 11/2/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class TrackIndicatorView: UIView {
    
    private let bag = DisposeBag()
    let pointCount = BehaviorSubject(value: 10)
    
    // MARK: - Components
    let mainHStack = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        return sv
    }()

    var pointViews = [IndicatorPointView]()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAutoLayout()
        setBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        self.addSubview(mainHStack)
        pointViews.forEach { mainHStack.addArrangedSubview($0) }
        
        mainHStack.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    // MARK: - Binding
    private func setBinding() {
        pointCount.asObservable()
            .bind(with: self) { owner, count in
                // pointViews를 갱신하기 전에 스택뷰에서 "완전히" 제거
                owner.pointViews.forEach { $0.removeFromSuperview() }
                // pointViews를 갱신하고 스택뷰에 다시 할당
                owner.pointViews = (0..<count).map { _ in IndicatorPointView() }
                owner.pointViews.forEach { owner.mainHStack.addArrangedSubview($0) }
            }
            .disposed(by: bag)
    }
}

#Preview(traits: .fixedLayout(width: 300, height: 100)) {
    TrackIndicatorView()
}
