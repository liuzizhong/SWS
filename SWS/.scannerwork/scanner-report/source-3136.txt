//
//  SW_RangeService.swift
//  SWS
//
//  Created by jayway on 2018/5/7.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit


class SW_RangeService: NSObject {

    // 获取发送公告列表
    // {type:0全部分区,1选择的分区单位,2,选择的单位部门,3选择的部门人员,当type为0时,idStr不用传,当type为3时,idStr结构为:单位id_部门id,
    //  例如:idStr:"1_2,2_2",max:10,offset:0,staffId:"员工id" idStr:1,2,3,4},例如:{type:2,idStr:"1,2,3,4",staffId:"1",max:0,offset:0}
    class func getSendMessageList(_ type: Int, staffId: Int, idStr: String = "", max: Int = 99999, offset: Int = 0) -> SW_MessageRequest {
        let request = SW_MessageRequest(resource: "sendMessageList.json")
        request["staffId"] = staffId
        request["idStr"] = idStr
        request["max"] = max
        request["offset"] = offset
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
//    "idStr":"当type为0时,
//    不用传,
//    当type=3,
//    idStr为:单位id_部门id;当type=4,
//    idStr为:分区id_单位id;当type=5,
//    idStr为:分区id",
//    "offset":"0",
//    "max":"15",
//    "type":"0 全部分区,
//    1 获取分区下的单位列表,
//    2 获取单位下的部门列表,
//    3 获取下部门的人员列表,
//    4 获取单位下的人员列表,
//    5 获取分区下的人员列表",
//    "GroupNum":"群号",
//    "keyWord":"关键词"
//    }
    /// 获取添加 群成员列表
//    例如:{GroupNum:"123456",type:2,idStr:"1,2,3,4",staffId:"1",max:0,offset:0}
    class func getAddGroupMemberList(_ type: Int, keyWord: String = "",GroupNum: String?, staffId: Int, idStr: String = "", max: Int = 99999, offset: Int = 0) -> SW_GroupRequest {
        let request = SW_GroupRequest(resource: "getAddGroupMemberList.json")
        if let GroupNum = GroupNum {
            request["GroupNum"] = GroupNum
        }
        request["keyWord"] = keyWord
        request["staffId"] = staffId
        request["idStr"] = idStr
        request["max"] = max
        request["offset"] = offset
        request["type"] = type
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
}
