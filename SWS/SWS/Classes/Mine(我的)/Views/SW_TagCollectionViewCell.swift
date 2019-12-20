//
//  SW_TagCollectionViewCell.swift
//  SWS
//
//  Created by jayway on 2018/4/17.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_TagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLb: UILabel!
    
    var isSelect = false {
        didSet {
            if isSelect {
                nameLb.textColor = UIColor.white
                backgroundColor = UIColor.v2Color.blue
                layer.borderColor = UIColor.v2Color.blue.cgColor
            } else {
                nameLb.textColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
                backgroundColor = UIColor.white
                layer.borderColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1).cgColor
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 1
        layer.cornerRadius = 3
        layer.masksToBounds = true
    }
    
}
