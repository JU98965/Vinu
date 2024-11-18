//
//  PickerVC.swift
//  Vinu
//
//  Created by 신정욱 on 9/18/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

final class PickerVC: UIViewController {
    private let pickerVM = PickerVM()
    private let bag = DisposeBag()
    private let once = OnlyOnce()
    
    // MARK: - Componets
    let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        return sv
    }()
    
    let thumbnailCV = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: .init())
        cv.register(ThumbnailCell.self, forCellWithReuseIdentifier: ThumbnailCell.identifier)
        cv.allowsMultipleSelection = true
        cv.backgroundColor = .clear
        return cv
    }()
    
    let pendingItemView = PendingItemView()
    
    let nextButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .tintBlue
        config.baseForegroundColor = .white
        config.attributedTitle = AttributedString(
            String(localized: "다음"),
            attributes: AttributeContainer([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)]))
        let button = UIButton(configuration: config)
        button.smoothCorner(radius: 64 / 4)
        button.clipsToBounds = true
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backWhite
        setNavigationBar(title: String(localized: "비디오 선택하기"))
        setAutoLayout()
        setBinding()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        once.excute {
            view.layoutIfNeeded()
            setLazyAutoLayout()
            setThumbnailCVLayout()
        }
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        view.addSubview(mainVStack)
        mainVStack.addArrangedSubview(thumbnailCV)
        mainVStack.addArrangedSubview(pendingItemView)
        mainVStack.addSubview(nextButton)
        
        mainVStack.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide).inset(UIEdgeInsets(bottom: 15)) }
    }

    private func setLazyAutoLayout() {
        nextButton.snp.makeConstraints { $0.edges.equalTo(pendingItemView.nextButtonBack) }
    }
    
    private func setThumbnailCVLayout() {
        thumbnailCV.setMultilineLayout(
            spacing: 3,
            itemCount: 4,
            sectionInset: UIEdgeInsets(edges: 3),
            insetOffset: UIEdgeInsets(bottom: 64))
    }
    
    // MARK: - Binding
    private func setBinding() {
        
        let input = PickerVM.Input(
            selectedThumbnailPath: thumbnailCV.rx.itemSelected.asObservable(),
            selectedPendingPath: pendingItemView.pendingCV.rx.itemSelected.asObservable(),
            tapNextButton: nextButton.rx.tap.asObservable())
        
        let output = pickerVM.transform(input: input)
        
        // 썸네일 컬렉션 뷰 바인딩
        output.thumbnailItems
            .bind(to: thumbnailCV.rx.items(dataSource: bindThumbnailData()))
            .disposed(by: bag)
        
        // 계류 컬렉션 뷰 바인딩
        output.pendingItems
            .bind(to: pendingItemView.pendingCV.rx.items(dataSource: bindPendingData()))
            .disposed(by: bag)
        
        // 클립 선택 텍스트 바인딩
        output.selectItemsCount
            .bind(with: self) { owner, count in
                owner.pendingItemView.clipLabel.text = String(localized: "\(count)개 클립 선택됨")
            }
            .disposed(by: bag)
        
        // 다음 버튼을 누르면 다음 화면에 선택한 에셋 전달
        output.assets
            .bind(with: self) { owner, assets in
                let vc = ConfigureVC()
                vc.configureVM = ConfigureVM(assets)
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: bag)
        
        output.nextButtonEnabling
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: bag)
    }
    
    private func bindThumbnailData() -> RxCollectionViewSectionedAnimatedDataSource<ThumbnailSectionData> {
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<ThumbnailSectionData> { animatedDataSource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailCell.identifier, for: indexPath) as? ThumbnailCell
            else { return UICollectionViewCell() }
            cell.configure(thumbnailData: item)
            return cell
        }
        
        // 애니메이션 구성 (생성자에서 구현해도 되긴 함)
        dataSource.animationConfiguration = .init(insertAnimation: .fade, reloadAnimation: .fade, deleteAnimation: .fade)
        return dataSource
    }
    
    private func bindPendingData() -> RxCollectionViewSectionedAnimatedDataSource<ThumbnailSectionData> {
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<ThumbnailSectionData> { animatedDataSource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PendingCell.identifier, for: indexPath) as? PendingCell
            else { return UICollectionViewCell() }
            cell.configure(thumbnailData: item)
            return cell
        }
        
        // 애니메이션 구성 (생성자에서 구현해도 되긴 함)
        dataSource.animationConfiguration = .init(insertAnimation: .none, reloadAnimation: .none, deleteAnimation: .none)
        return dataSource
    }
}



#Preview {
    UINavigationController(rootViewController: PickerVC())
}
