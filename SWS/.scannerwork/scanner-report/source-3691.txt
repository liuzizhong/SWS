//
//  SW_ ArchiveButtonView.swift
//  SWS
//
//  Created by jayway on 2018/11/14.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_ArchiveButtonView: UIView {

    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    
    var actionBlock: NormalBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        button.layer.borderColor = UIColor.v2Color.blue.cgColor
        button.setTitleColor(UIColor.v2Color.blue, for: UIControl.State())
        button.layer.cornerRadius = 3
        button.layer.borderWidth = 1
    }

    @IBAction func buttonDidClick(_ sender: QMUIButton) {
        actionBlock?()
    }
}
