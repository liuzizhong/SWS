//
//  SW_SalesContractService.swift
//  SWS
//
//  Created by jayway on 2019/5/24.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

//审核状态 1 未提交 2 待审核 3 已通过 4 已驳回
enum AuditState: Int {
    case noCommit =  1
    case wait
    case pass
    case rejected
    
    var rawTitle: String {
        switch self {
        case .noCommit:
            return "未提交"
        case .wait:
            return "待审核"
        case .pass:
            return "已通过"
        case .rejected:
            return "已驳回"
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .noCommit:
            return UIColor.v2Color.darkGray
        case .wait:
            return #colorLiteral(red: 0.862745098, green: 0.5098039216, blue: 0, alpha: 1)
        case .pass:
            return #colorLiteral(red: 0, green: 0.6509803922, blue: 0, alpha: 1)
        case .rejected:
            return UIColor.v2Color.red
        }
    }
}

//"payState":"合同状态 1 未收款 2 已收定金 3 已收全款  4已结审",
enum PayState: Int {
    case noPay = 1
    case deposit
    case full
    case final
    
    var rawTitle: String {
        switch self {
        case .noPay:
            return "未收款"
        case .deposit:
            return "已收定金"
        case .full:
            return "已收全款"
        case .final:
            return "已结审"
        }
    }
}


class SW_SalesContractService: NSObject {

    /// 获取汽车销售合同保险列表
//    {
//    "offset":0,
//    "invalidAuditState":"作废状态 1未提交 2待审核 3已通过 4已驳回",
//    "endDate":"结束时间",
//    "max":10,
//    "contractAuditState":"合同审核状态  1 未提交 2 待审核 3 已通过 4 已驳回",
//    "finalAuditState":"结审状态",
//    "payState":"合同状态 1 未付款 2 已付定金 3 已付全款",
//    "staffId":"员工id",
//    "startDate":"开始时间",
//    "bUnitId":"单位id",
//    "keyWord":"条件查询"
//    }
    class func getSaleInsuranceContractList(_ keyWord: String = "", max: Int = 99999, offset: Int = 0) -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/insuranceContract"
        request["max"] = max
        request["offset"] = offset
//        request["staffId"] = SW_UserCenter.shared.user!.id
//        request["bUnitId"] = SW_UserCenter.shared.user?.staffWorkDossier.businessUnitId
        request["appKeyWord"] = keyWord
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 获取汽车 合同按揭-列表
//    {
//    "offset":0,
//    "endDate":"结束时间",
//    "max":10,
//    "staffId":"员工id",
//    "assignationState":"分配状态 1 未分配 2分配",
//    "startDate":"开始时间",
//    "bUnitId":"单位id",
//    "keyWord":"关键字"
//    }
    class func getSaleMortgageContractList(_ keyWord: String = "", max: Int = 99999, offset: Int = 0) -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/mortgageContract"
        request["max"] = max
        request["offset"] = offset
//        request["staffId"] = SW_UserCenter.shared.user!.id
//        request["bUnitId"] = SW_UserCenter.shared.user?.staffWorkDossier.businessUnitId
        request["appKeyWord"] = keyWord
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 获取汽车 合同上牌列表
    //    {
    //    "offset":0,
    //    "endDate":"结束时间",
    //    "max":10,
    //    "staffId":"员工id",
    //    "assignationState":"分配状态 1 未分配 2分配",
    //    "startDate":"开始时间",
    //    "bUnitId":"单位id",
    //    "keyWord":"关键字"
    //    }
    class func getSaleCarNumContractList(_ keyWord: String = "", type: Int, max: Int = 99999, offset: Int = 0) -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/carNumContract"
        request["max"] = max
        request["offset"] = offset
        request["type"] = type
//        request["staffId"] = SW_UserCenter.shared.user!.id
//        request["bUnitId"] = SW_UserCenter.shared.user?.staffWorkDossier.businessUnitId
        request["appKeyWord"] = keyWord
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    ///  根据合同id 获取合同按揭信息
    ///
    /// - Parameter contractId: 合同id
    /// - Returns: 请求
    class func getContractDetail(_ contractId: String, type: ContractBusinessType) -> SWSRequest {
        var request = SWSRequest(resource: "show/\(contractId).json")
        var requestType: RequestType
        switch type {
        case .assgnationCar:
            request = SWSRequest(resource: "contractAssgnationCarShow/\(contractId).json")
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/carSalesContract"
            requestType = .get
            request.disableCache = true
        case .insurance:
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/insuranceContract"
            requestType = .get
            request.disableCache = true
        case .mortgageLoans:
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/mortgageContract"
            requestType = .get
            request.disableCache = true
        default:
//            {
//                "contractId":"合同id",
//                "type":"1 上牌详情  2购置税"
//            }
            request = SWSRequest(resource: "show.json")
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/carNumContract"
            requestType = .post
            request["contractId"] = contractId
            request["type"] = type.rawValue - 1
        }
        request.send(requestType).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 合同分配或解除车辆
//   {
//        "carInfoId":"车辆信息id",
//        "contractId":"合同id",
//        "type":"1分配车辆 2解除车辆 3解除并分配",
//        "operatorId":"审核人id"
//    }
    class func contractAssgnationCarOrReleaseCar(contractId: String, carInfoId: String, type: Int) -> SWSRequest {
            let request = SWSRequest(resource: "contractAssgnationCarOrReleaseCar.json")
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/carSalesContract"
            request["contractId"] = contractId
            request["carInfoId"] = carInfoId
            request["type"] = type
            request["operatorId"] = SW_UserCenter.shared.user!.id
            request.send(.post).completion { (json, error) -> Any? in
                if error == nil {
                    return json?["data"]
                }
                return json
            }
            return request
        }
    
    /// 完成购置税
//    {
//    "contractId":"合同id",
//    "carPurchaseTaxAmount":"购置税金额",
//    "operatorId":"审核人id"
//    }
    class func saveCarPurchaseTax(contractId: String, contract: SW_SalesContractDetailModel) -> SWSRequest {
        let request = SWSRequest(resource: "carPurchaseFinish.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/carNumContract"
        request["contractId"] = contractId
        request["carPurchaseTaxAmount"] = contract.carPurchaseTaxAmount.toServiceInt()
        request["attachmentList"] = contract.attachmentList.map({ return $0.replacingOccurrences(of: contract.imagePrefix, with: "") })
        request["operatorId"] = SW_UserCenter.shared.user!.id
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    ///  完成上牌办理
//    {
//    "contractId":"合同id",
//    "carNum":"车牌号",
//    "handleDate":"上牌时间",
//    "operatorId":"操作人id",
//    "carNumCostAmount":"上牌成本"
//    }
    class func saveCarNumContractFinish(contractId: String, contract: SW_SalesContractDetailModel) -> SWSRequest {
        let request = SWSRequest(resource: "carNumContractFinish.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/carNumContract"
        request["contractId"] = contractId
        request["numberPlate"] = contract.numberPlate
        request["handleDate"] = contract.handleDate
        request["attachmentList"] = contract.attachmentList.map({ return $0.replacingOccurrences(of: contract.imagePrefix, with: "") })
        request["operatorId"] = SW_UserCenter.shared.user!.id
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    ///   完成办理按揭
//    {
//    "mortgagePeriod":"按揭期数",
//    "images":["附件url",
//    "附件url"],
//    "financialOrgId":"金融机构id",
//    "contractId":"合同id",
//    "mortgageCostAmount":"按揭成本",
//    "handleDate":"批复日期",
//    "approvalAmount":"批复金额",
//    "operatorId":"审核人id"
//    }
    class func saveMortgageContractFinish(contractId: String, contract: SW_SalesContractDetailModel) -> SWSRequest {
        let request = SWSRequest(resource: "mortgageContractFinish.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/mortgageContract"
        request["contractId"] = contractId
        request["financialOrgId"] = contract.financialOrgId
        request["handleDate"] = contract.handleDate
        request["mortgagePeriod"] = contract.mortgagePeriod
        request["approvalAmount"] = contract.approvalAmount.toServiceInt()
        request["attachmentList"] = contract.attachmentList.map({ return $0.replacingOccurrences(of: contract.imagePrefix, with: "") })
        request["operatorId"] = SW_UserCenter.shared.user!.id
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    ///   提交保险办理审核
//    {
//    "images":["附件url",
//    "附件url"],
//    "insuranceNum":"保险单号",
//    "carShipTaxAmount":"车船税金额",
//    "compulsoryInsuranceAmount":"交强险金额",
//    "insuranceCompanyId":"保险公司Id",
//    "contractId":"合同id",
//    "insuranceStartDate":"保单开始时间",
//    "insuranceEndDate":"保单结束时间",
//    "operatorId":"操作人id",
//    "insuranceItems":[{
//    "name":"险种名称",
//    "insuredAmount":"保险金额"
//    }]
//    }
    class func submitInsuranceContractAudit(contractId: String, contract: SW_SalesContractDetailModel) -> SWSRequest {
        let request = SWSRequest(resource: "submitInsuranceContractAudit.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/insuranceContract"
        request["contractId"] = contractId
        request["insuranceCompanyId"] = contract.insuranceCompanyId
        request["insuranceNum"] = contract.insuranceNum
        request["commercialInsuranceNum"] = contract.commercialInsuranceNum
        request["insuranceStartDate"] = contract.insuranceStartDate
        request["insuranceEndDate"] = contract.insuranceEndDate
//        if contract.carShipTaxTag == 1 {
        request["carShipTaxAmount"] = contract.carShipTaxAmount.toServiceInt()
//        }
//        if contract.compulsoryInsuranceTag == 1 {
        request["compulsoryInsuranceAmount"] = contract.compulsoryInsuranceAmount.toServiceInt()
//        }
        request["insuranceItems"] = contract.insuranceItems.map({ return ["name":$0.name, "insuredAmount":$0.insuredAmount.toServiceInt()] })
        request["attachmentList"] = contract.attachmentList.map({ return $0.replacingOccurrences(of: contract.imagePrefix, with: "") })
        request["operatorId"] = SW_UserCenter.shared.user!.id
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    ///  获取金融机构列表
    class func getFinancialOrgList(_ bUnitId: Int) -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/financialOrg"
        request["bUnitId"] = bUnitId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
}
