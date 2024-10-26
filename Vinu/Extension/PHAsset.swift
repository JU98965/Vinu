//
//  PHAsset.swift
//  Vinu
//
//  Created by 신정욱 on 10/1/24.
//


import UIKit
import Photos

extension PHAsset {
    func fetchURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)) {
        guard self.mediaType == .video else { return }
        
        let options = PHVideoRequestOptions()
        options.version = .current
        
        PHImageManager.default().requestAVAsset(
            forVideo: self,
            options: options,
            resultHandler: { asset, audioMix, info in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
    }
    
    func fetchImage(completionHandler : @escaping ((_ responseImage : UIImage?) -> Void)) {
        guard self.mediaType == .video else { return }
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = false
        options.version = .current // 편집사항을 반영하는 현재 버전 가져오기
        options.resizeMode = .fast // targetSize에 근접하도록 알아서 크기 효율적으로 조정
        options.deliveryMode = .opportunistic // isSynchronous가 false라면 처음엔 저화질 주고 고화질로드 끝나면 고화질 줌
        options.isSynchronous = false // 기본값 false
        
        PHImageManager.default().requestImage(
            for: self,
            targetSize: CGSize(width: 128, height: 128),
            contentMode: .aspectFill,
            options: options) { image, info in
                DispatchQueue.main.async {
                    if let image {
                        completionHandler(image)
                    } else {
                        completionHandler(nil)
                    }
                }
            }
    }
    
    func fetchAVAsset(completionHandler : @escaping ((_ responseURL : AVAsset?) -> Void)) {
        guard self.mediaType == .video else { return }
        
        let options = PHVideoRequestOptions()
        options.version = .current
        options.isNetworkAccessAllowed = false
        options.deliveryMode = .automatic
        
        PHImageManager.default().requestAVAsset(
            forVideo: self,
            options: options,
            resultHandler: { asset, audioMix, info in
                DispatchQueue.main.async {
                    if let asset {
                        completionHandler(asset)
                    } else {
                        completionHandler(nil)
                    }
                }
            })
    }
}
