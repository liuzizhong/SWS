//
//  SW_GroupModel.swift
//  SWS
//
//  Created by jayway on 2018/4/20.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_GroupModel: NSObject {
    //    "groupId": 3,
    //    "groupName": "宝沃工作群",
    //    "groupCreaterId": "12321",
    //    "groupCreateDate": 123123,
    //    "groupNum": "3",
    //    "imageUrl": "http://p6ncqqle1.bkt.clouddn.com/1231231"
    //    groupState 群组状态 1启用 2禁用
    
    var groupName = ""
    var groupCreaterId = ""
    var groupCreateDate: TimeInterval = 0
    /// 群组ID
    var groupNum = ""
    var imageUrl = ""
    //    groupState 群组状态 1启用 2禁用
    var groupState = true
    
    init(_ json: JSON) {
        super.init()
        groupName = json["groupName"].stringValue
        groupCreaterId = json["groupCreaterId"].stringValue
        groupCreateDate = json["groupCreateDate"].doubleValue
        groupNum = json["groupNum"].stringValue
        imageUrl = json["imageUrl"].stringValue
        groupState = json["groupState"].intValue != 2
    }
    
    
}
