//
//  SW_TwoButtonView.swift
//  SWS
//
//  Created by jayway on 2018/11/15.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_TwoButtonView: UIView {
    
    @IBOutlet weak var leftBtn: SW_BlueButton!
    
    @IBOutlet weak var rightBtn: SW_BlueButton!
    
    var leftActionBlock: NormalBlock?
    
    var rightActionBlock: NormalBlock?
    
    @IBAction func leftBtnClick(_ sender: SW_BlueButton) {
        leftActionBlock?()
    }
    
    @IBAction func rightBtnClick(_ sender: SW_BlueButton) {
        rightActionBlock?()
    }
    
    func setupLeft(_ title: String, action: NormalBlock?) {
        leftBtn.setTitle(title, for: UIControl.State())
        leftActionBlock = action
    }

    func setupRight(_ title: String, action: NormalBlock?) {
        rightBtn.setTitle(title, for: UIControl.State())
        rightActionBlock = action
    }
}
