//
//  SW_PieChartModel.swift
//  SWS
//
//  Created by jayway on 2018/9/6.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_PieChartModel: SW_BaseChartModel {
    
    var pieChartTitle = ""
    
    var data = [SW_PieChartDataModel]()
    
    var total = 0
    
    init(_ json: JSON) {
        super.init()
        total = json["total"].intValue
        data = json["list"].arrayValue.map({ return SW_PieChartDataModel($0) })
    }
}


class SW_PieChartDataModel: NSObject {
    /// 名称
    var name = ""
    /// 数值
    var value: Double = 0
    
    init(_ json: JSON) {
        super.init()
        name = json["carName"].stringValue
        value = Double(json["count"].intValue)
    }
    
}
