//
//  SW_ProcurementListCell.swift
//  SWS
//
//  Created by jayway on 2019/3/20.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_ProcurementListCell: UITableViewCell {
    
    @IBOutlet weak var supplierLb: UILabel!
    @IBOutlet weak var purchaseOrderLb: UILabel!
    @IBOutlet weak var buyDateLb: UILabel!
    
    var orderModel: SW_ProcurementListModel? {
        didSet {
            guard let orderModel = orderModel else { return }
            supplierLb.text = orderModel.supplier
            purchaseOrderLb.text = orderModel.orderNo
            buyDateLb.text = orderModel.buyDateString
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
}
