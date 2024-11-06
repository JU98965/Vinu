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
    
    // MARK: - Componets
    let thumbnailCV = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: .init())
        cv.register(ThumbnailCell.self, forCellWithReuseIdentifier: ThumbnailCell.identifier)
        cv.allowsMultipleSelection = true
        cv.backgroundColor = .chuLightGray
        return cv
    }()
    
    let bottomSV = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = .chu16
        sv.distribution = .fill
        sv.backgroundColor = .white
        sv.isLayoutMarginsRelativeArrangement = true
        sv.directionalLayoutMargins = .init(top: .chu16, leading: .chu16, trailing: .chu16)
        return sv
    }()
    
    let clipLabel = {
        let label = UILabel()
        label.text = "0개 클립 선택됨" // temp
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    let pendingCV = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: .init())
        cv.register(PendingCell.self, forCellWithReuseIdentifier: PendingCell.identifier)
        cv.allowsSelection = true
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        cv.layer.cornerRadius = 8
        cv.layer.cornerCurve = .continuous
        cv.clipsToBounds = true
        return cv
    }()
    
    let nextButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .white
        config.title = String(localized: "다음")
        
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = .chu16
        button.layer.cornerCurve = .continuous
        button.clipsToBounds = true
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar(title: String(localized: "비디오 선택하기"))
        setAutoLayout()
        setBinding()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setCollectionViewLayout()
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        view.addSubview(thumbnailCV)
        view.addSubview(bottomSV)
        bottomSV.addArrangedSubview(clipLabel)
        bottomSV.addArrangedSubview(pendingCV)
        bottomSV.addArrangedSubview(nextButton)
        
        thumbnailCV.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(bottomSV.snp.top)
        }
        bottomSV.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalToSuperview()
        }
        pendingCV.snp.makeConstraints { $0.height.equalTo(64) }
        nextButton.snp.makeConstraints { $0.height.equalTo(50) }
    }
    
    private func setCollectionViewLayout() {
        thumbnailCV.setMultilineLayout(spacing: 16, itemCount: 3, sectionInset: .init(edges: 16))
        pendingCV.setSinglelineLayout(spacing: 4, width: 64, height: 64)
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
