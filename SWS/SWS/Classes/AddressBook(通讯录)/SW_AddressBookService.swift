//
//  SW_AddressBookService.swift
//  SWS
//
//  Created by jayway on 2018/4/19.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_AddressBookService: NSObject {
    
    // 根据获取全部分区列表，并做数据处理，如：广东省-惠州市-惠城区
    // {staffId:"1134,keyWord:"搜索关键词",max:10,offset:0,sort:"id",order:"desc"}
    class func getRegionList(_ staffId: Int, keyWord: String = "", max: Int = 99999, offset: Int = 0) -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/regionInfo"
        request["staffId"] = staffId
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
    
    // 获取所有分区,单位,部门树状结构，
    class func getRegionTree() -> SWSRequest {
        let request = SWSRequest(resource: "getRegionTree.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/regionInfo"
        request.disableCache = true
        request.send(.get).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    // 获取通讯录单位列表 利用分区id
    // {keyWord:"",max:1,offset:0,staffId:2,regionId:2}
    class func getBusinessList(_ staffId: Int, regionId: Int, keyWord: String = "", max: Int = 99999, offset: Int = 0) -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/businessUnit"
        request["staffId"] = staffId
        request["regionId"] = regionId
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
    
    //     获取通讯录部门列表   businessUnitId 根据单位id
//    {
//    "offset":"0",
//    "max":"10",
//    "sort":"id",
//    "keyWord":"搜索关键词",
//    "order":"desc",
//    "bUnitId":"单位id"
//    }
    class func getDepartmentList(_ staffId: Int, bUnitId: Int, keyWord: String = "", max: Int = 99999, offset: Int = 0) -> SWSRequest {
        let request = SWSRequest(resource: "getListForContacts.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/department"
        request["staffId"] = staffId
        request["bUnitId"] = bUnitId
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
    
    
    // 获取部门员工列表
    // {keyWord:"搜索关键词",max:10,offset:0,sort:"id",order:"desc",departmentId:"部门id",staffId:"员工id"}
    class func getDepartmentStaffList(_ staffId: Int, departmentId: Int, businessUnitId: Int, keyWord: String = "", max: Int = 99999, offset: Int = 0) -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "getAddressBookStaffList.json")
        request["staffId"] = staffId
        request["departmentId"] = departmentId
        request["businessUnitId"] = businessUnitId
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
    
    
    // 获取通讯录部门员工列表    搜索用户  i新增接口
//    {
//    "offset":"0",
//    "regionId":"分区id",
//    "max":"15",
//    "deptId":"部门id",
//    "keyWord":"搜索关键词",
//    "bUnitId":"单位id"
//    }
    class func searchStaff(_ keyWord: String = "", regionId: SW_AddressBookModel?, bUnitId: SW_AddressBookModel?, deptId: SW_AddressBookModel?,  max: Int = 99999, offset: Int = 0) -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "searchStaff.json")
        if let regionId = regionId {
            request["regionId"] = regionId.id
        }
        if let bUnitId = bUnitId {
            request["bUnitId"] = bUnitId.id
        }
        if let deptId = deptId {
            request["deptId"] = deptId.id
        }
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
    
    
    // 获取通讯录部门员工详情
    // {staffId:"1134"}
    class func getStaffInfoDetail(_ staffId: Int) -> SWSLoginRequest {
        let request = SWSLoginRequest(resource: "getAddressBookStaffInfo.json")
        request["staffId"] = staffId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    
    // 根据staffId初始化通讯录群组列表
    // {staffId:"1134",keyWord:"搜索关键词",max:10,offset:0,sort:"id",order:"desc"}
    class func getGroupList(_ staffId: Int, keyWord: String = "", max: Int = 99999, offset: Int = 0) -> SW_GroupRequest {
        let request = SW_GroupRequest(resource: "list.json")
        request["staffId"] = staffId
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
    
}


/// 客户关系接口
class SW_CustomerRequest: SWSRequest {
    override var apiURL: String {
        get {
            return SWSApiCenter.getBaseUrl() + "/api/app/customer"
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

/// 临时客户相关接口
class SW_TempCustomerRequest: SWSRequest {
    override var apiURL: String {
        get {
            return SWSApiCenter.getBaseUrl() + "/api/app/customerTemp"
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

//MARK: -  临时客户相关接口
extension SW_AddressBookService {
//     {
//    "staffId":"销售顾问id",
//    "bUnitId":"销售顾问所在单位id"
//    regionId 分区id  createrId  创建人id
//    }
    /// 根据staffId 创建临时客户
    class func createTempCustomer() -> SW_TempCustomerRequest {
        let request = SW_TempCustomerRequest(resource: "create.json")
        request["staffId"] = SW_UserCenter.shared.user!.id
        request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
        request["regionId"] = SW_UserCenter.shared.user!.staffWorkDossier.regionInfoId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
//    {
//    "level":1,
//    "keyProblem":"核心问题",
//    "likeCarSeries":"",
//    "customerTempId":"5028b3fa653775a80165377ace8b0006",
//    "phoneNum":"手机号码",
//    "realName":"客户姓名",
//    "customerSourceSite":1,
//    "likeCarBrand":"",
//    "customerTempType":"1",
//    "likeCarModel":"",
//    "customerSource":1,
//    "staffId":"4"
//    "bUnitId":"1",
//    }
    /// 临时客户-建档、归档
    class func createCustomer(_ customerTempId: String, customerTempType: TempCustomerType, phoneNum: String, customer: SW_CustomerModel) -> SW_TempCustomerRequest {
        let request = SW_TempCustomerRequest(resource: "createCustomer.json")
        request["staffId"] = SW_UserCenter.shared.user!.id
        request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
        request["level"] = customer.level.rawValue
        request["keyProblem"] = customer.keyProblem
        request["likeCarBrand"] = customer.likeCarBrand
        request["likeCarSeries"] = customer.likeCarSeries
        request["likeCarModel"] = customer.likeCarModel
        request["realName"] = customer.realName
        request["customerSource"] = customer.customerSource.rawValue
        request["customerSourceSite"] = customer.customerSourceSite.rawValue
        request["customerTempId"] = customerTempId
        request["customerTempType"] = customerTempType.rawValue
        request["phoneNum"] = phoneNum
        request["province"] = customer.province
        request["city"] = customer.city
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
//    {
//    "clearPeople":"清除人名称",
//    "customerTempId":"临时客户Id",
//    "staffId":"销售顾问id",
//    "bUnitId":" 销售顾问所在单位id"
//    }
    ///     临时客户移除
    class func clear(_ customerTempId: String) -> SW_TempCustomerRequest {
        let request = SW_TempCustomerRequest(resource: "clear.json")
        request["staffId"] = SW_UserCenter.shared.user!.id
        request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
        request["clearPeople"] = SW_UserCenter.shared.user!.realName
        request["customerTempId"] = customerTempId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
//    {
//    "customerId":"对应临时客户已存在的客户id",
//    "customerTempType":"临时客户类型",
//    "customerTempId":"临时客户id",
//    "staffId":"销售顾问id",
//    "bUnitId":"单位id"
//    }
    ///     临时客户建档-协助接待
    class func assistingReception(_ customerTempId: String, customerTempType: TempCustomerType, customerId: String) -> SW_TempCustomerRequest {
        let request = SW_TempCustomerRequest(resource: "assistingReception.json")
        request["staffId"] = SW_UserCenter.shared.user!.id
        request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
        request["customerTempId"] = customerTempId
        request["customerTempType"] = customerTempType.rawValue
        request["customerId"] = customerId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    //    {
    //    "customerId":"对应临时客户已存在的客户id",
    //    "customerTempType":"临时客户类型",
    //    "customerTempId":"临时客户id",
    //    "staffId":"销售顾问id",
    //    "bUnitId":"单位id"
    //    }
    ///        临时客户建档-申请调档
    class func applyCustomerChangeSave(_ customerTempId: String, customerTempType: TempCustomerType, customerId: String) -> SW_TempCustomerRequest {
        let request = SW_TempCustomerRequest(resource: "applyCustomerChangeSave.json")
        request["staffId"] = SW_UserCenter.shared.user!.id
        request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
        request["customerTempId"] = customerTempId
        request["customerTempType"] = customerTempType.rawValue
        request["customerId"] = customerId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
}

// MARK: - 客户关系通讯录相关接口
extension SW_AddressBookService {
    
//    {
//"offset":"0",
//"lowDataPercentage":"客户资料完整度--低值",
//"max":"10",
//"level":"客户等级",
//"dataType":"1最近新客 2待访问  3全部",
//"staffId":"当前用户id",
//"bUnitId":"用户单位id",
//"keyWord":"关键词",
//"hightDataPercentage":"客户资料完整度--高值"
//    }
    /// 根据staffId初始化通讯录客户关系列表
    class func getCustomerList(_ keyWord: String = "", type: Int, level: Int, dataPercent: Int, max: Int = 99999, offset: Int = 0) -> SW_CustomerRequest {
        let request = SW_CustomerRequest(resource: "v2/customerList.json")
        request["staffId"] = SW_UserCenter.shared.user!.id
        request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
        request["keyWord"] = keyWord
        if keyWord.isEmpty {
            request["dataType"] = type
            if level != 0 {
                request["level"] = level
            }
            switch dataPercent {
            case 1:
                request["lowDataPercentage"] = 0
                request["hightDataPercentage"] = 59
            case 2:
                request["lowDataPercentage"] = 60
                request["hightDataPercentage"] = 79
            case 3:
                request["lowDataPercentage"] = 80
                request["hightDataPercentage"] = 100
            default:
                break
            }
        }
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
    
    
    //    {
    //        "staffId":"销售顾问id"
    //    }
    /// 根据customerId获取客户详情
    class func getCutomerCount() -> SW_CustomerRequest {
        let request = SW_CustomerRequest(resource: "cutomerCount.json")
        request["staffId"] = SW_UserCenter.shared.user!.id
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
//    {
//    "customerId":"客户id",
//    "staffId":"员工id"
//    }
    /// 根据customerId获取客户详情
    class func getCustomerDetail(_ customerId: String) -> SW_CustomerRequest {
        let request = SW_CustomerRequest(resource: "show.json")
        request["staffId"] = SW_UserCenter.shared.user!.id//staffId
        request["customerId"] = customerId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    /// 根据customerId获取客户详情
    class func getSellerList() -> SW_CustomerRequest {
        let request = SW_CustomerRequest(resource: "getSellerList.json")
        request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId//staffId
        request["staffId"] = SW_UserCenter.shared.user!.id
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
//    {
//    "customerId":"121212121112121212",
//    "consultantInfoId":"客户顾问信息id",
//    "staffId":"销售人员id"
//    }
    /// 根据customerId获取客户详情
    class func changeStaff(_ customerId: String, staffId: Int, consultantInfoId: Int) -> SW_CustomerRequest {
        let request = SW_CustomerRequest(resource: "changeStaff.json")
        request["staffId"] = staffId
        request["customerId"] = customerId
        request["consultantInfoId"] = consultantInfoId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    //    {
    //    "customerId":"客户id",
    //    "staffId":"员工id"
    //    }
    /// 根据customerId获取客户是否正在接待信息
    class func getCustomerBeingAccess(_ customerId: String) -> SW_CustomerRequest {
        let request = SW_CustomerRequest(resource: "beingAccess.json")
        request["staffId"] = SW_UserCenter.shared.user!.id
        request["customerId"] = customerId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 根据customerId获取客户 某用户下接待中的客户列表
    class func getCustomerAccessingList(_ staffId: Int) -> SW_CustomerRequest {
        let request = SW_CustomerRequest(resource: "accessingList.json")
        request["staffId"] = staffId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }

//    {
//    "customerId":"客户id",
//    "portrait":"头像key"
//    }
    /// 保存客户头像
    class func savePortrait(_ customerId: String, portrait: String) -> SW_CustomerRequest {
        let request = SW_CustomerRequest(resource: "savePortrait.json")
        request["customerId"] = customerId
        request["portrait"] = portrait
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    //    {
    //    "customerId":"客户id",
    //    "staffId":"员工id"
    //    "isFollow":"是否关注  1关注 2 不关注(默认)"
    //    }
    /// 关注取消关注客户
    class func followCustomer(_ customerId: String, isFollow: Bool) -> SW_CustomerRequest {
        let request = SW_CustomerRequest(resource: "followCustomer.json")
        request["staffId"] = SW_UserCenter.shared.user!.id
        request["customerId"] = customerId
        request["isFollow"] = isFollow ? 1 : 2
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    /// 保存客户意向信息
    class func saveCustomerIntention(_ customer: SW_CustomerModel) -> SWSRequest {
        let request = SWSRequest(resource: "save.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/customerIntention"
        request["customerId"] = customer.id
        request["dataPercentage"] = customer.dataPercentage
        request["customerIntentionId"] = customer.customerIntentionId
        request["consultantInfoId"] = customer.consultantInfoId
//        request["birthdayRemind"] = customer.birthdayRemind ? 1 : 0
        request["level"] = customer.level.rawValue
        request["customerSource"] = customer.customerSource.rawValue
        request["customerSourceSite"] = customer.customerSourceSite.rawValue
        request["interiorColor"] = customer.interiorColor
//        request["characteristics"] = customer.characteristics
        request["carUser"] = customer.carUser
        request["userSex"] = customer.userSex.rawValue
        request["useFor"] = customer.useFor.rawValue
        request["buyCount"] = max(1, customer.buyCount)
        request["buyBudget"] = customer.buyBudget
        request["buyWay"] = customer.buyWay.rawValue
        request["buyDate"] = customer.buyDate
        request["buyType"] = customer.buyType.rawValue
        request["keyProblem"] = customer.keyProblem
        request["province"] = customer.province
        request["city"] = customer.city
        request["likeCarBrand"] = customer.likeCarBrand
        request["likeCarSeries"] = customer.likeCarSeries
        request["likeCarModel"] = customer.likeCarModel
        request["likeCarColor"] = customer.likeCarColor
        request["contrastCarBrand"] = customer.contrastCarBrand
        request["contrastCarSeries"] = customer.contrastCarSeries
//        request["contrastCarModel"] = customer.contrastCarModel
//        request["contrastCarColor"] = customer.contrastCarColor
        request["replaceCarBrand"] = customer.replaceCarBrand
        request["replaceCarSeries"] = customer.replaceCarSeries
//        request["replaceCarModel"] = customer.replaceCarModel
//        request["replaceCarColor"] = customer.replaceCarColor
        request["havedCarBrand"] = customer.havedCarBrand
        request["havedCarSeries"] = customer.havedCarSeries
//        request["havedCarModel"] = customer.havedCarModel
//        request["havedCarColor"] = customer.havedCarColor
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    //    {
    //    "phoneNum":"客户手机号",
    //    "staffId":"当前用户id",
    //    "bUnitId":"用户单位id"
    //    }
    ///     查询客户信息   查询是否存在
    class func queryCustomer(_ phoneNum: String = "") -> SW_CustomerRequest {
        let request = SW_CustomerRequest(resource: "queryCustomer.json")
        request["staffId"] = SW_UserCenter.shared.user!.id
        request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
        request["phoneNum"] = phoneNum
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
//    {
//    "numberPlate":"车牌号"
//    }
    /// 获取客户以及车辆信息通过车牌号
    class func getCustomerInfoByNumberPlate(_ numberPlate: String) -> SW_CustomerRequest {
        let request = SW_CustomerRequest(resource: "getCustomerInfoAndCarInfoByNumberPlate.json")
        request["numberPlate"] = numberPlate
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
//    {
//    "birthdayRemind":"生日提醒 0 不开启 1 开启",
//    "customerIntentionId":"客户意向信息id"
//    }
    /// 根据 customerIntentionId  修改客户生日提醒
    class func setBirthdayRemind(_ customerIntentionId: String, birthdayRemind: Bool) -> SWSRequest {
        let request = SWSRequest(resource: "setBirthdayRemind.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/customerIntention"
        
        request["birthdayRemind"] = birthdayRemind ? "1" : "0"
        request["customerIntentionId"] = customerIntentionId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
}

/// 访客记录相关请求
class SW_CustomerRecordRequest: SWSRequest {
    override var apiURL: String {
        get {
            return SWSApiCenter.getBaseUrl() + "/api/app/accessCustomerRecord"
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


// MARK: - 访客记录相关接口
extension SW_AddressBookService {
    // 获取访问客户记录列表数据
    class func getAccessCustomerRecordList(_ consultantInfoId: Int, max: Int = 99999, offset: Int = 0) -> SW_CustomerRecordRequest {
        let request = SW_CustomerRecordRequest(resource: "list.json")
        request["consultantInfoId"] = consultantInfoId
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
    
    // 获取访问客户记录数据详情
    class func getAccessCustomerRecord(_ recordId: String) -> SW_CustomerRecordRequest {
        let request = SW_CustomerRecordRequest(resource: "show/\(recordId).json")
        request.disableCache = true
        request.send(.get).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }

    /// 保存访问客户记录信息
    class func saveAccessCustomerRecord(_ record: SW_AccessCustomerRecordModel) -> SW_CustomerRecordRequest {
        let request = SW_CustomerRecordRequest(resource: "save.json")
        
        request["accessType"] = record.accessType.rawValue
        request["customerId"] = record.customerId
        request["staffId"] = SW_UserCenter.shared.user!.id
        request["recordContent"] = record.recordContent
        if record.startDate != 0 {
            request["startDate"] = record.startDate
        }
        if record.endDate != 0 {
            request["endDate"] = record.endDate
        }
        request["regionId"] = SW_UserCenter.shared.user!.staffWorkDossier.regionInfoId
        request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
        request["deptId"] = SW_UserCenter.shared.user!.staffWorkDossier.departmentId
        request["testDriveRecordId"] = record.testDriveRecordId
        request["testCarBrand"] = record.testCarBrand
        request["testCarSeries"] = record.testCarSeries
        request["testCarModel"] = record.testCarModel
//        request["testCarColor"] = record.testCarColor
        request["testDriveContractImg"] = record.testDriveContractImg
        request["testCarVIN"] = record.testCarVIN
        request["testCarKeyNum"] = record.testCarKeyNum
        request["testCarNumberPlate"] = record.testCarNumberPlate
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }

    /// 更新-结束销售接待记录信息
    class func updateAccessCustomerRecord(_ record: SW_AccessCustomerRecordModel) -> SW_CustomerRecordRequest {
        let request = SW_CustomerRecordRequest(resource: "receptionUpdate.json")
        request["accessCustomerRecordId"] = record.id
        request["customerId"] = record.customerId
        request["comeStoreType"] = record.comeStoreType.rawValue
        request["recordContent"] = record.recordContent
        request["satisfaction"] = record.satisfaction.rawValue
        request["staffId"] = SW_UserCenter.shared.user!.id
        request["customerCount"] = record.customerCount
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }



    /// 试乘试驾评论保存 -结束试乘试驾
    class func saveTestDriveComment(_ comment: SW_TestDriveCommentModel) -> SW_CustomerRecordRequest {
        let request = SW_CustomerRecordRequest(resource: "testDriveCommentSave.json")
        request["accessCustomerRecordId"] = comment.recordId
        request["staffId"] = SW_UserCenter.shared.user!.id
        request["testDriveContent"] = comment.testDriveContent
        request["customerId"] = comment.customerId
//        request["serviceItems"] = comment.serviceItems.map({ (model) -> [String:Any] in
//            return ["id":model.id,"score":Int(model.value)]
//        })
//        request["carItems"] = comment.carItems.map({ (model) -> [String:Any] in
//            return ["id":model.id,"score":Int(model.value)]
//        })
        
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    /// 试乘试驾评论保存 -结束试乘试驾  新接口
    class func saveTestDriveContent(_ comment: SW_TestDriveCommentModel) -> SW_CustomerRecordRequest {
        let request = SW_CustomerRecordRequest(resource: "testDriveContentSave.json")
        request["accessCustomerRecordId"] = comment.recordId
        request["staffId"] = SW_UserCenter.shared.user!.id
        request["testDriveContent"] = comment.testDriveContent
        request["customerId"] = comment.customerId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
//    /// 获取服务评价项目 - 评价试乘试驾
//    class func getServiceItemList() -> SWSRequest {
//        let request = SWSRequest(resource: "list.json")
//        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/serviceItem"
//        request.send(.post).completion { (json, error) -> Any? in
//            if error == nil {
//                return json?["data"]
//            }
//            return json
//        }
//        return request
//    }
//
//    /// 获取车辆评价项目 - 评价试乘试驾
//    class func getCarItemList() -> SWSRequest {
//        let request = SWSRequest(resource: "list.json")
//        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/carItem"
//        request.send(.post).completion { (json, error) -> Any? in
//            if error == nil {
//                return json?["data"]
//            }
//            return json
//        }
//        return request
//    }
    
    // 获取客户购车记录列表数据
//    {
//    "offset":0,
//    "max":10,
//    "customerId":"客户id",
//    "bUnitId":"单位id",
//    }
    class func getCarSalesContractRecordList(_ customerId: String, appKeyWord: String = "", max: Int = 99999, offset: Int = 0) -> SWSRequest {
        let request = SWSRequest(resource: "list.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/carSalesContract"
        if !customerId.isEmpty {
            request["customerId"] = customerId
        } else {
            request["contractAuditState"] = 3
            request["isFinal"] = 2
            request["isInvalid"] = 2
        }
        if !appKeyWord.isEmpty {
            request["appKeyWord"] = appKeyWord
        }
        request["max"] = max
        request["offset"] = offset
        request["bUnitId"] = SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    
    ///  根据合同id 获取购车合同信息
    ///
    /// - Parameter contractId: 合同id
    /// - Returns: 请求
    class func getCarSalesContractDetail(_ contractId: String, modifyAuditState: AuditState) -> SWSRequest {
        let apiStr = modifyAuditState == .wait ? "modifyShow" : "show"
        let request = SWSRequest(resource: "\(apiStr)/\(contractId).json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/carSalesContract"
        request.disableCache = true
        request.send(.get).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    // 审核车辆销售合同
//    {
//    "contractId":"合同id",
//    "remark":"备注",
//    "isReject":"是否为驳回日志  1驳回 2通过"
//    }
    class func carSalesContractAudit(_ contractId: String, remark: String = "", isReject: Int) -> SWSRequest {
        let request = SWSRequest(resource: "carSalesContractAudit.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/carSalesContract"
        request["contractId"] = contractId
        request["remark"] = remark
        request["isReject"] = isReject
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
    // 审核销售合同作废
    //    {
    //    "contractId":"合同id",
    //    "remark":"备注",
    //    "isReject":"是否为驳回日志  1驳回 2通过"
    //    }
    class func carSalesContractInvalidAudit(_ contractId: String, remark: String = "", isReject: Int) -> SWSRequest {
        let request = SWSRequest(resource: "carSalesContractInvalidAudit.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/carSalesContract"
        request["contractId"] = contractId
        request["remark"] = remark
        request["isReject"] = isReject
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
    
//    api/app/carSalesContract/auditModifyContract.json 审核修改申请
    // 审核销售合同修改
    //    {
    //    "contractId":"合同id",
    //    "remark":"备注",
    //    "isReject":"是否为驳回日志  1驳回 2通过"
    //    }
    class func carSalesContractModifyAudit(_ contractId: String, remark: String = "", isReject: Int) -> SWSRequest {
        let request = SWSRequest(resource: "auditModifyContract.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/carSalesContract"
        request["contractId"] = contractId
        request["remark"] = remark
        request["isReject"] = isReject
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
}
