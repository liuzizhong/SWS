//
//  SW_CustomerSectionHeaderView.swift
//  SWS
//
//  Created by jayway on 2018/8/15.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_CustomerSectionHeaderView: UIView {
    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var editBtn: UIButton!
    
    var editBlock: NormalBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        editBtn.setTitleColor(UIColor.v2Color.blue, for: UIControl.State())
    }
    
    @IBAction func editAction(_ sender: UIButton) {
        editBlock?()
    }
    
    func setup(_ title: String, btnName: String) {
        titleLb.text = title
        editBtn.setTitle(btnName, for: UIControl.State())
    }
}
