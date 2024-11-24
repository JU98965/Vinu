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
    let patternImageView = {
        let color = UIColor.black.withAlphaComponent(0.02)
        let view = UIImageView()
        view.image = UIImage(named: "main_pattern")?.withTintColor(color)
        view.contentMode = .top
        return view
    }()
    
    let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 30
        return sv
    }()
    
    let imageView = {
        let view = UIImageView()
        view.image = UIImage(named: "export_image")?.resizeImage(newWidth: 250)
        view.contentMode = .center
        view.dropShadow(
            radius: 15,
            opacity: 0.05,
            offset: CGSize(width: 0, height: 5))
        return view
    }()
    
    let progressStateView = ProgressStateView()
    
    let notificationLabel = {
        let padding = UIEdgeInsets(horizontal: 15) + UIEdgeInsets(bottom: 50)
        let label = PaddingUILabel(padding: padding)
        label.text = String(localized: "내보내기 전 디바이스의 저장 공간이 충분한지 확인해 주세요.")
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .textGray
        return label
    }()
    
    let exportButtonContainer = {
        let sv = UIStackView()
        sv.directionalLayoutMargins = NSDirectionalEdgeInsets(horizontal: 35)
        sv.isLayoutMarginsRelativeArrangement = true
        return sv
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
        view.addSubview(patternImageView)
        view.addSubview(mainVStack)
        mainVStack.addArrangedSubview(imageView)
        mainVStack.addArrangedSubview(progressStateView)
        mainVStack.addArrangedSubview(notificationLabel)
        mainVStack.addArrangedSubview(exportButtonContainer)
        // exportButtonContainer
        exportButtonContainer.addArrangedSubview(exportButton)
        
        patternImageView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        mainVStack.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide).inset(15) }
        exportButton.snp.makeConstraints { $0.height.equalTo(50) }
    }
    
    // MARK: - Binding
    private func setBinding() {
        guard let exporterVM else { return }
        
        let input = ExporterVM.Input(
            exportButtonTap: exportButton.rx.tap.asObservable())
        
        let output = exporterVM.transform(input: input)
        
        output.estimatedFileSizeText
            .bind(to: progressStateView.estimatedFileSizeFactorLabel.rx.text)
            .disposed(by: bag)
        
        output.isExportButtonEnabled
            .bind(to: exportButton.rx.isEnabled)
            .disposed(by: bag)
        
        output.progress
            .bind(to: progressStateView.progressBar.rx.progress)
            .disposed(by: bag)
        
        output.progressText
            .bind(to: progressStateView.progressLabel.rx.text)
            .disposed(by: bag)
        
        output.statusText
            .bind(to: progressStateView.statusLabel.rx.text)
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
