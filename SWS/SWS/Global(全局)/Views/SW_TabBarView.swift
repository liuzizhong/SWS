//
//  SW_TabBarView.swift
//  SWS
//
//  Created by jayway on 2017/12/23.
//  Copyright © 2017年 yuanrui. All rights reserved.
//

import UIKit

class SW_TabBarView: UIView {
    
    lazy var accessingListView: SW_AccessingListView = {
        let view = Bundle.main.loadNibNamed("SW_AccessingListView", owner: nil, options: nil)?.first as! SW_AccessingListView
        return view
    }()
    
    /// 用于存放tabbarbutton的容器view
    var tabBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.addShadow()//设置阴影的偏移量
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        addSubview(tabBar)
        tabBar.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(0)
            make.height.equalTo(TABBAR_HEIGHT + TABBAR_BOTTOM_INTERVAL)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func showAccessListView() {
        if accessingListView.superview == nil {
            addSubview(accessingListView)
            accessingListView.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                make.bottom.equalTo(tabBar.snp.top)
                make.height.equalTo(65)
            }
        }
    }
    
    /// 可以添加点动画
    func hideAccessListView() {
        if accessingListView.superview != nil {
            accessingListView.removeFromSuperview()
        }
    }
    
    deinit {
        SW_CustomerAccessingManager.shared.removeDelegate(accessingListView)
        PrintLog("deinit")
    }
    
}

