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
        let maxScale: CGFloat = 10.0
        let minScale: CGFloat = 0.1
        
        let images = Observable.just(images).share(replay: 1)
        let trackDataArr = BehaviorSubject<[TrackData]>(value: [.init(original: 60), .init(original: 120), .init(original: 90)])
        
        // 바뀐 내부 셀의 컬렉션 뷰의 콘텐츠 오프셋을 전체 길이로 나눠서 시작 지점 특정
        // 시작지점으로 부터 현재 셀의 프레임의 넓이만큼 더하고 전체 길이로 나누면 그곳이 종료지점
        
        let cellWidths = trackDataArr
            .map { $0.map { $0.currentWidth } }
        
        // 핀치스케일이 바뀌면 셀 스케일들도 바뀜
        input.pinchScale
            .withLatestFrom(trackDataArr) { ($0, $1) }
            .map { scale, dataArr in
                dataArr.map {
                    var data = $0
                    
                    data.scale *= scale
                    
                    // 최저, 최대 스케일 제한
                    if data.scale < minScale {
                        data.scale = minScale
                    } else if data.scale > maxScale {
                        data.scale = maxScale
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
                } else if dataArr[index].startPoint > dataArr[index].endPoint - 10 {
                    dataArr[index].startPoint = dataArr[index].endPoint - 10
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
                } else if dataArr[index].endPoint < dataArr[index].startPoint + 10 {
                    dataArr[index].endPoint = dataArr[index].startPoint + 10
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
                    let width = width * maxScale
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

/*
 final class VideoTrackVM {
     struct Input {
         let pinchScale: Observable<CGFloat>
         let focusedIndexPath: Observable<IndexPath>
         let leftPanTranslation: Observable<CGPoint>
         let leftPanStatus: Observable<UIGestureRecognizer.State>
         let rightPanTranslation: Observable<CGPoint>
     }
     
     struct Output {
         // let frameImages: Observable<[VideoClip.FrameImages]>
         let cellWidths: Observable<[CGFloat]>
         let focusedIndexPath: Observable<IndexPath>
         let leftPanOffset: Observable<(CGPoint, IndexPath)> // 스크롤 뷰, 셀 내부 컬렉션 뷰 오프셋 변경에 필요
         let needUpdateClipCVWidth: Observable<Void>
         let drawFocusView: Observable<IndexPath>
     }
     
     // private let sources: [VideoClip]
     private let bag = DisposeBag()
     
     // init(_ sources: [VideoClip]) {
     //     self.sources = sources
     // }
     
     func transform(input: Input) -> Output {
         // 현재 트랙 뷰 사이즈를 지정하는 서브젝트
         let cellWidths = BehaviorSubject<[CGFloat]>(value: {
             // sources.map { CGFloat($0.metadata.duration.seconds * 10) }
             [60, 120, 90]
         }())
         
         let cellOriginalWidths = BehaviorSubject<[CGFloat]>(value: [60, 120, 90])
         let cellScale = BehaviorSubject<CGFloat>(value: 1.0) // 최저, 최대 스케일 제한 용도로 쓸까?
         let startOffsets = BehaviorSubject<[CGFloat]>(value: [0, 0, 0])
         let endOffsets = BehaviorSubject<[CGFloat]>(value: [60, 120, 90])
         
         // 바뀐 내부 셀의 컬렉션 뷰의 콘텐츠 오프셋을 전체 길이로 나눠서 시작 지점 특정
         // 시작지점으로 부터 현재 셀의 프레임의 넓이만큼 더하고 전체 길이로 나누면 그곳이 종료지점
         
         input.pinchScale
             .withLatestFrom(startOffsets) { scale, offsets in
                 offsets.map { $0 * scale }
             }
             .bind(to: startOffsets)
             .disposed(by: bag)
         

         
         input.pinchScale
             .withLatestFrom(cellOriginalWidths) { scale, widths in
                 widths.map { $0 * scale }
             }
             .bind(to: cellOriginalWidths)
             .disposed(by: bag)

         // 핀치 제스처의 스케일에 따라 전체 셀 넓이 변경
         input.pinchScale
             .withLatestFrom(cellWidths) { scale, widths in
                 let newWidth = widths.map { $0 * scale }
                 return newWidth
             }
             .bind(to: cellWidths)
             .disposed(by: bag)
         
         // 왼쪽 핸들 조작 중 포커스가 바뀌지 않게 하는 로직을 추가
         let focusedIndexPath = input.focusedIndexPath
             .withLatestFrom(input.leftPanStatus) { ($0, $1) }
             .filter { $0.1 != .changed }
             .map { $0.0 }
             .share(replay: 1)
         
         // temp
         input.leftPanTranslation
             .withLatestFrom(Observable.combineLatest(focusedIndexPath, startOffsets)) { translation, combined in
                 let translation = translation
                 let index  = combined.0.row
                 var offsets = combined.1
                 
                 offsets[index] = offsets[index] + translation.x
                 
                 if offsets[index] < 0 {
                     offsets[index] = 0
                 }
                 
                 return offsets
             }
             .bind(to: startOffsets)
             .disposed(by: bag)
         
         // temp
         input.rightPanTranslation
             .withLatestFrom(Observable.combineLatest(focusedIndexPath, endOffsets)) { translation, combined in
                 let translation = translation
                 let index  = combined.0.row
                 var offsets = combined.1
                 
                 offsets[index] = offsets[index] + translation.x
                 
                 if offsets[index] < 0 {
                     offsets[index] = 0
                 }
                 
                 return offsets
             }
             .bind(to: endOffsets)
             .disposed(by: bag)
         
         // 트리밍 핸들 조작으로 인한 특정 셀의 넓이의 변경
         Observable
             .merge(
                 // 왼쪽 팬 제스처는 x를 음수로 변환
                 input.leftPanTranslation.map { CGPoint(x: -$0.x, y: $0.y) },
                 input.rightPanTranslation
             )
             .withLatestFrom(Observable.combineLatest(focusedIndexPath, cellWidths)) { translation, combined in
                 let translation = translation
                 let index = combined.0.row
                 var widths = combined.1
                 
                 widths[index] = widths[index] + translation.x
                 
                 // 셀의 넓이가 음수가 되는것을 막음
                 if widths[index] <= 10 {
                     widths[index] = 10
                 }
                 
                 return widths
             }
             .bind(to: cellWidths)
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
                 needUpdateClipCVWidth.withLatestFrom(focusedIndexPath),
                 focusedIndexPath)
         
         // 좌측 팬 제스처가 실행중일 때 스크롤 뷰 타입의 뷰들의 콘텐츠 오프셋을 조정하기 위함
         let leftPanOffset = input.leftPanTranslation
             .withLatestFrom(focusedIndexPath) { ($0, $1) }

         // 트랙 뷰에 들어갈 이미지 묶음들
         // let frameImages = Observable
         //     .just({
         //         sources.map { $0.frameImages }
         //     }())
         //     .share(replay: 1)
         
         return Output(
             // frameImages: frameImages,
             cellWidths: cellWidths.asObservable(),
             focusedIndexPath: focusedIndexPath,
             leftPanOffset: leftPanOffset,
             needUpdateClipCVWidth: needUpdateClipCVWidth,
             drawFocusView: drawFocusView)
     }
 }
 */
