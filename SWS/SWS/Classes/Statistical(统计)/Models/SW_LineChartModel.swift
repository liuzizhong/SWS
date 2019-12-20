//
//  SW_LineChartModel.swift
//  SWS
//
//  Created by jayway on 2018/8/1.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_LineChartModel: SW_BaseChartModel {
    var lineChartTitle = ""
    
    var unit = "万元"
    
    var dateType = DateType.day
    
    var accountsType = AccountsType.profits
    
    var days = 0
    
    var data = [SW_LineChartDataSetModel]()
    
    init(_ dateType: DateType, accountsType: AccountsType, days: Int, json: JSON) {
        super.init()
        self.dateType = dateType
        self.accountsType = accountsType
        self.days = days
//        switch dateType {
//        case .day:
//            unit = "万元"
//        case .month:
//            unit = "十万元"
//        case .year:
//            unit = "百万元"
//        }
        self.data = json.arrayValue.map({ return SW_LineChartDataSetModel(dateType, json: $0) })
      
    }
    
}


class SW_LineChartDataSetModel: NSObject {
    
    var label = ""
    
    ///这个values代表了多少条线
    var value = [SW_LineChartDataModel]()
    
    
    init(_ dateType: DateType, json: JSON) {
        super.init()
        label = json["label"].stringValue
        value = json["value"].arrayValue.map({ return SW_LineChartDataModel(dateType, json: $0) })
    }
}


class SW_LineChartDataModel: NSObject {
    /// 线的名称
    var name = ""
    var costTotal: Double = 0
    var profit: Double = 0
    var revenueTotal: Double = 0

    var dateType = DateType.day
    
    init(_ dateType: DateType, json: JSON) {
        super.init()
        self.dateType = dateType
        name = json["name"].stringValue
        costTotal = (json["costTotal"].doubleValue / dateType.unit).roundTo(places: 2)
        revenueTotal = (json["revenueTotal"].doubleValue / dateType.unit).roundTo(places: 2)
        profit = (json["profit"].doubleValue / dateType.unit).roundTo(places: 2)
    }
    
    func getAmount(accountsType: AccountsType) -> Double {
        switch accountsType {
        case .profits:
            return profit
        case .income:
            return revenueTotal
        case .cost:
            return costTotal
        }
    }
}
