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
    var exporterVM: ExporterVM?
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
    
    let progressBar = {
        let bar = UIProgressView(progressViewStyle: .bar)
        bar.backgroundColor = .lightGray
        bar.progressTintColor = .tintSoda
        bar.smoothCorner(radius: 16)
        bar.clipsToBounds = true
        return bar
    }()
    
    let progressLabel = {
        let label = UILabel()
        label.text = String(localized: "진행률: 0%")
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    let statusLabel = {
        let label = UILabel()
        label.text = String(localized: "준비중")
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
    
    let backHomeButton = {
        let button = UIButton(configuration: .filled())
        button.setTitle("홈으로 돌아가기", for: .normal)
        return button
    }()
    
    // MARK: - Life Cylce
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backWhite
        setNavigationBar(title: String(localized: "비디오 내보내기"))
        setAutoLayout()
        setBinding()
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        view.addSubview(mainVStack)
        mainVStack.addArrangedSubview(estimatedFileSizeLabel)
        mainVStack.addArrangedSubview(progressBar)
        mainVStack.addArrangedSubview(progressLabel)
        mainVStack.addArrangedSubview(statusLabel)
        mainVStack.addArrangedSubview(exportButton)
        
        mainVStack.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        exportButton.snp.makeConstraints { $0.height.equalTo(64) }
        progressBar.snp.makeConstraints { $0.height.equalTo(32) }
    }
    
    // MARK: - Binding
    private func setBinding() {
        guard let exporterVM else { return }
        
        let input = ExporterVM.Input(
            exportButtonTap: exportButton.rx.tap.asObservable())
        
        let output = exporterVM.transform(input: input)
        
        output.estimatedFileSizeText
            .bind(to: estimatedFileSizeLabel.rx.text)
            .disposed(by: bag)
        
        output.isExportButtonEnabled
            .bind(to: exportButton.rx.isEnabled)
            .disposed(by: bag)
        
        output.isExportButtonHidden
            .bind(to: exportButton.rx.isHidden)
            .disposed(by: bag)
        
        output.progress
            .bind(to: progressBar.rx.progress)
            .disposed(by: bag)
        
        output.progressText
            .bind(to: progressLabel.rx.text)
            .disposed(by: bag)
        
        output.statusText
            .bind(to: statusLabel.rx.text)
            .disposed(by: bag)
    }
}

#Preview {
    UINavigationController(rootViewController: ExporterVC())
}
