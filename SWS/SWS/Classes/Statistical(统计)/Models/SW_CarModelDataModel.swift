//
//  SW_CarModelDataModel.swift
//  SWS
//
//  Created by jayway on 2018/8/7.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_CarModelDataModel: NSObject {
    
    var barChartTitle = ""
    
    var accountsType = AccountsType.profits
    
    var data = [SW_CarModelData]()
    
    init(_ accountsType: AccountsType, json: JSON) {
        super.init()
        barChartTitle = "车型" + accountsType.rawTitle + "分析"
        self.accountsType = accountsType
        self.data = json["list"].arrayValue.map({ return SW_CarModelData(accountsType, json: $0) })
    }
}

let GlobalNumberFormatter = { () -> NumberFormatter in
    let format = NumberFormatter()
    format.minimumIntegerDigits = 1
    format.minimumFractionDigits = 0
    format.maximumFractionDigits = 2
    return format
}()

class SW_CarModelData: NSObject {
    var accountsType = AccountsType.profits
    var carBrand = ""
    var carSerie = ""
    var carModel = ""
    /// 车型的金额占比
    var amountPercent = ""
    /// 车型的金额
    var amount: Double = 0
    
    init(_ accountsType: AccountsType, json: JSON) {
        super.init()
        self.accountsType = accountsType
        carBrand = json["carBrand"].stringValue
        carSerie = json["carSerie"].stringValue
        carModel = json["carModel"].stringValue
        switch accountsType {
        case .profits:
            amountPercent = json["profitPercent"].stringValue
            amount = json["profit"].doubleValue
        case .cost:
            amountPercent = json["costPercent"].stringValue
            amount = json["cost"].doubleValue
        case .income:
            amountPercent = json["revenuePercent"].stringValue
            amount = json["revenue"].doubleValue
        }
    }
    
    func getAmountString() -> String {
        if amount >= 10000 || amount <= -10000 {//单位万元
            return (GlobalNumberFormatter.string(for: amount/10000) ?? "0") + "万元"
        } else {//单位元
            return (GlobalNumberFormatter.string(for: amount) ?? "0") + "元"
        }
    }
    
    func getPercentString() -> String {
        if accountsType == .profits { return "" }
        return amountPercent + "%"
    }
    
}
