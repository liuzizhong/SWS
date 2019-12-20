//
//  SW_CarInStockListModel.swift
//  SWS
//
//  Created by jayway on 2019/11/12.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

enum StockStateType: Int {
    case inRoad = 1
    case inStock
    case waitOut
    case hasOut
    
    var rawTitle: String {
        switch self {
        case .inRoad:
            return "在途"
        case .inStock:
            return "在库"
        case .waitOut:
            return "待出库"
        case .hasOut:
            return "已出库"
        }
    }
}

class SW_CarInStockListModel: NSObject {

    /// 车架号
    var vin = ""
    /// 在库天数
    var inStockDays = 0
    /// 库存状态 库存状态 1在途 2在库 3待出库 4已出库
    var stockState: StockStateType = .inRoad
    /// 厂牌
    var carBrand = ""
    /// 车系
    var carSeries = ""
    /// 车型
    var carModel = ""
    /// 车身颜色
    var carColor = ""
    /// upholsteryColor：内饰颜色
    var upholsteryColor = ""
    /// assignationState：车辆分配状态 1未分配 2已分配
    var assignationState = 1
    
    init(_ json: JSON) {
        super.init()
        vin = json["vin"].stringValue
        inStockDays = json["inStockDays"].intValue
        stockState = StockStateType(rawValue: json["stockState"].intValue) ?? .inRoad
        carBrand = json["carBrand"].stringValue
        carSeries = json["carSeries"].stringValue
        carModel = json["carModel"].stringValue
        carColor = json["carColor"].stringValue
        upholsteryColor = json["upholsteryColor"].stringValue
        assignationState = json["assignationState"].intValue
    }
}
