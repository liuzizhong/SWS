//
//  SW_WorkingMainCell.swift
//  SWS
//
//  Created by jayway on 2019/2/12.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_WorkingMainCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addShadow()
    }

}
