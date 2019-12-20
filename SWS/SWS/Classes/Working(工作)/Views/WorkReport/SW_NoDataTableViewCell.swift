//
//  SW_NoDataTableViewCell.swift
//  SWS
//
//  Created by jayway on 2019/1/17.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_NoDataTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
