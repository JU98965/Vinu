//
//  EmptyView.swift
//  Vinu
//
//  Created by 신정욱 on 11/24/24.
//

import UIKit
import SnapKit

final class EmptyView: UIView {
    
    // MARK: - Components
    let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 15
        sv.alignment = .center
        return sv
    }()
    
    let imageView = {
        let view = UIImageView()
        view.image = UIImage(systemName: "questionmark")?
            .resizeImage(newWidth: 30)
            .withTintColor(.textGray)
        return view
    }()
    
    let subtitleLabel = {
        let label = UILabel()
        label.textColor = .textGray
        label.adjustsFontSizeToFitWidth = true
        label.text = String(localized: "사진에서 불러올 수 있는 비디오가 없는 것 같아요.")
        label.font = .systemFont(ofSize: label.font.pointSize, weight: .semibold)
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
        mainVStack.addArrangedSubview(imageView)
        mainVStack.addArrangedSubview(subtitleLabel)
        
        mainVStack.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(30)
        }
    }
}

#Preview {
    EmptyView()
}
