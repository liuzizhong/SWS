//
//  SW_AccessingListView.swift
//  SWS
//
//  Created by jayway on 2018/11/21.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_AccessingListView: UIView, SW_CustomerAccessingManagerDelegate {
    
    var accessingList = [SW_AccessingListModel]() {
        didSet {
            /// 检查定时器
            checkShouldManagerDelegate()
            
            pageControl.numberOfPages = accessingList.count
            if let index = accessingList.firstIndex(where: { (model) -> Bool in
                return model.customerId == currentAccessing?.customerId
            }) {// 找到之前显示的view
                collectionView.reloadData()
                pageControl.currentPage = index
                collectionView.setContentOffset(CGPoint(x: collectionView.width * CGFloat(index), y: 0), animated: false)
            } else {/// 没找到之前的view
                collectionView.reloadData()
                pageControl.currentPage = 0
                collectionView.setContentOffset(CGPoint.zero, animated: false)
            }
        }
    }
    
    /// 记录当前显示的cell，当reload时计算偏移量
    var currentAccessing: SW_AccessingListModel?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private lazy var pageControl: SW_PageControl = {
        let pageC = SW_PageControl()
        pageC.pageIndicatorTintColor = #colorLiteral(red: 0.8470588235, green: 0.8470588235, blue: 0.8470588235, alpha: 1)
        pageC.currentPageIndicatorTintColor = UIColor.v2Color.blue
        pageC.isEnabled = false
        pageC.hidesForSinglePage = true
        pageC.backgroundColor = UIColor.clear
        pageC.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        return pageC
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.registerNib(SW_AccessingCollectionViewCell.self, forCellReuseIdentifier: "SW_AccessingCollectionViewCellID")
        
        pageControl.numberOfPages = accessingList.count
        addSubview(pageControl)
        pageControl.snp.makeConstraints { (make) in
            make.height.equalTo(20)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    func SW_CustomerAccessingManagerNotificationReloadTime(manager: SW_CustomerAccessingManager) {
        let cells = collectionView.visibleCells
        for cell in cells {
            let cell = cell as! SW_AccessingCollectionViewCell
            guard let model = cell.model else { return }
            
            guard model.shouldCalculate else {
                return
            }
            
            let results = SW_CustomerAccessingManager.calculateTimeLabel(accessStartTime: model.accessStartDate, tryDriveStartTime: model.tryDriveStartDate, tryDriveEndTime: model.tryDriveEndDate)
            cell.timeLb.text = results.0
            cell.endButton.isEnabled = model.tryDriveStartDate == 0 || (model.tryDriveStartDate != 0 && model.tryDriveEndDate != 0)
            /// 判断是否要停止计时
            if results.3 {
                model.shouldCalculate = false
                checkShouldManagerDelegate()
            }
        }
    }
    
    /// 用于判断是否需要使用计时器，根据list中的shouldCalculate 字段判断，当所有都是false时删除代理
    private func checkShouldManagerDelegate() {
        if accessingList.count > 0 {
            for obj in accessingList {
                /// 只要有一个需要计算，就添加计时器
                if obj.shouldCalculate {
                    SW_CustomerAccessingManager.shared.addDelegate(self)
                    return
                }
            }
        }
        /// 进入这里说明全部都不需要计算了，删除delegate
        SW_CustomerAccessingManager.shared.removeDelegate(self)
    }
}

extension SW_AccessingListView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accessingList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SW_AccessingCollectionViewCellID", for: indexPath) as! SW_AccessingCollectionViewCell
        guard accessingList.count > indexPath.row else { return cell }
        cell.model = accessingList[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard accessingList.count > indexPath.row else { return }
        let model = accessingList[indexPath.row]
        if #available(iOS 10.0, *) {
            if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        }
        
        if model.customerType == .real {
            let vc = SW_NavViewController.init(rootViewController: SW_CustomerDetailViewController(model.customerId, consultantInfoId: model.consultantInfoId))
            vc.modalPresentationStyle = .fullScreen
            getTopVC().present(vc, animated: true, completion: nil)
        } else {
            let vc = SW_NavViewController.init(rootViewController: SW_TempCustomerDetailViewController(model.customerId, customerTempNum: model.customerTempNum, consultantInfoId: model.consultantInfoId, createDate: model.createDate))
            vc.modalPresentationStyle = .fullScreen
            getTopVC().present(vc, animated: true, completion: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /// 计算当前页数 控制pagecontrol
        let currentPage = Int(scrollView.contentOffset.x / scrollView.width + 0.5)
        if accessingList.count > currentPage {
            currentAccessing = accessingList[currentPage]//当前显示的模型
        }
        pageControl.currentPage = currentPage
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: SCREEN_WIDTH, height: 65)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}


class SW_PageControl: UIPageControl {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.setValue(UIImage(named: "guide_circle"), forKeyPath: "_pageImage")
//        self.setValue(UIImage(named: "guide_circle_current"), forKeyPath: "_currentPageImage")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let count = subviews.count
        let dotwh = self.height / 2
        let marginX = dotwh
        let viewY: CGFloat = dotwh
        var viewX: CGFloat
        let leftRightMargin =  (self.width - CGFloat(count) * dotwh - CGFloat(count - 1) * marginX) / 2
        
        for i in 0..<count {
            let dot = subviews[i]
            viewX = ((dotwh + marginX) * CGFloat(i)) + leftRightMargin
            dot.frame = CGRect(x: viewX, y: viewY, width: dotwh, height: dotwh)
        }
    }
    
}
