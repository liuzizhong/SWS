//
//  SW_BarChartModel.swift
//  SWS
//
//  Created by jayway on 2018/8/1.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

enum BarChartDataType {
    case income
    case cost
    case level
    case customerSource
    
    var rawTitle: String {
        switch self {
        case .level:
            return "客户等级"
        case .customerSource:
            return "客户来源"
        case .income:
            return "收入"
        case .cost:
            return "成本"
        }
    }
}


class SW_BarChartModel: SW_BaseChartModel {
    
    var barChartTitle = ""
    
    var unit = "万元"
    
    var data = [SW_BarChartDataModel]()
    
    init(_ dataType: BarChartDataType, json: JSON) {
        super.init()
        switch dataType {
        case .level: fallthrough
        case .customerSource:
            barChartTitle = "接访\(dataType.rawTitle)：\(json["total"].intValue)人"
            unit = "人数"
        default:
            barChartTitle = dataType.rawTitle + "分析"
            unit = "万元"
        }
        
        self.data = json["list"].arrayValue.map({ return SW_BarChartDataModel(dataType, json: $0) })
    }
}


class SW_BarChartDataModel: NSObject {
    /// 柱的名称
    var amountName = ""
    /// 柱的数值
    var amount: Double = 0
    
    init(_ dataType: BarChartDataType, json: JSON) {
        super.init()
        switch dataType {
        case .cost:
            amountName = json["costName"].stringValue
            amount = (json["cost"].doubleValue / 10000.0).roundTo(places: 2)
        case .income:
            amountName = json["revenueName"].stringValue
            amount = (json["revenue"].doubleValue / 10000.0).roundTo(places: 2)
        case .level:
            amountName = json["customerLevelName"].stringValue + "级"
            amount = Double(json["count"].intValue)
        case .customerSource:
            amountName = json["customerSourceName"].stringValue
            amount = Double(json["count"].intValue)
        
        }
    }
    
}
