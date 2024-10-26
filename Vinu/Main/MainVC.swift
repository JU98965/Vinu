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
    let titleLabel = {
        let label = UILabel()
        label.text = String(localized: "대시보드")
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    let newProjectButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .white
        config.title = String(localized: "새 프로젝트")
        let button = UIButton(configuration: config)
        button.layer.cornerRadius = .chu16
        button.layer.cornerCurve = .continuous
        button.clipsToBounds = true
        return button
    }()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNavigationBar(
            leftBarButtonItems: [UIBarButtonItem(customView: titleLabel)])
        setAutoLayout()
        setBinding()
    }

    // MARK: - Layout
    private func setAutoLayout() {
        view.addSubview(newProjectButton)
        
        newProjectButton.snp.makeConstraints {
            $0.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide).inset(25)
            $0.height.equalTo(50)
        }
    }
    
    // MARK: - Binding
    private func setBinding() {
        let input = MainVM.Input(tapNewProjectButton: newProjectButton.rx.tap.asObservable())
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
