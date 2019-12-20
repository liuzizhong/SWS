//
//  SW_QrCodeService.swift
//  SWS
//
//  Created by jayway on 2019/6/12.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

/// 二维码相关业务接口
class SW_QrCodeService: NSObject {
    
//    {
//    "itemFlagStr":"对应的业务标示 不做统一规定，但必须唯一，可以为：出库单单号，采购单单号，登录uid",
//    "type":"2 配件内部领件出库二维码 3 精品内部领件出库"
//    }
    /// 二维码状态更新
    class func qrCodeUpdateState(_ qrKey: String, type: QrCodeType, itemFlagStr: String) -> SWSRequest {
        let request = SWSRequest(resource: "updateState.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/qrCode"
        request["qrKey"] = qrKey
        request["itemFlagStr"] = itemFlagStr
        request["type"] = type.rawValue
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
//    {
//    "businessType": 2,
//    "curStaffId": 481,
//    "id": "402881f46b55a0d8016b561cca4f0028",
//    "operatorId": 3,
//    "orderNum": "LJ201906140000872",
//    "qrKey": "e2221593-fea2-4eaa-af43-a9149ba0f942",
//    "staffId": 481
//    }
    /// 维修精品、配件出库返库
    /// accessoriesStock/outStock.json
    /// accessoriesStock/backStock.json
    /// 精品、配件内部领件单
    /// accessoriesReceiveOrder/outStock.json
    /// boutiqueReceiveOrder/outStock.json
    class func accessoriesBoutiqueReceiveOrder(_ qrKey: String, id: String, type: QrCodeType, businessType: Int, operatorId: Int, orderNum: String) -> SWSRequest {
        var action = ""
        switch type {
        case .accessoriesBack,.boutiqueBack,.repairAccessoriesBack,.repairBoutiqueBack,.playCarBoutiqueBack,.contractBoutiqueBack:
            action = "backStock"
        case .accessoriesReceive,.boutiqueReceive,.repairAccessoriesOut,.repairBoutiqueOut,.playCarBoutiqueOut,.contractBoutiqueOut:
            action = "outStock"
        default:
            break
        }
        let request = SWSRequest(resource: "\(action).json")
        switch type {/// 选择接口
        case .accessoriesReceive,.accessoriesBack:
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/accessoriesReceiveOrder"
        case .boutiqueReceive,.boutiqueBack:
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/boutiqueReceiveOrder"
        case .repairAccessoriesBack,.repairAccessoriesOut:
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/accessoriesStock"
        case .repairBoutiqueBack,.repairBoutiqueOut:
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/repairOrderBoutique"
        case .playCarBoutiqueBack,.playCarBoutiqueOut:
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/playCarBoutique"
        case .contractBoutiqueBack,.contractBoutiqueOut:
            request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/boutiqueContract"
        default:
            break
        }
        request["\(action)Id"] = SW_UserCenter.shared.user!.id
        request["qrKey"] = qrKey
        request["id"] = id
        request["businessType"] = businessType
        request["operatorId"] = operatorId
        request["orderNum"] = orderNum
        request["staffId"] = SW_UserCenter.shared.user!.id
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
