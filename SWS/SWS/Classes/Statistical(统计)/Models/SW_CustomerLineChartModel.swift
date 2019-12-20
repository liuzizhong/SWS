//
//  SW_CustomerLineChartModel.swift
//  SWS
//
//  Created by jayway on 2018/9/6.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_CustomerLineChartModel: SW_BaseChartModel {
    var lineChartTitle = ""
    var unit = "人数"
    
    var days = 0
    var dateType = DateType.day
    var dateString = ""
    var data = [SW_CustomerLineChartDataSetModel]()
    
    init(_ dateType: DateType, days: Int, json: JSON) {
        super.init()
        self.dateType = dateType
        self.days = days
        self.data = json["list"].arrayValue.map({ return SW_CustomerLineChartDataSetModel($0) })
        
        if self.data.count > 0 {
            for i in 0..<self.data[0].value.count {//给第一天的每条线添加颜色
                self.data[0].value[i].color = UIColor.getStatisticalChartColor(i)
            }
        }
    }
    
}


class SW_CustomerLineChartDataSetModel: NSObject {
    
    var label = ""
    
    ///这个values代表了多少条线
    var value = [SW_CustomerLineChartDataModel]()
    
    init(_ json: JSON) {
        super.init()
        label = json["dateTime"].stringValue
        value = json["list"].arrayValue.map({ return SW_CustomerLineChartDataModel($0) })
    }
}


class SW_CustomerLineChartDataModel: NSObject {
    /// 线的名称
    var name = ""
    var count: Int = 0
    var id: Int = 0
    var color = UIColor.clear
    
    init(_ json: JSON) {
        super.init()
        name = json["name"].stringValue
        count = json["count"].intValue
        id = json["id"].intValue
    }
}
