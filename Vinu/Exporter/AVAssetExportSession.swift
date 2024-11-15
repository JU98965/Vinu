//
//  AVAssetExportSession.swift
//  Vinu
//
//  Created by 신정욱 on 11/15/24.
//

import AVFoundation
import UIKit

extension AVAssetExportSession {
    convenience init?(_ configuration: ExporterConfiguration) {
        // 앨범에 저장할거라 결과물은 임시디렉토리에 저장해놓고 url만 끌어다 씀
        let documentsDirectory = FileManager.default.temporaryDirectory
        // outputFileType을 따로 지정해도 .mov라고 확장자는 적어줘야 함
        let videofileName = "\(configuration.title).mov"
        let outputURL = documentsDirectory.appendingPathComponent(videofileName)
        
        // outputURL이 유효하지 않다면 생성 실패 처리
        guard UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputURL.path) else { return nil }
        
        self.init(asset: configuration.composition, presetName: AVAssetExportPresetHighestQuality)
        self.outputFileType = .mov
        self.outputURL = outputURL
        self.videoComposition = configuration.videoComposition
        // Timerange를 수정한 경우 따로 exporter에 Timerange를 등록하지 않으면 에러가 발생함, 왠지는 모르겠음
        self.timeRange = CMTimeRange(start: .zero, duration: configuration.composition.duration)
    }
}

