//
//  IndicatorPointView.swift
//  Vinu
//
//  Created by 신정욱 on 11/2/24.
//

import UIKit
import SnapKit

final class IndicatorPointView: UIView {
    // MARK: - Components
    let pointView = {
        let view = UIView()
        view.layer.cornerRadius = 2.5
        view.backgroundColor = .black
        return view
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
        self.addSubview(pointView)
        
        pointView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(5)
        }
    }
}
