//
//  ExporterVC.swift
//  Vinu
//
//  Created by 신정욱 on 11/12/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ExporterVC: UIViewController {
    
    // MARK: - Components
    let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        return sv
    }()
    
    let resultLabel = {
        let label = UILabel()
        label.text = String(localized: "내보내기 결과")
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Life Cylce
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar(title: String(localized: "비디오 내보내기"))
        setAutoLayout()
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        view.addSubview(mainVStack)
        mainVStack.addArrangedSubview(resultLabel)
        
        mainVStack.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
    }

}

#Preview {
    UINavigationController(rootViewController: ExporterVC())
}
