//
//  SW_RevenueReportModel.swift
//  SWS
//
//  Created by jayway on 2018/6/22.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

/// 营收报表-订单列表模型
class SW_RevenueReportModel: NSObject {
    
    /// 订单的类型
    var type = RevenueReportType.dayOrder
    
    /// 订单唯一id
    var id = ""
    /// 订单编号
    var reportNo = ""
    /// 归属部门
    var fromDeptName = ""
    /// 订单署期
    var reportDate: TimeInterval = 0 {
        didSet {
            reportDateString = Date.dateWith(timeInterval: reportDate).stringWith(formatStr: "yyyy.MM.dd")
        }
    }
    /// 订单署期字符串
    var reportDateString = ""
    /// 订单记录时间
    var reportCreateDate: TimeInterval = 0 {
        didSet {
           reportCreateDateString = Date.dateWith(timeInterval: reportCreateDate).stringWith(formatStr: "yyyy.MM.dd")
        }
    }
    ///订单记录时间字符串
    var reportCreateDateString = ""
    
    init(_ type: RevenueReportType, json: JSON) {
        super.init()
        self.type = type
        id = json["id"].stringValue
        fromDeptName = json["fromDeptName"].stringValue
        reportCreateDate = json["orderCreateDate"].doubleValue
        switch type {
        case .dayOrder:
            reportNo = json["orderNo"].stringValue
            reportDate = json["orderDate"].doubleValue
        default:
            reportNo = json["flowNo"].stringValue
            reportDate = json["flowDate"].doubleValue
        }
        reportDateString = Date.dateWith(timeInterval: reportDate).stringWith(formatStr: "yyyy.MM.dd")
        reportCreateDateString = Date.dateWith(timeInterval: reportCreateDate).stringWith(formatStr: "yyyy.MM.dd")
    }
    
}
