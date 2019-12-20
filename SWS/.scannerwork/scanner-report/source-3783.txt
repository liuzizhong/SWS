//
//  FixedSpacingCollectionLayout.swift
//  Browser
//
//  Created by 115 on 2017/7/14.
//  Copyright © 2017年 114la.com. All rights reserved.
//

import UIKit


// MARK: - MyCollectionViewLayout
@objc protocol FixedSpacingCollectionLayoutDelegate {
    func collectionViewLayout(_ Layout: UICollectionViewLayout, didUpdateContentSize size: CGSize)
    
    func collectionViewLayout(_ layout: UICollectionViewLayout, sizeForIndexPath indexPath: IndexPath) -> CGSize
    
    @objc optional func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool
    
}


class FixedSpacingCollectionLayout: UICollectionViewLayout {
    
    weak var delegate: FixedSpacingCollectionLayoutDelegate?
    
    fileprivate var cellCount = 0
    
    fileprivate var boundsSize: CGSize = CGSize.zero
    
    private var lastCellFrame: CGRect = CGRect.zero
    
    /// 是否自动换行，默认会换行，false 不换行，一直叠加o向右
    var shouldBreakline = true
    /// 水平间距
    var lineSpacing: CGFloat = 0.0
    /// 垂直间距
    var interitemSpacing: CGFloat = 0.0
    /// 上下左右边距
    var edgeInset: UIEdgeInsets =  UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    private var maxX: CGFloat = 0
    
    override func prepare() {
        guard let collectionView = self.collectionView else { return }
        cellCount = collectionView.numberOfItems(inSection: 0)
        boundsSize = collectionView.bounds.size
        lastCellFrame = .zero
        maxX = 0
    }
    
    override var collectionViewContentSize : CGSize {
        let size = CGSize(width: maxX + edgeInset.right, height: lastCellFrame.maxY + edgeInset.bottom)
//        if lastCellFrame != .zero {
            self.delegate?.collectionViewLayout(self, didUpdateContentSize: size)
//        }
        return size
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var allAttributes = [UICollectionViewLayoutAttributes]()
        for i in 0 ..< cellCount {
            let indexPath: IndexPath = IndexPath(row: i, section: 0)
            let attr: UICollectionViewLayoutAttributes = self._layoutForAttributesForCellAtIndexPath(indexPath)
            
            allAttributes.append(attr)
        }
        return allAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self._layoutForAttributesForCellAtIndexPath(indexPath)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return self.delegate?.shouldInvalidateLayout?(forBoundsChange: newBounds) ?? true
    }
    
    func _layoutForAttributesForCellAtIndexPath(_ indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        //cell的大小
        let itemSize = self.delegate?.collectionViewLayout(self, sizeForIndexPath: indexPath) ?? CGSize(width: 10, height: 10)
        
//        print("lastframe:\(lastCellFrame)...indexpath:\(indexPath)")
        
        var frame: CGRect
        
        if indexPath.section == 0 && indexPath.row == 0 {
//            print("zero...")
            frame = CGRect(x: edgeInset.left, y: edgeInset.top, width: itemSize.width, height: itemSize.height)
        } else {
            frame = CGRect(x: lastCellFrame.maxX + lineSpacing, y: lastCellFrame.origin.y, width: itemSize.width, height: itemSize.height)
            if shouldBreakline , frame.maxX + edgeInset.right > boundsSize.width {
                frame = CGRect(x: edgeInset.left, y: lastCellFrame.maxY + interitemSpacing, width: itemSize.width, height: itemSize.height)
            }
        }
        
        let attr: UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
//        var frame = CGRect.zero
        //初始边距
//        frame.origin.x = CGFloat(itemPage) * boundsSize.width + CGFloat(columnPosition) * (itemSize.width + horizontalMargin) + edgeInset.left
//        frame.origin.y = CGFloat(rowPosition) * (itemSize.height + verticalMargin) + edgeInset.top
//        frame.size = itemSize
        attr.frame = frame
        
        lastCellFrame = frame
        if frame.maxX > maxX {
            maxX = frame.maxX
        }
        
        return attr
    }
    
}
