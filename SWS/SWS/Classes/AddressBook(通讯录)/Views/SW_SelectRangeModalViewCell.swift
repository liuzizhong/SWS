//
//  SW_SelectRangeModalViewCell.swift
//  SWS
//
//  Created by jayway on 2018/11/20.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_SelectRangeModalViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
//    @IBOutlet weak var peopleCountLb: UILabel!
    
    var model: SW_AddressBookModel? {
        didSet {
            guard let model = model else { return }
            nameLabel.text = model.name
//            peopleCountLb.text = "(\(model.staffCount))"
        }
    }
    
    var isSelect = false {
        didSet {
            nameLabel.textColor = isSelect ? #colorLiteral(red: 0, green: 0.4117647059, blue: 0.9019607843, alpha: 1) : UIColor.v2Color.darkBlack
//            peopleCountLb.textColor = isSelect ? #colorLiteral(red: 0, green: 0.4117647059, blue: 0.9019607843, alpha: 1) :  UIColor.v2Color.lightGray
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
