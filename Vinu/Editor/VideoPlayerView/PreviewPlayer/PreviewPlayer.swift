//
//  PreviewPlayer.swift
//  Vinu
//
//  Created by 신정욱 on 9/29/24.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation

final class PreviewPlayer: AVPlayer {
    var delegate: PreviewPlayerDelegate?
    private var chaseTime: CMTime = .zero
    // KVO는 변수에 담아서 쓰지 않으면 작동 안하는 것 같음
    private var timeControlStatusObserver: NSKeyValueObservation?
    private var playerItemStatusObserver: NSKeyValueObservation?

    override init() {
        super.init()
        // 플레이어의 재생 상태 변화를 관찰 (재생, 정지 등)
        self.timeControlStatusObserver = self.observe(\.timeControlStatus, options: [.new]) { [weak self] object, change in
            // 델리게이트 프록시 쪽에서 Any타입으로 업캐스팅되면 어차피 원시값으로 할당되기 때문에 사전에 Int로 할당
            self?.delegate?.didChangeTimeControlStatus?(timeControlStatus: object.timeControlStatus.rawValue)
        }
        // 주기적으로 이벤트를 발생시키는 옵저버 설정
        addPeriodicTimeObserver()
    }
    
    private func addPeriodicTimeObserver() {
        let interval = CMTime(value: 1, timescale: 30)
        
        // 영상 재생중 매 인터벌마다 이 클로저 구문이 실행됨 (재생 중: 지정된 인터벌마다, 일시정지 중: seek가 호출될 때마다)
        super.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] elapsedTime in
            // 탐색 중에는 시간변화를 전파하지 않도록 가드
            guard self?.timeControlStatus == .playing else { return }
            self?.delegate?.didChangeElapsedTime?(elapsedTime: elapsedTime)
        }
    }

    // 등록한 아이템의 상태 변화를 관찰할 수 있도록 오버라이딩
    override func replaceCurrentItem(with item: AVPlayerItem?) {
        // 등록된 아이템의 상태를 관찰
        playerItemStatusObserver = item?.observe(\.status, options: [.new]) { [weak self] object, change in
            // 델리게이트 프록시 쪽에서 Any타입으로 업캐스팅되면 어차피 원시값으로 할당되기 때문에 사전에 Int로 할당
            self?.delegate?.didChangePlayerItemStatus?(status: object.status.rawValue)
        }
        
        super.replaceCurrentItem(with: item)
    }
    
    // 오버라이딩해서 무의미한 seek 호출을 막기위한 로직을 추가
    override func seek(to newChaseTime: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime) {
        guard CMTimeCompare(chaseTime, newChaseTime) != 0 else { return }
        chaseTime = newChaseTime
        
        super.seek(to: newChaseTime, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter)
    }

    
}
