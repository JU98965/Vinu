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
    
    let clipLabel = {
        let label = PaddingUILabel(padding: .init(edges: 15))
        label.font = .boldSystemFont(ofSize: 14)
        label.text = "0개 클립 선택됨" // temp
        label.textColor = .textGray
        label.backgroundColor = .backWhite
        label.dropShadow(radius: 1, opacity: 0.05, offset: .init(width: 0, height: -2))
        return label
    }()
    
    let pendingCV = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: .init())
        cv.register(PendingCell.self, forCellWithReuseIdentifier: PendingCell.identifier)
        cv.setSinglelineLayout(
            spacing: 15,
            itemSize: .init(width: 64, height: 64),
            sectionInset: .init(horizontal: 15))
        cv.showsHorizontalScrollIndicator = false
        cv.allowsSelection = true
        cv.backgroundColor = .clear
        return cv
    }()
    
    let nextButtonShadowView = {
        let sv = UIStackView()
        sv.dropShadow(radius: 2.5, opacity: 0.1)
        return sv
    }()
    
    let nextButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .tintSoda
        config.baseForegroundColor = .white
        config.title = String(localized: "다음")
        
        let button = GradientButton(configuration: config)
        button.clipsToBounds = true
        button.smoothCorner(radius: 21.33)
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
        // 버튼 레이아웃 잡기 전에 layoutIfNeeded 호출하면 그라데이션이 풀려버림..
        once.excute {
            setNextButtonLayout()
            view.layoutIfNeeded()
            setCollectionViewLayout()
        }
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        view.addSubview(mainVStack)
        view.addSubview(nextButtonShadowView)
        mainVStack.addArrangedSubview(thumbnailCV)
        mainVStack.addArrangedSubview(clipLabel)
        mainVStack.addArrangedSubview(pendingCV)
        nextButtonShadowView.addArrangedSubview(nextButton)
        
        mainVStack.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide).inset(UIEdgeInsets(bottom: 15)) }
        pendingCV.snp.makeConstraints { $0.height.equalTo(64) }
    }
    
    private func setCollectionViewLayout() {
        thumbnailCV.setMultilineLayout(spacing: 15, itemCount: 3, sectionInset: .init(edges: 15))
    }
    
    private func setNextButtonLayout() {
        nextButtonShadowView.snp.makeConstraints {
            $0.trailing.equalToSuperview().multipliedBy(0.9)
            $0.centerY.equalTo(thumbnailCV.snp.bottom)
            $0.size.equalTo(64)
        }
    }
    
    // MARK: - Binding
    private func setBinding() {
        let input = PickerVM.Input(
            selectThumbnail: thumbnailCV.rx.itemSelected.asObservable(),
            selectPending: pendingCV.rx.itemSelected.asObservable(),
            tapNextButton: nextButton.rx.tap.asObservable())
        
        let output = pickerVM.transform(input: input)
        
        // 썸네일 컬렉션 뷰 바인딩
        output.thumbnailItems
            .bind(to: thumbnailCV.rx.items(dataSource: bindThumbnailData()))
            .disposed(by: bag)
        
        // 계류 컬렉션 뷰 바인딩
        output.pendingItems
            .bind(to: pendingCV.rx.items(dataSource: bindPendingData()))
            .disposed(by: bag)
        
        // 클립 선택 텍스트 바인딩
        output.selectItemsCount
            .bind(with: self) { owner, count in
                owner.clipLabel.text = String(localized: "\(count)개 클립 선택됨")
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
