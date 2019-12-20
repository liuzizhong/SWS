//
//  SW_WorkingService.swift
//  SWS
//
//  Created by jayway on 2018/4/26.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

/// 工作报告请求
class SW_WorkReportRequest: SWSRequest {
    override var apiURL: String {
        get {
            return SWSApiCenter.getBaseUrl() + "/api/app/workReport"
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

/// 营收报表请求
class SW_SaleOrderRequest: SWSRequest {
    override var apiURL: String {
        get {
            return SWSApiCenter.getFinanceBaseUrl() + "/api/app/saleOrder"
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

/// 营收报表请求
class SW_FlowSheetRequest: SWSRequest {
    override var apiURL: String {
        get {
            return SWSApiCenter.getFinanceBaseUrl() + "/api/app/flowSheet"
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

class SW_WorkingService: NSObject {
    
}

//MARK: - 公告模块接口
extension SW_WorkingService {
    // 根据查询参数获取公告列表
    // {keyWord:"关键词",msgTypeId:"公告类型id",max:10,offset:0,sort:"id",order:"desc",type:"0 只根据公告标题作为查询条件"}
    class func getInformList(_ msgTypeId: Int, staffId: Int, businessUnitId: Int, departmentId: Int, keyWord: String = "", max: Int = 20, offset: Int = 0) -> SW_MessageRequest {
        let request = SW_MessageRequest(resource: "list.json")
        request["msgTypeId"] = msgTypeId
        request["staffId"] = staffId
        request["businessUnitId"] = businessUnitId
        request["departmentId"] = departmentId
        request["keyWord"] = keyWord
        request["max"] = max
        request["offset"] = offset
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    // 发送公告信息-from 表单提交
    //"{publisherId:"发布者id",msgTypeId:"消息类型Id",title:"标题",content:"消息正文",summary:"摘要",fileBase64:"封面图片base64",fileName:"图片名称",sendList:"接收公告的id信息"} 如：{ type:"发送范围:0:分区,1:单位,2:部门,3:人员,"publisherId: 1115, title: "发送公告测试", content: "发送公告测试", summary: "摘111要111", fileName: "xxx.jpg", fileBase64: "iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAABC0lEQVRIibVVARLCIAyjvb7fF/hUN4QxOAjtgDnjccxBk7RFJPd6exfh09RjD4OPJwofhA+vyLdzDSlPRIYIN2QayntOFnzFw0RG1EOQQ80szxo88oTvUsjjPMpmZEQpMzeLf4A0xDMOR4A9Uje5q2EXu5Zl5BO/7/MB24aKyJjehUHnELeCUQYnedJK1VgTmBXKCCI83nUTP2WQD4PWg4xz7Z6ABRB8vMkEDT6O6ZIAECGYuSGPkJUT4SAYY7fPpwtrMsAUwbaq29wEaMjBVaEGKWJWTBxxv69u5mEPUMyqf1yLPUBjyz+04tBYQ4i1YVS6kUDeKzNuSvMv6XUjov7JgNMsRnxdUc3UF61qin1CqoMyAAAAAElFTkSuQmCC", sendList:"1,2,3,4" 说明:当type为2时,sendList格式为:"单位id_部门id" 如:"1_2,2_1" }
    class func sendInform(_ publisherId: Int, msgTypeId: Int, type: Int, title: String, content: String, fileBase64: String, fileName: String, sendList: String) -> SW_MessageRequest {
        let request = SW_MessageRequest(resource: "save.json")
        request["publisherId"] = publisherId
        request["msgTypeId"] = msgTypeId
        request["type"] = type
        request["title"] = title
        request["content"] = content
        request["fileBase64"] = fileBase64
        request["fileName"] = fileName
        request["sendList"] = sendList
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    //     是否已收藏该公告并更新阅读状态
    //     {msgId:"公告id",staffId:"员工id"} 如：{msgId:"1",staffId:"1115"}
    class func getIsCollectAndReadMsg(_ staffId: Int, msgId: Int) -> SW_MessageRequest {
        let request = SW_MessageRequest(resource: "isCollectAndReadMsg.json")
        request["staffId"] = staffId
        request["msgId"] = msgId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    //     收藏公告
    //     {msgId:"公告id",staffId:"员工id"} 如：{msgId:"1",staffId:"1115"}
    class func collectMsg(_ msgId: Int) -> SW_MessageRequest {
        let request = SW_MessageRequest(resource: "collectMsg.json")
        request["staffId"] = SW_UserCenter.shared.user!.id
        request["msgId"] = msgId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    //     取消收藏公告
    //     {msgId:"公告id",staffId:"员工id"} 如：{msgId:"1",staffId:"1115"}
    class func disCollectMsg(_ msgId: Int) -> SW_MessageRequest {
        let request = SW_MessageRequest(resource: "disCollectMsg.json")
        request["staffId"] = SW_UserCenter.shared.user!.id
        request["msgId"] = msgId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    //    根据id获取消息公告收藏列表
    //    {staffId:"staffId",max:10,offset:1,sort:"createDate",order:"desc"}
    class func getMsgCollectList(_ staffId: Int, max: Int = 20, offset: Int = 0, sort: String = "createDate", order: String = "desc") -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/msgCollect"
        request["staffId"] = staffId
        request["max"] = max
        request["offset"] = offset
        request["sort"] = sort
        request["order"] = order
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
//    获取公告阅读详情
    class func getInformReadRecord(_ informId: Int) -> SW_MessageRequest {
        let request = SW_MessageRequest(resource: "show.json")
        request["id"] = informId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
}

//MARK: - 营收报表模块接口
extension SW_WorkingService {
    //MARK: - 销售订单
    
//    {id:"","recoderId":1,"salesmanId":1,orderNo:"123",orderDate:"12312312",customerName:"李四",fromDeptId:"1",fromDeptName:"销售部",orderTypeKey:"1",salesman:"威哥",carBrand:"沃尔沃", carSerie:"S90",carModel:"T8尊贵版",carColor:"黑色",insuranceCompanyKey:"1",insuranceCompanyName:"中国平安",insuranceTypes:[{insuranceTypeId:"222",insuranceTypeName:"交强险",limitDate:12313454654}], "costList": [{"amount": 1600,"typeName": "广告支出","typeId": "13456465"}],"revenueList": [{"amount": 1600,"typeName": "广告收入","typeId": "13456465"}] }
    
    ///  保存每日订单
    ///
    /// - Parameter reportModel: 订单模型
    /// - Returns: 请求对象
    class func saveDayOrder(_ reportModel: SW_RevenueDetailModel) -> SW_SaleOrderRequest {
        let request = SW_SaleOrderRequest(resource: "save.json")
        if !reportModel.id.isEmpty {
            request["id"] = reportModel.id
        }
        request["recoder"] = SW_UserCenter.shared.user!.realName
        request["recoderId"] = SW_UserCenter.shared.user!.id
        request["orderNo"] = reportModel.orderNo
        request["orderDate"] = reportModel.orderDate
        request["customerName"] = reportModel.customerName
        request["fromDeptId"] = reportModel.fromDeptId
        request["fromDeptName"] = reportModel.fromDeptName
        request["orderTypeKey"] = reportModel.orderType.orderTypeKey
        request["salesman"] = reportModel.salesman
        request["salesmanId"] = reportModel.salesmanId
        request["carBrand"] = reportModel.carBrand.name
        request["carSerie"] = reportModel.carSerie.name
        request["carModel"] = reportModel.carModel.name
        request["carColor"] = reportModel.carColor.name
        request["carBrandId"] = reportModel.carBrand.id
        request["carSerieId"] = reportModel.carSerie.id
        request["carModelId"] = reportModel.carModel.id
        request["carColorId"] = reportModel.carColor.id
        if !reportModel.insuranceCompanyKey.isEmpty {//选择了保险公司才有这些数据
            request["insuranceCompanyKey"] = reportModel.insuranceCompanyKey
            request["insuranceCompanyName"] = reportModel.insuranceCompanyName
            request["insuranceTypes"] = reportModel.insuranceTypes.map({ return $0.toDict() })
        }
        let costList = reportModel.costList.filter({ return !$0.typeName.isEmpty })
        if costList.count > 0 {
            request["costList"] = costList.map({ return $0.toDict() })
        }
        let revenueList = reportModel.revenueList.filter({ return !$0.typeName.isEmpty })
        if revenueList.count > 0 {
            request["revenueList"] = revenueList.map({ return $0.toDict() })
        }
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 获取每日订单列表
//    {
//    "recoderId":"记录人id",
//    "keyWord":"订单编号/销售员姓名/部门名称"
//      }
    class func getSaleOrderList(keyWord: String = "", max: Int = 20, offset: Int = 0) -> SWSRequest {
        let request = SW_SaleOrderRequest(resource: "list.json")
        request["max"] = max
        request["offset"] = offset
        request["recoderId"] = SW_UserCenter.shared.user!.id
        request["keyWord"] = keyWord
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 请求路径    /api/app/saleOrder/show/{id}.json
    ///  描述信息    根据订单id 获取订单信息
    ///
    /// - Parameter orderId: 每日订单id
    /// - Returns: 请求
    class func getSaleOrderDetail(_ orderId: String) -> SWSRequest {
        let request = SW_SaleOrderRequest(resource: "show/\(orderId).json")
        request.disableCache = true
        request.send(.get).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 请求路径    /api/app/saleOrder/checkOrder/{id}.json
    ///  描述信息    校验订单是否可被修改
    ///
    /// - Parameter orderId: 每日订单id
    /// - Returns: 请求
    class func checkSaleOrder(_ orderId: String) -> SWSRequest {
        let request = SW_SaleOrderRequest(resource: "checkOrder/\(orderId).json")
        request.disableCache = true
        request.send(.get).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    //MARK: - 非订单报表
    
    //    {"id": "由uuid生成的唯一值,修改时必传","flowNo": "订单编号", "flowDate": "订单署期", "customerName": "客户姓名", "fromDeptId": "订单归属部门id", "fromDeptName": "订单归属部门名称", "flowDateType": "订单类型 // 1 日 2 月度 3 年度","salesman": "业务员姓名","recoder":"记录人姓名", "recoderId":"记录人id","salesmanId":"业务员id", "costList": [{"amount": "成本金额","typeName": "成本类型名字","typeId": "成本类型id"}, {"amount": "成本金额","typeName": "成本类型名字","typeId": "成本类型id"}], "revenueList":[{"amount": "收入金额","typeName": "收入类型名字","typeId": "收入类型id"}, {"amount": "收入金额","typeName": "收入类型名字","typeId": "收入类型id"}] } example:{id:"","recoderId":1,"salesmanId":1,"recoder":"粽子",flowDateType:1,flowNo:"123",flowDate:"12312312",customerName:"李四",fromDeptId:"1",fromDeptName:"销售部",salesman:"威哥", "costList": [{"amount": 1600,"typeName": "广告支出","typeId": "13456465"}],"revenueList": [{"amount": 1600,"typeName": "广告收入","typeId": "13456465"}] }
    
    ///  保存每（日/月/年）非订单报表
    ///
    /// - Parameter reportModel: 订单模型
    /// - Returns: 请求对象
    class func saveDayNonOrder(_ reportModel: SW_RevenueDetailModel) -> SW_FlowSheetRequest {
        let request = SW_FlowSheetRequest(resource: "save.json")
        if !reportModel.id.isEmpty {
            request["id"] = reportModel.id
        }
        request["recoder"] = SW_UserCenter.shared.user!.realName
        request["recoderId"] = SW_UserCenter.shared.user!.id
        request["flowNo"] = reportModel.orderNo
        request["flowDate"] = reportModel.orderDate
        if !reportModel.customerName.isEmpty {
            request["customerName"] = reportModel.customerName
        }
        if reportModel.fromDeptId != 0 {
            request["fromDeptId"] = reportModel.fromDeptId
            request["fromDeptName"] = reportModel.fromDeptName
        }
        request["flowDateType"] = reportModel.type.rawValue
        if !reportModel.salesman.isEmpty {
            request["salesman"] = reportModel.salesman
            request["salesmanId"] = reportModel.salesmanId
        }
        let costList = reportModel.costList.filter({ return !$0.typeName.isEmpty })
        if costList.count > 0 {
            request["costList"] = costList.map({ return $0.toDict() })
        }
        let revenueList = reportModel.revenueList.filter({ return !$0.typeName.isEmpty })
        if revenueList.count > 0 {
            request["revenueList"] = revenueList.map({ return $0.toDict() })
        }
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 获取每年月日非订单列表
//    {
//    "offset":0,
//    "max":10,
//    "flowDateType":"订单类型1 日 2 月度  3 年度",
//    "recoderId":"记录人id",
//    "keyWord":"销售员姓名/订单编号"
//    }
    class func getFlowSheetList(flowDateType: Int, keyWord: String = "", max: Int = 20, offset: Int = 0) -> SWSRequest {
        let request = SW_FlowSheetRequest(resource: "list.json")
        request["max"] = max
        request["offset"] = offset
        request["flowDateType"] = flowDateType
        request["recoderId"] = SW_UserCenter.shared.user!.id
        request["keyWord"] = keyWord
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    ///  获取每年月日非订单详情
    ///
    /// - Parameter orderId: 非订单id
    /// - Returns: 请求
    class func getFlowSheetDetail(_ orderId: String) -> SWSRequest {
        let request = SW_FlowSheetRequest(resource: "show/\(orderId).json")
        request.disableCache = true
        request.send(.get).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 请求路径    /api/app/saleOrder/checkOrder/{id}.json
    ///  描述信息    校验订单是否可被修改
    ///
    /// - Parameter orderId: 每日订单id
    /// - Returns: 请求
    class func checkFlowSheet(_ orderId: String) -> SWSRequest {
        let request = SW_FlowSheetRequest(resource: "checkOrder/\(orderId).json")
        request.disableCache = true
        request.send(.get).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    //MARK: - 获取填表中使用的各种类型数据列表
    /// 获取订单类型
    class func getOrderType() -> SWSRequest {
        let request = SWSRequest(resource: "getOrderType.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/orderType"
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 获取汽车品牌
//    {max:10,offset:0,type:0为单位已拥有的汽车品牌,busId:单位id}
    class func getCarBrand(_ type: Int = 0) -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/carBrand"
        request["max"] = 99999
        request["offset"] = 0
        if type == 0 {
            request["type"] = type
            request["busId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
        }
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 获取汽车系列
//    {max:10,offset:0,carBrandId:"汽车品牌id,必传"}
    class func getCarSeries(_ carBrandId: String) -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/carSeries"
        request["max"] = 9999
        request["offset"] = 0
        request["carBrandId"] = carBrandId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 获取汽车型号
    //    {max:10,offset:0,carSeriesId:"车系id,必传"} type:0为单位已拥有的汽车品牌,busId:单位id    saleState: 1在售 2 停售
    class func getCarModel(_ carSeriesId: String, type: Int = 1, saleState: Bool = false) -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/carModel"
        request["max"] = 9999
        request["offset"] = 0
        request["carSeriesId"] = carSeriesId
        if saleState {
            request["saleState"] = 1
        }
        if type == 0 {
            request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
        }
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 获取汽车颜色值
///    {max:10,offset:0,carBrandId:"汽车厂牌id,必传"}
    class func getCarProValue(_ carBrandId: String) -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/carProValue"
        request["max"] = 9999
        request["offset"] = 0
        request["carBrandId"] = carBrandId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 获取汽车内饰颜色值列表
    ///    {max:10,offset:0,carBrandId:"汽车厂牌id,必传"}
    class func getCarUpholsteryValue(_ carBrandId: String) -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/carUpholsteryValue"
        request["max"] = 9999
        request["offset"] = 0
        request["carBrandId"] = carBrandId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 获取试驾车列表
//    {
//    "offset":"0",
//    "max":"10",
//    "bUnitId":"单位id"
//    }
    class func getTestCar() -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/testCar"
        request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
        request["offset"] = 0
        request["max"] = 9999
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    /// 获取保险公司
    //    Object    {max:10,offset:0,sort:"id",order:"desc"}
    class func getInsuranceCompanys(_ bUnitId: Int) -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/insuranceCompany"
        request["max"] = 9999
        request["bUnitId"] = bUnitId
        request["offset"] = 0
        request["sort"] = "id"
        request["order"] = "desc"
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
//    保险类型列表
//    {max:10,offset:0,sort:"id",order:"desc",insuranceCompanyId:""}
    class func getInsuranceTypes(_ insuranceCompanyId: String) -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/insuranceType"
        request["max"] = 9999
        request["offset"] = 0
        request["sort"] = "id"
        request["order"] = "desc"
        request["insuranceCompanyId"] = insuranceCompanyId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
//        部门成本类型列表   日订单报表使用
//    {max:10,offset:0,sort:"id",order:"desc",depaId:"所属部门id"} /api/app/depCostType/list.json
    class func getDepCostTypes(_ depaId: Int) -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/depCostType"
        request["max"] = 9999
        request["offset"] = 0
        request["sort"] = "id"
        request["order"] = "desc"
        request["depaId"] = depaId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
//
    
    //        部门收入类型列表   日订单报表使用
    //    {max:10,offset:0,sort:"id",order:"desc",depaId:"所属部门id"} /api/app/depIncomeType/list.json
    class func getDepIncomeType(_ depaId: Int) -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/depIncomeType"
        request["max"] = 9999
        request["offset"] = 0
        request["sort"] = "id"
        request["order"] = "desc"
        request["depaId"] = depaId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
//
    
    //        单位成本类型列表   年月非订单报表使用
    //    {max:10,offset:0,sort:"id",order:"desc"}
    class func getBusUnitCostType() -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/busUnitCostType"
        request["max"] = 9999
        request["offset"] = 0
        request["sort"] = "id"
        request["order"] = "desc"
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    //        单位收入类型列表   年月非订单报表使用
    //     {max:10,offset:0,sort:"id",order:"desc"}
    class func getBusUnitIncomeType() -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/busUnitIncomeType"
        request["max"] = 9999
        request["offset"] = 0
        request["sort"] = "id"
        request["order"] = "desc"
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
}



//MARK: - 工作报告模块接口
extension SW_WorkingService {
    ///  保存工作报告  年、月、日
    ///
    /// - Parameter reportModel: 工作报告模型
    /// - Returns: 请求对象
    class func saveWorkReport(_ reportModel: SW_WorkReportModel) -> SWSRequest {
        let request = SW_WorkReportRequest(resource: "save.json")
        if !reportModel.id.isEmpty {///修改是传
            request["id"] = reportModel.id
        }
        request["reporterId"] = SW_UserCenter.shared.user!.id
        request["reportType"] = reportModel.reportType.rawValue
        if !reportModel.title.isEmpty {
            request["title"] = reportModel.title
        }
        if reportModel.workTypes.count > 0 {
            request["workTypes"] = reportModel.workTypes.map({ return $0.id })
        }
        request["content"] = reportModel.content
        request["images"] = reportModel.images.map({ return $0.replacingOccurrences(of: reportModel.imagePrefix, with: "") })
        request["receiverIds"] = reportModel.receivers.map({ return $0.id })
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    //      获取工作类型列表   工作日志使用
    //     {max:10,offset:0,sort:"id",deptId:"所属部门id"}
    class func getWorkType() -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/workType"
        request["max"] = 9999
        request["offset"] = 0
        request["sort"] = "id"
        request["deptId"] = SW_UserCenter.shared.user!.staffWorkDossier.departmentId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    //{
//    "reportType":"报告类型 0:每日 1:月度 2:年度",
//    "offset":0,
//    "max":10,
//    "staffId":"员工id",  当前员工的id
//    "keyWord":"关键字查询:发布报告姓名"
//    "isCheck":"是否批阅 0是 1否",
//    "reporterId":"发送报告者id", /// 指定看某个人的id  不传为所有
//}
    //      获取收到的工作报告列表
    class func getReceiveReportList(_ reportType: WorkReportType, keyWord: String = "", max: Int = 99999, offset: Int = 0, reporterId: Int? = nil, isCheck: Int = 1) -> SWSRequest {
        let request = SW_WorkReportRequest(resource: "receiveReportList.json")
        request["reportType"] = reportType.rawValue
        request["keyWord"] = keyWord
        request["staffId"] = SW_UserCenter.shared.user!.id
        request["max"] = max
        request["offset"] = offset
        request["isCheck"] = isCheck
        if let reporterId = reporterId {
            request["reporterId"] = reporterId
        }
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    //{
    //    "reportType":"报告类型 0:每日 1:月度 2:年度",
    //    "offset":0,
    //    "max":10,
    //    "staffId":"员工id",  当前员工的id
    //}
    //      获取我已审阅的工作报告用户列表
    class func getReceiveReportStaffList(_ reportType: WorkReportType, max: Int = 999, offset: Int = 0) -> SWSRequest {
        let request = SW_WorkReportRequest(resource: "receiveReportStaffList.json")
        request["reportType"] = reportType.rawValue
        request["staffId"] = SW_UserCenter.shared.user!.id
        request["max"] = max
        request["offset"] = offset
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
//    {
//    "reportType":"0",
//    "offset":0,
//    "max":10,
//    "reporterId":"2",
//    "keyWord":""
//    }
    //     {max:10,offset:0,sort:"id",deptId:"所属部门id"}
    /// 获取我的工作报告列表
    ///
    /// - Parameters:
    ///   - reportType: 报告类型
    ///   - keyWord: 关键词
    ///   - max:  请求最大数量
    ///   - offset: 偏移量
    /// - Returns: 请求对象
    class func getMineReportList(_ reportType: WorkReportType, keyWord: String = "", max: Int = 99999, offset: Int = 0) -> SWSRequest {
        let request = SW_WorkReportRequest(resource: "list.json")
        request["reportType"] = reportType.rawValue
        request["keyWord"] = keyWord
        request["reporterId"] = SW_UserCenter.shared.user!.id
        request["max"] = max
        request["offset"] = offset
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 获取我的工作报告详情
    ///
    /// - Parameter id: 报告id
    /// - Returns: 请求对象
    class func getMineWorkReportDetail(_ id: String) -> SWSRequest {
        let request = SW_WorkReportRequest(resource: "show/\(id).json")
        request.disableCache = true
        request.send(.get).completion { (json, error) -> Any? in
//            if error == nil {
//                return json?["data"]
//            }
            return json
        }
        return request
    }
    
//    {
//    "reportId":10,
//    "staffId":"1"
//    }
    /// 获取收到的xxx的工作报告详情
    ///
    /// - Parameter reportId: 报告id
    /// - Returns: 请求对象
    class func getReceiveWorkReportDetail(_ reportId: String) -> SWSRequest {
        let request = SW_WorkReportRequest(resource: "receiveReportShow.json")
        request["reportId"] = reportId
        request["staffId"] = SW_UserCenter.shared.user!.id
        request.send(.post).completion { (json, error) -> Any? in
            return json
        }
        return request
    }
    
//    {
//    "receiverId":"接收人id",
//    "reportId":"工作报告id",
//    "comment":"审阅内容"
//    }
    /// 审阅工作报告
    ///
    /// - Parameter reportId: 报告id
    /// - Parameter comment: 审阅内容
    /// - Returns: 请求对象
    class func saveWorkReportRecord(_ reportId: String, comment: String) -> SWSRequest {
        let request = SWSRequest(resource: "save.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/workReportRecord"
        request["receiverId"] = SW_UserCenter.shared.user!.id
        request["reportId"] = reportId
        request["comment"] = comment
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json
            }
            return json
        }
        return request
    }
}

//MARK: - 资料共享模块接口
extension SW_WorkingService {

    ///  获取文章类型列表
    class func getArticleTypeList() -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/articleType"
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
//    {
//    "offset":0,
//    "max":10,
//    "articleTypeId":"1",
//    "keyWord":"售后技术"
//    "staffId":2
//    }
    ///  获取文章列表
    class func getArticleList(_ keyWord: String = "", articleTypeId: String = "", max: Int = 20, offset: Int = 0) -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/article"
        request["keyWord"] = keyWord
        request["articleTypeId"] = articleTypeId
        request["max"] = max
        request["offset"] = offset
        request["collectorId"] = SW_UserCenter.shared.user!.id
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
//    {
//    "articleId":"文章id",
//    "collectorId":"收藏者的员工id"
//    }
    ///  保存文章收藏
    class func collectArticle(_ articleId: String) -> SWSRequest {
        let request = SWSRequest(resource: "collectArticle.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/articleCollect"
        request["collectorId"] = SW_UserCenter.shared.user!.id
        request["articleId"] = articleId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json
            }
            return json
        }
        return request
    }
    
    //    {
    //    "articleId":"文章id",
    //    "collectorId":"收藏者的员工id"
    //    }
    ///   取消收藏文章
    class func disCollectArticle(_ articleId: String) -> SWSRequest {
        let request = SWSRequest(resource: "disCollectArticle.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/articleCollect"
        request["collectorId"] = SW_UserCenter.shared.user!.id
        request["articleId"] = articleId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json
            }
            return json
        }
        return request
    }
    
    //    {
    //    "collectorId":"员工id"
    //    }
    ///  获取收藏文章列表
    class func getArticleCollectList(max: Int = 20, offset: Int = 0) -> SWSRequest {
        let request = SWSRequest(resource: "articleCollectList.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/articleCollect"
        request["collectorId"] = SW_UserCenter.shared.user!.id
        request["max"] = max
        request["offset"] = offset
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
}

//MARK: - 车辆库存模块接口
extension SW_WorkingService {
    ///  获取车辆库存列表
//    {
//        "offset":0,
//        "max":10,
//        "bUnitId":"单位id",
//        "keyWord":"条件查询"
//    assignationState  1 未分配  stockState  在库状态 1在途  2在库 3待出库 4已出库
//    }
    class func getCarStockList(_ keyWord: String = "", type: Int, max: Int = 20, offset: Int = 0) -> SWSRequest {
        let request = SWSRequest(resource: "carStockList.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/carStock"
        request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
        request["keyWord"] = keyWord
        if type == 3 {
            request["assignationState"] = 1
        } else {
            request["stockState"] = type
        }
        request["max"] = max
        request["offset"] = offset
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    ///  获取车辆库存列表
    class func getCarStockCount() -> SWSRequest {
        let request = SWSRequest(resource: "carStockCount.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/carStock"
        request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
}


//MARK: - 精品管理模块接口
extension SW_WorkingService {
    
    ///  获取合同精品安装列表
//    {
//        "isInvalid":"1已作废",
//        "isInstall":"1未安装  2已安装",
//        "bUnitId":"单位id",
//        "keyWord":""
//    }
    class func getBoutiqueInstallList(_ keyWord: String = "", type: Int, max: Int = 20, offset: Int = 0) -> SWSRequest {
            let request = SWSRequest(resource: "boutiqueContractInstallList.json")
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/boutiqueContract"
            request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
            request["appKeyWord"] = keyWord
            if type == 3 {
                request["isInvalid"] = 1
            } else if type != 0 {
                request["isInstall"] = type
            }
            request["max"] = max
            request["offset"] = offset
            request.send(.post).completion { (json, error) -> Any? in
                if error == nil {
                    return json?["data"]
                }
                return json
            }
            return request
        }
    
    ///  获取合同精品管理详情
//    {
//        "carSalesContractId":"合同信息id"
//    }
    class func getBoutiqueContractDetailShow(_ contractId: String = "") -> SWSRequest {
        let request = SWSRequest(resource: "boutiqueContractListShow.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/boutiqueContract"
        request["carSalesContractId"] = contractId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    ///   安装合同精品
//    {
//        "installList":[{
//            "boutiqueContractId":"合同精品id",
//            "count":"安装数量",
//            "boutiqueStockId":"精品库存id"
//        }],
//        "carSalesContractId":"合同id"
//    }
    class func installBoutique(_ contractId: String = "", installList: [SW_BoutiqueContractModel]) -> SWSRequest {
            let request = SWSRequest(resource: "installBoutique.json")
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/boutiqueContract"
            request["carSalesContractId"] = contractId
        request["installList"] = installList.map({ return ["boutiqueContractId":$0.boutiqueContractId,"count":$0.nowInstallCount!.roundTo(places: 4),"boutiqueStockId":$0.boutiqueStockId] })
            request.send(.post).completion { (json, error) -> Any? in
                if error == nil {
                    return json?["data"]
                }
                return json
            }
            return request
        }

    
    ///  获取精品采购单列表
//    {
//    "purchaserId":"采购单录入的员工id,
//    即当前用户id",
//    "invalidAuditState":"采购作废状态 1未提交 2 待审核 3 已通过 4 已驳回  传1",
//    "orderAuditState":"采购单审核状态 1未提交 2 待审核 3 已通过 4 已驳回  传1",
//    "from":"1 App 2 前端",
//    "appKeyWord":"搜索查询"
//    }
    class func getBoutiqueInOrderList(_ keyWord: String = "") -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/boutiqueInOrder"
        request["purchaserId"] = SW_UserCenter.shared.user!.id
        request["appKeyWord"] = keyWord
        request["from"] = 1
        request["invalidAuditState"] = 1
        request["orderAuditState"] = 1
        request["max"] = 99999
//        request["offset"] = 0
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    ///  获取精品采购单列表
//    {
//    "id":"精品采购订单id"
//    }
    class func getBoutiqueInOrderDetail(_ id: String = "") -> SWSRequest {
        let request = SWSRequest(resource: "show.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/boutiqueInOrder"
        request["id"] = id
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    /// 根据精品条码获取精品基本信息
    ///
    /// - Parameter boutiqueCode: 条形码
    /// - Returns: 请求对象
    class func getBoutiqueDetail(_ boutiqueCode: String, orderId: String) -> SWSRequest {
        let request = SWSRequest(resource: "show.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/boutique"
        request["boutiqueCode"] = boutiqueCode
        request["orderId"] = orderId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    //    {
    //    "offset":"0",
    //    "max":"9999",
    //    "bUnitId": "1",
    //    "keyWord":"配22"
    //    }
    /// 获取配件库存查询列表
    class func queryBoutiqueStockList(_ keyWord: String = "", max: Int = 20, offset: Int = 0) -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/boutiqueStock"
        request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
        request["keyWord"] = keyWord
        request["max"] = max
        request["offset"] = offset
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
}

//MARK: - 配件管理模块接口
extension SW_WorkingService {
    
    ///  获取配件采购单列表
    //    {
    //    "purchaserId":"采购单录入的员工id,
    //    即当前用户id",
    //    "invalidAuditState":"采购作废状态 1未提交 2 待审核 3 已通过 4 已驳回  传1",
    //    "orderAuditState":"采购单审核状态 1未提交 2 待审核 3 已通过 4 已驳回  传1",
    //    "from":"1 App 2 前端",
    //    "appKeyWord":"搜索查询"
    //    }
    class func getAccessoriesInOrderList(_ keyWord: String = "") -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/accessoriesInOrder"
        request["purchaserId"] = SW_UserCenter.shared.user!.id
        request["appKeyWord"] = keyWord
        request["from"] = 1
        request["invalidAuditState"] = 1
        request["orderAuditState"] = 1
        request["max"] = 99999
        //        request["offset"] = 0
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    ///  获取配件采购单列表
    //    {
    //    "id":"配件采购订单id"
    //    }
    class func getAccessoriesInOrderDetail(_ id: String = "") -> SWSRequest {
        let request = SWSRequest(resource: "show.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/accessoriesInOrder"
        request["id"] = id
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 根据配件条码获取配件基本信息
    ///
    /// - Parameter accessoriesCode: 条形码
    /// - Returns: 请求对象
    class func getAccessoriesDetail(_ accessoriesCode: String, orderId: String) -> SWSRequest {
        let request = SWSRequest(resource: "show.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/accessories"
        request["accessoriesCode"] = accessoriesCode
        request["orderId"] = orderId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    ///  保存配件、精品采购单
//    {
//    "accessoriesId":"精品、配件、id",
//    "purchaseCount":"采购数量",
//    "id":"精品、配件采购订单id"
//    }
    class func saveBoutiqueAccessoriesInOrder(_ type: ProcurementType, id: String, boutiqueAccessoriesId: String, count: Double) -> SWSRequest {
        let request = SWSRequest(resource: "save.json")
        if type == .accessories {
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/accessoriesInOrder"
            request["accessoriesId"] = boutiqueAccessoriesId
        } else {
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/boutiqueInOrder"
            request["boutiqueId"] = boutiqueAccessoriesId
        }
        request["id"] = id
        request["purchaseCount"] = count
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    ///   保存配件\精品、基本信息
    //    {
    //    "accessoriesId":"精品、配件、id",
    //    "purchaseCount":"采购数量",
    //    "id":"精品、配件采购订单id"
    //    }
    class func saveBoutiqueAccessories(_ type: ProcurementType, model: SW_BoutiquesAccessoriesModel) -> SWSRequest {
        let request = SWSRequest(resource: "save.json")
        if type == .accessories {
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/accessories"
            request["accessoriesNum"] = model.num
            request["accessoriesCode"] = model.code
            request["beApplicableType"] = model.forCarModelType
            request["accessoriesTypeId"] = model.accessoriesTypeId
        } else {
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/boutique"
            request["boutiqueNum"] = model.num
            request["boutiqueCode"] = model.code
            request["forCarModelType"] = model.forCarModelType
            request["hourlyWage"] = model.hourlyWage.toServiceInt()
            request["boutiqueTypeId"] = model.boutiqueTypeId
        }
        request["warehouseId"] = model.warehouseId
        request["carBrand"] = model.carBrand
        request["carBrandId"] = model.carBrandId
        request["supplierId"] = model.supplierId
        request["specification"] = model.specification
        request["claimPrice"] = model.claimPrice.toServiceInt()
        request["layerNum"] = model.layerNum
        request["unit"] = model.unit
        request["seatNum"] = model.seatNum
        request["shelfNum"] = model.shelfNum
        request["name"] = model.name
        request["areaNum"] = model.areaNum
        request["retailPrice"] = model.retailPrice.toServiceInt()
        request["carSeries"] = model.carSeries
        request["carSeriesId"] = model.carSeriesId
        request["costPriceTax"] = model.costPriceTax.toServiceInt()
        request["regionId"] = SW_UserCenter.shared.user!.staffWorkDossier.regionInfoId
        request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }

    /// 获取仓库列表
//    {
//    "offset":0,
//    "max":10,
//    "bUnitId":"单位id 当busId不传时,
//    获取仓库总列表无单位标记,
//    否则返回对应的单位标记"
//    } 仓库list  参数 改成  "proType":"1车辆 2精品 3配件"
    class func getWarehouseList(_ type: ProcurementType) -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/warehouse"
        request["proType"] = type.rawValue + 2
        request["max"] = 99999
        request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    ///  获取仓位字典
//    {
//    "isfilter":"是否过滤禁用和被使用  1是 2否",
//    "warehouseId":"仓库id 必传"
//    }
    class func getWarehousePositionList(_ warehouseId: String) -> SWSRequest {
        let request = SWSRequest(resource: "getWarehousePositionList.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/warehousePosition"
        request["warehouseId"] = warehouseId
        request["isfilter"] = 1
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 获取配件种类列表
    class func getAccessoriesTypeList() -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/accessoriesType"
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 获取精品种类列表
    class func getBoutiqueTypeList() -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/boutiqueType"
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
}


//MARK: - 盘点模块接口
extension SW_WorkingService {
    
    ///  获取盘点单列表
//    {
//    "staffId":"配件盘点录入的员工id,
//    即当前用户id",
//    "appKeyWord":"搜索查询"
//    }
    class func getInventoryOrderList(_ type: ProcurementType, keyWord: String = "") -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        if type == .accessories {
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/accessoriesInventoryOrder"
        } else {
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/boutiqueInventoryOrder"
        }
        request["staffId"] = SW_UserCenter.shared.user!.id
        request["appKeyWord"] = keyWord
        request["max"] = 99999
        //        request["offset"] = 0
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    ///  获取盘点单列表
    //    {
    //    "id":"配件采购订单id"
    //    }
    class func getInventoryOrderDetail(_ type: ProcurementType, id: String = "") -> SWSRequest {
        let request = SWSRequest(resource: "show.json")
        if type == .accessories {
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/accessoriesInventoryOrder"
        } else {
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/boutiqueInventoryOrder"
        }
        request["id"] = id
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 根据条码获取盘点区域信息
    ///
    /// - Parameter code: 条形码
    /// - Parameter id: 盘点单id
    /// - Returns: 请求对象
    class func getScanDetail(_ type: ProcurementType, code: String, id: String) -> SWSRequest {
        var request: SWSRequest
        if type == .accessories {
            request = SWSRequest(resource: "scanAccessories.json")
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/accessoriesInventoryOrder"
            request["accessoriesCode"] = code
        } else {
            request = SWSRequest(resource: "scanBoutique.json")
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/boutiqueInventoryOrder"
            request["boutiqueCode"] = code
        }
        request["id"] = id
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json
            }
            return json
        }
        return request
    }
    
    
    ///  保存配件、精品采购单
//    {
//    "id,
//    ":"盘点单id",
//    "accessoriesId":"配件id",
//    "count":"数量"
//    }
    class func saveInventoryOrder(_ type: ProcurementType, id: String, boutiqueAccessoriesId: String, count: Double, stockId: String) -> SWSRequest {
        let request = SWSRequest(resource: "save.json")
        if type == .accessories {
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/accessoriesInventoryOrder"
            request["accessoriesId"] = boutiqueAccessoriesId
        } else {
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/boutiqueInventoryOrder"
            request["boutiqueId"] = boutiqueAccessoriesId
        }
        request["id"] = id
        request["stockId"] = stockId
        request["count"] = count
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
}
