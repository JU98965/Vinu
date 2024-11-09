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
    private let once = OnlyOnce()
    
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
        cv.backgroundColor = .clear
        cv.clipsToBounds = false
        return cv
    }()
    
    let createButtonShadow = {
        let sv = UIStackView()
        sv.dropShadow(radius: 8, opacity: 0.1, offset: CGSize(width: 0, height: 0))
        return sv
    }()
    
    let createButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .tintSoda
        config.baseForegroundColor = .white
        config.title = String(localized: "프로젝트 만들기")
        
        let button = GradientButton(configuration: config)
        button.smoothCorner(radius: 64 / 3)
        button.clipsToBounds = true
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backWhite
        setNavigationBar(title: String(localized: "프로젝트 구성하기"))
        setAutoLaout()
        setBinding()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        once.excute {
            view.layoutIfNeeded()
            setCollectionViewLayout()
        }
    }
    
    // MARK: - Layout
    private func setAutoLaout() {
        view.addSubview(overallSV)
        view.addSubview(createButtonShadow)
        overallSV.addArrangedSubview(titleContainer)
        overallSV.addArrangedSubview(divider0)
        overallSV.addArrangedSubview(ratioContainer)
        titleContainer.addArrangedSubview(titleLabel)
        titleContainer.addArrangedSubview(titleTF)
        ratioContainer.addArrangedSubview(ratioLabel)
        ratioContainer.addArrangedSubview(ratioCV)
        createButtonShadow.addArrangedSubview(createButton)
        
        titleLabel.setContentHuggingPriority(.init(251), for: .vertical)
        
        overallSV.snp.makeConstraints { $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide) }
        ratioCV.snp.makeConstraints { $0.height.equalTo(96) }
        createButtonShadow.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(64)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(32)
            $0.height.equalTo(64)
        }
        
    }

    private func setCollectionViewLayout() {
        ratioCV.setSinglelineLayout(spacing: 15, itemSize: CGSize(width: 64, height: 96))
    }
    
    // MARK: - Binding
    private func setBinding() {
        guard let configureVM else { return }
        
        // text는 입력하기 전까지 이벤트를 내보내지 않는 걸로 알고 있어서 초기값 부여
        let titleText = titleTF.rx.text
            .startWith("")
            .share(replay: 1)
        
        // 첫번째 셀이 선택되어있도록 초기값 부여
        let selectedRatioPath = ratioCV.rx.itemSelected
            .startWith(IndexPath(row: 0, section: 0))
            .share(replay: 1)
        
        let input = ConfigureVM.Input(
            titleText: titleText,
            tapCreateButton: createButton.rx.tap.asObservable(),
            selectedRatioPath: selectedRatioPath)
        
        let output = configureVM.transform(input: input)
        
        output.ratioItems
            .bind(to: ratioCV.rx.items(cellIdentifier: RatioCell.identifier, cellType: RatioCell.self)) { index, item, cell in
                cell.configure(itemData: item)
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
