//
//  SW_SelectAllButton.swift
//  SWS
//
//  Created by jayway on 2018/5/7.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_SelectAllButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        self.setImage(#imageLiteral(resourceName: "Main_select"), for: .selected)
        self.setImage(#imageLiteral(resourceName: "Main_unselect"), for: UIControl.State())
        self.setTitle(InternationStr("取消全选"), for: .selected)
        self.setTitle(InternationStr("全选"), for: UIControl.State())
        self.titleLabel?.font = Font(16)
        setTitleColor(UIColor.v2Color.lightBlack, for: UIControl.State())
        self.titleLabel?.textAlignment = .left
        self.backgroundColor = UIColor.white
        
//        addBottomLine()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame = CGRect(x: 15, y: (self.height - 20) / 2, width: 20, height: 20)
        self.titleLabel?.frame = CGRect(x: (imageView?.frame.maxX ?? 0) + 10, y: 0, width: 150, height: self.height)
    }

}


class SW_LeftButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView?.frame.origin.x = 0
        imageView?.frame.origin.y = (self.height - (self.imageView?.height ?? 0)) / 2
        titleLabel?.frame.origin.x = (imageView?.frame.maxX ?? 0) + 5
        titleLabel?.frame.origin.y = 0
        titleLabel?.frame.size.height = self.height
    }
    
}
