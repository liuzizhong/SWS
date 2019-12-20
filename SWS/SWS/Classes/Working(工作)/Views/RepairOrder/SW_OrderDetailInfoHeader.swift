//
//  SW_OrderDetailInfoHeader.swift
//  SWS
//
//  Created by jayway on 2019/3/5.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit
import SpreadsheetView

class SW_OrderDetailInfoHeader: UIView {
    
    @IBOutlet weak var receivableLb: UILabel!
    
    @IBOutlet weak var waitReceiveLb: UILabel!

    var baseInfoView: SW_OrderDetailBaseInfoHeader = {
        return Bundle.main.loadNibNamed(String(describing: SW_OrderDetailBaseInfoHeader.self), owner: nil, options: nil)?.first as! SW_OrderDetailBaseInfoHeader
    }()
    
    @IBOutlet weak var baseContentHeight: NSLayoutConstraint!
    @IBOutlet weak var baseInfoContentView: UIView!
    
    @IBOutlet weak var payTypeLb: UILabel!
    
    @IBOutlet weak var payStateLb: UILabel!
    
    @IBOutlet weak var repairStateLb: UILabel!
    
    @IBOutlet weak var qualityStateLb: UILabel!
    
    var orderModel: SW_RepairOrderRecordDetailModel? {
        didSet {
            guard let orderModel = orderModel else { return }
            baseInfoView.isHideSenderLb = false
            baseInfoView.orderModel = orderModel
            receivableLb.text = orderModel.receivableAmount.toAmoutString()
            waitReceiveLb.text = (orderModel.receivableAmount - orderModel.paidedAmount).toAmoutString()
            payTypeLb.text = orderModel.payTypeStr
            payStateLb.text = orderModel.payStateStr
            repairStateLb.text = "\(orderModel.orderType != 2 ? "未确认" : orderModel.repairStateStr)"//orderModel.repairStateStr
            baseContentHeight.constant = orderModel.customerNameHeight + 150
            qualityStateLb.text = orderModel.qualityState.stateStr
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        baseInfoContentView.addSubview(baseInfoView)
        baseInfoView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

}
