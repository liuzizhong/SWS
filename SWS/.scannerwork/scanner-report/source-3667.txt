//
//  SW_InfoHeaderView.swift
//  SWS
//
//  Created by jayway on 2018/4/25.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_InfoHeaderView: UIView {

    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var nameLb: UILabel!
    
    @IBOutlet weak var depamentLb: UILabel!
    
    var iconImageTapBlock: NormalBlock?
    
    var viewTapBlock: NormalBlock?

    override func awakeFromNib() {
        super.awakeFromNib()
        iconImageView.layer.cornerRadius = 40
        iconImageView.layer.masksToBounds = true
        let tap = UITapGestureRecognizer { [weak self] (tap) in
            self?.viewTapBlock?()
        }
        let imgTap = UITapGestureRecognizer { [weak self] (tap) in
            self?.iconImageTapBlock?()
        }
        iconImageView.addGestureRecognizer(imgTap!)
        addGestureRecognizer(tap!)
    }
    
}
