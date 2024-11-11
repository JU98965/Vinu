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
    
    private init() {}
    
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
    

}
