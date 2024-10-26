//
//  PreviewPlayer+Rx.swift
//  Vinu
//
//  Created by 신정욱 on 9/29/24.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation

final class PreviewPlayerDelegateProxy: DelegateProxy<PreviewPlayer, PreviewPlayerDelegate>, DelegateProxyType, PreviewPlayerDelegate {
    static func registerKnownImplementations() {
        self.register { customAVPlayer in
            PreviewPlayerDelegateProxy(parentObject: customAVPlayer, delegateProxy: self)
        }
    }
    
    static func currentDelegate(for object: PreviewPlayer) -> (any PreviewPlayerDelegate)? {
        object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: (any PreviewPlayerDelegate)?, to object: PreviewPlayer) {
        object.delegate = delegate
    }
}

extension Reactive where Base: PreviewPlayer {
    var delegate: PreviewPlayerDelegateProxy {
        PreviewPlayerDelegateProxy.proxy(for: self.base)
    }
    
    // MARK: - DelegateProxy
    var status: Observable<AVPlayer.Status> {
        return delegate.methodInvoked(#selector(PreviewPlayerDelegate.didChangeStatus(status:)))
            .compactMap { parameter in parameter[0] as? Int }
            .compactMap { AVPlayer.Status(rawValue: $0) }
    }
    
    var rate: Observable<Float> {
        return delegate.methodInvoked(#selector(PreviewPlayerDelegate.didChangeRate(rate:)))
            .compactMap { parameter in parameter[0] as? Float }
    }
    
    var timeControlStatus: Observable<AVPlayer.TimeControlStatus> {
        return delegate.methodInvoked(#selector(PreviewPlayerDelegate.didChangeTimeControlStatus(timeControlStatus:)))
            .compactMap { parameter in parameter[0] as? Int }
            .compactMap { AVPlayer.TimeControlStatus(rawValue: $0) }
    }
    
    var elapsedTime: Observable<CMTime> {
        return delegate.methodInvoked(#selector(PreviewPlayerDelegate.didChangeElapsedTime(elapsedTime:)))
            .compactMap { parameter in parameter[0] as? CMTime }
    }
    
    var playerItemStatus: Observable<AVPlayerItem.Status> {
        return delegate.methodInvoked(#selector(PreviewPlayerDelegate.didChangePlayerItemStatus(status:)))
            .compactMap { parameter in parameter[0] as? Int }
            .compactMap { AVPlayerItem.Status(rawValue: $0) }
    }
    
    // MARK: - Binder
    var replaceCurrentItem: Binder<AVPlayerItem> {
        Binder(base) { base, newValue in
            base.replaceCurrentItem(with: newValue)
        }
    }
}
