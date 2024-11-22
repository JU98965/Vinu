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

    let exportButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .tintBlue
        config.baseForegroundColor = .white
        config.title = String(localized: "내보내기")
        config.cornerStyle = .large
        
        let button = UIButton(configuration: config)
        button.dropShadow(
            radius: 8,
            opacity: 0.5,
            offset: CGSize(width: 0, height: 5),
            color: .tintBlue)
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
        view.addSubview(exportButton)
        mainVStack.addArrangedSubview(progressContainer)
        mainVStack.addArrangedSubview(estimatedFileSizeContainer)
        progressContainer.addArrangedSubview(progressLabelHStack)
        progressContainer.addArrangedSubview(progressBar)
        progressLabelHStack.addArrangedSubview(statusLabel)
        progressLabelHStack.addArrangedSubview(UIView())
        progressLabelHStack.addArrangedSubview(progressLabel)
        estimatedFileSizeContainer.addArrangedSubview(estimatedFileSizeTitleLabel)
        estimatedFileSizeContainer.addArrangedSubview(estimatedFileSizeFactorLabel)
        
        mainVStack.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(15)
            $0.centerY.equalToSuperview()
        }
        exportButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(50)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(15)
            $0.height.equalTo(50)
        }
        progressBar.snp.makeConstraints { $0.height.equalTo(15) }
    }
    
    // MARK: - Binding
    private func setBinding() {
        guard let exporterVM else { return }
        
        let input = ExporterVM.Input(
            exportButtonTap: exportButton.rx.tap.asObservable())
        
        let output = exporterVM.transform(input: input)
        
        output.estimatedFileSizeText
            .bind(to: estimatedFileSizeFactorLabel.rx.text)
            .disposed(by: bag)
        
        output.isExportButtonEnabled
            .bind(to: exportButton.rx.isEnabled)
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
        
        output.exportButtonConfig
            .bind(with: self) { owner, config in
                let button = owner.exportButton
                button.configuration?.title = config.title
                button.isHidden = config.isHidden
            }
            .disposed(by: bag)
        
        output.backMainView
            .bind(with: self) { owner, _ in
                owner.navigationController?.popToRootViewController(animated: true)
            }
            .disposed(by: bag)
    }
}

#Preview {
    UINavigationController(rootViewController: ExporterVC())
}
