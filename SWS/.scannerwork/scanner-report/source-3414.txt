//
//  SW_RepairItemCell.swift
//  SWS
//
//  Created by jayway on 2019/6/12.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_RepairItemCell: UITableViewCell {

    @IBOutlet weak var selectImageView: UIImageView!
    
    
    var isSelect = false {
        didSet {
            selectImageView.image = isSelect ? #imageLiteral(resourceName: "Main_select") : #imageLiteral(resourceName: "Main_unselect")
        }
    }
    
    @IBOutlet weak var hourLb: UILabel!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var numLb: UILabel!
    var item: SW_RepairItemModel? {
        didSet {
            guard let item = item else { return }
            numLb.text = item.repairItemNum
            nameLb.text = item.repairItemName
            hourLb.text = item.workingHours.toAmoutString()
            
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
