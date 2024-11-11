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
        let selectedPlacementPath: Observable<IndexPath>
    }
    
    struct Output {
        let placeHolder: Observable<String>
        let ratioItems: Observable<[ConfigureCardCell.RatioData]>
        let placementItems: Observable<[ConfigureCardCell.PlacementData]>
        let isCreateButtonEnabled: Observable<Bool>
        let createButtonTitle: Observable<String>
        let presentLoadingVC: Observable<NewProjectData>
    }
    
    private let bag = DisposeBag()
    let phAssets: [PHAsset]
    // 비율 선택 컬렉션 뷰에 들어가는 데이터
    private let ratioItems: [ConfigureCardCell.RatioData] = [
        .init(image: UIImage(systemName: "1.square"), title: "9:16", exportSize: CGSize(width: 1080, height: 1920)),
        .init(image: UIImage(systemName: "2.square"), title: "16:9", exportSize: CGSize(width: 1920, height: 1080)),
    ]
    
    private let placementItems: [ConfigureCardCell.PlacementData] = [
        .init(image: UIImage(systemName: "3.square"), title: "끼움", placement: .aspectFit),
        .init(image: UIImage(systemName: "4.square"), title: "채움", placement: .aspectFill),
    ]
    
    init(_ phAssets: [PHAsset]) {
        self.phAssets = phAssets
    }
    
    func transform(input: Input) -> Output {
        let phAssets = Observable.just(phAssets)
        let ratioItems = BehaviorSubject(value: ratioItems)
        let placementItems = BehaviorSubject(value: placementItems)
        
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
            .withLatestFrom(ratioItems) { path, items in
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
            .bind(to: ratioItems)
            .disposed(by: bag)
        
        // 선택한 사이즈(비율) 가져오기
        let exportSize = ratioItems
            .map { items in
                let selectedItem = items.first { $0.isSelected }
                let exportSize = selectedItem?.exportSize ?? CGSize(width: 1080, height: 1920)
                return exportSize
            }
        
        // 영상 배치를 하나만 선택하도록 하는 로직
        input.selectedPlacementPath
            .withLatestFrom(placementItems) { path, items in
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
            .bind(to: placementItems)
            .disposed(by: bag)
        
        // 선택한 영상 배치 가져오기
        let placement = placementItems
            .map { items in
                let selectedItem = items.first { $0.isSelected }
                let placement = selectedItem?.placement ?? .aspectFit
                return placement
            }
        
        
        
        // 비디오 에디터에 필요한 데이터 미리 로드
        let videoClips = phAssets
            .flatMapLatest { phAssets in
                return Observable.create { observer in
                    let task = Task { @MainActor in
                        let result = await self.fetchVideoClips(phAssets)
                        
                        switch result {
                        case .success(let data):
                            observer.onNext(data)
                        case .failure(let error):
                            print(error)
                        }
                        
                        observer.onCompleted()
                    }
                    
                    return Disposables.create {
                        // 로드 중에 이전화면으로 넘어가는 경우 작업 취소
                        task.cancel()
                    }
                }
            }
            .share(replay: 1)
        
        // 비디오 클립을 가져와야 생성 버튼 활성화
        let isCreateButtonEnabled = videoClips
            .map { !$0.isEmpty }
        
        // 생성 버튼의 타이틀의 텍스트 설정
        let createButtonTitle = isCreateButtonEnabled
            .map {
                if $0 {
                    "프로젝트 시작하기"
                } else {
                    "데이터를 불러오고 있어요."
                }
            }
        
        // 생성 버튼을 누르면 프로젝트 데이터 생성
        let presentLoadingVC = input.tapCreateButton
            .withLatestFrom(Observable.combineLatest(titleText, exportSize, videoClips))
            .map { combined in
                let (titleText, exportSize, videoClips) = combined
                
                let result = NewProjectData(title: titleText, exportSize: exportSize, videoClips: videoClips)
                
                // 추후 필요하다면 이 시점에 코어데이터 저장 코드 추가
                
                return result
            }
        
        return Output(
            placeHolder: placeHolder,
            ratioItems: ratioItems.asObservable(),
            placementItems: placementItems.asObservable(),
            isCreateButtonEnabled: isCreateButtonEnabled,
            createButtonTitle: createButtonTitle,
            presentLoadingVC: presentLoadingVC)
    }
    
    // MARK: - Method
    
    
}
