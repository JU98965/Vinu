//
//  LoadingVM+Concurrency.swift
//  Vinu
//
//  Created by 신정욱 on 10/10/24.
//

import Foundation
import RxSwift
import RxCocoa
import AVFoundation
import Photos

extension LoadingVM {
    func fetchVideoClips(_ phAssets: [PHAsset]) async -> Result<[VideoClip], LoadingError> {
        let avAssets = await fetchAVAssets(phAssets)
        
        async let metadataArr = fetchMetadataArr(avAssets).compactMap { $0 }
        async let imagesArr = fetchImagesArr(avAssets).compactMap { $0 }
        
        if await metadataArr.count == imagesArr.count {
            let result = await zip(metadataArr, imagesArr).map { (metadata, images) in
                VideoClip(metadata: metadata, frameImages: images)
            }
            return Result.success(result)
        } else {
            return Result.failure(LoadingError.FailToInitVideoClips("메타데이터와 이미지의 갯수가 일치하지 않음."))
        }
    }

    // MARK: - fetchAVAsset
    // PHAsset 배열을 AVAsset배열로 변환
    private func fetchAVAssets(_ phAssets: [PHAsset]) async -> [AVAsset?] {
        // phAssets 개수만큼 빈 배열 만들기
        var avAssets = [AVAsset?](repeating: nil, count: phAssets.count)
        
        // 한번에 for를 병렬적으로 돌리기 위해서 TaskGroup사용
        // AVAsset이 Sendable한지 모르겠으니 일단 immutable한 값을 리턴
        await withTaskGroup(of: (Int, AVAsset?).self) { group in
            for (i, phAsset) in phAssets.enumerated() {
                group.addTask {
                    let avAsset = await self.fetchAVAsset(phAsset)
                    return (i, avAsset)
                }
            }
            
            // withTaskGroup은 완료 순서대로 담긴다고 함
            // 때문에 인덱스로 배열의 제 자리에 넣어주기
            for await (i, avAsset) in group {
                avAssets[i] = avAsset
            }
        }
        
        return avAssets
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
    private func fetchMetadataArr(_ avAssets: [AVAsset?]) async -> [VideoClip.Metadata?] {
        var metadataArr = [VideoClip.Metadata?](repeating: nil, count: avAssets.count)
        
        await withTaskGroup(of: (Int, VideoClip.Metadata?).self) { group in
            for (i, avAsset) in avAssets.enumerated() {
                group.addTask {
                    let metadata = await self.fetchMetaData(avAsset)
                    return (i, metadata)
                }
            }
            
            for await (i, metadata) in group {
                metadataArr[i] = metadata
            }
        }
        
        return metadataArr
    }
    
    private func fetchMetaData(_ avAsset: AVAsset?) async -> VideoClip.Metadata? {
        guard
            let avAsset,
            let assetVideoTrack = try? await avAsset.loadTracks(withMediaType: .video).first,
            let assetAudioTrack = try? await avAsset.loadTracks(withMediaType: .audio).first,
            let duration = try? await avAsset.load(.duration),
            let naturalSize = try? await assetVideoTrack.load(.naturalSize),
            let preferredTransform = try? await assetVideoTrack.load(.preferredTransform)
        else { return nil }
            
        return VideoClip.Metadata(
            asset: avAsset,
            assetVideoTrack: assetVideoTrack,
            assetAudioTrack: assetAudioTrack,
            duration: duration,
            naturalSize: naturalSize,
            preferredTransform: preferredTransform)
    }
    
    // MARK: - fetchImages
    private func fetchImagesArr(_ avAssets: [AVAsset?]) async -> [VideoClip.FrameImages?] {
        var imagesArr = [VideoClip.FrameImages?](repeating: nil, count: avAssets.count)
        
        await withTaskGroup(of: (Int, VideoClip.FrameImages?).self) { group in
            for (i, avAsset) in avAssets.enumerated() {
                group.addTask {
                    let images = await self.fetchImages(avAsset)
                    return (i, images)
                }
            }
            
            for await (i, images) in group {
                imagesArr[i] = images
            }
        }
        
        return imagesArr
    }
    
    // 가져온 메타데이터를 바탕으로 클립 셀에 들어갈 프레임 이미지 가져오기
    private func fetchImages(_ avAsset: AVAsset?) async -> VideoClip.FrameImages? {
        var images = VideoClip.FrameImages()
        
        guard
            let avAsset,
            // 전체 재생시간에서 소수점을 버린 값으로 시간 배열을 만들기
            let duration = try? await avAsset.load(.duration).seconds
        else { return nil }
        
        // 1초에 1장 단위로 가져오도록 시간 배열 만들어주기
        let cmTimes = (0...Int(duration)).map { CMTime(value: CMTimeValue($0 * 1), timescale: 1) }
        
        let imageGenerator = AVAssetImageGenerator(asset: avAsset)
        // 이미지 방향 유지시켜주는 옵션 (CGImage는 방향을 기억하지 못함)
        imageGenerator.appliesPreferredTrackTransform = true
        // 과도한 메모리 사용을 방지하기 위해 이미지 사이즈 조절
        imageGenerator.maximumSize = CGSize(width: 180, height: 180)
        
        // 이미지 생성을 위한 AsyncSequence 반환
        let results = imageGenerator.images(for: cmTimes)
        
        for await result in results {
            guard let image = try? result.image else { return nil }
            images.append(image)
        }
        
        return images
    }
    
    // MARK: - fetchPHAsset (코어데이터가 필요해지면 사용할 예정)
    // 로컬 식별자로 PHAsset불러오기, 동기적 메서드
    /* private func fetchPHAssets(identifiers: [String]) -> [PHAsset] {
        var assets = [PHAsset]()
        
        let options = PHFetchOptions()
        options.includeHiddenAssets = false
        options.includeAssetSourceTypes = [.typeUserLibrary]
        
        // fetchAssets이 순서를 기억못함, Set으로 넘겨주고 SortDescriptor로 정렬하는 방식인 듯
        // 그러니까 차라리 하나씩 넣어주는 쪽이 나을 듯
        identifiers.forEach { id in
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: options)
            fetchResult.enumerateObjects { asset, _, _ in assets.append(asset) }
        }
        
        return assets
    } */
}
