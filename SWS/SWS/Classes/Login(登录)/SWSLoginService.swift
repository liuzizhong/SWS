//
//  SWSLoginService.swift
//  SWS
//
//  Created by jayway on 2018/4/3.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit
import CloudPushSDK

class SWSLoginRequest: SWSRequest {
    override var apiURL: String {
        get {
            return SWSApiCenter.getBaseUrl() + "/api/app/staff"
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

enum SetUserInfoType: Int {
    case hobby        = 0
    case specialty
    case businessNum
    case portrait
}

enum SetPhoneNumType: Int {
    case num2        = 0
    case num3
}

class SWSLoginService: NSObject {
    
    // 获取员工基本信息  post   重新登录时用于更新userinfo
    class func getUserInfo(_ staffId: Int) -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "getUserInfo.json")
        request["staffId"] = staffId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    class func saveDeviceId() -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "saveDeviceId.json")
        request["staffId"] = SW_UserCenter.shared.user!.id
        request["deviceSysType"] = 2
        request["deviceId"] = CloudPushSDK.getDeviceId()
        request.send(.post).completion { (json, error) -> Any? in
            return json
        }
        return request
    }
    
    
    // 获取待办事项数量
    class func getBackLogCount() -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "getBackLogCount.json")
        request["staffId"] = SW_UserCenter.shared.user?.id ?? 0
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 获取待办事项列表数据
//    {
//    "backlogType":"1销售合同 2首保 3续保单 4维修单",
//    "isHistory":"是否为历史数据 1是 2否",
//    "staffId":"员工id",
//    "keyWord":"关键字"
//    }
    class func getBackLogList(_ backlogType: BackLogListType, isHistory: Int, keyWord: String, max: Int = 20, offset: Int = 0) -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "backLogList.json")
        request["staffId"] = SW_UserCenter.shared.user?.id ?? 0
        request["backlogType"] = backlogType.rawValue
        request["isHistory"] = isHistory
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
    
//    {staffId:"用户id",type:"0:修改爱好,1:修改特长,2:修改业务电话,3:头像" ,content:"修改的内容"}
    class func setUserInfo(_ staffId: Int, type: SetUserInfoType, content: String) -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "setUserInfo.json")
        request["staffId"] = staffId
        request["type"] = type.rawValue
        request["content"] = content
        request.send(.post).completion { (json, error) -> Any? in
//            if error == nil {
//                return json?["data"]
//            }
            return json
        }
        return request
    }
    
    //  更换联系方式  {staffId:"用户id",type:"0:联系方式2 , 1:联系方式3" ,phoneNum:"号码"}
    class func setPhoneNum(_ staffId: Int, type: SetPhoneNumType, phoneNum: String) -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "setPhoneNum.json")
        request["staffId"] = staffId
        request["type"] = type.rawValue
        request["phoneNum"] = phoneNum
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    //  删除联系方式  {staffId:"用户id",type:"0:联系方式2 , 1:联系方式3" ,phoneNum:"号码"}
    class func delPhoneNum(_ staffId: Int, type: SetPhoneNumType) -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "delPhoneNum.json")
        request["staffId"] = staffId
        request["type"] = type.rawValue
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    //  更换手机号 phonenum1  {staffId:"用户id",newPhoneNum:"新的手机号码"}
    class func setMobile(_ staffId: Int, newPhoneNum: String) -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "setMobile.json")
        request["staffId"] = staffId
        request["newPhoneNum"] = newPhoneNum
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    /// 帐号密码登录   post
    class func login(_ loginNum: String, password: String) -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "login.json")
        request["loginNum"] = loginNum
        request["password"] = password.passwordCoder()
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    // 校验密码  post   修改登录手机号码时先检验是否本人  {phoneNum:"登陆账号",password:"用户密码"}
    class func checkPwd(_ phoneNum: String, password: String) -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "checkPwd.json")
        request["phoneNum"] = phoneNum
        request["password"] = password.passwordCoder()
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 检查token是否过期   如果无过期后台会更新时效  过期则退出重新登录  7天都未登录过则过期   post
    class func checkLoginToken(_ token: String, staffId: Int) -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "checkLoginToken.json")
        request["token"] = token.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        request["staffId"] = staffId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 更新用户基本信息
    class func updateUserInfo(_ staffId: Int) -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "getUserInfo.json")
        request["staffId"] = staffId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    /// 员工无环信ID时调用创建环信账号
    ///
    /// - Parameter staffId: 员工id
    /// - Returns: 请求
    class func registerHxUser(_ staffId: Int) -> SWSRequest {
        let request = SWSRequest(resource: "registerHxUser.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/huanXin"
        request["staffId"] = staffId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 删除登陆token,退出App时调用   post
    class func delLoginToken(_ token: String) -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "delLoginToken.json")
        request["token"] = token.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//        request["staffId"] = staffId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 发送验证码   post
    class func sendValidate(_ phoneNum: String, type: Int) -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "sendValidate.json")
        request["phoneNum"] = phoneNum
        request["type"] = type
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
   
    /// 校验验证码   post
    class func checkValidate(_ phoneNum: String, code: String, type: Int, validateToken: String = "") -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "checkValidate.json")
        request["phoneNum"] = phoneNum
        request["code"] = code
        request["type"] = type
        if !validateToken.isEmpty {
            request["validateToken"] = validateToken
        }
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 注册新用户   post  {phoneNum:"账号",realName:"真实姓名",registerFrom:1 注意:" APP端注册传1,作为标识",password:"密码"}
    class func registerAccount(_ phoneNum: String, realName: String, password: String, registerFrom: Int = 1) -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "registerAccount.json")
        request["phoneNum"] = phoneNum
        request["realName"] = realName
        request["password"] = password
        request["registerFrom"] = registerFrom
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 第一次登陆修改密码   post
    class func setPassWordByFirst(_ staffId: Int, newPwd: String) -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "setPassWord.json")
        request["staffId"] = staffId
        request["newPwd"] = newPwd.passwordCoder()
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 手机号修改密码   post
    class func setPassWordByPhone(_ phoneNum: String, newPwd: String) -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "setPassWordByMobile.json")
        request["phoneNum"] = phoneNum
        request["newPwd"] = newPwd.passwordCoder()
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    /// 获取特长标签  post
    class func specialtiesLabelList() -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "specialtiesLabelList.json")
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 获取爱好标签  post
    class func hobbyLabelList() -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "hobbyLabelList.json")
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
}
