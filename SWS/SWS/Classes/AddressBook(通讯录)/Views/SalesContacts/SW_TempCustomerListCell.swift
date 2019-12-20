//
//  SW_TempCustomerListCell.swift
//  SWS
//
//  Created by jayway on 2018/11/7.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_TempCustomerListCell: UITableViewCell {

    @IBOutlet weak var tempNameLb: UILabel!
    
    @IBOutlet weak var lastDateLb: UILabel!
    
    @IBOutlet weak var stateLb: UILabel!
    
    var customerModel: SW_CustomerListModel? {
        didSet {
            guard let customerModel = customerModel else { return }
            
//           let numText = customerModel.customerTempNum
//            if numText.count > 4 {
//                tempNameLb.text = "客户" + String(numText[numText.index(numText.startIndex, offsetBy: 4)..<numText.endIndex])
//            } else {
//                tempNameLb.text = "客户" + numText
//            }
            tempNameLb.text = customerModel.customerTempNum
                
            lastDateLb.text = customerModel.lastAccessDateString
            stateLb.isHidden = false
            
            if customerModel.applyChangeState {
                stateLb.text = "(调档中)"
            } else if !customerModel.processRecordId.isEmpty {
                stateLb.text = "(待填写)"
            } else if customerModel.accessing {
                stateLb.text = "(接访中)"
            } else {
                stateLb.isHidden = true
            }
            
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
