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
        // label.text = "사용자가 작업을 취소했어요. 창을 닫고 다시 시도해 주세요."
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .textGray
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
        view.addSubview(patternImageView)
        view.addSubview(mainVStack)
        view.addSubview(exportButton)
        mainVStack.addArrangedSubview(imageView)
        mainVStack.addArrangedSubview(progressStateView)
        mainVStack.addArrangedSubview(notificationLabel)
        mainVStack.addArrangedSubview(UIView())
        
        patternImageView.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        mainVStack.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide).inset(15) }
        exportButton.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
            $0.height.equalTo(50)
        }
    }
    
    // MARK: - Binding
    private func setBinding() {
        guard let exporterVM else { return }
        
        let input = ExporterVM.Input(
            exportButtonTap: exportButton.rx.tap.asObservable())
        
        let output = exporterVM.transform(input: input)
        
        // 예상 파일 크기 텍스트
        output.estimatedFileSizeText
            .bind(to: progressStateView.estimatedFileSizeFactorLabel.rx.text)
            .disposed(by: bag)
        
        // 익스포터가 nil이면 내보내기 버튼 활성화 조차 안되게
        output.isExportButtonEnabled
            .bind(to: exportButton.rx.isEnabled)
            .disposed(by: bag)
        
        // 작업 진행률 수치
        output.progress
            .bind(with: self, onNext: { owner, progress in
                UIView.animate(withDuration: 0.5) {
                    owner.progressStateView.progressBar.progress = progress
                    owner.progressStateView.progressBar.layoutIfNeeded()
                }
            })
            .disposed(by: bag)
        
        // 진행률 퍼센트 텍스트
        output.progressText
            .bind(to: progressStateView.progressLabel.rx.text)
            .disposed(by: bag)
        
        // exporter의 상태 텍스트
        output.statusText
            .bind(to: progressStateView.statusLabel.rx.text)
            .disposed(by: bag)
        
        // 상태에 따른 버튼 타이틀
        output.exportButtonTitle
            .bind(with: self, onNext: { owner, title in
                owner.exportButton.configuration?.title = title
            })
            .disposed(by: bag)
        
        // 내보내기 완료 시, 버튼 누르면 홈 화면으로 이동
        output.popToRootView
            .bind(with: self) { owner, _ in
                owner.navigationController?.popToRootViewController(animated: true)
            }
            .disposed(by: bag)
        
        // 내보내기 실패 or 취소 시, 버튼 누르면 이전 화면으로 이동
        output.popThisView
            .bind(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: bag)
        
        // 내보내기 실패 or 취소 시, 프로그래스 바와 진행률 퍼센트 레이블의 색을 비활성화 색으로 변경
        output.disableColor
            .bind(to: progressStateView.progressBar.rx.progressTintColor, progressStateView.progressLabel.rx.textColor)
            .disposed(by: bag)
        
        // 알림 텍스트
        output.notificationText
            .bind(to: notificationLabel.rx.text)
            .disposed(by: bag)
    }
}

#Preview {
    UINavigationController(rootViewController: ExporterVC())
}
