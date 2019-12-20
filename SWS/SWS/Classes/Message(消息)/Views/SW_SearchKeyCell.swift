//
//  SW_SearchKeyCell.swift
//  SWS
//
//  Created by jayway on 2019/1/4.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_SearchKeyCell: UITableViewCell {
    
    @IBOutlet weak var searchKeyLb: UILabel!
    
    var keyWord = "" {
        didSet {
            searchKeyLb.text = "搜索:“\(keyWord)”"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        searchKeyLb.textColor = UIColor.v2Color.blue
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
