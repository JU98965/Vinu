//
//  ProgressStateView.swift
//  Vinu
//
//  Created by 신정욱 on 11/25/24.
//

import UIKit
import SnapKit

final class ProgressStateView: UIView {
    // MARK: - Components
    let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 15
        return sv
    }()
    
    let progressContainer = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 15
        sv.isLayoutMarginsRelativeArrangement = true
        sv.directionalLayoutMargins = NSDirectionalEdgeInsets(edges: 15)
        sv.backgroundColor = .white
        sv.smoothCorner(radius: 7.5)
        sv.dropShadow(radius: 7.5, opacity: 0.025)
        return sv
    }()
    
    let progressLabelHStack = UIStackView()
    
    let statusLabel = {
        let label = UILabel()
        label.text = String(localized: "준비중")
        label.textColor = .textGray
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    let progressLabel = {
        let label = UILabel()
        label.text = String(localized: "0%")
        label.textColor = .tintBlue
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    let progressBar = {
        let bar = UIProgressView(progressViewStyle: .bar)
        bar.backgroundColor = .chuLightGray
        bar.progressTintColor = .tintBlue
        bar.smoothCorner(radius: 3.75)
        bar.clipsToBounds = true
        return bar
    }()
    
    let estimatedFileSizeContainer = {
        let sv = UIStackView()
        sv.isLayoutMarginsRelativeArrangement = true
        sv.directionalLayoutMargins = NSDirectionalEdgeInsets(edges: 15)
        sv.backgroundColor = .white
        sv.smoothCorner(radius: 7.5)
        sv.dropShadow(radius: 7.5, opacity: 0.025)
        return sv
    }()
    
    let estimatedFileSizeTitleLabel = {
        let label = UILabel()
        label.text = String(localized: "예상 파일 크기")
        label.textColor = .textGray
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    let estimatedFileSizeFactorLabel = {
        let label = UILabel()
        label.text = "10MB"
        label.textColor = .tintBlue
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
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
        mainVStack.addArrangedSubview(progressContainer)
        mainVStack.addArrangedSubview(estimatedFileSizeContainer)
        // progressContainer
        progressContainer.addArrangedSubview(progressLabelHStack)
        progressContainer.addArrangedSubview(progressBar)
        // progressLabelHStack
        progressLabelHStack.addArrangedSubview(statusLabel)
        progressLabelHStack.addArrangedSubview(UIView())
        progressLabelHStack.addArrangedSubview(progressLabel)
        // estimatedFileSizeContainer
        estimatedFileSizeContainer.addArrangedSubview(estimatedFileSizeTitleLabel)
        estimatedFileSizeContainer.addArrangedSubview(UIView())
        estimatedFileSizeContainer.addArrangedSubview(estimatedFileSizeFactorLabel)
        
        mainVStack.snp.makeConstraints { $0.edges.equalToSuperview() }
        progressBar.snp.makeConstraints { $0.height.equalTo(15) }
    }
}

#Preview {
    ProgressStateView()
}
