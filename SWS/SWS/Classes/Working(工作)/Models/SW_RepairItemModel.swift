//
//  SW_RepairItemModel.swift
//  SWS
//
//  Created by jayway on 2019/6/12.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_RepairItemModel: NSObject {
    
    /// 维修项目名称
    var repairItemName = ""
    /// 维修项目id
    var repairItemId = ""
    /// 维修项目编号
    var repairItemNum = ""
    /// 工时
    var workingHours: Double = 0
    /// 工时费
    var hourlyWage: Double  = 0
    
    init(_ json: JSON) {
        super.init()
        repairItemNum = json["repairItemNum"].stringValue
        repairItemId = json["repairItemId"].stringValue
        repairItemName = json["repairItemName"].stringValue
        workingHours = json["workingHours"].doubleValue
        hourlyWage = json["hourlyWage"].doubleValue
    }
    
}
