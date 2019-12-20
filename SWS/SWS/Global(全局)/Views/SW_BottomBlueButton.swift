//
//  SW_BottomBlueButton.swift
//  SWS
//
//  Created by jayway on 2018/7/6.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

/// 底部白色背景蓝色图片的view
class SW_BottomBlueButton: UIView {

    var blueBtn: SW_BlueButton = {
        let btn = SW_BlueButton()
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = UIColor.white
        
        let line = UIView()
        line.backgroundColor = UIColor.mainColor.separator
        addSubview(line)
        line.snp.makeConstraints { (make) in
            make.top.trailing.leading.equalToSuperview()
            make.height.equalTo(SingleLineWidth)
        }
        
        addSubview(blueBtn)
        blueBtn.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.height.equalTo(44)
            make.top.equalTo(20)
        }
    }
    
}
