//
//  SW_StatisticalService.swift
//  SWS
//
//  Created by jayway on 2018/7/23.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

/// 综合报表图表请求
class SW_ComprehensiveRequest: SWSRequest {
    override var apiURL: String {
        get {
            return SWSApiCenter.getFinanceBaseUrl() + "/api/app/integrativeRevenue"
        }
        set {
            super.apiURL = newValue
        }
        
    }
    override var encryptAPI: Bool {
        get {
            return false
        }
        set {
            super.encryptAPI = newValue
        }
    }
}

/// 售前售后报表图表请求
class SW_SaleOrderDataShowRequest: SWSRequest {
    override var apiURL: String {
        get {
            return SWSApiCenter.getFinanceBaseUrl() + "/api/app/saleOrderDataShow"
        }
        set {
            super.apiURL = newValue
        }
        
    }
    override var encryptAPI: Bool {
        get {
            return false
        }
        set {
            super.encryptAPI = newValue
        }
    }
}

/// 客户关系可视化请求
class SW_CustomerStatisticsRequest: SWSRequest {
    override var apiURL: String {
        get {
            return SWSApiCenter.getBaseUrl() + "/api/app/customerStatistics"
        }
        set {
            super.apiURL = newValue
        }
        
    }
    override var encryptAPI: Bool {
        get {
            return false
        }
        set {
            super.encryptAPI = newValue
        }
    }
}

class SW_StatisticalService: NSObject {
}

//MARK: - 综合营收分析
extension SW_StatisticalService {
///   获取折线图数据
//    {
//    "dateType":"查询时间类型 : 0日期/1月份/2年份",
//    "regionId":"分区id",
//    "endDate":"结束时间",
//    "deptId":"部门id",
//    "startDate":"开始时间",
//    "bUnitId":"单位id"
//    }
    class func getComprehensiveLineChart(dateType: DateType, accountsType: AccountsType, regionId: SW_FilterRegionModel?, bUnitId: SW_FilterUnitModel?, deptId: SW_FilterDeptModel?, startDate: TimeInterval, endDate: TimeInterval) -> SWSRequest {
        let request = SW_ComprehensiveRequest(resource: "getLineChart.json")
        request["accountsType"] = accountsType.rawValue
        request["dateType"] = dateType.rawValue
        request["startDate"] = startDate
        request["endDate"] = min(Date().getCurrentTimeInterval(), endDate)
        if let regionId = regionId {
            request["regionId"] = regionId.regionId
        }
        if let bUnitId = bUnitId {
            request["bUnitId"] = bUnitId.bUnitId
        }
        if let deptId = deptId {
            request["deptId"] = deptId.deptId
        }
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
///   获取总收入饼图数据
//    {
//    "regionId":"分区id",
//    "endDate":"结束时间",
//    "deptId":"部门id",
//    "startDate":"开始时间",
//    "bUnitId":"单位id"
//    }
    class func getRevenueAmountChart(regionId: SW_FilterRegionModel?, bUnitId: SW_FilterUnitModel?, deptId: SW_FilterDeptModel?, startDate: TimeInterval, endDate: TimeInterval) -> SWSRequest {
        let request = SW_ComprehensiveRequest(resource: "getRevenueAmountChart.json")
        request["startDate"] = startDate
        request["endDate"] = endDate
        if let regionId = regionId {
            request["regionId"] = regionId.regionId
        }
        if let bUnitId = bUnitId {
            request["bUnitId"] = bUnitId.bUnitId
        }
        if let deptId = deptId {
            request["deptId"] = deptId.deptId
        }
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    ///   获取总成本饼图数据
    //    {
    //    "regionId":"分区id",
    //    "endDate":"结束时间",
    //    "deptId":"部门id",
    //    "startDate":"开始时间",
    //    "bUnitId":"单位id"
    //    }
    class func getCostAmountChart(regionId: SW_FilterRegionModel?, bUnitId: SW_FilterUnitModel?, deptId: SW_FilterDeptModel?, startDate: TimeInterval, endDate: TimeInterval) -> SWSRequest {
        let request = SW_ComprehensiveRequest(resource: "getCostAmountChart.json")
        request["startDate"] = startDate
        request["endDate"] = endDate
        if let regionId = regionId {
            request["regionId"] = regionId.regionId
        }
        if let bUnitId = bUnitId {
            request["bUnitId"] = bUnitId.bUnitId
        }
        if let deptId = deptId {
            request["deptId"] = deptId.deptId
        }
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    ///   获取总利润饼图数据
    //    {
    //    "regionId":"分区id",
    //    "endDate":"结束时间",
    //    "deptId":"部门id",
    //    "startDate":"开始时间",
    //    "bUnitId":"单位id"
    //    }
//    class func getProfitTotal(regionId: SW_FilterRegionModel?, bUnitId: SW_FilterUnitModel?, deptId: SW_FilterDeptModel?, startDate: TimeInterval, endDate: TimeInterval) -> SWSRequest {
//        let request = SW_ComprehensiveRequest(resource: "getProfitTotal.json")
//        request["startDate"] = startDate
//        request["endDate"] = endDate
//        if let regionId = regionId {
//            request["regionId"] = regionId.regionId
//        }
//        if let bUnitId = bUnitId {
//            request["bUnitId"] = bUnitId.bUnitId
//        }
//        if let deptId = deptId {
//            request["deptId"] = deptId.deptId
//        }
//        request.send(.post).completion { (json, error) -> Any? in
//            if error == nil {
//                return json?["data"]
//            }
//            return json
//        }
//        return request
//    }
}

//MARK: -  订单数据可视化APP相关接口
extension SW_StatisticalService {
    
///   获取售前或者售后订单折线图数据
//    {
//    "dateType":"查询时间类型 : 0日期/1月份/2年份",
//    "orderTypeKey":"1 售前订单  2售后订单",
//    "regionId":"分区id",
//    "endDate":"结束时间",
//    "deptId":"部门id",
//    "startDate":"开始时间",
//    "bUnitId":"单位id"
//    }
    class func getSaleOrderDataShowLineChart(dateType: DateType, accountsType: AccountsType, orderTypeKey: Int, regionId: SW_FilterRegionModel?, bUnitId: SW_FilterUnitModel?, deptId: SW_FilterDeptModel?, startDate: TimeInterval, endDate: TimeInterval) -> SWSRequest {
        let request = SW_SaleOrderDataShowRequest(resource: "getLineChart.json")
        request["dateType"] = dateType.rawValue
        request["accountsType"] = accountsType.rawValue
        request["orderTypeKey"] = orderTypeKey
        request["startDate"] = startDate
        request["endDate"] = min(Date().getCurrentTimeInterval(), endDate)
        if let regionId = regionId {
            request["regionId"] = regionId.regionId
        }
        if let bUnitId = bUnitId {
            request["bUnitId"] = bUnitId.bUnitId
        }
        if let deptId = deptId {
            request["deptId"] = deptId.deptId
        }
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
///    获取售前或售后订单成本类型比例
//    {
//    "orderTypeKey":"1 售前订单  2售后订单",
//    "regionId":"分区id",
//    "endDate":"结束时间",
//    "startDate":"开始时间",
//    "bUnitId":"单位id"
//    }
    class func getSaleOrderCostType(orderTypeKey: Int, regionId: SW_FilterRegionModel?, bUnitId: SW_FilterUnitModel?, startDate: TimeInterval, endDate: TimeInterval) -> SWSRequest {
        let request = SW_SaleOrderDataShowRequest(resource: "getSaleOrderCostType.json")
        request["orderTypeKey"] = orderTypeKey
        request["startDate"] = startDate
        request["endDate"] = endDate
        if let regionId = regionId {
            request["regionId"] = regionId.regionId
        }
        if let bUnitId = bUnitId {
            request["bUnitId"] = bUnitId.bUnitId
        }
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    ///   获取售前或售后订单总利润数据
    //    {
    //    "orderTypeKey":"1 售前订单  2售后订单",
    //    "regionId":"分区id",
    //    "endDate":"结束时间",
    //    "startDate":"开始时间",
    //    "bUnitId":"单位id"
    //    }
    class func getSaleOrderRevenueAndCost(orderTypeKey: Int, regionId: SW_FilterRegionModel?, bUnitId: SW_FilterUnitModel?, startDate: TimeInterval, endDate: TimeInterval) -> SWSRequest {
        let request = SW_SaleOrderDataShowRequest(resource: "getSaleOrderRevenueAndCost.json")
        request["orderTypeKey"] = orderTypeKey
        request["startDate"] = startDate
        request["endDate"] = endDate
        if let regionId = regionId {
            request["regionId"] = regionId.regionId
        }
        if let bUnitId = bUnitId {
            request["bUnitId"] = bUnitId.bUnitId
        }
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    ///    获取售前或者售后订单 收入 成本 根据车型
    //    {
    //    "orderTypeKey":"1 售前订单  2售后订单",
    //    "regionId":"分区id",
    //    "endDate":"结束时间",
    //    "startDate":"开始时间",
    //    "bUnitId":"单位id"
    //    }
    class func getSaleOrderRevenueAndCostByCarModel(orderTypeKey: Int, regionId: SW_FilterRegionModel?, bUnitId: SW_FilterUnitModel?, startDate: TimeInterval, endDate: TimeInterval) -> SWSRequest {
        let request = SW_SaleOrderDataShowRequest(resource: "getSaleOrderRevenueAndCostByCarModel.json")
        request["orderTypeKey"] = orderTypeKey
        request["startDate"] = startDate
        request["endDate"] = endDate
        if let regionId = regionId {
            request["regionId"] = regionId.regionId
        }
        if let bUnitId = bUnitId {
            request["bUnitId"] = bUnitId.bUnitId
        }
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    ///    获取售前或售后订单收入类型比例
    //    {
    //    "orderTypeKey":"1 售前订单  2售后订单",
    //    "regionId":"分区id",
    //    "endDate":"结束时间",
    //    "startDate":"开始时间",
    //    "bUnitId":"单位id"
    //    }
    class func getSaleOrderRevenueType(orderTypeKey: Int, regionId: SW_FilterRegionModel?, bUnitId: SW_FilterUnitModel?, startDate: TimeInterval, endDate: TimeInterval) -> SWSRequest {
        let request = SW_SaleOrderDataShowRequest(resource: "getSaleOrderRevenueType.json")
        request["orderTypeKey"] = orderTypeKey
        request["startDate"] = startDate
        request["endDate"] = endDate
        if let regionId = regionId {
            request["regionId"] = regionId.regionId
        }
        if let bUnitId = bUnitId {
            request["bUnitId"] = bUnitId.bUnitId
        }
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
}

//MARK: - 客户关系可视化接口
extension SW_StatisticalService {
    
    ///   获取客户折线数据分析
    //    {
    //    "dateType":"查询时间类型 : 0日期/1月份/2年份",
    //    "regionId":"分区id",
    //    "endDate":"结束时间",
    //    "startDate":"开始时间",
    //    "bUnitId":"单位id"
    //    }
    class func getCustomerLineData(dateType: DateType, regionId: SW_FilterRegionModel?, bUnitId: SW_FilterUnitModel?, startDate: TimeInterval, endDate: TimeInterval) -> SWSRequest {
        let request = SW_CustomerStatisticsRequest(resource: "getCustomerLineData.json")
        request["dateType"] = dateType.rawValue
        request["startDate"] = startDate
        request["endDate"] = min(Date().getCurrentTimeInterval(), endDate)
        if let regionId = regionId {
            request["regionId"] = regionId.regionId
        }
        if let bUnitId = bUnitId {
            request["bUnitId"] = bUnitId.bUnitId
        }
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    ///   获取客户接待类型数据分析 --可以横向滑动的数据
    //    {
    //    "regionId":"分区id",
    //    "endDate":"结束时间",
    //    "startDate":"开始时间",
    //    "bUnitId":"单位id"
    //    }
    class func getCustomerAccessTypeData(regionId: SW_FilterRegionModel?, bUnitId: SW_FilterUnitModel?, startDate: TimeInterval, endDate: TimeInterval) -> SWSRequest {
        let request = SW_CustomerStatisticsRequest(resource: "getCustomerAccessTypeData.json")
        request["startDate"] = startDate
        request["endDate"] = min(Date().getCurrentTimeInterval(), endDate)
        if let regionId = regionId {
            request["regionId"] = regionId.regionId
        }
        if let bUnitId = bUnitId {
            request["bUnitId"] = bUnitId.bUnitId
        }
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
///   获取客户数据分析
//    {
//    "endDate":"结束时间",
//    "regionId":"分区id",
//    "dataType":"数据类型 1:客户接待 2:客户留存",
//    "startDate":"开始时间",
//    "bUnitId":"单位id"
//    }
    class func getCustomerReceptionData(dataType: Int, regionId: SW_FilterRegionModel?, bUnitId: SW_FilterUnitModel?, startDate: TimeInterval, endDate: TimeInterval) -> SWSRequest {
        let request = SW_CustomerStatisticsRequest(resource: "getCustomerReceptionData.json")
        request["dataType"] = dataType
        request["startDate"] = startDate
        request["endDate"] = endDate
        if let regionId = regionId {
            request["regionId"] = regionId.regionId
        }
        if let bUnitId = bUnitId {
            request["bUnitId"] = bUnitId.bUnitId
        }
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    ///   获取客户意向车型分析数据
    //    {
    //    "regionId":"分区id",
    //    "endDate":"结束时间",
    //    "startDate":"开始时间",
    //    "bUnitId":"单位id"
    //    }
    class func getCustomerLikeCarData(regionId: SW_FilterRegionModel?, bUnitId: SW_FilterUnitModel?, startDate: TimeInterval, endDate: TimeInterval) -> SWSRequest {
        let request = SW_CustomerStatisticsRequest(resource: "getCustomerLikeCarData.json")
        request["startDate"] = startDate
        request["endDate"] = min(Date().getCurrentTimeInterval(), endDate)
        if let regionId = regionId {
            request["regionId"] = regionId.regionId
        }
        if let bUnitId = bUnitId {
            request["bUnitId"] = bUnitId.bUnitId
        }
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    ///   获取客户来源分析数据
    //    {
    //    "regionId":"分区id",
    //    "endDate":"结束时间",
    //    "startDate":"开始时间",
    //    "bUnitId":"单位id"
    //    }
    class func getCustomerSourceData(regionId: SW_FilterRegionModel?, bUnitId: SW_FilterUnitModel?, startDate: TimeInterval, endDate: TimeInterval) -> SWSRequest {
        let request = SW_CustomerStatisticsRequest(resource: "getCustomerSourceData.json")
        request["startDate"] = startDate
        request["endDate"] = min(Date().getCurrentTimeInterval(), endDate)
        if let regionId = regionId {
            request["regionId"] = regionId.regionId
        }
        if let bUnitId = bUnitId {
            request["bUnitId"] = bUnitId.bUnitId
        }
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    ///   获取客户等级分析数据
    //    {
    //    "regionId":"分区id",
    //    "endDate":"结束时间",
    //    "startDate":"开始时间",
    //    "bUnitId":"单位id"
    //    }
    class func getCustomerLevelData(regionId: SW_FilterRegionModel?, bUnitId: SW_FilterUnitModel?, startDate: TimeInterval, endDate: TimeInterval) -> SWSRequest {
        let request = SW_CustomerStatisticsRequest(resource: "getCustomerLevelData.json")
        request["startDate"] = startDate
        request["endDate"] = min(Date().getCurrentTimeInterval(), endDate)
        if let regionId = regionId {
            request["regionId"] = regionId.regionId
        }
        if let bUnitId = bUnitId {
            request["bUnitId"] = bUnitId.bUnitId
        }
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
}







