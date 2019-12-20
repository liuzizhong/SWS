//
//  SW_BoutiqueInstallDetailModel.swift
//  SWS
//
//  Created by jayway on 2019/11/15.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_BoutiqueInstallDetailModel: NSObject {
    
    //MARK: - 公用属性
    /// 合同号
    var contractNum = ""
    /// 合同id
//    var contractId = ""
       
    /// 合同作废状态，3表示作废成功
//    var invalidAuditState = 1
    /// 销售顾问名字
    var saleName = ""
    /// 车架号
    var vin = ""
    /// 厂商品牌
    var carBrand = ""
    /// 车系
    var carSeries = ""
    /// 车型
    var carModel = ""
    /// 车颜色
    var carColor = ""
    /// 已装数量
    var boutiqueInstallCount: Double = 0
    /// 实际出库数量
    var concreteOutStockNum: Double = 0
    
    var boutiqueContractList = [SW_BoutiqueContractModel]()

    override init() {
        super.init()
    }
    
    init(_ json: JSON) {
        let infoJson = json["info"]
        
        contractNum = infoJson["contractNum"].stringValue
        boutiqueInstallCount = infoJson["boutiqueInstallCount"].doubleValue.roundTo(places: 4)
        vin = infoJson["vin"].stringValue
        saleName = infoJson["saleName"].stringValue
        carBrand = infoJson["carBrand"].stringValue
        carSeries = infoJson["carSeries"].stringValue
        carModel = infoJson["carModel"].stringValue
        carColor = infoJson["carColor"].stringValue
        boutiqueContractList = infoJson["boutiqueContractList"].arrayValue.map({ return SW_BoutiqueContractModel($0) })
        /// boutiqueContractList计算得出
        concreteOutStockNum = boutiqueContractList.reduce(0) { (result, model) -> Double in
            return result + model.concreteOutStockNum
        }.roundTo(places: 4)
        
//        boutiqueOutCount = infoJson["boutiqueOutCount"].doubleValue.roundTo(places: 4)
    }
    
}

