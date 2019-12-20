//
//  SW_BackLogListCell.swift
//  SWS
//
//  Created by jayway on 2019/8/21.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_BackLogListCell: UITableViewCell {
    
    @IBOutlet weak var customerTitleLb: UILabel!
    
    @IBOutlet weak var customerNameLb: UILabel!
    
    @IBOutlet weak var orderStateLb: UILabel!
    
    @IBOutlet weak var numTitleLb: UILabel!
    
    @IBOutlet weak var numLb: UILabel!
    
    @IBOutlet weak var staffTitleLb: UILabel!
    
    @IBOutlet weak var staffNameLb: UILabel!
    
    @IBOutlet weak var auditStateLb: UILabel!
    
    var isRead = false {
        didSet {
            customerTitleLb.textColor = isRead ?  UIColor.v2Color.lightGray : UIColor.v2Color.lightBlack
            customerNameLb.textColor = isRead ?  UIColor.v2Color.lightGray : UIColor.v2Color.lightBlack
        }
    }
    
    var backLog: SW_BackLogListModel? {
        didSet {
            guard let backLog = backLog else { return }
            customerNameLb.text = backLog.customerName
            staffNameLb.text = backLog.staffName
            numLb.text = backLog.orderNum
            
            if backLog.invalidAuditState == .wait {/// 作废待审核
                auditStateLb.text = "申请作废"
                auditStateLb.textColor = backLog.invalidAuditState.textColor
            } else if backLog.modifyAuditState == .wait {/// 修改合同审核
                auditStateLb.text = "申请修改"
                auditStateLb.textColor = backLog.modifyAuditState.textColor
            } else {
                auditStateLb.text = backLog.auditState.rawTitle
                auditStateLb.textColor = backLog.auditState.textColor
            }
            switch backLog.type {
            case .saleContract:
                staffTitleLb.text = "销售顾问:"
                numTitleLb.text = "合同编号:"
                orderStateLb.text = "合同状态:\(backLog.payState.rawTitle)"
            case .repairOrder:
                staffTitleLb.text = "SA:"
                numTitleLb.text = "维修单号:"
                orderStateLb.text = "维修单状态:\(backLog.payState.rawTitle)"
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
