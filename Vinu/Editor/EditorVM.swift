//
//  EditorVM.swift
//  Vinu
//
//  Created by 신정욱 on 9/24/24.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa

final class EditorVM {
    
    struct Input {
        let progress: Observable<Double>
        let currentTimeRanges: Observable<[CMTimeRange]>
        let scrollProgress: Observable<CGFloat>
        let scaleFactor: Observable<CGFloat>
        let controlStatus: Observable<AVPlayer.TimeControlStatus>
        let playbackTap: Observable<Void>
    }
    
    struct Output {
        let playerItem: Observable<AVPlayerItem>
        let trackViewData: Observable<[VideoTrackModel]>
        let progress: Observable<Double>
        let seekingPoint: Observable<CMTime>
        let elapsedTimeText: Observable<(String, String)>
        let scaleFactorText: Observable<String>
        let needPlaying: Observable<Bool>
    }
    
    let bag = DisposeBag()
    let videoClips: [VideoClip]

    init(_ videoClips: [VideoClip]) {
        self.videoClips = videoClips
    }
    
    func transform(input: Input) -> Output {
        let videoClips = BehaviorSubject(value: videoClips).asObservable()
        // 재생 상태를 가지는 서브젝트
        let controlStatus = BehaviorSubject(value: AVPlayer.TimeControlStatus.paused)
        
        // 트랙 뷰에 들어갈 데이터 준비
        let trackViewData = videoClips
            .map { videoClips in
                videoClips.map { VideoTrackModel(image: $0.image, duration: $0.metadata.duration) }
            }
            .share(replay: 1)

        // 트랙뷰에서 제공받은 각 클립의 시간 범위를 기반으로 플레이어 아이템 작성
        let playerItem = input.currentTimeRanges
            .withLatestFrom(videoClips) { [weak self] timeRanges, videoClips in
                let metadataArr = videoClips.map { $0.metadata }
                let playerItem = self?.makePlayerItem(metadataArr, timeRanges, exportSize: CGSize(width: 1080, height: 1920))
                return playerItem
            }
            .compactMap { $0 }
            .share(replay: 1)

        // 비디오 플레이어의 진행률
        let progress = input.progress
            .share(replay: 1)
        
        // 트랙뷰가 스크롤 되거나 콘텐츠 오프셋이 변경되면 탐색 시점을 전달
        let seekingPoint = input.scrollProgress
            .withLatestFrom(playerItem) { progress, item in
                let timePoint = progress * item.duration.seconds
                return CMTime(seconds: timePoint, preferredTimescale: 30)
            }
            .distinctUntilChanged()
            .share(replay: 1)
        
        // 트랙뷰가 스크롤 되거나 콘텐츠 오프셋이 변경되면 경과 시간 텍스트 바인딩
        // 스크롤 진행률의 초기값이 있어야 실행 때 값을 방출할 수 있음
        let elapsedTimeText = Observable
            .combineLatest(playerItem, input.scrollProgress.startWith(0))
            .flatMapLatest(getElapsedTimeText(item:progress:))
            .share(replay: 1)
        
        // 확대 배율을 텍스트로 바꿔서 콘솔에 전달
        // 초기값이 있어야 실행 때 값을 방출할 수 있음
        let scaleFactorText = input.scaleFactor.startWith(1.0)
            .map { String(format: "x%.2f", $0) }
            .share(replay: 1)
        
        // 플레이어의 재생 상태가 변하면 서브젝트에 업데이트
        input.controlStatus
            .bind(to: controlStatus)
            .disposed(by: bag)

        // 재생 버튼이 눌리면 현재의 재생 상태를 Bool로 전달
        // 재생을 할지, 말지만 담당
        let needPlaying = input.playbackTap
            // 진행률 100퍼면 재생 버튼을 눌러도 의미 없음
            .withLatestFrom(input.progress)
            .filter { $0 != 1.0 }
            .withLatestFrom(controlStatus) { _ ,status -> Bool? in
                switch status {
                case .paused:
                    return false
                case .playing:
                    return true
                default:
                    return nil
                }
            }
            .share(replay: 1)
        
//        let isPlaying =
#warning("버튼은 재생을 할지, 말지만을 담당, controlStatus의 변화에 따라서 버튼의 이미지는 바뀌여야 함, 즉 재생과 이미지 설정 로직이 독립적이여야 함")

                
        return Output(
            playerItem: playerItem,
            trackViewData: trackViewData,
            progress: progress,
            seekingPoint: seekingPoint,
            elapsedTimeText: elapsedTimeText,
            scaleFactorText: scaleFactorText,
            needPlaying: needPlaying)
    }
    
    // MARK: - Private methods
    // 분명히 더 최적화 가능할 거 같은데, 연구가 필요해 보임..
    private func makePlayerItem(_ metadataArr: [VideoClip.Metadata], _ timeRanges: [CMTimeRange], exportSize: CGSize) -> AVPlayerItem? {
        let mixComposition = AVMutableComposition()
        var instructions = [AVMutableVideoCompositionLayerInstruction]()

        
        var accumulatedTime = CMTime.zero
        
        // 각 클립을 하나의 트랙으로 합치는 로직
        for (metadata, timeRange) in zip(metadataArr, timeRanges) {
            let assetVideoTrack = metadata.assetVideoTrack
            let assetAudioTrack = metadata.assetAudioTrack
            
            
            // kCMPersistentTrackID_Invalid로 하면 알아서 고유한 트랙 id를 만들어 줌, 직접 설정하는 것도 가능
            let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            // 비디오, 오디오 트랙의 재생 시간의 범위를 등록, 트랙뷰가 처리해준 timeRange를 그대로 사용
            do {
                try videoTrack?.insertTimeRange(
                    timeRange,
                    of: assetVideoTrack,
                    at: accumulatedTime)
                
                try audioTrack?.insertTimeRange(
                    timeRange,
                    of: assetAudioTrack,
                    at: accumulatedTime)
            } catch {
                return nil
            }

            // 다음 비디오의 시작 지점은 전 비디오의 종료 시점
            accumulatedTime = CMTimeAdd(accumulatedTime, timeRange.duration)
            
            
            // instruction 배열을 만들어주기, 그리고 만드는 김에 투명도를 변경
            // 비디오의 끝부분에서는 자기 자신을 disappear해야하기 때문에 투명도 0 효과의 Instruction을 추가
            if let videoTrack {
                let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
                instruction.setOpacity(0.0, at: accumulatedTime)
                instructions.append(instruction)
            }
        }
        
        
        // 각 비디오의 사이즈를 정렬하는 로직, 아핀 배열을 변경하는 instruction을 추가
        zip(instructions, metadataArr).forEach { instruction, metadata in
            let transform = VideoHelper.shared.transformAspectFit(metadata: metadata, exportSize: exportSize)
            instruction.setTransform(transform, at: .zero)
        }
        
        
        // instruction이나 timeRange등의 변경사항을 한 데 모으고 플레이어 아이템을 리턴
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRange(start: .zero, duration: mixComposition.duration)
        mainInstruction.layerInstructions = instructions
        
        // 비디오 컴포지션 설정, 모든 변경사항을 이 친구가 받아서 아이템에 적용시켜줌
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30) // 30fps로 설정
        videoComposition.renderSize = exportSize // 출력 해상도 설정
        videoComposition.instructions = [mainInstruction]
        // HDR 효과 끄기, 너무 눈뽕임..
        videoComposition.colorPrimaries = AVVideoColorPrimaries_ITU_R_709_2
        videoComposition.colorTransferFunction = AVVideoTransferFunction_ITU_R_709_2
        videoComposition.colorYCbCrMatrix = AVVideoYCbCrMatrix_ITU_R_709_2
        
        let item = AVPlayerItem(asset: mixComposition)
        item.videoComposition = videoComposition
        
        return item
    }
    
    private func getElapsedTimeText(item: AVPlayerItem, progress: CGFloat) -> Observable<(String, String)> {
        return Observable.create { observer in
            let duration = CMTimeGetSeconds(item.duration)
            let progress = progress * duration
            // progress의 유효성 확인, 이게 유효하면 duration도 유효하다는 이야기일테니까...?
            guard !(progress.isNaN || progress.isInfinite) else { return Disposables.create() }
            
            let roundedDuration = Int(duration.rounded())
            let minuteDuration = roundedDuration.cutMinute
            let secondDuration = roundedDuration.cutSecond
            
            let roundedProgress = Int(progress.rounded())
            let minuteProgress = roundedProgress.cutMinute
            let secondProgress = roundedProgress.cutSecond
            
            let durationText = String(format: "%02d:%02d", minuteDuration, secondDuration)
            let progressText = String(format: "%02d:%02d", minuteProgress, secondProgress)
            
            let result = (progressText, durationText)
            observer.onNext(result)
            
            return Disposables.create()
        }
    }
}


