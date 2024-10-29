//
//  VideoClipCollectionView.swift
//  Vinu
//
//  Created by 신정욱 on 10/2/24.
//

import UIKit

/// UICollectionViewDelegateFlowLayout의 델리게이트 메서드가 뷰 계층에 보이는 게 보기 싫어서 만든 서브클래스.
/// itemWidths를 업데이트 하고 invalidateLayout() 호출하면 됨.
/// rxcocoa로 데이터 소스만 바인딩 한 경우에 사용가능, 그 외에는 델리게이트 프록시와 충돌이 발생할지도?
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
