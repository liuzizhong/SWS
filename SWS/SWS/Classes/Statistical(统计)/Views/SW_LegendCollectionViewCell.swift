//
//  SW_LegendCollectionViewCell.swift
//  SWS
//
//  Created by jayway on 2018/8/3.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_LegendCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var legendColor: UIView!
    
    @IBOutlet weak var legendName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        legendColor.layer.cornerRadius = 2
    }

}
