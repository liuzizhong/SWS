//
//  SW_RepairBoardModel.swift
//  SWS
//
//  Created by jayway on 2019/6/11.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_RepairBoardModel: NSObject {
    /// 维修单号
    var repairOrderNum = ""
    /// 维修单id
    var repairOrderId = ""
    /// 车牌号
    var numberPlate = ""
    /// 车架号
    var vin = ""
    /// 入厂时间
    var inStockDate: TimeInterval = 0 {
        didSet {
            inStockDateString = Date.dateWith(timeInterval: inStockDate).stringWith(formatStr: "yyyy.MM.dd HH:mm")
        }
    }
    var inStockDateString = ""
    /// 预计出厂时间
    var predictDate: TimeInterval = 0 {
        didSet {
            predictDateString = Date.dateWith(timeInterval: predictDate).stringWith(formatStr: "yyyy.MM.dd HH:mm")
        }
    }
    var predictDateString = ""
    
    var afterSaleGroupList = [AfterSaleGroupListModel]()
    
    init(_ json: JSON) {
        super.init()
        repairOrderNum = json["repairOrderNum"].stringValue
        repairOrderId = json["repairOrderId"].stringValue
        numberPlate = json["numberPlate"].stringValue
        vin = json["vin"].stringValue
        predictDate = json["predictDate"].doubleValue
        predictDateString = Date.dateWith(timeInterval: predictDate).stringWith(formatStr: "yyyy.MM.dd HH:mm")
        inStockDate = json["inStockDate"].doubleValue
        inStockDateString = Date.dateWith(timeInterval: inStockDate).stringWith(formatStr: "yyyy.MM.dd HH:mm")
        
        afterSaleGroupList = json["afterSaleGroupList"].arrayValue.map({ return AfterSaleGroupListModel($0) })
    }
}

struct AfterSaleGroupListModel {
    
    var name = ""
    var workingHoursTotal: Double = 0
    var balanceWorkingHours: Double = 0
    
    init(_ json: JSON) {
        name = json["name"].stringValue
        workingHoursTotal = json["workingHoursTotal"].doubleValue
        balanceWorkingHours = json["balanceWorkingHours"].doubleValue
    }
    
}
