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
    let exporterVM: ExporterVM? = ExporterVM()
    private let bag = DisposeBag()
    
    // MARK: - Components
    let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 15
        return sv
    }()
    
    let estimatedFileSizeLabel = {
        let label = UILabel()
        label.text = String(localized: "예상 크기: 12MB")
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    let resultLabel = {
        let label = UILabel()
        label.text = String(localized: "내보내기 결과")
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    let exportButton = {
        let button = UIButton(configuration: .filled())
        button.setTitle("내보내기", for: .normal)
        return button
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
        mainVStack.addArrangedSubview(estimatedFileSizeLabel)
        mainVStack.addArrangedSubview(resultLabel)
        mainVStack.addArrangedSubview(exportButton)
        
        mainVStack.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        exportButton.snp.makeConstraints { $0.height.equalTo(64) }
    }
    
    // MARK: - Binding
    private func setBinding() {
        guard let exporterVM else { return }
        
        let input = ExporterVM.Input(
            exportButtonTap: exportButton.rx.tap.asObservable())
        
        let output = exporterVM.transform(input: input)
    }
}

#Preview {
    UINavigationController(rootViewController: ExporterVC())
}
