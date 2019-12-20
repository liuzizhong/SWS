//
//  SW_WorkReportBottomView.swift
//  SWS
//
//  Created by jayway on 2018/7/5.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_WorkReportBottomView: UIView {
    
    @IBOutlet weak var receivedBtn: UIButton!
    
    @IBOutlet weak var mineBtn: UIButton!
    
    var receivedBtnBlock: NormalBlock?

    var mineBtnBlock: NormalBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadow()//设置阴影的偏移量
        mineBtn.setTitleColor(UIColor.v2Color.blue, for: .selected)
        receivedBtn.setTitleColor(UIColor.v2Color.blue, for: .selected)
        setBadgeState()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.RedDotNotice, object: nil, queue: nil) {  [weak self]  (notifi) in
            self?.setBadgeState()
        }
    }
    
    private func setBadgeState() {
        receivedBtn.badgeWidth = 10
        mineBtn.badgeWidth = 10
        receivedBtn.badgeView(state: SW_BadgeManager.shared.workBadge.receiveWorkNotice)
        mineBtn.badgeView(state: SW_BadgeManager.shared.workBadge.myWorkNotice)
    }
    
    @IBAction func receivedBtnClick(_ sender: UIButton) {
        if receivedBtn.isSelected { return }
        mineBtn.isSelected = false
        receivedBtn.isSelected = true
        receivedBtnBlock?()
    }
    
    @IBAction func mineBtnClick(_ sender: UIButton) {
        if mineBtn.isSelected { return }
        receivedBtn.isSelected = false
        mineBtn.isSelected = true
        mineBtnBlock?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let offSetX = -(SCREEN_WIDTH - 170)/4
        receivedBtn.badgeOffset = CGPoint(x: offSetX, y: 20)
        mineBtn.badgeOffset = CGPoint(x: offSetX, y: 20)
    }
    
    deinit {
        PrintLog("deinit")
        NotificationCenter.default.removeObserver(self)
    }
}
