//
//  SW_ProportionBarCell.swift
//  SWS
//
//  Created by jayway on 2018/9/10.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_ProportionBarCell: UITableViewCell {
    
    @IBOutlet weak var barView: UIView!
    
    @IBOutlet weak var countLb: UILabel!
    
    @IBOutlet weak var barWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        countLb.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
