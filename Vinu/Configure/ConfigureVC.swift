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
        sv.spacing = 30
        return sv
    }()
    
    let titleContainer = TitleContainer()
    
    let sizeContainer = SizeContainer()
    
    let placementContainer = PlacementContainer()
    
    let createButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .tintBlue
        config.baseForegroundColor = .white
        config.title = String(localized: "데이터를 불러오고 있어요.")
        config.showsActivityIndicator = true
        config.imagePadding = 15
        config.cornerStyle = .large
        
        let button = UIButton(configuration: config)
        button.dropShadow(
            radius: 8,
            opacity: 0.5,
            offset: CGSize(width: 0, height: 5),
            color: .tintBlue)
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
        view.addSubview(createButton)
        mainVStack.addArrangedSubview(titleContainer)
        mainVStack.addArrangedSubview(sizeContainer)
        mainVStack.addArrangedSubview(placementContainer)
        
        
        mainVStack.snp.makeConstraints { $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(UIEdgeInsets(top: 15)) }
        createButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(50)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(15)
            $0.height.equalTo(50)
        }
        
    }
    
    // MARK: - Binding
    private func setBinding() {
        guard let configureVM else { return }
        
        // text는 입력하기 전까지 이벤트를 내보내지 않는 걸로 알고 있어서 초기값 부여
        let titleText = titleContainer.titleTF.rx.text
            .startWith("")
            .share(replay: 1)
        
        // 첫번째 셀이 선택되어있도록 초기값 부여
        let selectedSizePath = sizeContainer.sizeCV.rx.itemSelected
            .startWith(IndexPath(row: 0, section: 0))
            .share(replay: 1)
        
        let selectedPlacementPath = placementContainer.placementCV.rx.itemSelected
            .startWith(IndexPath(row: 0, section: 0))
            .share(replay: 1)
        
        let input = ConfigureVM.Input(
            titleText: titleText,
            tapCreateButton: createButton.rx.tap.asObservable(),
            selectedSizePath: selectedSizePath,
            selectedPlacementPath: selectedPlacementPath)
        
        let output = configureVM.transform(input: input)
        
        output.sizeItems
            .bind(to: sizeContainer.sizeCV.rx.items(cellIdentifier: ConfigureCardCell.identifier, cellType: ConfigureCardCell.self)) { index, item, cell in
                cell.configure(itemData: item)
            }
            .disposed(by: bag)
        
        output.placementItems
            .bind(to: placementContainer.placementCV.rx.items(cellIdentifier: ConfigureCardCell.identifier, cellType: ConfigureCardCell.self)) { index, item, cell in
                cell.configure(itemData: item)
            }
            .disposed(by: bag)
        
        output.placeHolder
            .bind(to: titleContainer.titleTF.rx.placeholder)
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
                let editorVC = EditorVC()
                editorVC.editorVM = EditorVM(config)
                
                owner.navigationController?.pushViewController(editorVC, animated: true)
                // 화면 전환이 끝나면 네비게이션 스택을 다시 구성
                if let rootVC = owner.navigationController?.viewControllers.first {
                    owner.navigationController?.setViewControllers([rootVC, editorVC], animated: false)
                }
            }
            .disposed(by: bag)

    }
}

#Preview {
    let vc = ConfigureVC()
    vc.configureVM = ConfigureVM([])
    return UINavigationController(rootViewController: vc)
}
