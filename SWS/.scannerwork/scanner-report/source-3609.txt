//
//  SW_AfterSaleCustomerModel.swift
//  SWS
//
//  Created by jayway on 2019/2/23.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_AfterSaleCustomerModel: NSObject {
    //MARK: - 客户基本信息
    /// 客户id
    var id = ""
    /// vin：车架号
    var vin = ""
    /// numberPlate：车牌号
    var numberPlate = ""
    /// bUnitName：单位ID
    var bUnitId = 0
    /// upholsteryColor：内饰颜色
    var upholsteryColor = ""
    /// 客户vip级别  0-10
    var customerLevel = 0
    /// 客户性别
    var sex: Sex = .man
    /// 客户姓名
    var customerName = ""
    /// 购车时间
    var buyCarDate: TimeInterval = 0
    /// 客户手机号
    var phoneNum = ""
    /// 送修人手机号
    var senderPhone = ""
    /// 里程数
    var mileage = 0
    /// 维修车型
    var carBrand = ""
    var carSeries = ""
    var carModel = ""
    var carColor = ""
    /// 客户头像
    var portrait = ""
    
    /// 接待记录列表
    var recordDatas = [SW_AfterSaleAccessRecordListModel]()
    /// 接待记录总数
    var recordTotalCount = 0
    
    /// 维修记录列表
    var repairOrderRecordDatas = [SW_RepairOrderRecordListModel]()
    /// 维修记录总数
    var repairOrderRecordTotalCount = 0
    
    override init() {
        super.init()
    }
    
    init(_ json: JSON) {
        super.init()
        
        let afterSaleVisitRecord = json["afterSaleVisitRecordMap"]
        recordDatas = afterSaleVisitRecord["list"].arrayValue.map({ (value) -> SW_AfterSaleAccessRecordListModel in
            return SW_AfterSaleAccessRecordListModel(value)
        })
        recordTotalCount = afterSaleVisitRecord["count"].intValue
        
        let repairOrderRecord = json["repairOrderRecordMap"]
        repairOrderRecordDatas = repairOrderRecord["list"].arrayValue.map({ (value) -> SW_RepairOrderRecordListModel in
            return SW_RepairOrderRecordListModel(value)
        })
        repairOrderRecordTotalCount = repairOrderRecord["count"].intValue
        
        let repairOrder = json["repairOrder"]
        id = repairOrder["customerId"].stringValue
        vin = repairOrder["vin"].stringValue
        numberPlate = repairOrder["numberPlate"].stringValue
        customerName = repairOrder["customerName"].stringValue
        bUnitId = repairOrder["bUnitId"].intValue
        carBrand = repairOrder["carBrand"].stringValue
        carSeries = repairOrder["carSeries"].stringValue
        carModel = repairOrder["carModel"].stringValue
        carColor = repairOrder["carColor"].stringValue
        upholsteryColor = repairOrder["upholsteryColor"].stringValue
        customerLevel = repairOrder["customerLevel"].intValue
        buyCarDate = repairOrder["buyCarDate"].doubleValue
        mileage = repairOrder["mileage"].intValue
        numberPlate = repairOrder["numberPlate"].stringValue
        phoneNum = repairOrder["customerPhoneNum"].stringValue
        senderPhone = repairOrder["senderPhone"].stringValue
        sex = Sex(rawValue: repairOrder["customerSex"].intValue) ?? .man
        portrait = repairOrder["customerPortrait"].stringValue
    }

}

