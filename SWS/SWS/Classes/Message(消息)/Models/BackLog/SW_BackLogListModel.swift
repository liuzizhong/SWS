//
//  SW_BackLogListModel.swift
//  SWS
//
//  Created by jayway on 2019/8/21.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_BackLogListModel: NSObject {
    var type: BackLogListType = .saleContract
    /// 单位id
    var bUnitId = 0
    /// 单id
    var orderId = ""
    /// 客户姓名
    var customerName = ""
    /// 单编号
    var orderNum = ""
    /// 顾问姓名 
    var staffName = ""
    /// 收款状态，对应单状态
    var payState: PayState = .noPay
    /// 审核状态
    var auditState: AuditState = .noCommit
    /// 作废状态  界面要优先判断是否有作废
    var invalidAuditState: AuditState = .noCommit
    /// 申请合同修改状态 界面要优先判断是否修改
    var modifyAuditState: AuditState = .noCommit
    
    init(_ json: JSON, type: BackLogListType) {
        super.init()
        self.type = type
        staffName = json["staffName"].stringValue
        customerName = json["customerName"].stringValue
        invalidAuditState = AuditState(rawValue: json["invalidAuditState"].intValue) ?? .noCommit
        payState = PayState(rawValue: json["payState"].intValue) ?? .noPay
        switch type {
        case .saleContract:
            modifyAuditState = AuditState(rawValue: json["modifyAuditState"].intValue) ?? .noCommit
            orderId = json["contractId"].stringValue
            orderNum = json["contractNum"].stringValue
            auditState = AuditState(rawValue: json["contractAuditState"].intValue) ?? .noCommit
        case .repairOrder:
            orderId = json["repairOrderId"].stringValue
            orderNum = json["repairOrderNum"].stringValue
            auditState = AuditState(rawValue: json["orderAuditState"].intValue) ?? .noCommit
        }
    }
}
