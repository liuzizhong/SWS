//
//  UICollectionGridViewLayout.swift
//  hangge_1081
//
//  Created by hangge on 2016/11/19.
//  Copyright © 2016年 hangge.com. All rights reserved.
//
import Foundation
import UIKit

//多列表格组件布局类
class UICollectionGridViewLayout: UICollectionViewLayout {
    //记录每个单元格的布局属性
    private var itemAttributes: [[UICollectionViewLayoutAttributes]] = []
    private var itemsSize: [NSValue] = []
    private var contentSize: CGSize = CGSize.zero
    //表格组件视图控制器
    var viewController: UICollectionGridViewController!
    
    //准备所有view的layoutAttribute信息
    override func prepare() {
        if collectionView?.numberOfSections == 0 {
            return
        }
        
        var column = 0
        var xOffset: CGFloat = 0
        var yOffset: CGFloat = 0
        var contentWidth: CGFloat = 0
        var contentHeight: CGFloat = 0
        
        if itemAttributes.count > 0 {
            return
        }
        
        itemAttributes = []
        itemsSize = []
        
        if itemsSize.count != viewController.cols.count {
            calculateItemsSize()
        }
        
        for section in 0 ..< (collectionView?.numberOfSections)! {
            var sectionAttributes: [UICollectionViewLayoutAttributes] = []
            for index in 0 ..< viewController.cols.count {
                let itemSize = itemsSize[index].cgSizeValue
                
                let indexPath = IndexPath(item: index, section: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                //除第一列，其它列位置都左移一个像素，防止左右单元格间显示两条边框线
                if index == 0{
                    attributes.frame = CGRect(x:xOffset, y:yOffset, width:itemSize.width,
                                              height:itemSize.height).integral
                }else {
                    attributes.frame = CGRect(x:xOffset-1, y:yOffset,
                                              width:itemSize.width+1,
                                              height:itemSize.height).integral
                }
                
                sectionAttributes.append(attributes)
                
                xOffset = xOffset+itemSize.width
                column += 1
                
                if column == viewController.cols.count {
                    if xOffset > contentWidth {
                        contentWidth = xOffset
                    }
                    
                    column = 0
                    xOffset = 0
                    yOffset += itemSize.height
                }
            }
            itemAttributes.append(sectionAttributes)
        }
        
        if let attributes = itemAttributes.last?.last {
            contentHeight = attributes.frame.origin.y + attributes.frame.size.height
            contentSize = CGSize(width:contentWidth, height:contentHeight)
        } else {
            contentHeight = 0
            contentSize = CGSize(width:contentWidth, height:contentHeight)
        }
    }
    
    //需要更新layout时调用
    override func invalidateLayout() {
        itemAttributes = []
        itemsSize = []
        contentSize = CGSize.zero
        super.invalidateLayout()
    }
    
    // 返回内容区域总大小，不是可见区域
    override var collectionViewContentSize: CGSize {
        get {
            return contentSize
        }
    }
    
    // 这个方法返回每个单元格的位置和大小
    override func layoutAttributesForItem(at indexPath: IndexPath)
        -> UICollectionViewLayoutAttributes? {
        return itemAttributes[indexPath.section][indexPath.row]
    }
    
    // 返回所有单元格位置属性
    override func layoutAttributesForElements(in rect: CGRect)
        -> [UICollectionViewLayoutAttributes]? {
            var attributes: [UICollectionViewLayoutAttributes] = []
            for section in itemAttributes {
                attributes.append(contentsOf: section.filter(
                    {(includeElement: UICollectionViewLayoutAttributes) -> Bool in
                        return rect.intersects(includeElement.frame)
                }))
            }
            return attributes
    }
    
    //当边界发生改变时，是否应该刷新布局。
    //本例在宽度变化时，将重新计算需要的布局信息。
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let oldBounds = self.collectionView?.bounds
        if oldBounds?.width != newBounds.width {
            return true
        }else {
            return false
        }
    }
    
    //计算所有单元格的尺寸（每一列各一个单元格）
    func calculateItemsSize() {
        var remainingWidth = collectionView!.frame.width -
            collectionView!.contentInset.left - collectionView!.contentInset.right
        
        var index = viewController.cols.count-1
        while index >= 0 {
            let newItemSize = sizeForItemWithColumnIndex(columnIndex: index,
                                                         remainingWidth: remainingWidth)
            remainingWidth -= newItemSize.width
            let newItemSizeValue = NSValue(cgSize: newItemSize)
            //由于遍历列的时候是从尾部开始遍历了，因此将结果插入数组的时候都是放人第一个位置
            itemsSize.insert(newItemSizeValue, at: 0)
            index -= 1
        }
    }
    
    //计算某一列的单元格尺寸
    func sizeForItemWithColumnIndex(columnIndex: Int, remainingWidth: CGFloat) -> CGSize {
        let columnString = viewController.cols[columnIndex]
        //根据列头标题文件，估算各列的宽度
        let size = NSString(string: columnString).size(withAttributes: [
            .font: UIFont.systemFont(ofSize: 15),
            .underlineStyle: NSUnderlineStyle.single.rawValue
            ])
//        [.font : UIFont(name: "PingFangSC-Medium", size: 14)!,
//         .foregroundColor : UIColor.mainColor.darkBlack,
//         .paragraphStyle : paragraphStyle]
        
        //如果有剩余的空间则都给第一列
        if columnIndex == 0 {
            return CGSize(width:max(remainingWidth, size.width + 24),
                          height:size.height + 20)
        }
        //行高增加20像素，列宽增加17像素
        return CGSize(width:size.width + 24, height:size.height + 20)
    }
}
