//
//  SW_SuggestionModel.swift
//  SWS
//
//  Created by jayway on 2018/12/11.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_SuggestionModel: NSObject {
//{
//    "id": 49,
//    "tittle": "",
//    "content": "stjstjsthshstjstjsthsthsthsthsthsTstjstjdgndgnsgnsgnstnsgnsgjsgnstnstnstjstj",
//    "createDate": 1544240899231,
//    "auitState": 0,  0 未审阅  1 已审阅
//    "staffId": 1,
//    "replyContent": "",
//    "realName": "张剑威",
//    "position": "开发员",
//    "regionInfo": "广东省-惠州市-惠城区",
//    "deptName": "销售部",
//    "bUnitName": "沃尔沃"
//    }
    
    var tittle = ""
    var content = ""
    var createDate: TimeInterval = 0
    var replyContent = ""//回复
    
    init(_ json: JSON) {
        super.init()
        tittle = json["tittle"].stringValue
        content = json["content"].stringValue
        createDate = json["createDate"].doubleValue
        replyContent = json["replyContent"].stringValue
    }
    
}
