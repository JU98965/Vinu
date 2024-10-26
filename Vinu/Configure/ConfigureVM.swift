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
    }
    
    struct Output {
        let placeHolder: Observable<String>
        let ratioData: Observable<[(UIImage?, String)]>
        let presentLoadingVC: Observable<ProjectData>
    }
    
    private let bag = DisposeBag()
    let phAssets: [PHAsset]
    
    init(_ phAssets: [PHAsset]) {
        self.phAssets = phAssets
    }
    
    func transform(input: Input) -> Output {
        // weak self 귀찮으니 여기에다가 복사
        let phAssets = Observable.just(phAssets)
        
        // 텍스트 필드 플레이스홀더 설정
        let placeHolder = Observable
            .just({
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy년 M월 d일"
                return formatter.string(from: Date())
            }())
        
        // 생성 버튼을 누르면 ProjectData를 코어데이터에 저장
        let presentLoadingVC = input.tapCreateButton
            .withLatestFrom(Observable.combineLatest(input.titleText, placeHolder, phAssets))
            .map { combined in
                let projectData: ProjectData
                
                let designatedTitle = combined.0?.trimmingCharacters(in: .whitespaces) ?? ""
                let defaultTitle = combined.1
                let assets = combined.2
                
                // 딱히 지정한 제목이 없다면 현재 날짜로 제목 생성
                if designatedTitle.isEmpty {
                    projectData = ProjectData(title: defaultTitle, phAssets: assets, date: Date())
                } else {
                    projectData = ProjectData(title: designatedTitle, phAssets: assets, date: Date())
                }
                
                // 추후 필요하다면 이 시점에 코어데이터 저장 코드 추가
                
                return projectData
            }
            
        // 비율 선택 컬렉션 뷰에 사용하는 데이터
        let ratioData = Observable
            .just({
                let ratioImage = [UIImage(systemName: "1.square"), UIImage(systemName: "2.square")]
                let ratioText = ["16:9", "9:16"]
                
                return zip(ratioImage, ratioText).map { ($0, $1) }
            }())
            .share(replay: 1)
        
        return Output(
            placeHolder: placeHolder,
            ratioData: ratioData,
            presentLoadingVC: presentLoadingVC)
    }
}
