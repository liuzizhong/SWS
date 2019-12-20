//
//  SW_SalesContractInstallListModel.swift
//  SWS
//
//  Created by jayway on 2019/11/14.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_SalesContractInstallListModel: NSObject {
    /// customerName：客户姓名
    var customerName = ""
    /// 合同号
    var contractNum = ""
    /// 合同id
    var contractId = ""
    /// 车架号
    var vin = ""
    /// 合同作废状态，3表示作废成功
    var invalidAuditState = 1
    /// 精品安装数量
    var boutiqueInstallCount = 0
    /// "payState":"合同状态 1 未付款 2 已付定金 3 已付全款",
    var payState: PayState = .noPay
    /// 预计交车时间
    var deliveryDate: TimeInterval = 0
    
    /// 车厂牌
    var carBrand = ""
    /// 车系
    var carSeries = ""
    /// 车型
    var carModel = ""
    /// 车颜色
    var carColor = ""
    /// 是否安装 isInstall 1未安装 2已安装
    var isInstall = false
    
    init(_ json: JSON) {
        super.init()
        contractNum = json["contractNum"].stringValue
        contractId = json["contractId"].stringValue
        carBrand = json["carBrand"].stringValue
        carSeries = json["carSeries"].stringValue
        carModel = json["carModel"].stringValue
        carColor = json["carColor"].stringValue
        vin = json["vin"].stringValue
        customerName = json["customerName"].stringValue
        invalidAuditState = json["invalidAuditState"].intValue
        boutiqueInstallCount = json["boutiqueInstallCount"].intValue
        payState = PayState(rawValue: json["payState"].intValue) ?? .noPay
        deliveryDate = json["deliveryDate"].doubleValue
        isInstall = json["isInstall"].intValue == 2
    }
}
