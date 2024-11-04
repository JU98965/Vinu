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
        sv.distribution = .fill
        return sv
    }()
    
    let splashyView = SplashyView()
    
    let entryView = EntryView()

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backWhite
        setAutoLayout()	
        setBinding()
    }

    // MARK: - Layout
    private func setAutoLayout() {
        view.addSubview(mainVStack)
        mainVStack.addArrangedSubview(splashyView)
        mainVStack.addArrangedSubview(entryView)
        
        
        mainVStack.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(50)
        }
        splashyView.snp.makeConstraints { $0.height.equalToSuperview().multipliedBy(0.7) }
    }
    
    // MARK: - Binding
    private func setBinding() {
        let input = MainVM.Input(tapNewProjectButton: entryView.mergeButton.button.rx.tap.asObservable())
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
