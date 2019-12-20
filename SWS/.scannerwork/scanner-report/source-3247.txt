//
//  SW_SalesContractListModel.swift
//  SWS
//
//  Created by jayway on 2019/5/22.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_SalesContractListModel: NSObject {
    var type: ContractBusinessType = .insurance
    
    /// customerName：客户姓名
    var customerName = ""
    /// 合同号
    var contractNum = ""
    /// 合同id
    var contractId = ""
    /// 车架号
    var vin = ""
    /// 业务结审状态 1 未提交 2 待审核 3 已通过 4 已驳回
    var auditState: AuditState = .noCommit
    /// 合同作废状态，3表示作废成功
    var invalidAuditState = 1
    /// 购置税状态，上牌时需要购置税状态
    var carPurchaseState: AuditState = .noCommit
    
    /// "payState":"合同状态 1 未付款 2 已付定金 3 已付全款",
    var payState: PayState = .noPay
    /// 预计交车时间
    var deliveryDate: TimeInterval = 0
    
//             "carBrand": "沃尔沃",
//           "carSeries": "V40",
//           "carModel": "2018款 T4 智雅版(进口)",
//           "carColor": "冰雪白",
//          "assignationState": 0, ：车辆分配状态 1未分配 2已分配
//          "saleName": "刘梓仲",
    /// 车厂牌
    var carBrand = ""
    /// 车系
    var carSeries = ""
    /// 车型
    var carModel = ""
    /// 车颜色
    var carColor = ""
    /// 销售员
    var saleName = ""
    /// 车辆分配状态 1未分配 2已分配
    var assignationState = 1
    
    init(_ json: JSON, type: ContractBusinessType) {
        super.init()
        self.type = type
        contractNum = json["contractNum"].stringValue
        contractId = json["contractId"].stringValue
        saleName = json["saleName"].stringValue
        carBrand = json["carBrand"].stringValue
        carSeries = json["carSeries"].stringValue
        carModel = json["carModel"].stringValue
        carColor = json["carColor"].stringValue
        vin = json["vin"].stringValue
        customerName = json["customerName"].stringValue
        invalidAuditState = json["invalidAuditState"].intValue
        switch type {
        case .insurance:
            auditState = AuditState(rawValue: json["insuranceAuditState"].intValue) ?? .noCommit
        case .mortgageLoans:
//            "state":"按揭状态 1 未办理  2已办理"
            auditState = json["state"].intValue == 2 ? .pass : .noCommit
        case .registration:
//            "carNumState":"上牌 1 未办理  2已办理"
            auditState = json["carNumState"].intValue == 2 ? .pass : .noCommit
            carPurchaseState = json["carPurchaseState"].intValue == 2 ? .pass : .noCommit
        case .purchaseTax:
//            "carPurchaseState":"购置税 1 未办理  2已办理"
            auditState = json["carPurchaseState"].intValue == 2 ? .pass : .noCommit
        case .assgnationCar:
            assignationState = json["assignationState"].intValue
        }
        
        payState = PayState(rawValue: json["payState"].intValue) ?? .noPay
        deliveryDate = json["deliveryDate"].doubleValue
    }
}
