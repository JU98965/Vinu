//
//  ConfigureVC.swift
//  Vinu
//
//  Created by 신정욱 on 9/24/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ConfigureVC: UIViewController {
    var configureVM: ConfigureVM? = ConfigureVM([])
    private let bag = DisposeBag()
    
    // MARK: - Components
    let overallSV = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = .chu16
        sv.distribution = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.directionalLayoutMargins = .init(top: .chu16, leading: .chu16, trailing: .chu16)
        return sv
    }()
    
    let titleContainer = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        return sv
    }()
    
    let titleLabel = {
        let label = UILabel()
        label.text = String(localized: "프로젝트 제목")
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    let titleTF = {
        let tf = UITextField()
        tf.placeholder = String(localized: "2024년 10월 9일") // Temp
        tf.returnKeyType = .done // 키보드 리턴키를 "완료"로 변경
        tf.clearButtonMode = .whileEditing
        tf.borderStyle = .roundedRect
        tf.backgroundColor = .chuLightGray
        return tf
    }()
    
    let divider0 = DivideView(lineWidth: 1, lineColor: .chuLightGray)
    
    let ratioContainer = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        return sv
    }()
    
    let ratioLabel = {
        let label = UILabel()
        label.text = String(localized: "화면 비율")
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    let ratioCV = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: .init())
        cv.register(RatioCell.self, forCellWithReuseIdentifier: RatioCell.identifier)
        cv.allowsSelection = true
        return cv
    }()
    
    
    
    let createButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .tintSoda
        config.baseForegroundColor = .white
        config.title = String(localized: "프로젝트 만들기")
        
        let button = GradientButton(configuration: config)
        button.smoothCorner(radius: 25)
        button.clipsToBounds = true
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar(title: String(localized: "프로젝트 구성하기"))
        setAutoLaout()
        setBinding()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setCollectionViewLayout()
    }
    
    // MARK: - Layout
    private func setAutoLaout() {
        view.addSubview(overallSV)
        overallSV.addArrangedSubview(titleContainer)
        overallSV.addArrangedSubview(divider0)
        overallSV.addArrangedSubview(ratioContainer)
        overallSV.addArrangedSubview(createButton)
        titleContainer.addArrangedSubview(titleLabel)
        titleContainer.addArrangedSubview(titleTF)
        ratioContainer.addArrangedSubview(ratioLabel)
        ratioContainer.addArrangedSubview(ratioCV)
        
        titleLabel.setContentHuggingPriority(.init(251), for: .vertical)
        
        overallSV.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
        createButton.snp.makeConstraints { $0.height.equalTo(50) }
    }

    private func setCollectionViewLayout() {
        view.layoutIfNeeded()
        ratioCV.setMultilineLayout(spacing: .chu16, itemCount: 2)
    }
    
    // MARK: - Binding
    private func setBinding() {
        guard let configureVM else { return }
        
        let input = ConfigureVM.Input(
            titleText: titleTF.rx.text.asObservable(),
            tapCreateButton: createButton.rx.tap.asObservable())
        let output = configureVM.transform(input: input)
        
        output.ratioData
            .bind(to: ratioCV.rx.items(cellIdentifier: RatioCell.identifier, cellType: RatioCell.self)) { index, item, cell in
                cell.imageView.image = item.0
                cell.ratioLabel.text = item.1
            }
            .disposed(by: bag)
        
        output.placeHolder
            .bind(to: titleTF.rx.placeholder)
            .disposed(by: bag)
        
        output.presentLoadingVC
            .bind(with: self) { owner, projectData in
                let vc = LoadingVC()
                vc.loadingVM = LoadingVM(projectData)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: bag)

    }
}

#Preview {
    UINavigationController(rootViewController: ConfigureVC())
}
