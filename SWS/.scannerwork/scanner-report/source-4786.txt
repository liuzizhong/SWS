//
//  SW_TabBarButton.swift
//  SWS
//
//  Created by jayway on 2017/12/23.
//  Copyright © 2017年 yuanrui. All rights reserved.
//

import UIKit

class SW_TabBarButton: QMUIButton {

    override var isSelected: Bool {
        didSet {
            tintColor = isSelected ? UIColor.v2Color.blue : #colorLiteral(red: 0.6274509804, green: 0.6745098039, blue: 0.7529411765, alpha: 1)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        creatChildViewToTabBarButton() //创建子控件
    }
    
   //创建子控件
    func creatChildViewToTabBarButton() -> Void {
        //1.创建上边的图片
        
        imagePosition = .top
        spacingBetweenImageAndTitle = 4
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        setTitleColor(#colorLiteral(red: 0.6274509804, green: 0.6745098039, blue: 0.7529411765, alpha: 1), for: UIControl.State())
        setTitleColor(UIColor.v2Color.blue, for: .selected)
        
        adjustsButtonWhenHighlighted = true
        
        adjustsTitleTintColorAutomatically = true
        adjustsImageTintColorAutomatically = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
