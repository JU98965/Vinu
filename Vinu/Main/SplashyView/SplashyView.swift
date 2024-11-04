//
//  SplashyView.swift
//  Vinu
//
//  Created by 신정욱 on 11/4/24.
//

import UIKit
import SnapKit

final class SplashyView: UIView {
    // MARK: - Components
    let imageView = {
        let view = UIImageView()
        view.image = UIImage(named: "main_view_image")
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    
    let titleLabel = {
        let label = UILabel()
        label.text = "The easiest way to\nmerge videos."
        label.font = .preferredFont(forTextStyle: .extraLargeTitle2)
        label.numberOfLines = 2
        label.textColor = .white
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = .zero
        label.layer.shadowOpacity = 0.5
        label.layer.shadowRadius = 10
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
        self.addSubview(imageView)
        self.addSubview(titleLabel)
        imageView.addSubview(blurView)
        
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview().multipliedBy(0.8)
            $0.horizontalEdges.equalToSuperview().inset(25)
        }
    }
}

#Preview {
    SplashyView()
}
