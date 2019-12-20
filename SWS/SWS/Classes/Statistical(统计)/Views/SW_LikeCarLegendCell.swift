//
//  SW_LikeCarLegendCell.swift
//  SWS
//
//  Created by jayway on 2018/9/6.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_LikeCarLegendCell: UICollectionViewCell {

    @IBOutlet weak var legendColor: UIView!
    
    @IBOutlet weak var legendName: UILabel!
    
    @IBOutlet weak var peopleCountLb: UILabel!
    
    @IBOutlet weak var peopleLbWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        legendColor.layer.cornerRadius = 2
        peopleCountLb.layer.cornerRadius = 10
    }
}
