//
//  SW_ SuggestionService.swift
//  SWS
//
//  Created by jayway on 2018/4/13.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit


class SWSSuggestionRequest: SWSRequest {
    override var apiURL: String {
        get {
            return SWSApiCenter.getBaseUrl() + "/api/app/suggestion"
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

class SW_SuggestionService: NSObject {

    // 提交意见反馈  staffId:反馈者id,content:"反馈内容",tittle:"标题"
    class func saveSuggestion(_ staffId: Int, content: String, tittle: String) -> SWSSuggestionRequest {
        let request = SWSSuggestionRequest(resource: "save.json")
        request["staffId"] = staffId
        request["content"] = content
        request["tittle"] = tittle
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    // 获取意见反馈列表      根据员工id获取意见反馈列表
//    {staffId:"1",max:10,offset:0,sort:"createDate",order:"desc"}
    class func getSuggestionList(_ staffId: Int, max: Int = 99999, offset: Int = 0, sort: String = "create_date", order: String = "desc") -> SWSSuggestionRequest {
        let request = SWSSuggestionRequest(resource: "list.json")
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
    
}
