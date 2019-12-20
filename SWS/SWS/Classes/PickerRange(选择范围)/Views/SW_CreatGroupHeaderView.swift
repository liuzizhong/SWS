//
//  SW_CreatGroupHeaderView.swift
//  SWS
//
//  Created by jayway on 2018/12/5.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_CreatGroupHeaderView: UIView {
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var selectCountLb: UILabel!
    
    var editIconBlock: NormalBlock?
    
    var editNameBlock: NormalBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconImageView.layer.cornerRadius = iconImageView.height/2
//        iconImageView.addGestureRecognizer(UITapGestureRecognizer(actionBlock: { [weak self] (gesture) in
//            self?.editIconBlock?()
//        }))
    }
    
    @IBAction func editIconAction(_ sender: UIControl) {
        editIconBlock?()
    }
    
    @IBAction func editNameAction(_ sender: UIControl) {
        editNameBlock?()
    }
    
    
    
}
