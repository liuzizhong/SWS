//
//  SW_AfterSaleService.swift
//  SWS
//
//  Created by jayway on 2019/2/25.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

/// 售后维修相关接口
class SW_AfterSaleRequest: SWSRequest {
    override var apiURL: String {
        get {
            return SWSApiCenter.getBaseUrl() + "/api/app/repairOrder"
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

/// 售后维修相关接口
class SW_AfterSaleService: NSObject {
    
//    {
//    "offset":"0",
//    "max":"10",
//    "staffId":"用户id",
//    "keyWord":"关键词",
//    "bUnitId":"单位id"
//    }
    /// 根据staffId初始化通讯录客户关系列表
    class func getCustomerList(_ keyWord: String = "", max: Int = 99999, offset: Int = 0) -> SW_AfterSaleRequest {
        let request = SW_AfterSaleRequest(resource: "customerList.json")
        request["staffId"] = SW_UserCenter.shared.user!.id
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
    
//    {
//    "repairOrderId":"维修单id",
//    "offset":"0",
//    "max":"10",
//    "customerId":"客户id",
//    "vin":"车架号",
//    "bUnitId":"单位id"
//    }
    /// 获取售后客户通讯录详情
    class func getCustomerDetail(_ repairOrderId: String, customerId: String, vin: String, bUnitId: Int, max: Int = 2, offset: Int = 0) -> SW_AfterSaleRequest {
        let request = SW_AfterSaleRequest(resource: "customerShow.json")
        request["repairOrderId"] = repairOrderId
        request["customerId"] = customerId
        request["vin"] = vin
        request["bUnitId"] = bUnitId
        request["repairOrderId"] = repairOrderId
        request["max"] = max
        request["offset"] = offset
        request["sort"] = "createDate"
        request["order"] = "desc"
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 获取售后部员工列表
    class func getAfterSaleList() -> SWSRequest {
        let request = SWSRequest(resource: "getAfterSaleData.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/staff"
        request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId//staffId
        request["staffId"] = SW_UserCenter.shared.user!.id
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
//    {
//    "toStaffId":"目标销售顾问id",
//    "customerId":"121212121112121212",
//    "fromStaffId":"原售后顾问id"
//    }
    /// 更换售后顾问
    class func changeAfterSale(_ customerId: String, toStaffId: Int) -> SW_AfterSaleRequest {
        let request = SW_AfterSaleRequest(resource: "changeAfterSale.json")
        request["toStaffId"] = toStaffId
        request["customerId"] = customerId
        request["fromStaffId"] = SW_UserCenter.shared.user!.id
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
//    "max":"10",
//    "vin":"车架号",
//    "bUnitId":"单位id"
//    }
    /// 售后-维修记录列表
    class func getRepairOrderList(_ vin: String, offSet: Int = 0) -> SW_AfterSaleRequest {
        let request = SW_AfterSaleRequest(resource: "list.json")
        request["vin"] = vin
        request["offSet"] = offSet
        request["max"] = 100
        request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
//    {
//    "repairOrderId":"维修单id",
//    "staffId":"售后顾问id"
//    }
    /// 售后-维修单详情
    class func getRepairOrderDetail(_ repairOrderId: String) -> SW_AfterSaleRequest {
        let request = SW_AfterSaleRequest(resource: "orderDetail.json")
        request["repairOrderId"] = repairOrderId
//        request["staffId"] = SW_UserCenter.shared.user!.id
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
//    {
//    "repairOrderId":"ff8080816898568301689867301d002a",
//    "customerId":"ff80808168557fd1016855ae06d00005",
//    "sort":"createDate",
//    "order":"asc"
//    }
    /// 获取售后接访记录列表
    class func getAfterSaleVisitRecordList(_ repairOrderId: String, customerId: String, max: Int = 9999, offSet: Int = 0) -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/afterSaleVisitRecord"
        request["repairOrderId"] = repairOrderId
        request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
        request["customerId"] = customerId
        request["max"] = max
        request["offSet"] = offSet
        request["sort"] = "createDate"
        request["order"] = "desc"
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 获取售后接访记录详情数据
    class func getAfterSaleVisitRecordData(_ afterSaleVisitRecordId: String) -> SWSRequest {
        let request = SWSRequest(resource: "show.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/afterSaleVisitRecord"
        request["afterSaleVisitRecordId"] = afterSaleVisitRecordId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 保存访问客户记录信息
    class func saveAccessCustomerRecord(_ record: SW_AfterSaleAccessRecordListModel) -> SWSRequest {
        let request = SWSRequest(resource: "save.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/afterSaleVisitRecord"
        request["accessType"] = record.accessType.rawValue
        request["repairOrderId"] = record.repairOrderId
        request["customerId"] = record.customerId
        request["staffId"] = SW_UserCenter.shared.user!.id
        request["recordContent"] = record.recordContent
        if record.startDate != 0 {
            request["startDate"] = record.startDate
        }
        if record.endDate != 0 {
            request["endDate"] = record.endDate
        }
        request["regionId"] = SW_UserCenter.shared.user!.staffWorkDossier.regionInfoId
        request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
        request["deptId"] = SW_UserCenter.shared.user!.staffWorkDossier.departmentId
        
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    //  维修单审核
//    {
//    "repairOrderId":"维修单id",
//    "remark":"原因",
//    "isReject":"0通过 1驳回"
//    }
    class func orderAudit(_ repairOrderId: String, remark: String = "", isReject: Int) -> SW_AfterSaleRequest {
        let request = SW_AfterSaleRequest(resource: "orderAudit.json")
        request["repairOrderId"] = repairOrderId
        request["remark"] = remark
        request["isReject"] = isReject
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    //  根据维修订单id 获取维修订单信息
    //    {
    //    "repairOrderId":"维修单id"
    //    }
    class func showRepairOrder(_ repairOrderId: String) -> SW_AfterSaleRequest {
        let request = SW_AfterSaleRequest(resource: "show.json")
        request["repairOrderId"] = repairOrderId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
}

// MARK: - 工作模块
extension SW_AfterSaleService {
    
    
//    {
//    "offset":"0",
//    "max":"10",
//    "staffId":"售后顾问id",
//    "keyWord":"关键词"
//    }
    /// 获取维修单列表
    class func getOrderList(_ keyWord: String = "", max: Int = 99999, offset: Int = 0) -> SW_AfterSaleRequest {
        let request = SW_AfterSaleRequest(resource: "orderList.json")
//        request["staffId"] = SW_UserCenter.shared.user!.id
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
    
//    {
//    "bUnitId":"单位id",
//    "keyWord":"关键词查询"
//    }
    /// 获取维修看板列表
    class func getRepairBoardList(_ keyWord: String = "", max: Int = 99999, offset: Int = 0) -> SW_AfterSaleRequest {
        let request = SW_AfterSaleRequest(resource: "repairBoard.json")
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
    
//    {
//    "offset":"0",
//    "max":"10",
//    "staffId":"售后顾问id",
//    "bUnitId":"单位id",
//    "queryType":"1 施工列表查询 2 质检列表查询"
//    }
    /// 获取维修单列表
    class func getConstructionList(_ keyWord: String = "", queryType: Int, max: Int = 99999, offset: Int = 0) -> SW_AfterSaleRequest {
        let request = SW_AfterSaleRequest(resource: "constructionList.json")
        if queryType == 1 {
            request["staffId"] = SW_UserCenter.shared.user!.id
        }
        request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
        request["keyWord"] = keyWord
        request["queryType"] = queryType
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
//    "repairOrderId":"维修单id",
//    "staffId":"售后顾问id",
//    "bUnitId":"单位id"
//    "type":"1 施工列表查询 2 质检列表查询"
//    }
    /// 售后-施工、质检单详情
    class func getConstructionDetail(_ repairOrderId: String, bUnitId: Int, type: Int) -> SW_AfterSaleRequest {
        let request = SW_AfterSaleRequest(resource: "constructionDetail.json")
        request["repairOrderId"] = repairOrderId
        request["staffId"] = SW_UserCenter.shared.user!.id
        request["bUnitId"] = bUnitId
        request["type"] = type
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
//    {
//    "repairOrderId":"维修单id",
//    "repairOrderItemList":[{
//    "repairOrderItemId":"修改必传",
//    "itemState":"维修项目状态 1 未开工 2 已开工 3 已完工"
//    }],
//    "staffId":"员工id"
//    }
    class func constructionStateChange(_ repairOrderId: String, repairOrderItemList: [SW_RepairOrderItemModel], state: RepairStateType) -> SW_AfterSaleRequest {
        let request = SW_AfterSaleRequest(resource: "constructionStateChange.json")
        request["repairOrderId"] = repairOrderId
        request["repairOrderItemList"] = repairOrderItemList.map({ (value) -> [String:Any] in
            return ["repairOrderItemId":value.repairOrderItemId, "itemState":state.rawValue]
        })
        request["staffId"] = SW_UserCenter.shared.user!.id
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
//    {
//    "repairOrderId":"维修单id",
//    "repairOrderItems":[{
//    "qualityState":"3 合格、通过 4 不合格、不通过",
//    "repairOrderItemId":"维修项目id"
//    }],
//    "remark":"备注",
//    "staffId":"员工id",
//    "isReject":"1 驳回 2通过"
//    }
    class func qualityStateChange(_ repairOrderId: String, repairOrderItemList: [SW_RepairOrderItemModel], remark: String) -> SW_AfterSaleRequest {
        let request = SW_AfterSaleRequest(resource: "qualityStateChange.json")
        request["repairOrderId"] = repairOrderId
        request["repairOrderItems"] = repairOrderItemList.map({ (value) -> [String:Any] in
            return ["repairOrderItemId":value.repairOrderItemId, "qualityState":value.isQualified ? 3 : 4]
        })
        request["remark"] = remark
        let noQualifiedList =  repairOrderItemList.filter({ return !$0.isQualified })
        request["isReject"] = noQualifiedList.count == 0 ? 2 : 1
        request["staffId"] = SW_UserCenter.shared.user!.id
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
//    "repairOrderItemList":[{
//    "afterSaleGroupId":"班组id",
//    "areaNum":"工位",
//    "id":"维修项目id",
//    "afterSaleGroupName":"班组名称"
//    }],
//    "id":"维修单id"
    /// 维修项目派工
    class func dispatchRepairItem(_ repairOrderId: String, repairItemList: [SW_RepairOrderItemModel], groupName: String, groupId: String, areaNum: String) -> SW_AfterSaleRequest {
        let request = SW_AfterSaleRequest(resource: "dispatch.json")
        request["id"] = repairOrderId
        request["repairOrderItemList"] = repairItemList.map({ (value) -> [String:Any] in
            return ["id":value.repairOrderItemId, "afterSaleGroupId": groupId,"afterSaleGroupName": groupName, "areaNum": areaNum]
        })
        request["staffId"] = SW_UserCenter.shared.user!.id
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    ///  获取售后班组和对应可使用的工位
    class func getAfterSaleGroupList(_ bUnitId: Int) -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/afterSaleGroup"
        request["bUnitId"] = bUnitId
        request["saleGroupType"] = 0
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
    //    "state":"使用状态 1启用 2禁用",
    //    "keyWord":"输入维修项目名称"
    //    }
    /// 获取维修项目列表
    class func getRepairItemList(_ keyWord: String = "", max: Int = 20, offset: Int = 0) -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/repairItem"
        request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
        request["keyWord"] = keyWord
        request["state"] = 1
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
//    "offset":"0",
//    "max":"9999",
//    "bUnitId": "1",
//    "keyWord":"配22"
//    }
    /// 获取配件库存列表
    class func getAccessoriesStockList(_ keyWord: String = "", max: Int = 20, offset: Int = 0) -> SWSRequest {
        let request = SWSRequest(resource: "accessoriesStockList.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/accessoriesStock"
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
    

    //    {
    //    "offset":"0",
    //    "max":"9999",
    //    "bUnitId": "1",
    //    "keyWord":"配22"
    //    }
        /// 获取配件库存查询列表
        class func queryAccessoriesStockList(_ keyWord: String = "", max: Int = 20, offset: Int = 0) -> SWSRequest {
            let request = SWSRequest(resource: "list.json")
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/accessoriesStock"
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
        
    
//    {
//    "repairOrderItemList":[{
//    "hourlyWage":"工时费",
//    "workingHours":"工时",
//    "repairOrderItemName":"维修项目名称"
//    }],
//    "id":"维修单id"
//    }
    class func appendRepairItem(_ repairOrderId: String, repairItemList: [SW_RepairItemModel]) -> SW_AfterSaleRequest {
        let request = SW_AfterSaleRequest(resource: "appendRepairItem.json")
        request["id"] = repairOrderId
        request["repairOrderItemList"] = repairItemList.map({ (value) -> [String:Any] in
            return ["repairOrderItemName":value.repairItemName, "workingHours":value.workingHours,"hourlyWage":value.hourlyWage,"repairItemNum":value.repairItemNum]
        })
        request["staffId"] = SW_UserCenter.shared.user!.id
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
//    {
//    "repairOrderAccessories":[{
//    "accessoriesId":"配件id",
//    "unit":"度量单位",
//    "saleCount":"销售数量",
//    "dealAmount":"成交总价金额(小计)",
//    "accessoriesName":"配件名称",
//    "retailAmount":"零售总价金额(小计)",
//    "accessoriesNum":"配件编号"
//    }],
//    "id":"维修单id"
//    }
    /// 增加维修配件
    class func appendRepairOrderAccessories(_ repairOrderId: String, accessoriesList: [SW_BoutiquesAccessoriesModel]) -> SW_AfterSaleRequest {
        let request = SW_AfterSaleRequest(resource: "appendRepairOrderAccessories.json")
        request["id"] = repairOrderId
        request["repairOrderAccessories"] = accessoriesList.map({ (value) -> [String:Any] in
            let amount = Int(value.retailPrice*10000*value.addCount)
            return ["accessoriesId":value.id, "unit":value.unit,"saleCount":value.saleCount, "dealAmount":amount,"retailAmount":amount, "accessoriesName":value.name,"accessoriesNum":value.num,"accessoriesStockId":value.stockId]
        })
        request["staffId"] = SW_UserCenter.shared.user!.id
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
//    {
//    "feedback":"反馈内容",
//    "id":"投诉记录id"
//    }
    /// 处理投诉
    class func handleComplaint(_ id: String, feedback: String) -> SWSRequest {
        let request = SWSRequest(resource: "handleComplaint.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/complaintRecord"
        request["id"] = id
        request["feedback"] = feedback
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
}
