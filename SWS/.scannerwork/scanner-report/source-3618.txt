//
//  SW_CustomerModel.swift
//  SWS
//
//  Created by jayway on 2018/8/20.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

@objc class SW_CustomerModel: NSObject {
    /// 客户id
    var id = ""
    /// 客户顾问id   对应员工id
    var consultantInfoId = 0
    /// 客户意向信息ID
    var customerIntentionId = ""
    /// 客户性别
    var sex: Sex = .man
    /// 客户姓名
    var realName = ""
    /// 客户职务
    var occupation = ""
    /// 客户手机号
    var phoneNum = ""
    /// 客户等级 H A B C O F
    var level: CustomerLevel = .none {
        didSet {
            calculateDataPercentage()
        }
    }
    /// 上次接访时间
    var lastAccessDate: TimeInterval = 0 {
        didSet {
            setLastAccessDateString()
        }
    }
    var lastAccessDateString = ""
    /// 接访客户记录条数
    var accessCustomerRecord = 0
    /// 生日提醒
    var birthdayRemind = false
    /// 客户来源
    var customerSource: CustomerSource = .none {
        didSet {
            if customerSource != .networkPhone {
                customerSourceSite = .none
            }
            calculateDataPercentage()
        }
    }
    /// 客户来源网址
    var customerSourceSite = CustomerSourceSite.none
    /// 内饰喜好  颜色等
    var interiorColor = "" {
        didSet {
            calculateDataPercentage()
        }
    }
    /// 客户特征
    var characteristics = ""
    /// 使用者
    var carUser = "" {
        didSet {
            calculateDataPercentage()
        }
    }
    /// 使用者性别
    var userSex = Sex.unkown {
        didSet {
            calculateDataPercentage()
        }
    }
    /// 主要用途
    var useFor = UseforType.none {
        didSet {
            calculateDataPercentage()
        }
    }
    /// 购买数量
    var buyCount = 0
    /// 购买预算
    var buyBudget = 0 {
        didSet {
            calculateDataPercentage()
        }
    }
    /// 购买方式
    var buyWay = BuyWay.none {
        didSet {
            calculateDataPercentage()
        }
    }
    /// 购买时间
    var buyDate: TimeInterval = 0 {
        didSet {
            calculateDataPercentage()
        }
    }
    var buyDateString = ""
    /// 购买类型
    var buyType = BuyType.none {
        didSet {
            if buyType != .replace {
                replaceCarBrand = ""
                replaceCarSeries = ""
//                replaceCarModel = ""
            }
            calculateDataPercentage()
        }
    }
    /// 核心问题
    var keyProblem = "" {
        didSet {
            calculateDataPercentage()
        }
    }
    /// 意向车型
    var likeCarBrand = "" {
        didSet {
            calculateDataPercentage()
        }
    }
    var likeCarBrandId = ""
    var likeCarSeries = ""
    var likeCarModel = ""
    /// 外色喜好
    var likeCarColor = "" {
        didSet {
            calculateDataPercentage()
        }
    }
    var likeCar: String {
        get {
            return likeCarBrand + " " + likeCarSeries + " " + likeCarModel
        }
    }
    /// 对比车型
    var contrastCarBrand = "" {
        didSet {
            calculateDataPercentage()
        }
    }
    var contrastCarSeries = ""
//    var contrastCarModel = ""
    var contrastCar: String {
        get {
            return contrastCarBrand + " " + contrastCarSeries// + " " + contrastCarModel
        }
    }
    /// 现有车型
    var havedCarBrand = "" {
        didSet {
            calculateDataPercentage()
        }
    }
    var havedCarSeries = ""
//    var havedCarModel = ""
    var havedCar: String {
        get {
            return havedCarBrand + " " + havedCarSeries// + " " + havedCarModel
        }
    }
    /// 置换车型
    var replaceCarBrand = ""
    var replaceCarSeries = ""
//    var replaceCarModel = ""
    var replaceCar: String {
        get {
            return replaceCarBrand + " " + replaceCarSeries// + " " + replaceCarModel
        }
    }
    var province = ""
    var city = ""
    
    //MARK: -  接待状态数据
    /// 销售接待记录id  --  正在进行的才有
    var accessRecordId = ""
    /// 正在进行的销售接待开始时间
    var accessStartDate: TimeInterval = 0 {
        didSet {
            setLastAccessDateString()
        }
    }
    /// 试乘试驾记录id  --  正在进行的才有
    var tryDriveRecordId = ""
    /// 最新一条的试乘试驾开始时间
    var tryDriveStartDate: TimeInterval = 0
    /// 最新一条试驾的结束时间，可能为0
    var tryDriveEndDate: TimeInterval = 0
    /// 试驾车名称 -评价时使用
    var testCar = ""
    
    /// 客户头像
    var portrait = ""
    /// 临时客户编号
    var customerTempNum = ""
    /// 是否关注客户
    var isFollow = false
    /// 资料完整度
    @objc var dataPercentage: Int = 0
    
    /// 新建临时客户时使用，客户对应销售顾问的名字
    var staffName = ""
    /// 新建临时客户时使用，客户对应销售顾问的id
    var staffId = 0
    
    var createDate: TimeInterval = 0
    
    override init() {
        super.init()
    }
    
    init(_ json: JSON) {
        super.init()
        id = json["id"].stringValue
        customerIntentionId = json["customerIntentionId"].stringValue
        consultantInfoId = json["consultantInfoId"].intValue
        realName = json["realName"].stringValue
        occupation = json["occupation"].stringValue
        phoneNum = json["phoneNum"].stringValue
        level = CustomerLevel(rawValue: json["level"].intValue) ?? .none
        sex = Sex(rawValue: json["sex"].intValue) ?? .man
        lastAccessDate = json["lastAccessDate"].doubleValue
        setLastAccessDateString()
        accessCustomerRecord = json["accessCustomerRecord"].intValue
        birthdayRemind = json["birthdayRemind"].intValue == 1
        customerSource = CustomerSource(rawValue: json["customerSource"].intValue) ?? .none
        customerSourceSite = CustomerSourceSite(rawValue:json["customerSourceSite"].intValue) ?? .none
        interiorColor = json["interiorColor"].stringValue
        characteristics = json["characteristics"].stringValue
        carUser = json["carUser"].stringValue
        userSex = Sex(rawValue: json["userSex"].intValue) ?? .unkown
        useFor = UseforType(rawValue: json["useFor"].intValue) ?? .none
        buyCount = json["buyCount"].intValue
        buyBudget = json["buyBudget"].intValue
        buyWay = BuyWay(rawValue: json["buyWay"].intValue) ?? .none
        buyDate = json["buyDate"].doubleValue
        if buyDate != 0 {
            buyDateString = Date.dateWith(timeInterval: buyDate).simpleTimeString(formatter: .year)
        }
        buyType = BuyType(rawValue: json["buyType"].intValue) ?? .none
        keyProblem = json["keyProblem"].stringValue
        likeCarBrand = json["likeCarBrand"].stringValue
        likeCarBrandId = json["likeCarBrandId"].stringValue
        likeCarSeries = json["likeCarSeries"].stringValue
        likeCarModel = json["likeCarModel"].stringValue
        likeCarColor = json["likeCarColor"].stringValue
        contrastCarBrand = json["contrastCarBrand"].stringValue
        contrastCarSeries = json["contrastCarSeries"].stringValue
//        contrastCarModel = json["contrastCarModel"].stringValue
//        contrastCarColor = json["contrastCarColor"].stringValue
        havedCarBrand = json["havedCarBrand"].stringValue
        havedCarSeries = json["havedCarSeries"].stringValue
//        havedCarModel = json["havedCarModel"].stringValue
//        havedCarColor = json["havedCarColor"].stringValue
        replaceCarBrand = json["replaceCarBrand"].stringValue
        replaceCarSeries = json["replaceCarSeries"].stringValue
//        replaceCarModel = json["replaceCarModel"].stringValue
//        replaceCarColor = json["replaceCarColor"].stringValue
        province = json["province"].stringValue
        city = json["city"].stringValue
        createDate = json["createDate"].doubleValue
        isFollow = json["isFollow"].intValue == 1 ? true : false
        
        portrait = json["portrait"].stringValue
        dataPercentage = json["dataPercentage"].intValue
    }
    
    private func setLastAccessDateString() {
        if lastAccessDate == 0 {
            lastAccessDateString = accessStartDate != 0 ? "正在接访":"无"
        } else {
            lastAccessDateString = accessStartDate != 0 ? "正在接访":Date.dateWith(timeInterval: lastAccessDate).stringWith(formatStr: "yyyy/MM/dd HH:mm")
        }
    }
    
    /// 计算数据完成度 计算完成赋值给datapercentage
    private func calculateDataPercentage() {
        var tempDataPercentag = 0
        ///  必填信息占 40% 每个占8%
        if level != .none { tempDataPercentag += 8 }
        if customerSource != .none { tempDataPercentag += 8 }
        if likeCar != "  " { tempDataPercentag += 8 }
        if !keyProblem.isEmpty { tempDataPercentag += 8 }
        if !city.isEmpty { tempDataPercentag += 8 }
        
        /// 选填信息占 60%
//        选填信息填了的个数
        var optionCount = 0
        if contrastCar != "  " { optionCount += 1 }
        if buyDate != 0 { optionCount += 1 }
        if buyBudget != 0 { optionCount += 1 }
        if buyWay != .none { optionCount += 1 }
        if !likeCarColor.isEmpty { optionCount += 1 }
        if !interiorColor.isEmpty { optionCount += 1 }
        if useFor != .none { optionCount += 1 }
        if !carUser.isEmpty { optionCount += 1 }
//        if userSex != .unkown { optionCount += 1 }//使用者性别不参与计算
        if havedCar != "  " { optionCount += 1 }
        if buyType != .none { optionCount += 1 }
        
        tempDataPercentag +=  Int(ceil(Float(optionCount) / 10.0 * 60))
        
        setValue(min(tempDataPercentag, 100), forKeyPath: #keyPath(SW_CustomerModel.dataPercentage))

    }
    
    func setBeingAccessJson(_ json: JSON) {
        guard json.arrayValue.count > 0 else { return }//没数据之间return
        
        json.arrayValue.forEach { (dictJson) in
            switch dictJson["accessType"].intValue {
            case 4:
                accessRecordId = dictJson["accessCustomerRecordId"].stringValue
                accessStartDate = dictJson["startDate"].doubleValue
                tryDriveStartDate = dictJson["lastTestDriveStartDate"].doubleValue
                tryDriveEndDate = dictJson["lastTestDriveEndDate"].doubleValue
            case 5:
                testCar = dictJson["testCarBrand"].stringValue + " " + dictJson["testCarSeries"].stringValue + " " + dictJson["testCarModel"].stringValue + " " + dictJson["testCarColor"].stringValue
                tryDriveRecordId = dictJson["accessCustomerRecordId"].stringValue
                tryDriveStartDate = dictJson["startDate"].doubleValue
            default:
                break
            }
        }
        PrintLog("end set data")
    }
}

extension SW_CustomerModel: NSCopying {
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copyObj = SW_CustomerModel()
        copyObj.id = id
        copyObj.customerIntentionId = customerIntentionId
        copyObj.consultantInfoId = consultantInfoId
        copyObj.sex = sex
        copyObj.realName = realName
        copyObj.occupation = occupation
        copyObj.phoneNum = phoneNum
        copyObj.level = level
        copyObj.lastAccessDate = lastAccessDate
        copyObj.lastAccessDateString = lastAccessDateString
        copyObj.accessCustomerRecord = accessCustomerRecord
        copyObj.birthdayRemind = birthdayRemind
        copyObj.customerSource = customerSource
        copyObj.customerSourceSite = customerSourceSite
        copyObj.interiorColor = interiorColor
        copyObj.characteristics = characteristics
        copyObj.carUser = carUser
        copyObj.useFor = useFor
        copyObj.userSex = userSex
        copyObj.buyCount = buyCount
        copyObj.buyBudget = buyBudget
        copyObj.buyWay = buyWay
        copyObj.buyDate = buyDate
        copyObj.buyDateString = buyDateString
        copyObj.buyType = buyType
        copyObj.keyProblem = keyProblem
        copyObj.province = province
        copyObj.city = city
        copyObj.likeCarBrand = likeCarBrand
        copyObj.likeCarBrandId = likeCarBrandId
        copyObj.likeCarSeries = likeCarSeries
        copyObj.likeCarModel = likeCarModel
        copyObj.likeCarColor = likeCarColor
        copyObj.contrastCarBrand = contrastCarBrand
        copyObj.contrastCarSeries = contrastCarSeries
//        copyObj.contrastCarModel = contrastCarModel
//        copyObj.contrastCarColor = contrastCarColor
        copyObj.havedCarBrand = havedCarBrand
        copyObj.havedCarSeries = havedCarSeries
//        copyObj.havedCarModel = havedCarModel
//        copyObj.havedCarColor = havedCarColor
        copyObj.replaceCarBrand = replaceCarBrand
        copyObj.replaceCarSeries = replaceCarSeries
//        copyObj.replaceCarModel = replaceCarModel
//        copyObj.replaceCarColor = replaceCarColor
        return copyObj
    }
    
}
