//
//  SW_GroupService.swift
//  SWS
//
//  Created by jayway on 2018/4/20.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit


class SW_GroupRequest: SWSRequest {
    override var apiURL: String {
        get {
            return SWSApiCenter.getBaseUrl() + "/api/app/group"
        }
        set {
            self.apiURL = newValue
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

class SW_GroupService: NSObject {

    //保存 工作群组
    //'保存时:{staffId:"群主员工号",groupName:"群组名称",staffIds:"群成员的员工号",imageUrl:"群组头像路径"}
    //例如:{staffId:"1134",groupName:"三惠群",staffIds:"2_9_8",imageUrl:""}
    class func saveGroup(_ staffId: Int, groupName: String, staffIds: String, imageUrl: String) -> SW_GroupRequest {
        let request = SW_GroupRequest(resource: "save.json")
        request["staffId"] = staffId
        request["groupName"] = groupName
        request["staffIds"] = staffIds
        request["imageUrl"] = imageUrl
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    //更新 工作群组
    //更新时:{groupNum:"环信群id",groupName:"群组名称",imageUrl:"群组头像路径"},
    //例如:{groupNum:"2313212",groupName:"三惠汽贸",imageUrl:"sdfjsfashsfs"}'
    class func updateGroup(_ groupNum: String, imageUrl: String = "", groupName: String = "") -> SW_GroupRequest {
        let request = SW_GroupRequest(resource: "save.json")
        request["groupNum"] = groupNum
        if !imageUrl.isEmpty {
            request["imageUrl"] = imageUrl
        }
        if !groupName.isEmpty {
            request["groupName"] = groupName
        }
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    /// 保存 工作群说明
//    {
//    "groupId":"群组id",
//    "remark":"群备注"
//    }
    class func saveGroupRemark(_ groupId: Int, remark: String) -> SW_GroupRequest {
        let request = SW_GroupRequest(resource: "saveGroupRemark.json")
        request["groupId"] = groupId
        request["remark"] = remark
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    //    {groupNum:"1134",staffId:"1134"}
    // 获取群名称和头像,并判断是否为群主 返回值isOwner：0不是群主，1是群主
    class func showGroup(_ groupNum: String, staffId: Int) -> SW_GroupRequest {
        let request = SW_GroupRequest(resource: "show.json")
        request["staffId"] = staffId
        request["groupNum"] = groupNum
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
        
    }
    
    //    {groupNum:"46711241244673",staffId:"1134",max:10,offset:0,type:"0:获取包含群主,1除群主的群成员"}
    //    分页获取群成员
    class func getGroupMemberList(_ groupNum: String, keyWord: String = "", max: Int = 15, offset: Int = 0, type: Int = 0) -> SW_GroupRequest {
        let request = SW_GroupRequest(resource: "memberList.json")
        request["keyWord"] = keyWord
        request["staffId"] = SW_UserCenter.shared.user!.id
        request["groupNum"] = groupNum
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
    
//        添加群成员
//    /{staffIds:"1134_1155",groupNum:""}
    class func addGroupMember(_ groupNum: String, staffIds: String) -> SW_GroupRequest {
        let request = SW_GroupRequest(resource: "addGroupMember.json")
        request["groupNum"] = groupNum
        request["staffIds"] = staffIds
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
        
    }
    
    //        删除群成员
    //    /{staffIds:"1134_1155",groupNum:""}
    class func delGroupMember(_ groupNum: String, staffIds: String) -> SW_GroupRequest {
        let request = SW_GroupRequest(resource: "delGroupMember.json")
        request["groupNum"] = groupNum
        request["staffIds"] = staffIds
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
        
    }
    
    
    //    转让群主
    //    /{ownerId:2,groupNum:""}
    class func transferChatGroupOwner(_ groupNum: String, ownerId: Int) -> SW_GroupRequest {
        let request = SW_GroupRequest(resource: "transferChatGroupOwner.json")
        request["groupNum"] = groupNum
        request["ownerId"] = ownerId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
        
    }
    
    //   根据关键词搜索人员和群组列表  全局搜索用
    //    {keyWord:"关键词"}
    class func getStaffAndGroupList(_ keyWord: String, staffId: Int) -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "getStaffAndGroupList.json")
        request["keyWord"] = keyWord
        request["staffId"] = staffId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
        
    }
}
