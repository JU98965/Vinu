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
        let selectedThumbnailPath: Observable<IndexPath>
        let selectedPendingPath: Observable<IndexPath>
        let tapNextButton: Observable<Void>
        let tapRedirectButton: Observable<Void>
    }
    
    struct Output {
        let thumbnailSectionDataArr: Observable<[ThumbnailSectionData]>
        let pendingItems: Observable<[ThumbnailSectionData]>
        let selectItemsCount: Observable<Int>
        let assets: Observable<[PHAsset]>
        let nextButtonEnabling: Observable<Bool>
        let thumbnailCVBackState: Observable<(isAuthorized: Bool, isItemsEmpty: Bool)>
    }
    
    private let bag = DisposeBag()
    
    func transform(input: Input) -> Output {
        // 썸네일 셀 아이템 상태를 저장하는 서브젝트
        let thumbnailSectionDataArr = BehaviorSubject<[ThumbnailSectionData]>(value: [])
        // 번호표 상태를 저장하는 서브젝트
        let numberTagIndexPaths = BehaviorSubject<[IndexPath]>(value: [])
        
        // 사진 앨범 권한 확인
        let isAuthorized = checkAuthorization()
            .share(replay: 1)
        
        // 권한 허용 여부에 따라 아이템을 가져올지 말지 결정
        isAuthorized
            .compactMap { [weak self] isAuthorized in
                isAuthorized ? self?.fetchThumbnailItems() : nil
            }
            .bind(to: thumbnailSectionDataArr)
            .disposed(by: bag)
        
        let thumbnailCVBackState = isAuthorized
            .withLatestFrom(thumbnailSectionDataArr) { isAuthorized, sectionDataArr in
                return (isAuthorized: isAuthorized, isItemsEmpty: sectionDataArr.items.isEmpty)
            }
        
        // 썸네일 셀을 탭하면 선택 or 선택 해제
        input.selectedThumbnailPath
            .withLatestFrom(Observable.combineLatest(numberTagIndexPaths, thumbnailSectionDataArr)) {
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
                thumbnailSectionDataArr.onNext(result.items)
                numberTagIndexPaths.onNext(result.numberTagPaths)
            }
            .disposed(by: bag)
        
        // 계류 셀 탭하면 선택 해제
        input.selectedPendingPath
            .withLatestFrom(Observable.combineLatest(numberTagIndexPaths, thumbnailSectionDataArr)) {
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
                thumbnailSectionDataArr.onNext(result.items)
                numberTagIndexPaths.onNext(result.numberTagPaths)
            }
            .disposed(by: bag)
        
        // 계류 콜렉션뷰에 사용될 아이템 걸러내기
        let pendingItems = Observable
            // 썸네일 아이템, 번호표 패스의 정보가 함께 필요하기 때문에 zip으로 짝을 맞춰서 가져옴
            .zip(thumbnailSectionDataArr, numberTagIndexPaths) { sectionData, numberTagPaths in
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
        
        // 설정으로 이동 버튼을 누르면 설정 창으로 리디렉션
        input.tapRedirectButton
            .bind(with: self) { owner, _ in
                // 설정 창으로 이동
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
                      UIApplication.shared.canOpenURL(settingsURL)
                else { return }
                
                UIApplication.shared.open(settingsURL)
            }
            .disposed(by: bag)
        
        return Output(
            thumbnailSectionDataArr: thumbnailSectionDataArr.asObservable(),
            pendingItems: pendingItems,
            selectItemsCount: selectItemsCount,
            assets: assets,
            nextButtonEnabling: nextButtonEnabling,
            thumbnailCVBackState: thumbnailCVBackState)
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
    
    private func checkAuthorization() -> Observable<Bool> {
        Observable.create { observer in
            /// .notDetermined: 아직 아무것도 결정하지 않음
            /// .restricted: 외부적인 제한에 의해 권한을 사용할 수 없음 (이건 내가 어케 못함)
            /// .denied: 거절됨
            /// .authorized: 허가됨
            /// .limited: 제한적 접근 허가됨
            
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

            switch status {
            case .notDetermined:
                Task { @MainActor in
                    // 아직 아무것도 결정하지 않았다면 권한 요청 후 결과 받아오기
                    let result = await self.requtestAuthorization()
                    observer.onNext(result)
                }
            case .denied, .restricted:
                observer.onNext(false)
            case .authorized, .limited:
                observer.onNext(true)
            @unknown default:
                print("예외 발생", #function)
            }
            
            return Disposables.create()
        }
    }
    
    private func requtestAuthorization() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        
        switch status {
        case .denied, .restricted:
            return false
        case .authorized, .limited:
            return true
        default:
            print("예외 발생", #function)
            return false
        }
    }
}
