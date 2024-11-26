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
    let patternImageView = {
        let color = UIColor.black.withAlphaComponent(0.05)
        let view = UIImageView()
        view.image = UIImage(named: "main_pattern")?.withTintColor(color)
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    let mainVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.isLayoutMarginsRelativeArrangement = true
        sv.directionalLayoutMargins = NSDirectionalEdgeInsets(edges: 50)
        sv.spacing = 50
        return sv
    }()
    
    let titleVStack = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 15
        return sv
    }()
    
    let titleLabel = {
        let label = UILabel()
        label.text = String(localized: "손쉽게 하나의 영상으로")
        label.font = .preferredFont(forTextStyle: .extraLargeTitle)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.dropShadow(radius: 7.5, opacity: 0.1)
        return label
    }()
    
    let subTitleLabel = {
        let label = UILabel()
        label.text = String(localized: "순식간에 합쳐드릴게요.\n완전 무료! 광고도 없답니다.")
        label.font = .boldSystemFont(ofSize: label.font.pointSize)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.dropShadow(radius: 7.5, opacity: 0.1)

        return label
    }()

    let imageView = {
        let view = UIImageView()
        view.image = UIImage(named: "main_entry_image")?.resizeImage(newWidth: 200)
        view.contentMode = .center
        view.dropShadow(
            radius: 15,
            opacity: 0.05,
            offset: CGSize(width: 0, height: 5))
        return view
    }()
    
    let startButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .backWhite
        config.baseForegroundColor = .tintBlue
        config.cornerStyle = .large
        config.attributedTitle = AttributedString(
            String(localized: "시작하기"),
            attributes: AttributeContainer([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 20)]))
        let button = UIButton(configuration: config)
        button.dropShadow(
            radius: 8,
            opacity: 0.05,
            offset: CGSize(width: 0, height: 5))
        return button
    }()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .tintBlue

        setAutoLayout()
        setBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 영상 선택창에서 다시 돌아올 때 네비게이션 바를 숨김
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        // 다른 창으로 넘어갈 때 숨겼던 네비게이션 바를 표시
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - Layout
    private func setAutoLayout() {
        view.addSubview(patternImageView)
        view.addSubview(mainVStack)
        mainVStack.addArrangedSubview(imageView)
        mainVStack.addArrangedSubview(titleVStack)
        mainVStack.addArrangedSubview(startButton)
        titleVStack.addArrangedSubview(titleLabel)
        titleVStack.addArrangedSubview(subTitleLabel)

        patternImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        mainVStack.snp.makeConstraints { $0.edges.equalTo(view.safeAreaLayoutGuide) }
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
