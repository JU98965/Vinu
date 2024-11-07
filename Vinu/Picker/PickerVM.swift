//
//  PickerVM.swift
//  Vinu
//
//  Created by 신정욱 on 9/18/24.
//

import UIKit
import RxSwift
import RxCocoa
import Photos

final class PickerVM {
    
    struct Input {
        let selectThumbnail: Observable<IndexPath>
        let selectPending: Observable<IndexPath>
        let tapNextButton: Observable<Void>
    }
    
    struct Output {
        let thumbnailItems: Observable<[ThumbnailSectionData]>
        let pendingItems: Observable<[ThumbnailSectionData]>
        let selectItemsCount: Observable<Int>
        let assets: Observable<[PHAsset]>
        let nextButtonEnabling: Observable<Bool>
    }
    
    private let bag = DisposeBag()
    
    func transform(input: Input) -> Output {
        // 썸네일 셀 아이템 상태를 저장하는 서브젝트
        let thumbnailItems = BehaviorSubject<[ThumbnailSectionData]>(value: fetchThumbnailItems())
        // 번호표 상태를 저장하는 서브젝트
        let numberTagIndexPaths = BehaviorSubject<[IndexPath]>(value: [])
        
        // 썸네일 셀을 탭하면 선택 or 선택 해제
        input.selectThumbnail
            .withLatestFrom(Observable.combineLatest(numberTagIndexPaths, thumbnailItems)) {
                let selectPath = $0
                var numberTagPaths = $1.0
                var items = $1.1.items
                
                // 탭한 셀이 이미 번호표를 가지고 있는지 아닌지 확인 후 추가 or 삭제
                if numberTagPaths.contains(selectPath) {
                    // 번호표 리스트에서 제거
                    numberTagPaths = numberTagPaths.filter { !($0 == selectPath) }
                    // 아이템 리스트에서도 번호표 제거
                    items[selectPath.row].selectNumber = nil
                } else {
                    // 번호표 리스트에 추가
                    numberTagPaths.append(selectPath)
                }
                
                // 번호표 리스트 바탕으로 번호표 붙여주기
                numberTagPaths.enumerated().forEach { numberTag, path in
                    // 선택한 순서가 0부터 시작하면 안되니 1 더하기
                    items[path.row].selectNumber = numberTag + 1
                }
                
                return (items: items.sectionData, numberTagPaths: numberTagPaths)
            }
            .bind { result in
                // 각 서브젝트에 새로운 값을 업데이트 및 방출
                thumbnailItems.onNext(result.items)
                numberTagIndexPaths.onNext(result.numberTagPaths)
            }
            .disposed(by: bag)
        
        // 계류 셀 탭하면 선택 해제
        input.selectPending
            .withLatestFrom(Observable.combineLatest(numberTagIndexPaths, thumbnailItems)) {
                let selectPath = $0
                var numberTagPaths = $1.0
                var items = $1.1.items
                
                // 선택된 계류 셀의 인덱스로 선택 해제할 썸네일 셀 인덱스 특정
                let targetPath = numberTagPaths[selectPath.row]
                // 썸네일 셀 번호표 제거
                items[targetPath.row].selectNumber = nil
                // 번호표 리스트에서도 제거
                numberTagPaths.remove(at: selectPath.row)
                
                // 번호표 리스트 바탕으로 번호표 붙여주기
                numberTagPaths.enumerated().forEach { numberTag, path in
                    // 선택한 순서가 0부터 시작하면 안되니 1 더하기
                    items[path.row].selectNumber = numberTag + 1
                }
                
                return (items: items.sectionData, numberTagPaths: numberTagPaths)
            }
            .bind { result in
                // 각 서브젝트에 새로운 값을 업데이트 및 방출
                thumbnailItems.onNext(result.items)
                numberTagIndexPaths.onNext(result.numberTagPaths)
            }
            .disposed(by: bag)
        
        // 계류 콜렉션뷰에 사용될 아이템 걸러내기
        let pendingItems = Observable
            // 썸네일 아이템, 번호표 패스의 정보가 함께 필요하기 때문에 zip으로 짝을 맞춰서 가져옴
            .zip(thumbnailItems, numberTagIndexPaths) { sectionData, numberTagPaths in
                let items = sectionData.items
                var pendingItems = [ThumbnailData]()
                numberTagPaths.forEach { pendingItems.append(items[$0.row]) }
                return pendingItems.sectionData
            }
            .share(replay: 1)
        
        // 몇 개의 아이템을 선택했는지 레이블에 뿌림
        let selectItemsCount = numberTagIndexPaths
            .map { $0.count }
            .share(replay: 1)
        
        // 다음 버튼을 누르면 다음 화면에 선택한 에셋 전달
        let assets = input.tapNextButton
            .withLatestFrom(pendingItems)
            .map { sectionData in
                sectionData.items.map { $0.asset }
            }
            .share(replay: 1)
        
        // 선택한 아이템이 있어야 다음 버튼을 활성화
        let nextButtonEnabling = numberTagIndexPaths
            .map { !$0.isEmpty }
        
        return Output(
            thumbnailItems: thumbnailItems.asObservable(),
            pendingItems: pendingItems,
            selectItemsCount: selectItemsCount,
            assets: assets,
            nextButtonEnabling: nextButtonEnabling)
    }
    
    // 메타데이터를 가져와서, 셀에 들어갈 데이터를 생성
    private func fetchThumbnailItems() -> [ThumbnailSectionData] {
        var assets = [PHAsset]()
        
        let options = PHFetchOptions()
        options.includeHiddenAssets = false
        options.includeAssetSourceTypes = [.typeUserLibrary]
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let fetchResult = PHAsset.fetchAssets(with: .video, options: options)
        fetchResult.enumerateObjects { asset, _, _ in assets.append(asset) }
        let items = assets.map { ThumbnailData(id: UUID(), asset: $0) }
        
        return items.sectionData
    }
}
