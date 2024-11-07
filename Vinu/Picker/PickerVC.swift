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
    
    let bottomVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.backgroundColor = .backWhite
        sv.dropShadow(radius: 8, opacity: 0.05, offset: CGSize(width: 0, height: -8))
        return sv
    }()
    
    let clipLabel = {
        let label = PaddingUILabel(padding: .init(edges: 15))
        label.font = .boldSystemFont(ofSize: 14)
        label.text = String(localized: "0개 클립 선택됨") // temp
        label.textColor = .textGray
        return label
    }()
    
    let pendingCV = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: .init())
        cv.register(PendingCell.self, forCellWithReuseIdentifier: PendingCell.identifier)
        cv.setSinglelineLayout(
            spacing: 10,
            itemSize: .init(width: 64, height: 64),
            sectionInset: .init(horizontal: 15))
        cv.showsHorizontalScrollIndicator = false
        cv.allowsSelection = true
        cv.backgroundColor = .clear
        return cv
    }()
    
    let bottomShadowMaskView = {
        let view = UIView()
        view.backgroundColor = .backWhite
        return view
    }()
    
    let nextButtonShadowView = {
        let sv = UIStackView()
        sv.backgroundColor = .backWhite
        sv.clipsToBounds = true
        sv.smoothCorner(radius: 32)
        return sv
    }()
    
    let nextButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .tintSoda
        config.baseForegroundColor = .white
        config.attributedTitle = AttributedString(
            String(localized: "다음"),
            attributes: AttributeContainer([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)]))
        let button = GradientButton(configuration: config)
        button.isEnabled = false
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
            setLazyAutoLayout()
            view.layoutIfNeeded()
            setThumbnailCVLayout()
        }
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        view.addSubview(mainVStack)
        mainVStack.addArrangedSubview(thumbnailCV)
        mainVStack.addArrangedSubview(bottomVStack)
        mainVStack.addArrangedSubview(bottomShadowMaskView)
        bottomVStack.addArrangedSubview(clipLabel)
        bottomVStack.addArrangedSubview(pendingCV)
        bottomVStack.addSubview(nextButtonShadowView)
        nextButtonShadowView.addArrangedSubview(nextButton)
        
        mainVStack.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
        pendingCV.snp.makeConstraints { $0.height.equalTo(64) }
    }

    private func setLazyAutoLayout() {
        bottomShadowMaskView.snp.makeConstraints {
            $0.height.equalTo(view.safeAreaInsets.bottom)
        }
        nextButtonShadowView.snp.makeConstraints {
            $0.trailing.equalToSuperview().multipliedBy(0.9)
            $0.centerY.equalTo(thumbnailCV.snp.bottom)
            $0.size.equalTo(64)
        }
    }
    
    private func setThumbnailCVLayout() {
        thumbnailCV.setMultilineLayout(
            spacing: 3,
            itemCount: 4,
            sectionInset: .init(edges: 3),
            insetOffset: .init(bottom: 32))
    }
    
    // MARK: - Binding
    private func setBinding() {
//        guard false else { return }
        
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
