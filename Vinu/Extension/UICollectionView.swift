//
//  UICollectionView.swift
//  Vinu
//
//  Created by 신정욱 on 10/1/24.
//


import UIKit

extension UICollectionView {
    func setMultilineLayout(spacing: CGFloat, itemCount: CGFloat, itemHeight: CGFloat) {
        var totalInterSpace: CGFloat { (itemCount - 1) * spacing }
        let itemSize = CGSize(width: (self.bounds.width - totalInterSpace) / itemCount, height: itemHeight)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical // 스크롤 방향
        flowLayout.itemSize = itemSize
        flowLayout.minimumInteritemSpacing = spacing // 스크롤 방향 기준 아이템 간 간격
        flowLayout.minimumLineSpacing = spacing // 스크롤 방향 기준 열 간격
        
        self.collectionViewLayout = flowLayout
    }
    
    func setMultilineLayout(
        spacing: CGFloat,
        itemCount: CGFloat,
        sectionInset: UIEdgeInsets = .zero,
        insetOffset: UIEdgeInsets = .zero) {
        var totalInterSpace: CGFloat { (itemCount - 1) * spacing }
        var insetWidth: CGFloat { sectionInset.left + sectionInset.right }
        var insetHeight: CGFloat { sectionInset.top + sectionInset.bottom }
        
        let itemSize = CGSize(
            width: (self.bounds.width - totalInterSpace - insetWidth) / itemCount,
            height: (self.bounds.width - totalInterSpace - insetHeight) / itemCount)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical // 스크롤 방향
        flowLayout.itemSize = itemSize
        flowLayout.minimumInteritemSpacing = spacing // 스크롤 방향 기준 아이템 간 간격
        flowLayout.minimumLineSpacing = spacing // 스크롤 방향 기준 열 간격
        flowLayout.sectionInset = sectionInset + insetOffset
        
        self.collectionViewLayout = flowLayout
    }
    
    func setSinglelineLayout(spacing: CGFloat, itemSize: CGSize, sectionInset: UIEdgeInsets = .zero) {
            let flowLayout = UICollectionViewFlowLayout()
            flowLayout.scrollDirection = .horizontal // 스크롤 방향
            flowLayout.itemSize = itemSize
            flowLayout.minimumInteritemSpacing = .zero // 스크롤 방향 기준 아이템 간 간격
            flowLayout.minimumLineSpacing = spacing // 스크롤 방향 기준 열 간격
            flowLayout.sectionInset = sectionInset
            
            self.collectionViewLayout = flowLayout
        }
    
}
