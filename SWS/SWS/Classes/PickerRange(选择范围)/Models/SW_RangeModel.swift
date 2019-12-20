//
//  SW_RangeModel.swift
//  SWS
//
//  Created by jayway on 2018/5/7.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit
//import WCDBSwift

enum RangeType: Int/*, TableCodable*/ {//同样用于标识model数据的类型
    case region       = 0      //全部分区
    case business              //选择的分区单位
    case department            //选择的单位部门
    case staff                 //选择的部门人员
    
//    enum CodingKeys: String, CodingTableKey {
//        typealias Root = RangeType
//        static let objectRelationalMapping = TableBinding(CodingKeys.self)
//        case region
//        case business
//        case department
//        case staff
//    }
}

enum MemberType: Int {//同样用于标识model数据的类型
    case owner       = 0      //群主
    case normal               //普通群成员
}

class SW_RangeModel: NSObject, NSCoding/*, TableCodable */{
    func encode(with aCoder: NSCoder) {
        aCoder.encode(type.rawValue, forKey: "type")
        aCoder.encode(id, forKey: "id")
        aCoder.encode(regId, forKey: "regId")
        aCoder.encode(busId, forKey: "busId")
        aCoder.encode(depId, forKey: "depId")
        aCoder.encode(staffCount, forKey: "count")
        aCoder.encode(realName, forKey: "realName")
        aCoder.encode(portrait, forKey: "portrait")
    }
    
    required init?(coder aDecoder: NSCoder) {
        type = RangeType(rawValue:  aDecoder.decodeInteger(forKey: "type")) ?? .region
        id = aDecoder.decodeInteger(forKey: "id")
        regId = aDecoder.decodeInteger(forKey: "regId")
        busId = aDecoder.decodeInteger(forKey: "busId")
        depId = aDecoder.decodeInteger(forKey: "depId")
        staffCount = aDecoder.decodeInteger(forKey: "count")
        portrait = aDecoder.decodeObject(forKey: "portrait") as? String ?? ""
        realName = aDecoder.decodeObject(forKey: "realName") as? String ?? ""
    }
    
    
//    enum CodingKeys: String, CodingTableKey {
//        typealias Root = SW_RangeModel
//        static let objectRelationalMapping = TableBinding(CodingKeys.self)
//        case type
//        case id
//        case regId
//        case busId
//        case depId
//        case count
//    }
    
    var type = RangeType.region//根据type解析数据
    
    //当前范围下的  子范围
//    var subRange: [SW_RangeModel]?
    
    //当前项的id
    var id = 0
//    ---------------------------
    // 当前项  所在的上级的id   ： -1 代表没有该上级
    //当前项所在的分区id
    var regId = 0
    //当前项所在的单位id
    var busId = 0
    //当前项所在的部门id
    var depId = 0
    
    //该范围下的总人数
    var staffCount = 0
    
    //    分区数据
    var regStr = ""
    
//    单位数据
    var businessName = ""
    
//    部门数据
    var departmentName = ""
    
//    员工数据
    var realName = ""
    var portrait = ""
    var positionName = ""
    //添加置顶联系人时使用 环信账号
    var huanxinUser = ""
    // 管理群时使用
    var memberType = MemberType.normal
    
    //工作报告接收人用
    var isCheck = false
    var comment = ""
    var checkDate: TimeInterval = 0
    
    
    override init() {
        super.init()
    }
    
    init(_ json: JSON, type: RangeType) {
        super.init()
        self.type = type
        
        //都有count
        staffCount = json["staffCount"].intValue
        
        switch type {
        case .region:
            //    "id": 4,
            //    "regStr": "广东省-惠州市-惠城区",
            //    "count": 3
            id = json["id"].intValue
            regStr = json["regStr"].stringValue
        case .business:
            //    "id": 1,
            //    "regId": 4,
            //    "name": "沃尔沃",
            //    "count": 4
            id = json["id"].intValue
            regId = json["regId"].intValue
            businessName = json["name"].stringValue
        case .department:
            //    "regId": 4,
            //    "busId": 1,
            //    "depId": 2,
            //    "regStr": "广东省-惠州市-惠城区",
            //    "depName": "销售部",
            //    "busName": "沃尔沃",
            //    "count": 3
            id = json["depId"].intValue
            regId = json["regId"].intValue
            busId = json["busId"].intValue
            regStr = json["regStr"].stringValue
            businessName = json["busName"].stringValue
            departmentName = json["depName"].stringValue
        case .staff:
            //    "portrait": "http://img-test.yuanruiteam.com/portrait/1/1524212852785.jpg",
            //    "id": 1,
            //    "regId": 4,
            //    "busId": 1,
            //    "depId": 2,
            //    "realName": "张剑威",
            //    "posName": "财务总监",
            //    "regStr": "广东省-惠州市-惠城区-沃尔沃-销售部"
            id = json["id"].intValue
            regId = json["regId"].intValue
            busId = json["busId"].intValue
            depId = json["depId"].intValue
            realName = json["realName"].stringValue
            portrait = json["portrait"].stringValue
            positionName = json["posName"].stringValue
            regStr = json["regStr"].stringValue
            huanxinUser = json["huanxinUser"].stringValue
            memberType = MemberType(rawValue: json["memberType"].int ?? 1) ?? .normal
        }
    }
    
    //    "name": "张剑威",
    //    "isCheck": 0,
    //    "staffId": 1,
    //    "portrait": "http://img-test.yuanruiteam.com/portrait/1/1531382370980.jpg",
    //    "comment": "",
    //    "checkDate": 0
    init(commentJson: JSON) {
        super.init()
        self.type = .staff
        id = commentJson["staffId"].intValue
        realName = commentJson["name"].stringValue
        portrait = commentJson["portrait"].stringValue
        isCheck = commentJson["isCheck"].intValue == 0
        comment = commentJson["comment"].stringValue
        checkDate = commentJson["checkDate"].doubleValue
    }
    
    
    /// 接收一个群成员数组 排序后返回 群主排到第一位  管理员接后面 普通成员在后面
    ///
    /// - Parameter groupMembers: 需要排序的数组
    /// - Returns: 排序好后的数组
    class func sortGroupMembers(_ groupMembers: [SW_RangeModel]) -> [SW_RangeModel] {
        var groupMembers = groupMembers
        if let index = groupMembers.index(where: { return $0.memberType == .owner }) {
            let owner = groupMembers[index]
            groupMembers.remove(at: index)
            groupMembers.insert(owner, at: 0)
        }
        return groupMembers
    }
    
}


//MARK: - NSCopying
extension SW_RangeModel: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copyObj = SW_RangeModel()
        copyObj.type = type
        copyObj.id = id
        copyObj.regId = regId
        copyObj.busId = busId
        copyObj.depId = depId
        copyObj.realName = realName
        copyObj.portrait = portrait
        return copyObj
    }
    
}
