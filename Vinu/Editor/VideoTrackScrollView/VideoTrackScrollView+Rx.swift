//
//  VideoTrackScrollView+Rx.swift
//  Vinu
//
//  Created by 신정욱 on 10/4/24.
//

import UIKit
import RxSwift
import RxCocoa

final class VideoTrackScrollViewDelegateProxy: DelegateProxy<VideoTrackScrollView, VideoTrackScrollViewDelegate>, DelegateProxyType, VideoTrackScrollViewDelegate {
    static func registerKnownImplementations() {
        self.register { videoTrackScrollView in
            VideoTrackScrollViewDelegateProxy(parentObject: videoTrackScrollView, delegateProxy: self)
        }
    }
    
    static func currentDelegate(for object: VideoTrackScrollView) -> (any VideoTrackScrollViewDelegate)? {
        object.delegate_
    }
    
    static func setCurrentDelegate(_ delegate: (any VideoTrackScrollViewDelegate)?, to object: VideoTrackScrollView) {
        object.delegate_ = delegate
    }
}

extension Reactive where Base: VideoTrackScrollView {
    var delegate_: VideoTrackScrollViewDelegateProxy {
        VideoTrackScrollViewDelegateProxy.proxy(for: self.base)
    }
    
    // MARK: - DelegateProxy
    var didChangeContentOffset: Observable<VideoTrackScrollView> {
        return delegate_.methodInvoked(#selector(VideoTrackScrollViewDelegate.didChangeContentOffset(object:)))
            .compactMap { parameter in parameter[0] as? VideoTrackScrollView }
    }
}
