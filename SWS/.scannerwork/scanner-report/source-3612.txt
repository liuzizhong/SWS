//
//  SW_AccessCustomerRecordModel.swift
//  SWS
//
//  Created by jayway on 2018/8/21.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_AccessCustomerRecordModel: NSObject {
    
    /// 记录id
    var id = ""
    /// 客户ID
    var customerId = ""
    /// 访问方式
    var accessType = AccessType.none
    /// 访问开始时间
    var startDate: TimeInterval = 0
    /// 访问结束时间
    var endDate: TimeInterval = 0
    /// 访问接待记录内容
    var recordContent = ""
    /// 接访时长
    var duration = ""
    
    /// 到店类型   邀约
    var comeStoreType = ComeStoreType.none
    /// 满意度
    var satisfaction = SatisfactionType.none
    /// 是否有试乘试驾
    var isTestDrive = ""
    /// 到店人数
    var customerCount = 0
    /// 投诉处理状态
    var complaintState: ComplaintState = .pass
    /// 客户评分项目
    var customerServingItemScores = [SW_CustomerScoreModel]()
    /// 客户非评分项目
    var nonGrandedItems = [SW_NonGradedItemsModel]()
    /// 客户投诉记录
    var complaintRecords = [SW_ComplaintsModel]()
    
    var getScore: Double {
        get {
            return customerServingItemScores.reduce(0, { (result, model) -> Double in
                return result + model.score
            })
        }
    }
    
    /// 试乘试驾图片key
    var testDriveContractImg = ""
    /// 车架号
    var testCarVIN = ""
    /// 试驾车品牌
    var testCarBrand = ""
    /// 试驾车系
    var testCarSeries = ""
    /// 试驾车型
    var testCarModel = ""
    /// 试驾车颜色
//    var testCarColor = ""
    var testCar: String {
        get {
            return testCarBrand + " " + testCarSeries + " " + testCarModel
        }
    }
    /// 试乘试驾 所属的 销售接待ID
    var testDriveRecordId = ""
    
    /// 选择试驾车时使用
    var testCarNumberPlate = ""
    var testCarKeyNum = ""
    
    //MARK: - 试乘试驾详情页属性
    /// 其他意见内容
    var testDriveContent = ""
    /// 服务综合评分
    var serviceAverageScore: Float = 0
    /// 服务评分项
    var serviceItemList = [NormalModel]()
    /// 汽车综合评分
    var carAverageScore: Float = 0
    /// 汽车评分项
    var carItemList = [NormalModel]()
    
    
    override init() {
        super.init()
    }

    init(_ json: JSON) {
        super.init()
        id = json["id"].stringValue
        accessType = AccessType(rawValue: json["accessType"].intValue) ?? .none
        startDate = json["startDate"].doubleValue
        endDate = json["endDate"].doubleValue
        recordContent = json["recordContent"].stringValue
        duration = json["duration"].stringValue
        comeStoreType = ComeStoreType(rawValue: json["comeStoreType"].intValue) ?? .none
        satisfaction = SatisfactionType(rawValue: json["satisfaction"].intValue) ?? .none
        isTestDrive = json["isTestDrive"].stringValue
        customerCount = json["customerCount"].intValue
        
        testCarVIN = json["testCarVIN"].stringValue
        testDriveContent = json["testDriveContent"].stringValue
        testCarBrand = json["testCarBrand"].stringValue
        testCarSeries = json["testCarSeries"].stringValue
        testCarModel = json["testCarModel"].stringValue
//        testCarColor = json["testCarColor"].stringValue
        serviceAverageScore = json["serviceAverageScore"].floatValue
        carAverageScore = json["carAverageScore"].floatValue
        serviceItemList = json["serviceItemList"].arrayValue.map({ (item) -> NormalModel in
            let model = NormalModel(item)
            model.value = CGFloat(item["score"].intValue)
            return model
        })
        carItemList = json["carItemList"].arrayValue.map({ (item) -> NormalModel in
            let model = NormalModel(item)
            model.value = CGFloat(item["score"].intValue)
            return model
        })
        nonGrandedItems = json["customerServingItemNonScores"].arrayValue.map({ (item) -> SW_NonGradedItemsModel in
            return SW_NonGradedItemsModel(item)
        })
        customerServingItemScores = json["customerServingItemScores"].arrayValue.map({ (item) -> SW_CustomerScoreModel in
            return SW_CustomerScoreModel(item)
        })
        complaintRecords = json["complaintRecords"].arrayValue.map({ (item) -> SW_ComplaintsModel in
            return SW_ComplaintsModel(item)
        })
        if complaintRecords.count > 0 {
            complaintState = complaintRecords.first!.auditState
        }
    }

}
