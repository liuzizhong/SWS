//
//  UserModel.swift
//  SWS
//
//  Created by jayway on 2018/1/2.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

enum Sex: Int {
    case women  = 0  //女
    case man    = 1  //男
    case unkown = 2  //未知
    
    var rawTitle: String {
        switch self {
        case .women:
            return "女"
        case .man:
            return "男"
        case .unkown:
            return ""
        }
    }
    
    init(_ title: String) {
        switch title {
        case "女性":
            self = .women
        case "男性":
            self = .man
        default:
            self = .unkown
        }
    }
    
    var littleImage: UIImage {
        switch self {
        case .women:
            return #imageLiteral(resourceName: "women")
        case .man:
            return #imageLiteral(resourceName: "men")
        case .unkown:
            return #imageLiteral(resourceName: "men")
        }
    }
    
    var bigImage: UIImage {
        switch self {
        case .women:
            return #imageLiteral(resourceName: "big_women")
        case .man:
            return #imageLiteral(resourceName: "big_men")
        case .unkown:
            return #imageLiteral(resourceName: "big_men")
        }
    }
}

enum Marry: Int {
    case unmarried  = 0  // 未婚
    case married    = 1  // 已婚
    case divorced   = 2  //异地？？？？离异？？
    
    var rawTitle: String {
        switch self {
        case .unmarried:
            return "未婚"
        case .married:
            return "已婚"
        case .divorced:
            return "离异"
        }
    }
}

class UserModel: NSObject {
    //登录后token
    var token = ""
    
    ///集团名称
    var blocName = ""
    ///单位名称
    var businessUnitName = ""
    ///部门名称
    var departmentName = ""
    ///集团图标
    var blocIcon = ""
    ///单位图标
    var busIcon = ""
    ///部门图标
    var depIcon = ""
    
    ///用户ID
    var id = 0
    ///员工编号
    var jobNum = ""
    ///真实姓名
    var realName = ""
    ///昵称
    var nickname = ""
    ///年龄
    var age = ""
    ///性别
    var sex = Sex.unkown
    ///生日
    var birthday: TimeInterval = 0 {
        didSet {
            if birthday == 0 {
                birthdayString = ""
            } else {
                birthdayString = Date.dateWith(timeInterval: birthday).simpleTimeString(formatter: .year)
            }
        }
    }
    ///体重
    var weight: Double = 0
    ///身高
    var bodyHeight = ""
    
    ///结婚情况
     var isMarried = Marry.unmarried
    /// 职务
     var position = ""
    
    ///手机号码1    登录手机号  可更改
     var phoneNum1 = ""
    ///手机号码2
    var phoneNum2 = ""
    ///手机号码3
    var phoneNum3 = ""
    ///业务号码
    var businessNum = ""
    //--------------------------------------------------------
    ///头像
    var portrait = ""
    
    ///是否第一次登录
    var isFirstLogin = false
    //--------------------------------------------------------
    ///  1个月  试用期？
    var seniority = ""
    
    ///籍贯
    var origin = ""
    ///地区
    var regionInfo = ""
    ///民族
    var nation = "汉族"
    ///工作状态
    var jobStauts = 0
    
    ///特长
    var specialty = ""
    ///爱好
    var hobby = ""
    
    ///紧急联系人名称
    var contacterName = ""
    ///紧急联系人号码
    var contacterNum = ""
    ///紧急联系人与自己关系
    var contacteRrelation = ""
    
    var birthdayString = ""
    //---------- 文档有 接口没返回的
//    isOperator    是否为管理员 0 不是 1 是
//    Type: Int
//    Multiple: false
    //-----------
    var huanxin = HuanXin(json: JSON.init([]))
    
    //权限管理模型
    var auth = AuthModel(json: JSON.init([]))
    
    var staffSaveData = StaffSaveData(json: JSON.init([]))
    
    var staffWorkDossier = StaffWorkDossier(json: JSON.init([]))
    
    init(jsonDict: [String: Any]) {
        super.init()
        let json = JSON.init(jsonDict)
        setUserData(json: json["user"])
        token = json["token"].stringValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//        staffSaveData       staffWelfareDossier    这两个是null  还不知道是什么
        huanxin = HuanXin(json: json["huanxin"])
        auth = AuthModel(json: json["auth"])
        staffWorkDossier = StaffWorkDossier(json: json["staffWorkDossier"])
        staffSaveData = StaffSaveData(json: json["staffSaveData"])
    }
    
    ///查看员工详情时创建的员工对象 登录时不用这个方法
    init(staffJson: JSON) {
        super.init()
        setUserData(json: staffJson["userInfo"])
        huanxin = HuanXin(json: staffJson["huanxin"])
        departmentName = staffJson["departmentName"].stringValue
        position = staffJson["staffPositionName"].stringValue
        regionInfo = staffJson["userInfo"]["regionInfo"].stringValue
        businessUnitName = staffJson["businessName"].stringValue
    }
    
    func setUserData(json: JSON) {//登录接口数据解析
        blocName = json["blocName"].stringValue
        businessUnitName = json["businessUnitName"].stringValue
        departmentName = json["departmentName"].stringValue
        blocIcon = json["blocIcon"].stringValue
        busIcon = json["busIcon"].stringValue
        depIcon = json["depIcon"].stringValue
        id = json["id"].intValue//83//76//80//75//83
        jobNum = json["jobNum"].stringValue
        realName = json["realName"].stringValue
        nickname = json["nickname"].stringValue
        //保存用户头像数据
        portrait = json["portrait"].stringValue
        if SW_UserCenter.shared.user == nil || id == SW_UserCenter.shared.user?.id {/// 如果没登录，赋值
            InsertMessageToPerform(portrait, ICON_IMAGE)
        }
        isFirstLogin = json["isFirstLogin"].intValue != 1
        age = json["age"].stringValue
        sex = Sex.init(rawValue: json["sex"].intValue) ?? .unkown
        birthday = json["birthday"].doubleValue
        weight = json["weight"].doubleValue
        bodyHeight = json["bodyHeight"].stringValue
        isMarried = Marry.init(rawValue: json["isMarried"].intValue) ?? .unmarried
        position = json["position"].stringValue
        phoneNum1 = json["phoneNum1"].stringValue
        phoneNum2 = json["phoneNum2"].stringValue
        phoneNum3 = json["phoneNum3"].stringValue
        businessNum = json["businessNum"].stringValue
        seniority = json["seniority"].stringValue
        origin = json["origin"].stringValue
        regionInfo = json["regionInfo"].stringValue
        nation = json["nation"].stringValue
        jobStauts = json["jobStauts"].intValue
        specialty = json["specialty"].stringValue
        hobby = json["hobby"].stringValue
        contacterName = json["contacterName"].stringValue
        contacterNum = json["contacterNum"].stringValue
        contacteRrelation = json["contacteRrelation"].stringValue
    }
    
    func updateUserData(_ json: JSON) {
//        let json = json["staff"]
        businessNum = json["userInfo"]["businessNum"].stringValue
        phoneNum1 = json["userInfo"]["phoneNum1"].stringValue
        phoneNum2 = json["userInfo"]["phoneNum2"].stringValue
        phoneNum3 = json["userInfo"]["phoneNum3"].stringValue
        hobby = json["userInfo"]["hobby"].stringValue
        specialty = json["userInfo"]["specialty"].stringValue
//        isFirstLogin = json["userInfo"]["isFirstLogin"].intValue != 1
        nickname = json["userInfo"]["nickname"].stringValue
        portrait = json["userInfo"]["portrait"].stringValue
//        if !json["userInfo"]["blocName"].stringValue.isEmpty {
            blocName = json["userInfo"]["blocName"].stringValue
//        }
//        if !json["businessName"].stringValue.isEmpty {
            businessUnitName = json["businessName"].stringValue
//        }
//        if !json["departmentName"].stringValue.isEmpty {
            departmentName = json["departmentName"].stringValue
//        }
//        if !json["userInfo"]["blocIcon"].stringValue.isEmpty {
            blocIcon = json["userInfo"]["blocIcon"].stringValue
//        }
//        if !json["userInfo"]["busIcon"].stringValue.isEmpty {
            busIcon = json["userInfo"]["busIcon"].stringValue
//        }
//        if !json["userInfo"]["depIcon"].stringValue.isEmpty {
            depIcon = json["userInfo"]["depIcon"].stringValue
//        }
        position = json["staffPositionName"].stringValue
         regionInfo = json["userInfo"]["regionInfo"].stringValue
        auth = AuthModel(json: json["auth"])
        //每次更新了用户数据则进行一次缓存更新
        updateUserDataToCache()
    }
    
    //当用户数据改变时，可以调用该方法更新缓存的用户数据，   如头像，是否第一次登录等
    func updateUserDataToCache() {
        var json = [String: Any]()
        json["blocName"] = blocName
        json["businessUnitName"] =  businessUnitName
        json["departmentName"] = departmentName
        json["blocIcon"] =  blocIcon
        json["busIcon"] =  busIcon
        json["depIcon"] =  depIcon
        json["id"] = id
        json["jobNum"] = jobNum
        json["realName"] = realName
        json["nickname"] = nickname
        //保存用户头像数据
        json["portrait"] = portrait
        InsertMessageToPerform(portrait, ICON_IMAGE)
        json["isFirstLogin"] = isFirstLogin ? 0 : 1
        json["age"] = age
        json["sex"] = sex.rawValue
        json["birthday"] = birthday
        json["weight"] = weight
        json["bodyHeight"] = bodyHeight
        json["isMarried"] = isMarried.rawValue
        json["position"] = position
        json["phoneNum1"] = phoneNum1
        json["phoneNum2"] = phoneNum2
        json["phoneNum3"] = phoneNum3
        json["businessNum"] = businessNum
        json["seniority"] = seniority
        json["origin"] = origin
        json["regionInfo"] = regionInfo
        json["nation"] = nation
        json["jobStauts"] = jobStauts
        json["specialty"] = specialty
        json["hobby"] = hobby
        json["contacterName"] = contacterName
        json["contacterNum"] = contacterNum
        json["contacteRrelation"] = contacteRrelation
        
        UserCache?.setObject(["token": token, "user": json, "staffWorkDossier": staffWorkDossier.toDictionary(), "huanxin": huanxin.toDictionary(), "auth": auth.toDictionary(), "staffSaveData": staffSaveData.toDictionary()] as [String : Any] as NSCoding, forKey: USERDATAKEY)
    }
}

//员工工作档案
class StaffWorkDossier: NSObject {
    ///在职状态  在职或者离职
//    var jobStatus = 0
    
    ///自己所在区域id
    var regionInfoId = 0
    ///自己所在单位id
    var businessUnitId = 0
    ///自己所在部门id
    var departmentId = 0
    ///自己所在职务id
    var staffPositionId = 0
    
    init(json: JSON) {
//        jobStatus = json["jobStatus"].intValue
        regionInfoId = json["regionInfoId"].intValue
        businessUnitId = json["businessUnitId"].intValue
        departmentId = json["departmentId"].intValue
        staffPositionId = json["staffPositionId"].intValue
    }
    
    func toDictionary() -> [String: Any] {
        var dict = [String: Any]()
//        dict["jobStatus"] = jobStatus
        dict["regionInfoId"] = regionInfoId
        dict["businessUnitId"] = businessUnitId
        dict["departmentId"] = departmentId
        dict["staffPositionId"] = staffPositionId
        return dict
    }
}

// 身份证号码
class StaffSaveData: NSObject {
    var idCard = "无"
    
    init(json: JSON) {
        idCard = json["idCard"].string ?? "无"
    }
    
    func toDictionary() -> [String: Any] {
        var dict = [String: Any]()
        dict["idCard"] = idCard
        return dict
    }
}

// 环信数据 用户名或者密码
class HuanXin: NSObject {

    var huanxinAccount = ""
    ///自己所在单位id
    var huanxinPwd = ""

    
    init(json: JSON) {
        huanxinAccount = json["huanxinAccount"].stringValue
        huanxinPwd = json["huanxinPwd"].stringValue
    }
    
    func toDictionary() -> [String: Any] {
        var dict = [String: Any]()
        dict["huanxinAccount"] = huanxinAccount
        dict["huanxinPwd"] = huanxinPwd
        return dict
    }
}
