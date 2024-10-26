//
//  VideoTrackScrollView.swift
//  Vinu
//
//  Created by 신정욱 on 10/4/24.
//

import UIKit

final class VideoTrackScrollView: UIScrollView {
    var delegate_: VideoTrackScrollViewDelegate?
    private var contentOffsetObserver: NSKeyValueObservation?

    init() {
        super.init(frame: .zero)
        // 스크롤 뷰의 콘텐츠 오프셋을 관찰, 근데 자기 자신을 파라미터로 주는...
        self.contentOffsetObserver = self.observe(\.contentOffset, options: [.new]) { [weak self] object, change in
            self?.delegate_?.didChangeContentOffset?(object: object)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
