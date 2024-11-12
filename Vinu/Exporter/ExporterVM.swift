//
//  ExporterVM.swift
//  Vinu
//
//  Created by 신정욱 on 11/12/24.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa

final class ExporterVM {
    
    struct Input {
        let exportButtonTap: Observable<Void>
    }
    
    struct Output {

    }
    
    private let bag = DisposeBag()

    func transform(input: Input) -> Output {
        input.exportButtonTap
            .bind(onNext: { VideoHelper.shared.export() })
            .disposed(by: bag)
        
        
        return Output()
    }
    
    func export(asset: AVAsset) {
        // 앨범에 저장할거라 결과물은 임시디렉토리에 저장해놓고 url만 끌어다 씀
        let documentsDirectory = FileManager.default.temporaryDirectory
        let videoID = UUID().uuidString
        // outputFileType을 따로 지정해도 .mov라고 확장자는 적어줘야 함
        let videofileName = "\(videoID).mov"
        let outputURL = documentsDirectory.appendingPathComponent(videofileName)
        
        let exporter = AVAssetExportSession(asset: VideoHelper.shared.composition, presetName: AVAssetExportPresetHighestQuality)!
        exporter.outputFileType = .mov
        exporter.outputURL = outputURL
        exporter.videoComposition = VideoHelper.shared.videoComposition
        // Timerange를 수정한 경우 따로 exporter에 Timerange를 등록하지 않으면 에러가 발생함, 왠지는 모르겠음
        exporter.timeRange = CMTimeRange(start: .zero, duration: VideoHelper.shared.composition.duration)
        
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
