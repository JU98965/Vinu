//
//  VideoClipCollectionView.swift
//  Vinu
//
//  Created by 신정욱 on 10/2/24.
//

import UIKit

final class VideoClipCollectionView: UICollectionView {
    var itemWidths = [CGFloat]()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VideoClipCollectionView: UICollectionViewDelegateFlowLayout {
    // 컬렉션 뷰의 셀 너비를 가변적으로 적용
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard itemWidths.count > indexPath.row else { return .zero }
        return CGSize(width: itemWidths[indexPath.row], height: collectionView.bounds.height)
    }
}
