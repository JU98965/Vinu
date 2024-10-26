//
//  LoadingVM.swift
//  Vinu
//
//  Created by 신정욱 on 9/26/24.
//

import Foundation
import RxSwift
import RxCocoa
import AVFoundation
import Photos

final class LoadingVM {
    struct Output {
        let presentEditorVC: Observable<[VideoClip]>
    }
    
    private let bag = DisposeBag()
    private let projectData: ProjectData

    init(_ projectData: ProjectData) {
        self.projectData = projectData
    }
    
    func transform() -> Output {
        // PHAsset들로 비디오 클립들을 가져오기
        let videoClips = Observable<[VideoClip]>
            .create { observer in
                Task { @MainActor in
                    let result = await self.fetchVideoClips(self.projectData.phAssets)
                    
                    switch result {
                    case .success(let data):
                        observer.onNext(data)
                    case .failure(let error):
                        print(error)
                    }
                    
                    observer.onCompleted()
                }
                
                return Disposables.create()
            }
            .share(replay: 1)
        
        return Output(presentEditorVC: videoClips)
    }
}
