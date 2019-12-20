//
//  SW_SelectArticleTypeCell.swift
//  SWS
//
//  Created by jayway on 2019/1/22.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_SelectArticleTypeCell: UICollectionViewCell {

    @IBOutlet weak var nameLb: UILabel!
    
    @IBOutlet weak var selectImageView: UIImageView!
    
    var isSelect = false {
        didSet {
            selectImageView.image = isSelect ? #imageLiteral(resourceName: "text_icon_checkbox_selected ") : #imageLiteral(resourceName: "text_icon_checkbox_normal")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
