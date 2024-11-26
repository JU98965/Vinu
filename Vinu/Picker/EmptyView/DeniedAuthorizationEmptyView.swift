//
//  DeniedAuthorizationEmptyView.swift
//  Vinu
//
//  Created by 신정욱 on 11/24/24.
//

import UIKit
import SnapKit

final class DeniedAuthorizationEmptyView: UIView {
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
        view.image = UIImage(systemName: "exclamationmark.triangle")?
            .resizeImage(newWidth: 50)
            .withTintColor(.textGray)
        return view
    }()
    
    let subtitleLabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .textGray
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.text = String(localized: "사진에 접근할 수 없어요.\n앱 설정에서 사진 접근을 허용하고 다시 시도해 주세요.")
        label.font = .systemFont(ofSize: label.font.pointSize, weight: .semibold)
        return label
    }()

    
    let redirectButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .tintBlue
        config.title = String(localized: "설정으로 이동")
        let button = UIButton(configuration: config)
        button.smoothCorner(radius: 7.5)
        return button
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
        mainVStack.addArrangedSubview(redirectButton)

        mainVStack.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(30)
        }
        redirectButton.snp.makeConstraints { $0.height.equalTo(30) }
    }
}

#Preview {
    DeniedAuthorizationEmptyView()
}
