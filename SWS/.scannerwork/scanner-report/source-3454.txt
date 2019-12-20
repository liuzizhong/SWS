//
//  SW_InventoryListCell.swift
//  SWS
//
//  Created by jayway on 2019/4/7.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_InventoryListCell: UITableViewCell {
    
    @IBOutlet weak var warehouseLb: UILabel!
    @IBOutlet weak var areaNumsLb: UILabel!
    @IBOutlet weak var orderLb: UILabel!
    @IBOutlet weak var createDateLb: UILabel!
    
    var model: SW_InventoryListModel? {
        didSet {
            guard let model = model else { return }
            
            areaNumsLb.text = model.areaNums
            warehouseLb.text = model.warehouseName
            orderLb.text = model.orderNo
            createDateLb.text = model.createDateString
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
}
