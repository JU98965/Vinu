//
//  MainVC.swift
//  Vinu
//
//  Created by 신정욱 on 9/18/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MainVC: UIViewController {
    private let mainVM = MainVM()
    private let bag = DisposeBag()
    
    // MARK: - Componets
    let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
//        sv.isLayoutMarginsRelativeArrangement = true
//        sv.directionalLayoutMargins = NSDirectionalEdgeInsets(edges: 50)
        sv.spacing = 50
        return sv
    }()
    
    let titleLabel = {
        let label = UILabel()
        label.text = String(localized: "안녕하세요 비누라고 해요.")
        label.font = .preferredFont(forTextStyle: .title1)
        label.textColor = .textGray
        label.dropShadow(radius: 8, opacity: 0.1)
        return label
    }()
    
    let subTitleLabel = {
        let label = UILabel()
        label.text = String(localized: "온 세상의 추억들을 하나로 이음.")
        label.font = .preferredFont(forTextStyle: .title1)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .textGray
        label.textAlignment = .center
        label.dropShadow(radius: 8, opacity: 0.1)
        return label
    }()
    
    let imageContentView = UIView()
    let imageView = {
        let view = UIImageView()
        view.image = UIImage(named: "main_entry_image")?.withTintColor(.tintBlue)
        return view
    }()
    
//    let splashyView = SplashyView()

    let startButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .tintBlue
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        config.attributedTitle = AttributedString(
            String(localized: "시작하기"),
            attributes: AttributeContainer([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)]))
        let button = UIButton(configuration: config)
        button.dropShadow(
            radius: 8,
            opacity: 0.5,
            offset: CGSize(width: 0, height: 5),
            color: .tintBlue)
        button.setTitleShadowColor(.black, for: .normal)
        return button
    }()
    
//    let entryView = EntryView()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backWhite
//        setNavigationBar(title: String(localized: "Vinu"))

        setAutoLayout()
        setBinding()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        // 영상 선택창에서 다시 돌아올 때 네비게이션 바를 숨김
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        // 다른 창으로 넘어갈 때 숨겼던 네비게이션 바를 표시
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
//    }

    // MARK: - Layout
    private func setAutoLayout() {
        view.addSubview(mainVStack)
        mainVStack.addArrangedSubview(imageContentView)
        mainVStack.addArrangedSubview(titleLabel)
        mainVStack.addArrangedSubview(subTitleLabel)
//        mainVStack.addArrangedSubview(splashyView)
        mainVStack.addArrangedSubview(startButton)
        imageContentView.addSubview(imageView)
        
        mainVStack.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
//        imageContentView.snp.makeConstraints { $0.height.equalToSuperview().multipliedBy(0.5) }
        imageView.snp.makeConstraints { $0.center.equalToSuperview() }
        startButton.snp.makeConstraints { $0.height.equalTo(50) }
    }
    
    // MARK: - Binding
    private func setBinding() {
        let input = MainVM.Input(tapNewProjectButton: startButton.rx.tap.asObservable())
        let output = mainVM.transform(input: input)
        
        // 비디오 피커 띄우기
        output.presentVideoPickerVC
            .bind(with: self) { owner, _ in
                let vc = PickerVC()
                owner.navigationController?.pushViewController(vc, animated: true)
            }
            .disposed(by: bag)
    }
}

#Preview {
    UINavigationController(rootViewController: MainVC())
}
