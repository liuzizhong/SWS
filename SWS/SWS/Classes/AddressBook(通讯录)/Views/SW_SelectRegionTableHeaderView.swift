//
//  SW_SelectRegionTableHeaderView.swift
//  SWS
//
//  Created by jayway on 2018/11/19.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_SelectRegionTableHeaderView: UIView {
    
    private lazy var flowLayout: FixedSpacingCollectionLayout = {
        let layout = FixedSpacingCollectionLayout()
        layout.delegate = self
        layout.lineSpacing = 15
        layout.interitemSpacing = 10
        layout.shouldBreakline = false
        layout.edgeInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        return layout
    }()
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    /// 当前选择的范围数组
    private var selectDatas = [SW_AddressBookModel]()
//    private var selectRegion: SW_AddressBookModel?
//    private var selectUnit: SW_AddressBookModel?
//    private var selectDept: SW_AddressBookModel?
    
    /// 选择范围改变
    var rangeChangeBlock: SelectAddressBookRangeBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.collectionViewLayout = flowLayout
        collectionView.registerNib(SW_FilterCollectionViewCell.self, forCellReuseIdentifier: "SW_FilterCollectionViewCellID")
    }
    
    func setUpDatas(_ region: SW_AddressBookModel?, bunit: SW_AddressBookModel?, dept: SW_AddressBookModel?) {
//        selectRegion = region
//        selectUnit = bunit
//        selectDept = dept
        selectDatas = []
        selectDatas.append(safe: region)
        selectDatas.append(safe: bunit)
        selectDatas.append(safe: dept)
        collectionView.reloadData()
    }
}

extension SW_SelectRegionTableHeaderView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectDatas.count > 0 {
            return selectDatas.count
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SW_FilterCollectionViewCellID", for: indexPath) as! SW_FilterCollectionViewCell
        if selectDatas.count > 0 {
            cell.nameLb.text = selectDatas[indexPath.row].name
            cell.isSelect = true
        } else {
            cell.nameLb.text = "筛 选"
            cell.isSelect = false
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        /// 显示选择弹窗  选择成功会回调，失败就不回调
        SW_SelectRangeModalView.show() { (region, unit, dept) in
            self.setUpDatas(region, bunit: unit, dept: dept)
            self.rangeChangeBlock?(region, unit, dept)
        }
    }
    
    
    
}

extension SW_SelectRegionTableHeaderView: FixedSpacingCollectionLayoutDelegate {
    
    func collectionViewLayout(_ layout: UICollectionViewLayout, sizeForIndexPath indexPath: IndexPath) -> CGSize {
        var string = "筛 选"
        if selectDatas.count > 0, selectDatas.count > indexPath.row {
            string = selectDatas[indexPath.row].name
        }
        let textSize = NSString(string: string).size(withAttributes: [NSAttributedString.Key.font:Font(12)])
        return CGSize(width: textSize.width + 14 * 2.0, height: 30)
    }
    
    func collectionViewLayout(_ Layout: UICollectionViewLayout, didUpdateContentSize size: CGSize) {
    }
    
}
