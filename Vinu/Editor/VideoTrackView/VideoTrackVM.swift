//
//  VideoTrackVM.swift
//  Vinu
//
//  Created by 신정욱 on 10/20/24.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa

final class VideoTrackVM {
    typealias FrameImages = [UIImage]
    
    struct Input {
        let sourceIn: Observable<[VideoTrackModel]>
        let pinchScale: Observable<CGFloat>
        let focusedIndexPath: Observable<IndexPath>
        let leftPanTranslation: Observable<CGPoint>
        let panState: Observable<UIGestureRecognizer.State>
        let rightPanTranslation: Observable<CGPoint>
        let scrollProgress: Observable<CGFloat>
    }
    
    struct Output {
        let frameImagesArr: Observable<[FrameImages]>
        let cellWidths: Observable<[CGFloat]>
        let focusedIndexPath: Observable<IndexPath>
        let leftPanOffsetShift: Observable<CGFloat> // 스크롤 뷰 오프셋 변경에 필요
        let needUpdateClipCVWidth: Observable<Void>
        let drawFocusView: Observable<IndexPath>
        let leftPanInnerOffset: Observable<(CGFloat, IndexPath)> // 셀 내부 컬렉션 뷰 오프셋 변경에 필요
        let timeRanges: Observable<[CMTimeRange]>
        let scrollProgress: Observable<CGFloat>
        let scaleFactor: Observable<CGFloat>
    }
    
    private let bag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let MAX_SCALE: CGFloat = 10.0
        let MIN_SCALE: CGFloat = 0.1
        let MIN_WIDTH: CGFloat = 0.1
        
        // 바인딩 된 데이터를 전적으로 관리하는 서브젝트
        let trackDataArr = BehaviorSubject<[VideoTrackModel]>(value: [])
        
        // 외부로부터 데이터가 바인딩 되면 trackDataArr의 데이터를 업데이트
        input.sourceIn
            .bind(to: trackDataArr)
            .disposed(by: bag)
        
        // 바뀐 내부 셀의 컬렉션 뷰의 콘텐츠 오프셋을 전체 길이로 나눠서 시작 지점 특정
        // 시작지점으로 부터 현재 셀의 프레임의 넓이만큼 더하고 전체 길이로 나누면 그곳이 종료지점
        
        // 셀 넓이의 초기 할당 및 업데이트
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
        
        // 특정 셀을 포커싱, 핸들 조작 중 포커스가 바뀌지 않는 로직도 추가
        let focusedIndexPath = input.focusedIndexPath
            .withLatestFrom(input.panState) { ($0, $1) }
            .compactMap { $1 != .changed ? $0 : nil }
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
        
        // 각 클립에 들어갈 이미지 배열
        let frameImagesArr = trackDataArr
            .map { dataArr in
                return dataArr.map {
                    let image = $0.image
                    // 스케일이 반영된 원본 넓이를 기준으로 프레임 이미지 배열 만들기
                    let cellCount = ceil($0.originalWidth / 60).int
                    
                    return FrameImages(repeating: image, count: cellCount)
                }
            }
            .distinctUntilChanged {
                // 전체 이미지 개수로 필터링하면 오작동은 없을 것으로 예상중
                $0.flatMap { $0 }.count == $1.flatMap { $0 }.count
            }
        
        // MARK: Transfer to outside
        // 트리밍이 끝난 순간에만 새로운 재생 범위를 외부에 전달
        let newTimeRanges = input.panState
            .withLatestFrom(trackDataArr) { state, dataArr in
                (state, dataArr.map { $0.newTimeRange})
            }
            .compactMap { $0.0 == .ended ? $0.1 : nil }
            .share(replay: 1)
        
        // 플레이어를 구성하기 위해 초기 재생 범위를 외부에 전달
        let firstTimeRanges = trackDataArr
            .map { $0.map { $0.newTimeRange } }
            // 유의미한 배열이 올 때까지 필터링
            .filter { !$0.isEmpty }
            .take(1)
        
        // 초기 범위와 새로운 범위를 전달하는 스트림을 하나로 묶기
        let timeRanges = Observable.merge(newTimeRanges, firstTimeRanges)
            .share(replay: 1)
        
        // 스크롤 진행률을 외부에 전달, 총 재생시간에 대해 seek 작업은 상위 뷰에서 처리
        // 단, 트리밍 중에는 전달하지 않음
        let scrollProgress = input.scrollProgress
            .withLatestFrom(input.panState) { ($0, $1) }
            .compactMap { $1 != .changed ? $0 : nil }
        
        // 확대 배율을 외부에 전달
        let scaleFactor = trackDataArr
            .map { $0.first?.scale }
            .compactMap { $0 }
            .distinctUntilChanged()
            .share(replay: 1)

        
        return Output(
            frameImagesArr: frameImagesArr,
            cellWidths: cellWidths,
            focusedIndexPath: focusedIndexPath,
            leftPanOffsetShift: leftPanOffsetShift,
            needUpdateClipCVWidth: needUpdateClipCVWidth,
            drawFocusView: drawFocusView,
            leftPanInnerOffset: leftPanInnerOffset,
            timeRanges: timeRanges,
            scrollProgress: scrollProgress,
            scaleFactor: scaleFactor)
    }
}


