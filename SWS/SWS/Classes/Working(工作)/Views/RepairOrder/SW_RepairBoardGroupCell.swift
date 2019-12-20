//
//  SW_RepairBoardGroupCell.swift
//  SWS
//
//  Created by jayway on 2019/6/12.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_RepairBoardGroupCell: UITableViewCell {

    @IBOutlet weak var nameLb: UILabel!
    
    @IBOutlet weak var totalHourLb: UILabel!
    
    @IBOutlet weak var balanceHourLb: UILabel!
    
    var model: AfterSaleGroupListModel? {
        didSet {
            guard let model = model else { return }
            nameLb.text = model.name
            totalHourLb.text = model.workingHoursTotal.toAmoutString()
            balanceHourLb.text = model.balanceWorkingHours.toAmoutString()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
