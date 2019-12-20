//
//  SW_ConstructionDetailBottomView.swift
//  SWS
//
//  Created by jayway on 2019/3/6.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_ConstructionDetailBottomView: UIView {
    
    @IBOutlet weak var startBtn: SW_BlueButton!
    
    @IBOutlet weak var completeBtn: UIButton!
    
    var startActionBlock: NormalBlock?
    
    var completeActionBlock: NormalBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadow()
       
        completeBtn.setTitleColor(UIColor.v2Color.blue, for: UIControl.State())
        completeBtn.layer.borderColor = UIColor.v2Color.blue.cgColor
        completeBtn.layer.borderWidth = 1
        completeBtn.titleLabel?.font = Font(16)
        completeBtn.layer.cornerRadius = 3.0
        completeBtn.layer.masksToBounds = true
    }
    
    @IBAction func startBtnClick(_ sender: SW_BlueButton) {
        startActionBlock?()
    }
    
    @IBAction func completeBtnClick(_ sender: UIButton) {
        completeActionBlock?()
    }
    
}
