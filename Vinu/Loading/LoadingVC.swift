//
//  LoadingVC.swift
//  Vinu
//
//  Created by 신정욱 on 9/26/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class LoadingVC: UIViewController {
    var loadingVM: LoadingVM!
    private let bag = DisposeBag()
    
    // MARK: - Components
    let stackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .center
        sv.spacing = .chu16
        return sv
    }()
    
    let indicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = .darkGray
        return view
    }()
    
    let titleLabel = {
        let label = UILabel()
        label.text = String(localized: "불러오는 중")
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .darkGray
        return label
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true // 네비게이션 바 숨기기
        indicatorView.startAnimating()
        setAutoLayout()
        setBindind()
    }
    
    // MARK: - Layout
    private func setAutoLayout() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(indicatorView)
        stackView.addArrangedSubview(titleLabel)
        
        stackView.snp.makeConstraints { $0.center.equalToSuperview() }
    }
    
    // MARK: - Binding
    private func setBindind() {
        // 인풋은 없음
        let output = loadingVM.transform()
        
        // 모든 데이터 로딩이 끝나면 EditorVC로 화면전환
        // 자연스러운 화면전환 애니메이션을 위해 구독을 1초 지연
        output.presentEditorVC
            .delaySubscription(.seconds(1), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, editors in
                // 화면전환은 window layer가 담당하므로 거기에 트랜지션 효과 추가
                let transition = CATransition()
                transition.duration = 0.5
                transition.type = .fade
                transition.subtype = .none
                transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                owner.view.window?.layer.add(transition, forKey: kCATransition)
                
                let vc = EditorVC()
                vc.editorVM = EditorVM(editors)
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
    LoadingVC()
}
