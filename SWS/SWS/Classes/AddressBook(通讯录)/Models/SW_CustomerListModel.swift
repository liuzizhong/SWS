//
//  SW_CustomerListModel.swift
//  SWS
//
//  Created by jayway on 2018/8/20.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

/// 客户类型
///
/// - temp: 临时客户 未归档
/// - real: 已归档客户
enum CustomerType: Int {
    case temp = 1
    case real
}

class SW_CustomerListModel: NSObject {

    /// 客户id
    var id = ""
    /// 客户性别
    var sex: Sex = .man
    /// 客户姓名
    var realName = ""
    
    /// 客户职务
    var occupation = ""
    /// 客户等级 H A B C O F
    var level: CustomerLevel = .none
    /// 上次接访时间
    var lastAccessDate: TimeInterval = 0 {
        didSet {
            setLastAccessDateString()
        }
    }
    /// 上次接访时间字符串
    var lastAccessDateString = ""
    /// 访问状态  0 无   1待访问
    var accessState = 0
    /// 是否正在接待
    var accessing = false {
        didSet {
            setLastAccessDateString()
        }
    }
    /// true 时需要显示  待访问
    var  isHandle = false
    /// 线索创建时间
    var createDate: TimeInterval = 0
    /// 客户类型
    var customerType: CustomerType = .temp
    /// 客户头像
    var portrait = ""
    /// 临时客户编号
    var customerTempNum = ""
    /// 是否关注客户
    var isFollow = false
    /// 意向品牌
    var likeCarBrand = ""
    // 意向车系
    var likeCarSeries = ""
    // 意向车型
    var likeCarModel = ""
    /// 资料完整度
    var dataPercentage: Int = 0
    /// 临时客户是否调档中   true 调档中
    var applyChangeState = false
    /// 客户顾问id   用于获取访问记录列表
    var consultantInfoId = 0
    /// 后台结束的记录ID
    var processRecordId = ""
    
    init(_ json: JSON) {
        super.init()
        customerType = CustomerType(rawValue: json["customerType"].intValue) ?? .real
        id = json["id"].stringValue
        realName = json["realName"].stringValue
        portrait = json["portrait"].stringValue
        customerTempNum = json["customerTempNum"].stringValue
        occupation = json["occupation"].stringValue
        level = CustomerLevel(rawValue: json["level"].intValue) ?? .none
        sex = Sex(rawValue: json["sex"].intValue) ?? .man
        lastAccessDate = json["lastAccessDate"].doubleValue
        isFollow = json["isFollow"].intValue == 1
        accessing = json["accessing"].intValue == 1
        isHandle = json["isHandle"].intValue == 1
        applyChangeState = json["applyChangeState"].intValue == 1
        likeCarBrand = json["likeCarBrand"].stringValue
        likeCarSeries = json["likeCarSeries"].stringValue
        likeCarModel = json["likeCarModel"].stringValue
        dataPercentage = Int(json["dataPercentage"].stringValue) ?? 0
        consultantInfoId = json["consultantInfoId"].intValue
        setLastAccessDateString()
        accessState = json["accessState"].intValue
        processRecordId = json["processRecordId"].stringValue
        createDate = json["createDate"].doubleValue
    }
    
    private func setLastAccessDateString() {
        if lastAccessDate == 0 {
            lastAccessDateString = accessing ? "正在接访":"无"
        } else {
            lastAccessDateString = accessing ? "正在接访":Date.dateWith(timeInterval: lastAccessDate).stringWith(formatStr: "yyyy/MM/dd HH:mm")
        }
    }
}
