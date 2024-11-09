//
//  ConfigureVM.swift
//  Vinu
//
//  Created by 신정욱 on 9/24/24.
//

import UIKit
import RxSwift
import RxCocoa
import Photos

final class ConfigureVM {
    
    struct Input {
        let titleText: Observable<String?>
        let tapCreateButton: Observable<Void>
        let selectedRatioPath: Observable<IndexPath>
    }
    
    struct Output {
        let placeHolder: Observable<String>
        let ratioItems: Observable<[RatioCell.ItemData]>
        let presentLoadingVC: Observable<ProjectData>
    }
    
    private let bag = DisposeBag()
    let phAssets: [PHAsset]
    // 비율 선택 컬렉션 뷰에 들어가는 데이터
    private let ratioItems: [RatioCell.ItemData] = [
        .init(image: UIImage(systemName: "1.square"), label: "16:9"),
        .init(image: UIImage(systemName: "2.square"), label: "9:16"),
    ]
    
    init(_ phAssets: [PHAsset]) {
        self.phAssets = phAssets
    }
    
    func transform(input: Input) -> Output {
        let phAssets = Observable.just(phAssets)
        let ratioItems_ = BehaviorSubject(value: ratioItems)
        
        // 텍스트 필드 플레이스홀더 설정
        let placeHolder = Observable
            .just({
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy년 M월 d일"
                return formatter.string(from: Date())
            }())
            .share(replay: 1)
        
        // 타이틀 텍스트 필드에 무의미한 문자를 집어넣거나 아무것도 입력하지 않을 때 어떤 문자열을 내보낼건지에 대한 로직
        let titleText = input.titleText
            .withLatestFrom(placeHolder) { title, placeHolder in
                let trimed = title?.trimmingCharacters(in: .whitespaces) ?? ""
                return trimed.isEmpty ? placeHolder : trimed
            }
        
        // 비율을 하나만 선택하도록 하는 로직
        input.selectedRatioPath
            .withLatestFrom(ratioItems_) { path, items in
                return items.enumerated().map {
                    var (i, item) = $0
                    
                    if i == path.row {
                        item.isSelected = true
                    } else {
                        item.isSelected = false
                    }
                    
                    return item
                }
            }
            .bind(to: ratioItems_)
            .disposed(by: bag)
            
        // 비율 선택 컬렉션 뷰에 사용하는 데이터
        let ratioItems = ratioItems_.asObservable()

        // 생성 버튼을 누르면 프로젝트 데이터 생성
        let presentLoadingVC = input.tapCreateButton
            .withLatestFrom(Observable.combineLatest(titleText, phAssets))
            .map { combined in
                let (title, assets) = combined
                
                // 추후 필요하다면 이 시점에 코어데이터 저장 코드 추가
                
                return ProjectData(title: title, phAssets: assets, date: Date())
            }
        
        return Output(
            placeHolder: placeHolder,
            ratioItems: ratioItems,
            presentLoadingVC: presentLoadingVC)
    }
}
