//
//  VideoHelper.swift
//  Vinu
//
//  Created by 신정욱 on 10/11/24.
//

import UIKit
import AVFoundation

final class VideoHelper {
    
    static let shared = VideoHelper()
    
    let composition = AVMutableComposition()
    let videoComposition = AVMutableVideoComposition()
    
    private init() {}
    
    // 분명히 더 최적화 가능할 거 같은데, 연구가 필요해 보임..
    func makePlayerItem(_ makingOptions: VideoMakingOptions) -> AVPlayerItem? {
        let metadataArr = makingOptions.metadataArr
        let timeRanges = makingOptions.trimmedTimeRanges
        let size = makingOptions.size
        let placement = makingOptions.placement
        
        var instructions = [AVMutableVideoCompositionLayerInstruction]()

        // 해당 메서드가 다시 실행 될 때 기존의 시간범위를 지우고 다시 설정
        composition.removeTimeRange(CMTimeRange(start: .zero, duration: composition.duration))
        
        // 각 클립을 하나의 트랙으로 합치는 로직
        var accumulatedTime = CMTime.zero
        for (metadata, timeRange) in zip(metadataArr, timeRanges) {
            let assetVideoTrack = metadata.assetVideoTrack
            let assetAudioTrack = metadata.assetAudioTrack
            
            
            // kCMPersistentTrackID_Invalid로 하면 알아서 고유한 트랙 id를 만들어 줌, 직접 설정하는 것도 가능
            let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            // 비디오, 오디오 트랙의 재생 시간의 범위를 등록, 트랙뷰가 처리해준 timeRange를 그대로 사용
            do {
                try videoTrack?.insertTimeRange(
                    timeRange,
                    of: assetVideoTrack,
                    at: accumulatedTime)
                
                // 오디오 트랙이 없으면, 없는대로 만들어야지 머..
                if let assetAudioTrack {
                    try audioTrack?.insertTimeRange(
                        timeRange,
                        of: assetAudioTrack,
                        at: accumulatedTime)
                }
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
            let transform = transformAspect(metadata, size, placement)
            instruction.setTransform(transform, at: .zero)
        }
        
        
        // instruction이나 timeRange등의 변경사항을 한 데 모으고 플레이어 아이템을 리턴
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRange(start: .zero, duration: composition.duration)
        mainInstruction.layerInstructions = instructions
        
        // 비디오 컴포지션 설정, 모든 변경사항을 비디오 컴포지션이 받아서 아이템에 적용시켜줌
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30) // 30fps로 설정
        videoComposition.renderSize = size.cgSize // 출력 해상도 설정
        videoComposition.instructions = [mainInstruction]
        videoComposition.allowHDR(makingOptions.isHDRAllowed) // HDR 효과 관리

        let item = AVPlayerItem(asset: composition)
        item.videoComposition = videoComposition
        
        return item
    }
    
    // 영상의 스케일과 배치를 설정한 사이즈에 맞게 변형
    private func transformAspect(_ metadata: VideoMetadata, _ size: VideoSize, _ placement: VideoPlacement) -> CGAffineTransform {
        let (naturalSize, transform, size) = (metadata.naturalSize, metadata.preferredTransform, size.cgSize)
        
        // transform의 정보를 바탕으로 이 비디오가 세로모드인지 가로모드인지 판단
        switch transform.orientation {
        case .up:
            // MARK: - Landscape(.up)
            // size정도로 스케일을 맞추려면 배율을 얼마나 조정해야 하는지 계산
            // naturalSize가 이미 가로모드 기준이기 때문에 그대로 갖다쓰면 됨
            let scaleToWidth = size.width / naturalSize.width
            let scaleToHeight = size.height / naturalSize.height
            
            let scaleFactor = {
                switch placement {
                case .aspectFit:
                    // fit하게 스케일을 적용하려면 가장 짧은 면을 기준으로 맞춰야 함
                    min(scaleToWidth, scaleToHeight)
                case .aspectFill:
                    // fill하게 스케일을 적용하려면 가장 긴 면을 기준으로 맞춰야 함
                    max(scaleToWidth, scaleToHeight)
                }
            }()

            // 배율을 적용할 아핀 변환 만들어주기
            let scaleFix = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            
            // 영상의 중심점은 좌측상단, 내보내는 영상 사이즈 높이의 절반까지 이동시킨 후, 크기 조정된 영상 높이의 절반만큼 후퇴하면 y축의 중심에 배치 가능
            // Landscape라도 세로가 길쭉한 영상이 있을 수 있어서 좌표를 x,y축 모두 잡아줘야 함
            let xFix = size.width / 2 - (naturalSize.width * scaleFactor / 2)
            let yFix = size.height / 2 - (naturalSize.height * scaleFactor / 2)

            //  위치 보정할 아핀 변환 만들기
            let centerFix = CGAffineTransform(translationX: xFix, y: yFix)
            
            // 배율 및 위치이동을 적용한 아핀 변환 만들어주기
            return transform
                .concatenating(scaleFix)
                .concatenating(centerFix)
            
        case .down:
            // MARK: - Landscape(.down)
            // 가로모드라도 이미지가 180도 돌아가 있으면 정상적으로 다시 돌려주기
            // naturalSize가 이미 가로모드 기준이기 때문에 그대로 갖다쓰면 됨
            let scaleToWidth = size.width / naturalSize.width
            let scaleToHeight = size.height / naturalSize.height
            
            let scaleFactor = {
                switch placement {
                case .aspectFit:
                    // fit하게 스케일을 적용하려면 가장 짧은 면을 기준으로 맞춰야 함
                    min(scaleToWidth, scaleToHeight)
                case .aspectFill:
                    // fill하게 스케일을 적용하려면 가장 긴 면을 기준으로 맞춰야 함
                    max(scaleToWidth, scaleToHeight)
                }
            }()

            // 배율을 적용할 아핀 변환 만들어주기
            let scaleFix = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            
            // 180도 돌리는 아핀 변환 만들기 (.pi는 180도를 의미)
            let fixUpsideDown = CGAffineTransform(rotationAngle: .pi)
            
            // 좌측 상단 모서리 기준으로 180도 돌렸으니 이제 영상의 기준점은 우측 하단
            // 내보내는 사이즈의 높이의 절반까지 이동시킨 후, 크기 조정된 영상 높이의 절반만큼 이동하면 y축의 중심에 배치 가능
            let xFix = size.width / 2 + (naturalSize.width * scaleFactor / 2)
            let yFix = size.height / 2 + (naturalSize.height * scaleFactor / 2)

            //  위치 보정할 아핀 변환 만들기
            let centerFix = CGAffineTransform(translationX: xFix, y: yFix)
            
            // 배율, 회전, 위치변환까지 적용한 아핀 변환 만들어주기
            // 기존 transform에 회전을 적용시키면 회전이 이상하게 나오는 것 같아, fixUpsideDown에 concatenating 처리
            return fixUpsideDown
                .concatenating(scaleFix)
                .concatenating(centerFix)

        case .left, .right:
            // MARK: - Portrait(.left, .right)
            // 세로로 찍었더라도 영상의 naturalSize는 가로모드 기준으로 나오기 때문에 width와 height를 서로 뒤바꿔서 계산해야함
            let scaleToWidth = size.width / naturalSize.height
            let scaleToHeight = size.height / naturalSize.width

            let scaleFactor = {
                switch placement {
                case .aspectFit:
                    // fit하게 스케일을 적용하려면 가장 짧은 면을 기준으로 맞춰야 함
                    min(scaleToWidth, scaleToHeight)
                case .aspectFill:
                    // fill하게 스케일을 적용하려면 가장 긴 면을 기준으로 맞춰야 함
                    max(scaleToWidth, scaleToHeight)
                }
            }()
            
            // 배율을 적용할 아핀 변환 만들어주기
            let scaleFix = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            
            // Portrait라도 가로가 길쭉한 영상이 있을 수 있어서 좌표를 x,y축 모두 잡아줘야 함
            let xFix = size.width / 2 - (naturalSize.height * scaleFactor / 2)
            let yFix = size.height / 2 - (naturalSize.width * scaleFactor / 2)

            let centerFix = CGAffineTransform(translationX: xFix, y: yFix)
            
            // 새로운 스케일과 배치를 적용한 아핀 변환 반환
            return transform
                .concatenating(scaleFix)
                .concatenating(centerFix)
            
        default:
            return transform
        }
    }
            
    func export() {
        // 앨범에 저장할거라 결과물은 임시디렉토리에 저장해놓고 url만 끌어다 씀
        let documentsDirectory = FileManager.default.temporaryDirectory
        let videoID = UUID().uuidString
        // outputFileType을 따로 지정해도 .mov라고 확장자는 적어줘야 함
        let videofileName = "\(videoID).mov"
        let outputURL = documentsDirectory.appendingPathComponent(videofileName)
        
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!
        exporter.outputFileType = .mov
        exporter.outputURL = outputURL
        exporter.videoComposition = videoComposition
        // Timerange를 수정한 경우 따로 exporter에 Timerange를 등록하지 않으면 에러가 발생함, 왠지는 모르겠음
        exporter.timeRange = CMTimeRange(start: .zero, duration: composition.duration)
        
        Task {
            try? await print(exporter.estimatedOutputFileLengthInBytes)

            if #available(iOS 18, *) {
                print("Run at iOS 18")
                Task {
                    for await state in exporter.states(updateInterval: 1.0) {
                        switch state {
                        case .pending:
                            print("pending")
                        case .waiting:
                            print("waiting")
                        case .exporting(progress: let progress):
                            print("exporting", progress.fractionCompleted)
                        @unknown default:
                            print("default")
                        }
                    }
                }

                await exporter.export()
            } else {
                print("Run at others")
                await exporter.export()
            }
            
            switch exporter.status {
            case .failed:
                print("Export failed \(exporter.error!)")
            case .completed:
                if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputURL.path) {
                    UISaveVideoAtPathToSavedPhotosAlbum(outputURL.path, self, nil, nil)
                    print("끝completed")
                } else {
                    print("not completed")
                }
            default:
                break
            }
        }
    }
}
