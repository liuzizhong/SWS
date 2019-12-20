//
//  SW_RepairOrderListModel.swift
//  SWS
//
//  Created by jayway on 2019/2/28.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_RepairOrderListModel: NSObject {
    var type: RepairOrderListType = .order
    /// 售后顾问姓名 sa
    var staffName = ""
    /// 维修单状态 1保存 2确认
    var orderType = 1
    /// 维修单号
    var repairOrderNum = ""
    /// 维修单id
    var repairOrderId = ""
    /// 单位id
    var bUnitId = 0
    /// repairState：维修状态：  未确认  1 未开工 2 已开工 3 已完工
    var repairStateStr = ""
    /// qualityState：质量检测状态 1 未质检 2 待质检 3 已通过  不通过
    var qualityStateStr = ""
    /// 预计出厂时间
    var predictDate: TimeInterval = 0 {
        didSet {
            predictDateString = Date.dateWith(timeInterval: predictDate).stringWith(formatStr: "yyyy/MM/dd HH:mm")
        }
    }
    var predictDateString = ""
    /// 车牌号
    var numberPlate = ""
    /// 客户姓名
    var customerName = ""
    /// 客户等级 0-10
    var customerLevel = 0
    /// newItem： 是否有新的添加的项目 1 无 2 维修单中新增 3 施工单中新增
    var newItem = 1
    /// 客户性别
    var customerSex: Sex = .man
    /// 客户头像
    var customerPortrait = ""
    
    /// 是否已作废
    var isInvalid = false
    
    init(_ json: JSON, type: RepairOrderListType) {
        super.init()
        self.type = type
        repairOrderNum = json["repairOrderNum"].stringValue
        repairOrderId = json["repairOrderId"].stringValue
        staffName = json["staffName"].stringValue
        orderType = json["orderType"].intValue
        repairStateStr = json["repairStateStr"].stringValue
        qualityStateStr = json["qualityStateStr"].stringValue
        numberPlate = json["numberPlate"].stringValue
        customerName = json["customerName"].stringValue
        customerPortrait = json["customerPortrait"].stringValue
        customerSex = Sex(rawValue: json["customerSex"].intValue) ?? .man
        customerLevel = json["customerLevel"].intValue
        newItem = json["newItem"].intValue
        predictDate = json["predictDate"].doubleValue
        predictDateString = Date.dateWith(timeInterval: predictDate).stringWith(formatStr: "yyyy/MM/dd HH:mm")
        bUnitId = json["bUnitId"].intValue
        isInvalid = json["invalidAuditState"].intValue == 3
        
    }
}
