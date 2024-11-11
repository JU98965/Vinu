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
    func makePlayerItem(_ metadataArr: [VideoClip.Metadata], _ timeRanges: [CMTimeRange], exportSize: CGSize, placement: ConfigureData.VideoPlacement) -> AVPlayerItem? {
//        let mixComposition = AVMutableComposition()        
        var instructions = [AVMutableVideoCompositionLayerInstruction]()


        composition.removeTimeRange(CMTimeRange(start: .zero, duration: composition.duration))
        
        var accumulatedTime = CMTime.zero
        
        // 각 클립을 하나의 트랙으로 합치는 로직
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
            let transform = transformAspectFit(metadata: metadata, exportSize: exportSize, placement: placement)
            instruction.setTransform(transform, at: .zero)
        }
        
        
        // instruction이나 timeRange등의 변경사항을 한 데 모으고 플레이어 아이템을 리턴
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRange(start: .zero, duration: composition.duration)
        mainInstruction.layerInstructions = instructions
        
        // 비디오 컴포지션 설정, 모든 변경사항을 이 친구가 받아서 아이템에 적용시켜줌
//        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30) // 30fps로 설정
        videoComposition.renderSize = exportSize // 출력 해상도 설정
        videoComposition.instructions = [mainInstruction]
        // HDR 효과 끄기, 너무 눈뽕임..
        videoComposition.colorPrimaries = AVVideoColorPrimaries_ITU_R_709_2
        videoComposition.colorTransferFunction = AVVideoTransferFunction_ITU_R_709_2
        videoComposition.colorYCbCrMatrix = AVVideoYCbCrMatrix_ITU_R_709_2

        let item = AVPlayerItem(asset: composition)
        item.videoComposition = videoComposition
        
        return item
    }
    
    // 일단은 세로가 긴 영상을 만들 경우에 한해서 유효한 메서드
    func transformAspectFit(metadata: VideoClip.Metadata, exportSize: CGSize, placement: ConfigureData.VideoPlacement) -> CGAffineTransform {
        // 트랙에서 필요한 요소 뽑아오기
        let (naturalSize, transform) = (metadata.naturalSize, metadata.preferredTransform)
        
        
        // transform의 정보를 바탕으로 이 비디오가 세로모드인지 가로모드인지 판단
        let assetInfo = orientationFromTransform(transform)
        
        
        // 세로모드, 가로모드인지에 따라서 배율 계산이 달라질 수 있으니 if문으로 분기처리
        if assetInfo.isPortrait {
            // MARK: - Portrait
            
            // exportSize정도로 스케일을 맞추려면 배율을 얼마나 조정해야 하는지 계산
            // 세로로 찍었더라도 영상의 naturalSize는 가로모드 기준으로 나오기 때문에 width와 height를 서로 뒤바꿔서 계산해야함
            let scaleToWidth = exportSize.width / naturalSize.height
            let scaleToHeight = exportSize.height / naturalSize.width
            
            // fit하게 배율을 적용하려면 가장 짧은 면을 기준으로 맞춰야 함
            let scaleToFitRatio = {
                switch placement {
                case .aspectFit:
                    min(scaleToWidth, scaleToHeight)
                case .aspectFill:
                    max(scaleToWidth, scaleToHeight)
                }
            }()
            
            // 배율을 적용할 아핀 변환 만들어주기
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            
            // Portrait라도 가로가 길쭉한 영상이 있을 수 있어서 좌표를 x,y축 모두 잡아줘야 함
            let xFix = exportSize.width / 2 - (naturalSize.height * scaleToFitRatio / 2)
            let yFix = exportSize.height / 2 - (naturalSize.width * scaleToFitRatio / 2)

            let centerFix = CGAffineTransform(translationX: xFix, y: yFix)
            
            // 새로운 배율을 적용한 아핀변환 만들어주기
            let concat = transform
                .concatenating(scaleFactor)
                .concatenating(centerFix)
            
            
            return concat
        } else {
            // MARK: - Landscape
            
            // exportSize정도로 스케일을 맞추려면 배율을 얼마나 조정해야 하는지 계산
            // naturalSize가 이미 가로모드 기준이기 때문에 그대로 갖다쓰면 됨
            let scaleToWidth = exportSize.width / naturalSize.width
            let scaleToHeight = exportSize.height / naturalSize.height
            
            // fit하게 배율을 적용하려면 가장 짧은 면을 기준으로 맞춰야 함
            let scaleToFitRatio = {
                switch placement {
                case .aspectFit:
                    min(scaleToWidth, scaleToHeight)
                case .aspectFill:
                    max(scaleToWidth, scaleToHeight)
                }
            }()
            
            // 배율을 적용할 아핀 변환 만들어주기
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            
            
            // 영상의 중심점은 좌측상단
            // 내보내는 영상 사이즈 높이의 절반까지 이동시킨 후, 크기 조정된 영상 높이의 절반만큼 후퇴하면 y축의 중심에 배치 가능
            // Landscape라도 세로가 길쭉한 영상이 있을 수 있어서 좌표를 x,y축 모두 잡아줘야 함
            let xFix = exportSize.width / 2 - (naturalSize.width * scaleToFitRatio / 2)
            let yFix = exportSize.height / 2 - (naturalSize.height * scaleToFitRatio / 2)

            //  위치 보정할 아핀 변환 만들기
            let centerFix = CGAffineTransform(translationX: xFix, y: yFix)
            
            
            // 배율 및 위치이동을 적용한 아핀 변환 만들어주기
            var concat = transform
                .concatenating(scaleFactor)
                .concatenating(centerFix)
            
            
            // 가로모드라도 이미지가 180도 돌아가 있으면 정상적으로 다시 돌려주기
            if assetInfo.orientation == .down {
                // 180도 돌리는 아핀 변환 만들기 (.pi는 180도를 의미)
                let fixUpsideDown = CGAffineTransform(rotationAngle: .pi)
                
                
                // 좌측 상단 모서리 기준으로 180도 돌렸으니 이제 영상의 기준점은 우측 하단
                // 내보내는 사이즈의 높이의 절반까지 이동시킨 후, 크기 조정된 영상 높이의 절반만큼 이동하면 y축의 중심에 배치 가능
                let yFix = exportSize.height / 2 + (naturalSize.height * scaleToFitRatio / 2)
                // 위치 보정할 아핀 변환 만들기, 영상의 기준점은 우측 하단이니 x축을 크기 조정된 영상 넓이만큼 더 이동시켜야 함
                let centerFix = CGAffineTransform(translationX: naturalSize.width * scaleToFitRatio, y: yFix)
                
                
                // 배율, 회전, 위치변환까지 적용한 아핀 변환 만들어주기
                // 왠지 모르겠으나 기존 transform에 회전을 적용시키면 회전이 이상하게 나오는 것 같다.
                concat = fixUpsideDown
                    .concatenating(scaleFactor)
                    .concatenating(centerFix)
            }
            
            
            return concat
        }
    }
    
    private func orientationFromTransform(_ transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        let tfA = transform.a
        let tfB = transform.b
        let tfC = transform.c
        let tfD = transform.d
        
        if tfA == 0 && tfB == 1.0 && tfC == -1.0 && tfD == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if tfA == 0 && tfB == -1.0 && tfC == 1.0 && tfD == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if tfA == 1.0 && tfB == 0 && tfC == 0 && tfD == 1.0 {
            assetOrientation = .up
        } else if tfA == -1.0 && tfB == 0 && tfC == 0 && tfD == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }
    
//    func export() {
//        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .long
//        dateFormatter.timeStyle = .short
//        let date = dateFormatter.string(from: Date())
//        let url = documentDirectory.appendingPathComponent("mergeVideo-\(date).mov")
//        
//        // 12 합쳐진 비디오를 render하고 export 해야 한다. 먼저 AVAssetExportSession을 만들어
//        //export 설정과 함께 content 을 transcode 한다. 이전에 AVMutableVideoComposition을 설정해놨기 때문에 exporter 에 assign만 하면 된다.
//        guard let exporter = AVAssetExportSession(
//            asset: composition,
//            presetName: AVAssetExportPresetHighestQuality)
//        else { return }
//        exporter.outputURL = url
//        exporter.outputFileType = AVFileType.mov
//        exporter.shouldOptimizeForNetworkUse = true
//        exporter.videoComposition = videoComposition
//
//        // 13 export session을 초기화 한 뒤 exportAsynchrously()를 통해 export 작업을 시작할 수 있다.
//        // 비동기적으로 동작하기 때문에 함수는 바로 리턴한다. completion handler를 통해 성공/실패를 전닫ㄹ한다.
//        exporter.exportAsynchronously {}
//    }
    
    func export() {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let videoID = UUID().uuidString
        let videofileName = "\(videoID).mov"
        
        let outputURL = documentsDirectory.appendingPathComponent(videofileName)
        
        if FileManager.default.fileExists(atPath: outputURL.path) {
            do {
                try FileManager.default.removeItem(at: outputURL)
            }
            catch {}
        }
        
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!
        exporter.outputFileType = .mov
        exporter.outputURL = outputURL
        exporter.videoComposition = videoComposition
        // Timerange를 수정한 경우 따로 exporter에 Timerange를 등록하지 않으면 에러가 발생함, 왠지는 모르겠음
        exporter.timeRange = CMTimeRange(start: .zero, duration: composition.duration)
        
        exporter.exportAsynchronously{
            switch exporter.status {
            case .failed:
                print("Export failed \(exporter.error!)")
            case .completed:
//                UISaveVideoAtPathToSavedPhotosAlbum(outputURL.path, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
                print("completed")
            default:
                break
            }
        }
    }
}
