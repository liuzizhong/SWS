//
//  SW_AfterSaleAccessRecordListModel.swift
//  SWS
//
//  Created by jayway on 2019/2/25.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_AfterSaleAccessRecordListModel: NSObject {
    
//    "recordContent": "这是我我输入的售后电话访问记录内容",
//    "duration": 469,
//    "staffId": 4,
//    "regionId": 1,
//    "bUnitId": 1,
//    "deptId": 1,
//    "customerId": "ff80808168557fd1016855ae06d00005",
    
    
    /// 维修f单id
    var repairOrderId = ""
    /// 客户id
    var customerId = ""
    
    /// 记录id
    var id = ""
    /// 访问方式  有2种
    var accessType = AfterSaleAccessType.none
    /// 访问开始时间
    var startDate: TimeInterval = 0
    /// 结束时间
    var endDate: TimeInterval = 0
    /// 访问时间是周几
    var whatDay = ""
    /// 记录内容
    var recordContent = ""
    /// 接访时长
    var duration = ""
    
    override init() {
        super.init()
    }
    
    init(_ json: JSON) {
        super.init()
        repairOrderId = json["repairOrderId"].stringValue
        customerId = json["customerId"].stringValue
        id = json["id"].stringValue
        accessType = AfterSaleAccessType(rawValue: json["accessType"].intValue) ?? .phone
        startDate = json["startDate"].doubleValue
        endDate = json["endDate"].doubleValue
        whatDay = json["whatDay"].stringValue
        recordContent = json["recordContent"].stringValue
        duration = json["duration"].stringValue
    }
    
}
