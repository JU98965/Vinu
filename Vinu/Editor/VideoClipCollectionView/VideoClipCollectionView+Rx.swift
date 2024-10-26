//
//  VideoClipCollectionView+Rx.swift
//  Vinu
//
//  Created by 신정욱 on 10/2/24.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: VideoClipCollectionView {
    // MARK: - Binder
    var itemWidths: Binder<[CGFloat]> {
        return Binder(base) { _, newItemSizes in
            base.itemWidths = newItemSizes
        }
    }
}
