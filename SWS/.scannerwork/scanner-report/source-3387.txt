//
//  SW_SalesContractListCell.swift
//  SWS
//
//  Created by jayway on 2019/5/22.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_SalesContractListCell: UITableViewCell {
    
    @IBOutlet weak var customerNameLb: UILabel!
    
    @IBOutlet weak var contractNumLb: UILabel!
    
    @IBOutlet weak var vinTitleLb: UILabel!
    @IBOutlet weak var vinLb: UILabel!
    
    @IBOutlet weak var finalStateTitleLb: UILabel!
    
    @IBOutlet weak var finalStateLb: UILabel!
    
    @IBOutlet weak var payStateLb: UILabel!
    
    @IBOutlet weak var preDate: UILabel!
    
    @IBOutlet weak var transactImgV: UIImageView!
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
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
            if  contractModel.type == .assgnationCar {
                vinTitleLb.text = "销售顾问"
                vinLb.text = contractModel.saleName
                payStateLb.text = "车辆状态:\(contractModel.assignationState == 2 ? "已分配" : "未分配")"// + contractModel.payState.rawTitle
            } else {
                vinTitleLb.text = "车架号"
                vinLb.text = contractModel.vin.isEmpty ? "未分配" : contractModel.vin
                payStateLb.text = "合同状态:" + contractModel.payState.rawTitle
            }
            
            if contractModel.invalidAuditState == 3 {
                transactImgV.isHidden = false
                transactImgV.image = #imageLiteral(resourceName: "work_icon_obsolete")
            } else {
                transactImgV.isHidden = contractModel.auditState != .pass
                transactImgV.image = #imageLiteral(resourceName: "work_icon_transact")
            }
            
            preDate.text = Date.dateWith(timeInterval: contractModel.deliveryDate).stringWith(formatStr: "yyyy.MM.dd")
            
            /// 根据type  隐藏审核状态
            switch contractModel.type {
            case .assgnationCar:
                finalStateTitleLb.isHidden = false
                finalStateTitleLb.text = "合同车型:"
                finalStateLb.isHidden = false
                finalStateLb.text =  contractModel.carBrand + "  " + contractModel.carSeries + "  " + contractModel.carModel + "  " + contractModel.carColor
                finalStateLb.textColor = UIColor.v2Color.darkGray
                topConstraint.constant =  22
            case .insurance:
                finalStateTitleLb.isHidden = false
                finalStateTitleLb.text = "审核状态:"
                finalStateLb.isHidden = false
                finalStateLb.text = contractModel.auditState.rawTitle
                finalStateLb.textColor = contractModel.auditState.textColor
                topConstraint.constant =  22
            case .registration:
                finalStateTitleLb.isHidden = false
                finalStateTitleLb.text = "购置税:"
                finalStateLb.isHidden = false
                finalStateLb.text = contractModel.carPurchaseState == .noCommit ? "未办理" : "已办理"
                finalStateLb.textColor = contractModel.carPurchaseState == .noCommit ? UIColor.v2Color.red : UIColor.v2Color.darkGray
                topConstraint.constant =  22
            default:
                finalStateTitleLb.isHidden = true
                finalStateLb.isHidden = true
                topConstraint.constant = 2
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
