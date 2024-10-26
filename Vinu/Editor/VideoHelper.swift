//
//  VideoHelper.swift
//  Vinu
//
//  Created by 신정욱 on 10/11/24.
//

import UIKit
import AVFoundation

final class VideoHelper {
    let metadataArr: [VideoClip.Metadata]
    let exportSize: CGSize
    
    let mixComposition = AVMutableComposition()
    var instructions = [AVMutableVideoCompositionLayerInstruction]()
    
    init(metadataArr: [VideoClip.Metadata], exportSize: CGSize) throws {
        self.metadataArr = metadataArr
        self.exportSize = exportSize
        try prepare()
        setInstruction()
    }
    
    private func prepare() throws {
        var timeRange = CMTime.zero
        
        for metadata in metadataArr {
            let assetVideoTrack = metadata.assetVideoTrack
            let assetAudioTrack = metadata.assetAudioTrack
            let duration = metadata.duration
            
            
            // kCMPersistentTrackID_Invalid로 하면 알아서 고유한 트랙 id를 만들어 줌, 직접 설정하는 것도 가능
            let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            
            try videoTrack?.insertTimeRange(
                CMTimeRange(start: .zero, duration: duration),
                of: assetVideoTrack,
                at: timeRange)
            
            try audioTrack?.insertTimeRange(
                CMTimeRange(start: .zero, duration: duration),
                of: assetAudioTrack,
                at: timeRange)

            
            timeRange = CMTimeAdd(timeRange, duration)
            
            
            // 영상의 끝부분에서는 자기 자신을 숨겨야 하기 때문에 영상 끝부분의 timeRange를 사용함
            if let videoTrack {
                let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
                instruction.setOpacity(0.0, at: timeRange)
                instructions.append(instruction)
            }
        }
    }
    
    private func setInstruction() {
        zip(instructions, metadataArr).forEach { instruction, metadata in
            instruction.setTransform(transformAspectFit(metadata: metadata), at: .zero)
        }
    }
    
    func makePlayerItem() -> AVPlayerItem {
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRange(start: .zero, duration: mixComposition.duration)
        mainInstruction.layerInstructions = instructions
        
        // 기본적인 비디오 컴포지션 설정
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30) // 30fps로 설정
        videoComposition.renderSize = exportSize // 출력 해상도 설정
        videoComposition.instructions = [mainInstruction]
        
        let item = AVPlayerItem(asset: mixComposition)
        item.videoComposition = videoComposition
        
        return item
    }
    
    // 일단은 세로가 긴 영상을 만들 경우에 한해서 유효한 메서드
    func transformAspectFit(metadata: VideoClip.Metadata) -> CGAffineTransform {
        // 트랙에서 필요한 요소 뽑아오기
        let (naturalSize, transform) = (metadata.naturalSize, metadata.preferredTransform)
        
        
        // transform의 정보를 바탕으로 이 비디오가 세로모드인지 가로모드인지 판단
        let assetInfo = orientationFromTransform(transform)
        
        
        // 세로모드, 가로모드인지에 따라서 배율 계산이 달라질 수 있으니 if문으로 분기처리
        if assetInfo.isPortrait {
            // MARK: - Portrait
            
            // exportSize정도로 스케일을 맞추려면 배율을 얼마나 조정해야 하는지 계산
            // 세로로 찍었더라도 영상의 naturalSize는 가로모드 기준으로 나오기 때문에 width와 height를 서로 뒤바꿔서 계산해야함
            let scaleToFitRatio = exportSize.width / naturalSize.height
            // 배율을 적용할 아핀 변환 만들어주기
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            
            
            // 새로운 배율을 적용한 아핀변환 만들어주기
            let concat = transform
                .concatenating(scaleFactor)
            
            
            return concat
        } else {
            // MARK: - Landscape
            
            // exportSize정도로 스케일을 맞추려면 배율을 얼마나 조정해야 하는지 계산
            // naturalSize가 이미 가로모드 기준이기 때문에 그대로 갖다쓰면 됨
            let scaleToFitRatio = exportSize.width / naturalSize.width
            // 배율을 적용할 아핀 변환 만들어주기
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            
            
            // 영상의 중심점은 좌측상단
            // 내보내는 영상 사이즈 높이의 절반까지 이동시킨 후, 크기 조정된 영상 높이의 절반만큼 후퇴하면 y축의 중심에 배치 가능
            let yFix = exportSize.height / 2 - (naturalSize.height * scaleToFitRatio / 2)
            //  위치 보정할 아핀 변환 만들기
            let centerFix = CGAffineTransform(translationX: 0, y: yFix)
            
            
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
    
    func orientationFromTransform(_ transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
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
    

}



//func makeMainComposition() async -> AVMutableVideoComposition? {
//    let mainInstruction = AVMutableVideoCompositionInstruction()
//    mainInstruction.timeRange = CMTimeRange(start: .zero, duration: mixComposition.duration)
//    mainInstruction.layerInstructions = instructions
//    
//    
//    guard let filter = CIFilter(name: "CIGaussianBlur") else { return nil }
//    
//    
//    // 기본적인 비디오 컴포지션 설정
//    let videoComposition = try? await AVMutableVideoComposition.videoComposition(with: mixComposition) { request in
//        // Clamp to avoid blurring transparent pixels at the image edges.
//        let source = request.sourceImage.clampedToExtent()
//        filter.setValue(source, forKey: kCIInputImageKey)
//                
//        // Vary filter parameters based on the video timing.
//        let seconds = CMTimeGetSeconds(request.compositionTime)
//        filter.setValue(seconds * 10.0, forKey: kCIInputRadiusKey)
//                
//        // Crop the blurred output to the bounds of the original image.
//        if let output = filter.outputImage?.cropped(to: request.sourceImage.extent) {
//            request.finish(with: output, context: nil)
//        } else {
//            
//        }
//    }
//    
//    videoComposition?.frameDuration = CMTime(value: 1, timescale: 30) // 30fps로 설정
//    videoComposition?.renderSize = exportSize // 출력 해상도 설정
//
//    return videoComposition
//}

//func export() {
//    let mainInstruction = AVMutableVideoCompositionInstruction()
//    mainInstruction.timeRange = CMTimeRange(start: .zero, duration: mixComposition.duration)
//    mainInstruction.layerInstructions = instructions
//    
//    // 기본적인 비디오 컴포지션 설정
//    let videoComposition = AVMutableVideoComposition()
//    videoComposition.frameDuration = CMTime(value: 1, timescale: 30) // 30fps로 설정
//    videoComposition.renderSize = exportSize // 출력 해상도 설정
//    videoComposition.instructions = [mainInstruction]
//    
//    
//    // 11
//    let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//    let url = documentDirectory.appendingPathComponent("mergeVideo.mov")
//
//    // 12
//    guard let exporter = AVAssetExportSession(
//        asset: mixComposition,
//        presetName: AVAssetExportPresetHighestQuality)
//    else { return }
//    exporter.outputURL = url
//    exporter.outputFileType = .mov
//    exporter.shouldOptimizeForNetworkUse = true
//    exporter.videoComposition = videoComposition
//
//    // 13
//    exporter.exportAsynchronously {
//        if exporter.status == .completed {
//            print("성공")
//        } else {
//            print("실패")
//        }
//    }
//}
