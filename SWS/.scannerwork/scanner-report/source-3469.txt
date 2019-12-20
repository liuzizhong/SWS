
//
//  SW_CustomerAccessTypeChartModel.swift
//  SWS
//
//  Created by jayway on 2018/9/10.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_CustomerAccessTypeChartModel: SW_BaseChartModel {
    /// 客户接待数据 datatype：1
    var accessTypeDatas = [SW_CustomerAccessTypeChartDataModel]()
    /// 销售接待总人数
    var saleTotal = 0
    /// 电话访问总人数
    var phoneTotal = 0
    /// 试乘试驾总人数
    var testDriveTotal = 0
    /// 上门访问总人数
    var visitTotal = 0
    /// 车展访问总人数
    var autoShowTotal = 0
    /// 接待总人数
    var total = 0
    
    var dateString = ""
    
    init(_ lineChartModel:SW_CustomerLineChartModel, accessTypeJson: JSON?) {
        super.init()
        if lineChartModel.data.count > 0 {/// 先生成对应的条数，具体数值后面设置
            accessTypeDatas = lineChartModel.data[0].value.map { (model) -> SW_CustomerAccessTypeChartDataModel in
                return SW_CustomerAccessTypeChartDataModel(model.id, name: model.name, color: model.color)
            }
            setValue(accessTypeJson: accessTypeJson)
        }
    }
    
    /// 设置具体的数值
    func setValue(accessTypeJson: JSON?) {
        if let accessTypeJson = accessTypeJson {
            total = accessTypeJson["total"].intValue
            saleTotal = accessTypeJson["saleTotal"].intValue
            phoneTotal = accessTypeJson["phoneTotal"].intValue
            testDriveTotal = accessTypeJson["testDriveTotal"].intValue
            visitTotal = accessTypeJson["visitTotal"].intValue
            autoShowTotal = accessTypeJson["autoShowTotal"].intValue
            
            accessTypeJson["list"].arrayValue.forEach { (jsonDict) in
                if let index = self.accessTypeDatas.index(where: { return $0.id == jsonDict["id"].intValue }) {
                    self.accessTypeDatas[index].setValue(json: jsonDict)
                }
            }
            self.accessTypeDatas.sort(by: { return $0.totalCount > $1.totalCount })
        }
    }
    
    
    func getValue(_ cardType: AccessTypeChartType) -> Int {
        switch cardType {
        case .reception:
            return total
        case .saleAccess:
            return saleTotal
        case .testDrive:
            return testDriveTotal
        case .telephone:
            return phoneTotal
        case .visit:
            return visitTotal
        case .autoShow:
            return autoShowTotal
        }
    }
    
    func getColumns(_ cardType: AccessTypeChartType) -> [String] {
        switch cardType {
        case .reception:
            return ["名称","人数"]
        case .saleAccess:
            return ["名称","次数","首次","邀约","时长"]
        case .testDrive:
            return ["名称","次数","试驾率","时长"]
        case .telephone:
            return ["名称","次数","时长"]
        case .visit:
            return ["名称","次数","时长"]
        case .autoShow:
            return ["名称","次数","时长"]
        }
    }
    
    func getRows(_ cardType: AccessTypeChartType) -> [[Any]] {
        var rows = [[Any]]()
        for data in accessTypeDatas {
            
            switch cardType {
            case .reception:
                rows.append([data.name,data.totalCount])
//                return ["名称","人数"]
            case .saleAccess:
                rows.append([data.name,data.saleAccessCount,data.firstComeStroeCount,data.inviteComeStroeCount,data.saleAccessAvgDuration])
//                return ["名称","次数","首次","邀约","时长"]
            case .testDrive:
                rows.append([data.name,data.testDriveCount,data.testDrivePercent,data.testDriveAvgDuration])
//                return ["名称","次数","试驾率","时长"]
            case .telephone:
                rows.append([data.name,data.telephoneCount,data.telephoneAvgDuration])
//                return ["名称","次数","时长"]
            case .visit:
                rows.append([data.name,data.visitCount,data.visitAvgDuration])
//                return ["名称","次数","时长"]
            case .autoShow:
                rows.append([data.name,data.autoShowCount,data.autoShowAvgDuration])
//                return ["名称","次数","时长"]
            }
        }
        return rows
    }
}

class SW_CustomerAccessTypeChartDataModel: NSObject {
    
    var id = 0
    /// 首次到店人数
    var firstComeStroeCount = 0
    /// 接访人数
    var totalCount = 0
    /// 车展访问人数
    var autoShowCount = 0
    /// 销售接待人数
    var saleAccessCount = 0
    /// 试乘试驾人数
    var testDriveCount = 0
    /// 电话访问人数
    var telephoneCount = 0
    /// 邀约到店人数
    var inviteComeStroeCount = 0
    /// 上门访问人数
    var visitCount = 0
    /// 电话访问平均时长
    var telephoneAvgDuration = "00:00"
    /// 车展访问平均时长
    var autoShowAvgDuration = "00:00"
    /// 销售接待平均时长
    var saleAccessAvgDuration = "00:00"
    /// 上门访问平均时长
    var visitAvgDuration = "00:00"
    /// 试乘试驾平均时长
    var testDriveAvgDuration = "00:00"
    /// 试乘试驾率
    var testDrivePercent = "0%"
    /// 名字
    var name = ""
    /// 颜色
    var color = UIColor.clear
    
    init(_ id: Int, name: String, color: UIColor) {
        super.init()
        self.id = id
        self.name = name
        self.color = color
    }
    
    func setValue(json: JSON) {
        totalCount = json["totalCount"].intValue
        firstComeStroeCount = json["firstComeStroeCount"].intValue
        autoShowCount = json["autoShowCount"].intValue
        saleAccessCount = json["saleAccessCount"].intValue
        testDriveCount = json["testDriveCount"].intValue
        telephoneCount = json["telephoneCount"].intValue
        inviteComeStroeCount = json["inviteComeStroeCount"].intValue
        visitCount = json["visitCount"].intValue
        telephoneAvgDuration = json["telephoneAvgDuration"].stringValue
        autoShowAvgDuration = json["autoShowAvgDuration"].stringValue
        saleAccessAvgDuration = json["saleAccessAvgDuration"].stringValue
        visitAvgDuration = json["visitAvgDuration"].stringValue
        testDriveAvgDuration = json["testDriveAvgDuration"].stringValue
        testDrivePercent = json["testDrivePercent"].stringValue + "%"
        name = json["name"].stringValue
    }
    
    func getValue(_ cardType: AccessTypeChartType) -> Int {
        switch cardType {
        case .reception:
            return totalCount
        case .saleAccess:
            return saleAccessCount
        case .testDrive:
            return testDriveCount
        case .telephone:
            return telephoneCount
        case .visit:
            return visitCount
        case .autoShow:
            return autoShowCount
        }
    }
}

