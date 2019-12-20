//
//  SW_InsuranceSectionHeaderView.swift
//  SWS
//
//  Created by jayway on 2019/5/27.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_InsuranceSectionHeaderView: UIView {

    /// 是否i显示保险种类
    var isShowBxzl = true {
        didSet {
            bxzlLb.isHidden = !isShowBxzl
            beLeftConstraint.constant = isShowBxzl ? 125 : 15
        }
    }
    
    @IBOutlet weak var bxzlLb: UILabel!
    
    @IBOutlet weak var beLeftConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
