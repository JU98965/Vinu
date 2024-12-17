//
//  ConfigureVM+Concurrency.swift
//  Vinu
//
//  Created by 신정욱 on 11/10/24.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation
import Photos

extension ConfigureVM {
    func fetchVideoMetadataArr(_ phAssets: [PHAsset]) async -> Result<[VideoMetadata], ConfigureError> {
        let avAssets = await fetchAVAssets(phAssets)
        
        async let fetchedMetadataArr = fetchMetadataArr(avAssets).compactMap { $0 }
        async let fetchedImages = fetchImages(phAssets).compactMap { $0 }
        
        let (metadataArr, images) = await (fetchedMetadataArr, fetchedImages)

        if metadataArr.count == images.count {
            let result = zip(metadataArr, images).map { zipped in
                var (metadata, image) = zipped
                metadata.image = image
                return metadata
            }
            return Result.success(result)
        } else {
            return Result.failure(ConfigureError.FailToInitVideoMetadataArr("메타데이터와 이미지의 갯수가 일치하지 않음."))
        }
    }

    // MARK: - fetchAVAsset
    // PHAsset 배열을 AVAsset배열로 변환
    private func fetchAVAssets(_ phAssets: [PHAsset]) async -> [AVAsset?] {
        // fetchAVAsset을 병렬적으로 돌리기 위해서 TaskGroup사용
        return await withTaskGroup(of: (Int, AVAsset?).self, returning: [AVAsset?].self) { group in
            // phAssets 개수만큼 빈 배열 만들기
            var avAssets = [AVAsset?](repeating: nil, count: phAssets.count)

            
            // addTask로 자식 작업 만들기
            // 순서 보장은 안되고, 완료되는 거 먼저 저기 밑에 for문으로 들어감
            for (i, phAsset) in phAssets.enumerated() {
                group.addTask {
                    let avAsset = await self.fetchAVAsset(phAsset)
                    // AVAsset이 Sendable한지 모르겠으니 일단 immutable한 값을 리턴
                    return (i, avAsset)
                }
            }
            
            
            for await (i, avAsset) in group {
                // 순서를 보장해야 해서 append 안 씀
                avAssets[i] = avAsset
            }
            
            
            return avAssets
        }
    }
    
    private func fetchAVAsset(_ phAsset: PHAsset) async -> AVAsset? {
        return await withCheckedContinuation { continuation in
            
            let options = PHVideoRequestOptions()
            options.version = .current
            options.isNetworkAccessAllowed = false
            options.deliveryMode = .automatic
            
            PHImageManager.default().requestAVAsset(forVideo: phAsset, options: options) { avAsset, audioMix, info in
                continuation.resume(returning: avAsset)
            }
        }
    }
    
    // MARK: - fetchMetaData
    // AVAsset에서 필요한 메타 데이터 뽑아내기
    private func fetchMetadataArr(_ avAssets: [AVAsset?]) async -> [VideoMetadata?] {
        return await withTaskGroup(of: (Int, VideoMetadata?).self, returning: [VideoMetadata?].self) { group in
            var metadataArr = [VideoMetadata?](repeating: nil, count: avAssets.count)

            
            for (i, avAsset) in avAssets.enumerated() {
                group.addTask {
                    let metadata = await self.fetchMetaData(avAsset)
                    return (i, metadata)
                }
            }
            
            
            for await (i, metadata) in group {
                metadataArr[i] = metadata
            }
            
            
            return metadataArr
        }
    }
    
    private func fetchMetaData(_ avAsset: AVAsset?) async -> VideoMetadata? {
        guard let avAsset else { return nil }
        
        do {
            let assetVideoTrack = try await avAsset.loadTracks(withMediaType: .video).first
            let assetAudioTrack = try await avAsset.loadTracks(withMediaType: .audio).first
            let duration = try await avAsset.load(.duration)
            let naturalSize = try await assetVideoTrack?.load(.naturalSize)
            let preferredTransform = try await assetVideoTrack?.load(.preferredTransform)
            
            // 오디오 트랙이 없는 영상이 있을 수도 있어서 오디오 트랙은 nil 허용
            guard
                let assetVideoTrack,
                let naturalSize,
                let preferredTransform
            else { return nil }
            
            
            return VideoMetadata(
                asset: avAsset,
                assetVideoTrack: assetVideoTrack,
                assetAudioTrack: assetAudioTrack,
                duration: duration,
                naturalSize: naturalSize,
                preferredTransform: preferredTransform)
        } catch {
            print(error)
            return nil
        }
    }
    
    // MARK: - fetchImages
    // phAsset에서 비디오 트랙에 들어갈 프레임 이미지 추출 (일단은 썸네일 이미지 1장으로 대체)
    private func fetchImages(_ phAssets: [PHAsset]) async -> [UIImage?] {
        return await withTaskGroup(of: (Int, UIImage?).self, returning: [UIImage?].self) { group in
            var images = [UIImage?](repeating: nil, count: phAssets.count)
            
            
            for (i, phAsset) in phAssets.enumerated() {
                group.addTask {
                    let image = await self.fetchImage(phAsset)
                    return (i, image)
                }
            }
            
            
            for await (i, image) in group {
                images[i] = image
            }
            
            
            return images
        }
    }

    private func fetchImage(_ phAsset: PHAsset) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            
            // 썸네일 어떻게 가져올건지 옵션 설정
            let options = PHImageRequestOptions()
            // 아이클라우드에 있는 데이터도 가져올건지
            options.isNetworkAccessAllowed = false
            // 편집사항을 반영하는 현재 버전 가져오기
            options.version = .current
            // targetSize에 근접하도록 알아서 크기 효율적으로 조정
            options.resizeMode = .fast
            // isSynchronous가 false라면 처음엔 저화질 주고 고화질로드 끝나면 고화질 줌
            // resume이 두 번 이상 호출되면 안되기 때문에 여기서는 고퀄로 설정
            options.deliveryMode = .highQualityFormat
            // 기본값 false, true일 경우 deliveryMode는 자동으로 .highQualityFormat으로 지정됨
            options.isSynchronous = true
            
            // 옵션과 phAsset을 바탕으로 이미지 가져오기
            PHImageManager.default().requestImage(
                for: phAsset,
                targetSize: CGSize(width: 128, height: 128),
                contentMode: .aspectFill,
                options: options) { image, info in
                    continuation.resume(returning: image)
                }
        }
    }
    
    // MARK: - fetchPHAsset (코어데이터가 필요해지면 사용할 예정)
    // 로컬 식별자로 PHAsset불러오기, 동기적 메서드
    // private func fetchPHAssets(identifiers: [String]) -> [PHAsset] {
    //     var assets = [PHAsset]()
    //
    //     let options = PHFetchOptions()
    //     options.includeHiddenAssets = false
    //     options.includeAssetSourceTypes = [.typeUserLibrary]
    //
    //     // fetchAssets이 순서를 기억못함, Set으로 넘겨주고 SortDescriptor로 정렬하는 방식인 듯
    //     // 그러니까 차라리 하나씩 넣어주는 쪽이 나을 듯
    //     identifiers.forEach { id in
    //         let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: options)
    //         fetchResult.enumerateObjects { asset, _, _ in assets.append(asset) }
    //     }
    //
    //     return assets
    // }
    
    // MARK: - fetchImages (1초 단위로 프레임 이미지 불러오기, 필요하면 사용할 예정)
    // private func fetchImagesArr(_ avAssets: [AVAsset?]) async -> [VideoClip.FrameImages?] {
    //     var imagesArr = [VideoClip.FrameImages?](repeating: nil, count: avAssets.count)
    //
    //     await withTaskGroup(of: (Int, VideoClip.FrameImages?).self) { group in
    //         for (i, avAsset) in avAssets.enumerated() {
    //             group.addTask {
    //                 let images = await self.fetchImages(avAsset)
    //                 return (i, images)
    //             }
    //         }
    //
    //         for await (i, images) in group {
    //             imagesArr[i] = images
    //         }
    //     }
    //
    //     return imagesArr
    // }
    
    // 가져온 메타데이터를 바탕으로 클립 셀에 들어갈 프레임 이미지 가져오기
    // private func fetchImages(_ avAsset: AVAsset?) async -> VideoClip.FrameImages? {
    //     var images = VideoClip.FrameImages()
    //
    //     guard
    //         let avAsset,
    //         // 전체 재생시간에서 소수점을 버린 값으로 시간 배열을 만들기
    //         let duration = try? await avAsset.load(.duration).seconds
    //     else { return nil }
    //
    //     // 1초에 1장 단위로 가져오도록 시간 배열 만들어주기
    //     let cmTimes = (0...Int(duration)).map { CMTime(value: CMTimeValue($0 * 1), timescale: 1) }
    //
    //     let imageGenerator = AVAssetImageGenerator(asset: avAsset)
    //     // 이미지 방향 유지시켜주는 옵션 (CGImage는 방향을 기억하지 못함)
    //     imageGenerator.appliesPreferredTrackTransform = true
    //     // 과도한 메모리 사용을 방지하기 위해 이미지 사이즈 조절
    //     imageGenerator.maximumSize = CGSize(width: 180, height: 180)
    //
    //     // 이미지 생성을 위한 AsyncSequence 반환
    //     let results = imageGenerator.images(for: cmTimes)
    //
    //     for await result in results {
    //         guard let image = try? result.image else { return nil }
    //         images.append(image)
    //     }
    //
    //     return images
    // }
}
