//
//  SW_AssgnationCarListCell.swift
//  SWS
//
//  Created by jayway on 2019/11/14.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_AssgnationCarListCell: UITableViewCell {
    
    @IBOutlet weak var customerNameLb: UILabel!
    
    @IBOutlet weak var contractNumLb: UILabel!
    
    @IBOutlet weak var saleNameLb: UILabel!
    
    @IBOutlet weak var carModelLb: UILabel!
    
    @IBOutlet weak var preDate: UILabel!
    
    @IBOutlet weak var payStateLb: UILabel!
    
    //
//    /// 车辆分配状态 1未分配 2已分配
//    var assignationState = 1
//    /// 合同结审状态 1 未提交 2 待审核 3 已通过 4 已驳回
//    var finalAuditState: AuditState = .noCommit
//    /// "payState":"合同状态 1 未付款 2 已付定金 3 已付全款",
//    var payState: PayState = .noPay
    var contractModel: SW_SalesContractListModel? {
        didSet {
            guard let contractModel = contractModel else { return }
            customerNameLb.text = contractModel.customerName
            contractNumLb.text = contractModel.contractNum
            saleNameLb.text = contractModel.saleName
            payStateLb.text = "车辆状态:\(contractModel.assignationState == 2 ? "已分配" : "未分配")"
            preDate.text = Date.dateWith(timeInterval: contractModel.deliveryDate).stringWith(formatStr: "yyyy.MM.dd")
            carModelLb.text =  contractModel.carBrand + "  " + contractModel.carSeries + "  " + contractModel.carModel + "  " + contractModel.carColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
