//
//  SW_FilterCollectionView.swift
//  SWS
//
//  Created by jayway on 2018/7/26.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

let FilterCollectionViewItemWidth = (SCREEN_WIDTH - 2 * 7 - 30) / 3

class SW_FilterCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var buttonContentView: UIView!
    
    private var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.alpha = 0
        return view
    }()
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    lazy var flowLayout: FixedSpacingCollectionLayout = {
        let layout = FixedSpacingCollectionLayout()
        layout.delegate = self
        layout.lineSpacing = 7
        layout.interitemSpacing = 7
        layout.edgeInset = UIEdgeInsets(top: 35, left: 15, bottom: 35, right: 15)
        return layout
    }()
    
    private var sureBlock: ((String)->Void)?
    
    private var cancelBlock: (()->Void)?
    
    private var showItems = [String]()
    
    private var selectItem = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.collectionViewLayout = flowLayout
        collectionView.registerNib(SW_FilterCollectionViewCell.self, forCellReuseIdentifier: "SW_FilterCollectionViewCellID")
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(actionBlock: { [weak self] (gesture) in
            self?.cancelBlock?()
            self?.hide(timeInterval: FilterViewAnimationDuretion)
        }))
        collectionView.isHidden = true
        buttonContentView.isHidden = true
        buttonContentView.addShadow()
    }

    func show(_ selectItem: String, showItems: [String], timeInterval: TimeInterval, onView: UIView, edgeInset: UIEdgeInsets = .zero, isAutoSelect: Bool = false, sureBlock: @escaping (String)->Void, cancelBlock: @escaping (()->Void)) {
        if superview != nil { return }
        
        onView.addSubview(self)
        self.snp.makeConstraints { (make) in
            make.top.equalTo(edgeInset.top)
            make.leading.trailing.equalToSuperview()
        }
        onView.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.bottom)
            make.bottom.equalTo(-edgeInset.bottom)
            make.leading.equalTo(edgeInset.left)
            make.trailing.equalTo(-edgeInset.right)
        }
        onView.layoutIfNeeded()
        
        self.selectItem = selectItem
        self.showItems = showItems
        self.sureBlock = sureBlock
        self.cancelBlock = cancelBlock
        UIView.animate(withDuration: timeInterval, delay: 0, options: UIView.AnimationOptions.curveEaseInOut,  animations: {
            self.collectionView.isHidden = false
            self.buttonContentView.isHidden = isAutoSelect
            self.backgroundView.alpha = 1
        }, completion: nil)
//        UIView.animate(withDuration: timeInterval) {
//            self.collectionView.isHidden = false
//            self.buttonContentView.isHidden = isAutoSelect
//            self.backgroundView.alpha = 1
//        }
        collectionView.reloadData()
    }
    
    func hide(timeInterval: TimeInterval) {
        if self.superview != nil {
            UIView.animate(withDuration: timeInterval, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                self.buttonContentView.isHidden = true
                self.collectionView.isHidden = true
                self.backgroundView.alpha = 0
            }) { (finish) in
                self.removeFromSuperview()
                self.backgroundView.removeFromSuperview()
            }
        }
    }
    
    @IBAction func sureAction(_ sender: UIButton) {
        hide(timeInterval: FilterViewAnimationDuretion)
        sureBlock?(selectItem)
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        cancelBlock?()
        hide(timeInterval: FilterViewAnimationDuretion)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SW_FilterCollectionViewCellID", for: indexPath) as! SW_FilterCollectionViewCell
        cell.nameLb.text = showItems[indexPath.row]
        cell.isSelect = showItems[indexPath.row] == selectItem
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectItem = showItems[indexPath.row]
        if buttonContentView.isHidden {//隐藏则自动选择
            sureBlock?(selectItem)
            hide(timeInterval: FilterViewAnimationDuretion)
        } else {
            collectionView.reloadData()
        }
    }
    
}

extension SW_FilterCollectionView: FixedSpacingCollectionLayoutDelegate {
    func collectionViewLayout(_ Layout: UICollectionViewLayout, didUpdateContentSize size: CGSize) {
        collectionViewHeight.constant = size.height
    }
    
    func collectionViewLayout(_ layout: UICollectionViewLayout, sizeForIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: FilterCollectionViewItemWidth, height: 39)
    }
    
}
