//
//  VideoTrackVM.swift
//  Vinu
//
//  Created by 신정욱 on 10/20/24.
//

import UIKit
import RxSwift
import RxCocoa

final class VideoTrackVM {
    
    struct Input {
        let pinchScale: Observable<CGFloat>
        let focusedIndexPath: Observable<IndexPath>
        let leftPanTranslation: Observable<CGPoint>
        let leftPanStatus: Observable<UIGestureRecognizer.State>
        let rightPanTranslation: Observable<CGPoint>
    }
    
    struct Output {
        let frameImages: Observable<[VideoClip.FrameImages]>
        let cellWidths: Observable<[CGFloat]>
        let focusedIndexPath: Observable<IndexPath>
        let leftPanOffsetShift: Observable<CGFloat> // 스크롤 뷰 오프셋 변경에 필요
        let needUpdateClipCVWidth: Observable<Void>
        let drawFocusView: Observable<IndexPath>
        let leftPanInnerOffset: Observable<(CGFloat, IndexPath)> // 셀 내부 컬렉션 뷰 오프셋 변경에 필요
    }
    
    // private let sources: [VideoClip]
    private let bag = DisposeBag()
    private let images: [CGImage] = [
        UIImage(systemName: "macpro.gen3.fill")!.cgImage!,
        UIImage(systemName: "macbook.gen2")!.cgImage!,
        UIImage(systemName: "macmini.fill")!.cgImage!,
    ]

    // init(_ sources: [VideoClip]) {
    //     self.sources = sources
    // }
    
    func transform(input: Input) -> Output {
        let MAX_SCALE: CGFloat = 10.0
        let MIN_SCALE: CGFloat = 0.1
        let MIN_WIDTH: CGFloat = 0.1
        
        let images = Observable.just(images).share(replay: 1)
        let trackDataArr = BehaviorSubject<[TrackData]>(value: [.init(original: 60), .init(original: 120), .init(original: 90)])
        
        // 바뀐 내부 셀의 컬렉션 뷰의 콘텐츠 오프셋을 전체 길이로 나눠서 시작 지점 특정
        // 시작지점으로 부터 현재 셀의 프레임의 넓이만큼 더하고 전체 길이로 나누면 그곳이 종료지점
        
        // 셀 넓이 초기 할당 및 모든
        let cellWidths = trackDataArr
            .map { $0.map { $0.currentWidth } }
            .share(replay: 1)
        
        // 핀치스케일이 바뀌면 셀 스케일들도 바뀜
        input.pinchScale
            .withLatestFrom(trackDataArr) { ($0, $1) }
            .map { scale, dataArr in
                dataArr.map {
                    var data = $0
                    
                    data.scale *= scale
                    
                    // 최저, 최대 스케일 제한
                    if data.scale < MIN_SCALE {
                        data.scale = MIN_SCALE
                    } else if data.scale > MAX_SCALE {
                        data.scale = MAX_SCALE
                    }

                    return data
                }
            }
            .bind(to: trackDataArr)
            .disposed(by: bag)
        
        // 특정 셀을 포커싱, 왼쪽 핸들 조작 중 포커스가 바뀌지 않는 로직도 추가
        let focusedIndexPath = input.focusedIndexPath
            .withLatestFrom(input.leftPanStatus) { ($0, $1) }
            .filter { $0.1 != .changed }
            .map { $0.0 }
            .share(replay: 1)
        
        // 왼쪽 핸들을 조작해 특정 셀의 넓이(시작 지점)를 변경
        input.leftPanTranslation
            .withLatestFrom(Observable.combineLatest(focusedIndexPath, trackDataArr)) { translation, combined in
                let translation = translation
                let index  = combined.0.row
                var dataArr = combined.1
                
                dataArr[index].startPoint = dataArr[index].startPoint + translation.x
                
                // 원본의 시작 지점보다 앞으로는 확장할 수 없음
                if dataArr[index].startPoint < 0 {
                    dataArr[index].startPoint = 0
                // 시작 지점이 종료 지점보다 뒤에 올 수 없음
                } else if dataArr[index].startPoint > dataArr[index].endPoint - MIN_WIDTH {
                    dataArr[index].startPoint = dataArr[index].endPoint - MIN_WIDTH
                }
                
                return dataArr
            }
            .bind(to: trackDataArr)
            .disposed(by: bag)
        
        // 오른쪽 핸들을 조작해 특정 셀의 넓이(종료 지점)를 변경
        input.rightPanTranslation
            .withLatestFrom(Observable.combineLatest(focusedIndexPath, trackDataArr)) { translation, combined in
                let translation = translation
                let index  = combined.0.row
                var dataArr = combined.1
                
                dataArr[index].endPoint = dataArr[index].endPoint + translation.x
                
                // 원본의 종료 지점보다 뒤로는 확장할 수 없음
                if dataArr[index].endPoint > dataArr[index].originalWidth {
                    dataArr[index].endPoint = dataArr[index].originalWidth
                // 종료 지점이 시작 지점보다 앞에 올 수 없음
                } else if dataArr[index].endPoint < dataArr[index].startPoint + MIN_WIDTH {
                    dataArr[index].endPoint = dataArr[index].startPoint + MIN_WIDTH
                }
                
                return dataArr
            }
            .bind(to: trackDataArr)
            .disposed(by: bag)
        
        // 제스처가 감지되었으니 클립 컬렉션 뷰의 넓이를 업데이트 해달라는 신호"만" 방출
        // cellWidth는 사용 못함, 셀의 초기화 순서가 꼬임. 마찬가지로 제스처들에게 초깃값을 줘도 꼬임.
        let needUpdateClipCVWidth = Observable
            .merge(
                input.pinchScale.map { _ in },
                input.leftPanTranslation.map { _ in },
                input.rightPanTranslation.map { _ in })
        
        // 포커스 중인 인덱스 패스가 변하거나 제스처를 하고 있을 때에는 포커스 뷰를 다시 그림
        let drawFocusView = Observable
            .merge(
                trackDataArr.map { _ in }.withLatestFrom(focusedIndexPath),
                focusedIndexPath)
        
        // 좌측 팬 제스처가 실행중일 때 스크롤 뷰 콘텐츠 오프셋의 조정 값을 전달
        let leftPanOffsetShift = input.leftPanTranslation
            .withLatestFrom(Observable.combineLatest(focusedIndexPath, trackDataArr)) { translation, combined in
                let translation = translation
                let index  = combined.0.row
                let dataArr = combined.1
                
                if dataArr[index].startPoint == 0 {
                    return CGFloat(0)
                } else {
                    return translation.x
                }
            }
        
        // 좌측 팬 제스처가 실행중일 때 셀 내부의 콘텐츠 오프셋 자체를 전달
        let leftPanInnerOffset = trackDataArr
            .withLatestFrom(focusedIndexPath) { dataArr, path in
                let offset = dataArr[path.row].startPoint
                return (offset, path)
            }
        
        // 트랙 뷰에 들어갈 이미지 묶음들
        let frameImages = cellWidths
            .withLatestFrom(images) { widths, images in
                zip(widths, images).map { width, image in
                    // 일단 최대 스케일 기준으로 갯수를 상정하고 보내기
                    let width = width * MAX_SCALE
                    let cellCount = ceil(width / 60).int
                    return VideoClip.FrameImages(repeating: image, count: cellCount)
                }
            }
        
        return Output(
            frameImages: frameImages,
            cellWidths: cellWidths,
            focusedIndexPath: focusedIndexPath,
            leftPanOffsetShift: leftPanOffsetShift,
            needUpdateClipCVWidth: needUpdateClipCVWidth,
            drawFocusView: drawFocusView,
            leftPanInnerOffset: leftPanInnerOffset)
    }
}

fileprivate struct TrackData {
    private let originalWidth_: CGFloat
    private var startPoint_: CGFloat
    private var endPoint_: CGFloat
    var scale: CGFloat
    
    var originalWidth: CGFloat {
        originalWidth_ * scale
    }
    var startPoint: CGFloat {
        get { startPoint_ * scale }
        set { startPoint_ = newValue / scale }
    }
    var endPoint: CGFloat {
        get { endPoint_ * scale }
        set { endPoint_ = newValue / scale }
    }
    var currentWidth: CGFloat {
        endPoint - startPoint
    }
    
    init(original: CGFloat) {
        self.originalWidth_ = original
        self.startPoint_ = 0
        self.endPoint_ = original
        self.scale = 1.0
    }
}
