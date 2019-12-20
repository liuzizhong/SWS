//
//  SW_AfterSaleCustomerListModel.swift
//  SWS
//
//  Created by jayway on 2019/2/23.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_AfterSaleCustomerListModel: NSObject {
    

//    "bUnitId": 1,
//    "upholsteryColor": "米色",
//    "carColor": "白色",


    
    /// 维修订单id
    var repairOrderId = ""
    /// 客户id
    var id = ""
    
    /// 客户性别
    var sex: Sex = .man
    /// 客户姓名
    var realName = ""
    /// 车架号
    var vin = ""
    /// 车牌
    var numberPlate = ""
    /// 客户等级 0-10  ///0不是vip
    var customerLevel: Int = 0
    /// 上次接访时间
    var lastVisitDate: TimeInterval = 0 {
        didSet {
            setLastAccessDateString()
        }
    }
    /// 上次接访时间字符串
    var lastVisitDateString = ""
    
    /// 客户头像
    var portrait = ""
    /// 车品牌
    var carBrand = ""
    /// 车系
    var carSeries = ""
    /// 车型
    var carModel = ""
    /// 车身颜色
    var carColor = ""
    /// 所在单位id
    var bUnitId = 0
    /// 是否待处理
    var  isHandle = false
    
    init(_ json: JSON) {
        super.init()
        repairOrderId = json["repairOrderId"].stringValue
        id = json["customerId"].stringValue
        realName = json["customerName"].stringValue
        sex = Sex(rawValue: json["customerSex"].intValue) ?? .man
        portrait = json["customerPortrait"].stringValue
        vin = json["vin"].stringValue
        numberPlate = json["numberPlate"].stringValue
        customerLevel = json["customerLevel"].intValue
        lastVisitDate = json["lastVisitDate"].doubleValue
        bUnitId = json["bUnitId"].intValue
        carBrand = json["carBrand"].stringValue
        carSeries = json["carSeries"].stringValue
        carModel = json["carModel"].stringValue
        carColor = json["carColor"].stringValue
        setLastAccessDateString()
        isHandle = json["isHandle"].intValue == 1
    }
    
    private func setLastAccessDateString() {
        lastVisitDateString = lastVisitDate == 0 ? "无" : Date.dateWith(timeInterval: lastVisitDate).stringWith(formatStr: "yyyy/MM/dd HH:mm")
    }
}
