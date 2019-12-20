//
//  SW_MessageService.swift
//  SWS
//
//  Created by jayway on 2018/5/18.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_MessageRequest: SWSRequest {
    override var apiURL: String {
        get {
            return SWSApiCenter.getBaseUrl() + "/api/app/message"
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

class SW_MessageService: NSObject {
    
    //获取会话列表相关信息 环信返回缺少头像与名称等数据
//    {GroupNumStr:"群号",HuanxinNumStr:"环信用户名"} 例如:{GroupNumStr:"1111111,222222,33333,44444",HuanxinNumStr:"12,23,55,66"}
    class func getConversationList(_ groupNumStr: String, huanxinNumStr: String) -> SW_MessageRequest {
        let request = SW_MessageRequest(resource: "getConversationList.json")
        request["groupNumStr"] = groupNumStr
        request["huanxinNumStr"] = huanxinNumStr
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    
}
