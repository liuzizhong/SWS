//
//  SW_SearchHistoryCell.swift
//  SWS
//
//  Created by jayway on 2018/11/20.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_SearchHistoryCell: UITableViewCell {
    
    @IBOutlet weak var keywordLb: UILabel!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    var deleteActionBlock: NormalBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func deleteBtnClick(_ sender: UIButton) {
        deleteActionBlock?()
    }
    
}
