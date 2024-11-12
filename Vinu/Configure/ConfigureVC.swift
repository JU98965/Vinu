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
    var configureVM: ConfigureVM?
    private let bag = DisposeBag()
    
    // MARK: - Components
    let mainVStack = {
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
    
    let sizeContainer = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        return sv
    }()
    
    let sizeLabel = {
        let label = UILabel()
        label.text = String(localized: "화면 비율")
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    let sizeCV = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: .init())
        cv.register(ConfigureCardCell.self, forCellWithReuseIdentifier: ConfigureCardCell.identifier)
        cv.setSinglelineLayout(spacing: 15, itemSize: CGSize(width: 64, height: 96))
        cv.allowsSelection = true
        cv.backgroundColor = .clear
        cv.clipsToBounds = false
        return cv
    }()
    
    let placementContainer = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        return sv
    }()
    
    let placementLabel = {
        let label = UILabel()
        label.text = String(localized: "영상 배치")
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()

    let placementCV = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: .init())
        cv.register(ConfigureCardCell.self, forCellWithReuseIdentifier: ConfigureCardCell.identifier)
        cv.setSinglelineLayout(spacing: 15, itemSize: CGSize(width: 64, height: 96))
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
        config.title = String(localized: "데이터를 불러오고 있어요.")
        config.showsActivityIndicator = true
        config.imagePadding = 15
        
        let button = GradientButton(configuration: config)
        button.smoothCorner(radius: 64 / 3)
        button.clipsToBounds = true
        button.isEnabled = false
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
    
    // MARK: - Layout
    private func setAutoLaout() {
        view.addSubview(mainVStack)
        view.addSubview(createButtonShadow)
        mainVStack.addArrangedSubview(titleContainer)
        mainVStack.addArrangedSubview(divider0)
        mainVStack.addArrangedSubview(sizeContainer)
        mainVStack.addArrangedSubview(placementContainer)
        titleContainer.addArrangedSubview(titleLabel)
        titleContainer.addArrangedSubview(titleTF)
        sizeContainer.addArrangedSubview(sizeLabel)
        sizeContainer.addArrangedSubview(sizeCV)
        placementContainer.addArrangedSubview(placementLabel)
        placementContainer.addArrangedSubview(placementCV)
        createButtonShadow.addArrangedSubview(createButton)
        
        titleLabel.setContentHuggingPriority(.init(251), for: .vertical)
        
        mainVStack.snp.makeConstraints { $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide) }
        sizeCV.snp.makeConstraints { $0.height.equalTo(96) }
        placementCV.snp.makeConstraints { $0.height.equalTo(96) }
        createButtonShadow.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(64)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(32)
            $0.height.equalTo(64)
        }
        
    }
    
    // MARK: - Binding
    private func setBinding() {
        guard let configureVM else { return }
        
        // text는 입력하기 전까지 이벤트를 내보내지 않는 걸로 알고 있어서 초기값 부여
        let titleText = titleTF.rx.text
            .startWith("")
            .share(replay: 1)
        
        // 첫번째 셀이 선택되어있도록 초기값 부여
        let selectedSizePath = sizeCV.rx.itemSelected
            .startWith(IndexPath(row: 0, section: 0))
            .share(replay: 1)
        
        let selectedPlacementPath = placementCV.rx.itemSelected
            .startWith(IndexPath(row: 0, section: 0))
            .share(replay: 1)
        
        let input = ConfigureVM.Input(
            titleText: titleText,
            tapCreateButton: createButton.rx.tap.asObservable(),
            selectedSizePath: selectedSizePath,
            selectedPlacementPath: selectedPlacementPath)
        
        let output = configureVM.transform(input: input)
        
        output.sizeItems
            .bind(to: sizeCV.rx.items(cellIdentifier: ConfigureCardCell.identifier, cellType: ConfigureCardCell.self)) { index, item, cell in
                cell.configure(itemData: item)
            }
            .disposed(by: bag)
        
        output.placementItems
            .bind(to: placementCV.rx.items(cellIdentifier: ConfigureCardCell.identifier, cellType: ConfigureCardCell.self)) { index, item, cell in
                cell.configure(itemData: item)
            }
            .disposed(by: bag)
        
        output.placeHolder
            .bind(to: titleTF.rx.placeholder)
            .disposed(by: bag)
        
        output.isCreateButtonEnabled
            .bind(with: self, onNext: { owner, isEnabled in
                owner.createButton.isEnabled = isEnabled
                owner.createButton.configuration?.showsActivityIndicator = !isEnabled
            })
            .disposed(by: bag)
        
        output.createButtonTitle
            .bind(to: createButton.rx.title())
            .disposed(by: bag)
        
        // 모든 데이터 로딩이 끝나면 EditorVC로 화면전환
        output.presentEditorVC
            .bind(with: self) { owner, config in
                // 화면전환은 window layer가 담당하므로 거기에 트랜지션 효과 추가
                let vc = EditorVC()
                vc.editorVM = EditorVM(config)
                vc.modalPresentationStyle = .fullScreen
                owner.present(vc, animated: false) {
                    // 네비게이션 스택 모두 닫아주기
                    owner.navigationController?.popToRootViewController(animated: false)
                }
            }
            .disposed(by: bag)

    }
}

#Preview {
    var vc = ConfigureVC()
    vc.configureVM = ConfigureVM([])
    return UINavigationController(rootViewController: vc)
}
