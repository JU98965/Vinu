//
//  LoadingVM.swift
//  Vinu
//
//  Created by 신정욱 on 9/26/24.
//

import Foundation
import RxSwift
import RxCocoa
import AVFoundation
import Photos

//fileprivate final class LoadingVMOld {
//    typealias Metadata = (asset: AVAsset, track: AVAssetTrack, duration: CMTime, frameRate: Float, naturalSize: CGSize, preferredTransform: CGAffineTransform)
//    typealias Images = [CGImage]
//    
//    private let bag = DisposeBag()
//    private let projectData: ProjectData
//    
//    struct Output {
//        let presentEditorVC: Observable<[VideoClip]>
//    }
//    
//    init(_ projectData: ProjectData) {
//        self.projectData = projectData
//    }
//    
//    func transform() -> Output {
//        // 프로젝트 데이터에서 PHAsset을 추출 후, AVAsset으로 변환
//        let avAssets = Observable
//            .just(projectData)
//            .map { [weak self] projectData in
//                let identifiers = projectData.items.map { $0.assetID }
//                return self?.fetchPHAssets(identifiers: identifiers) ?? []
//            }
//            .flatMap { [weak self] in
//                self?.fetchAVAssets($0) ?? Observable<[AVAsset?]>.just([])
//            }
//            .share(replay: 1)
//
//        // 에디터 뷰에 쓸 메타 데이터 튜플 가져오기
//        let editorDataWithoutImagesArr = avAssets
//            .flatMap { [weak self] in self?.fetchMetadata($0) ?? Observable<[Metadata]>.just([]) }
//            .share(replay: 1)
//
//        // 메타 데이터 튜플로 에디터 뷰에 쓸 프레임 이미지 가져오기
//        let frameImagesArr = editorDataWithoutImagesArr
//            .flatMapLatest { [weak self] in self?.fetchFrameImages($0) ?? Observable<[[CGImage]]>.just([]) }
//            .share(replay: 1)
//
//        // 메타 데이터와 프레임 이미지 합쳐서 비디오 클립으로 만들기
//        let videoClips = Observable
//            .zip(editorDataWithoutImagesArr, frameImagesArr)
//            .map { zipped in
//                let zipped = zip(zipped.0, zipped.1)
//                    .map {
//                        VideoClip(asset: $0.0.asset, assetTrack: $0.0.track, duration: $0.0.duration, frameRate: $0.0.frameRate, frameImages: $0.1, naturalSize: $0.0.naturalSize, preferredTransform: $0.0.preferredTransform)
//                    }
//
//                return zipped
//            }
//            .observe(on: MainScheduler.instance)
//            .share(replay: 1)
//
//        return Output(presentEditorVC: videoClips)
//    }
//
//    // 로컬 식별자로 PHAsset불러오기
//    private func fetchPHAssets(identifiers: [String]) -> [PHAsset] {
//        var assets = [PHAsset]()
//
//        let options = PHFetchOptions()
//        options.includeHiddenAssets = false
//        options.includeAssetSourceTypes = [.typeUserLibrary]
//
//        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: options)
//        fetchResult.enumerateObjects { asset, _, _ in assets.append(asset) }
//
//        return assets
//    }
//
//    // PHAsset 배열을 AVAsset배열로 변환
//    private func fetchAVAssets(_ phAssets: [PHAsset]) -> Observable<[AVAsset?]> {
//        return Observable.create { observer in
//            var avAssets = [AVAsset?]()
//            let group = DispatchGroup()
//
//            phAssets.forEach { phAsset in
//                guard phAsset.mediaType == .video else { return }
//                group.enter()
//
//                let options = PHVideoRequestOptions()
//                options.version = .current
//                options.isNetworkAccessAllowed = false
//                options.deliveryMode = .automatic
//
//                PHImageManager.default().requestAVAsset(forVideo: phAsset, options: options) { avAsset, audioMix, info in
//                    avAssets.append(avAsset)
//                    group.leave()
//                }
//            }
//
//            group.notify(queue: .main) {
//                observer.onNext(avAssets)
//                observer.onCompleted()
//            }
//
//            return Disposables.create()
//        }
//    }
//
//    // AVAsset에서 필요한 메타 데이터 뽑아내기
//    private func fetchMetadata(_ avAssets: [AVAsset?]) -> Observable<[Metadata]> {
//        return Observable.create { observer in
//            Task {
//                var metadataArr = [Metadata?]()
//
//                for asset in avAssets {
//                    do {
//                        // 의도적인 강제 언래핑, 하나라도 언래핑 실패할 경우에는 AVAsset이 유효하지 않은것으로 간주
//                        let duration = try await asset!.load(.duration)
//                        let track = try await asset!.loadTracks(withMediaType: .video).first!
//                        let frameRate = try await track.load(.nominalFrameRate)
//                        let naturalSize = try await track.load(.naturalSize)
//                        let preferredTransform = try await track.load(.preferredTransform)
//                        metadataArr.append((
//                            asset: asset!,
//                            track: track,
//                            duration: duration,
//                            frameRate: frameRate,
//                            naturalSize: naturalSize,
//                            preferredTransform: preferredTransform))
//                    } catch {
//                        print("AVAsset이 유효하지 않음")
//                        metadataArr.append(nil)
//                    }
//                }
//
//                observer.onNext(metadataArr.compactMap { $0 })
//                observer.onCompleted()
//            }
//
//            return Disposables.create()
//        }
//    }
//
//    // 가져온 메타데이터를 바탕으로 클립 셀에 들어갈 프레임 이미지 가져오기
//    private func fetchFrameImages(_ metadataArr: [Metadata]) -> Observable<[[CGImage]]> {
//        return Observable.create { observer in
//            // 메타 데이터 수만큼 빈 배열 만들어주기
//            var imagesArr = metadataArr.map { _ in [CGImage]() }
//            let serialQueue = DispatchQueue(label: "imagesArr")
//            let group = DispatchGroup()
//
//            metadataArr.enumerated().forEach { i, metadata in
//                group.enter() // 디스패치 그룹 진입
//
//                // 전체 재생시간에서 소수점을 버린 값으로 시간 배열을 만들기
//                let duration = Int(metadata.duration.seconds)
//                // 1초에 1장 단위로 가져오도록 시간 배열 만들어주기
//                let cmTimes = (0...duration).map { CMTime(value: CMTimeValue($0 * 1), timescale: 1) }
//                // CMTime을 NSValue로 변환
//                let times = cmTimes.map { NSValue(time: $0) }
//
//                let imageGenerator = AVAssetImageGenerator(asset: metadata.asset)
//                // 이미지 방향 유지시켜주는 옵션 (CGImage는 방향을 기억하지 못함)
//                imageGenerator.appliesPreferredTrackTransform = true
//                // 과도한 메모리 사용을 방지하기 위해 이미지 사이즈 조절
//                imageGenerator.maximumSize = CGSize(width: 180, height: 180)
//
//                // 비동기적으로 이미지 생성
//                imageGenerator.generateCGImagesAsynchronously(forTimes: times, completionHandler: { _, cgImage, _, _, _ in
//                    guard let cgImage else { return }
//                    serialQueue.async {
//                        // 레이스 컨디션 방지를 위해 직렬 큐에서 이미지 추가
//                        imagesArr[i].append(cgImage)
//
//                        if imagesArr[i].count == cmTimes.count {
//                            // 이미지 모두 가져왔으면 디스패치 그룹 나가기
//                            group.leave()
//                        }
//                    }
//                })
//            }
//
//            group.notify(queue: .main) {
//                observer.onNext(imagesArr)
//                observer.onCompleted()
//            }
//
//
//            return Disposables.create()
//        }
//    }
//}
