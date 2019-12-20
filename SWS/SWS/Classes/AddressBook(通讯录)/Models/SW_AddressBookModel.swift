//
//  SW_AddressBookModel.swift
//  SWS
//
//  Created by jayway on 2018/4/20.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

enum AddressBookType {
    case region             // 分区cell  与模型
    case business           // 单位cell  与模型
    case department         // 部门cell  与模型
    case contact            // 联系人cell  与模型
    case group              // 群组cell
}

class SW_AddressBookModel: NSObject {
    
    var type = AddressBookType.region
    //公用都有id
    var id = -1
    /// 公用name，自己新增的，有些地方能用上
    var name = ""
    //公用portrait
    var portrait = ""
    /// 公用的人数
    var staffCount = 0
    
    //    分区数据
//    "id" : 10,
//    "regionInfoStr" : "广东省-广州市-荔湾区"
    var regionName = ""
    
//    "id": 1,
//    "managerId": 0,
//    "managerPhone1": null,
//    "managerPhone2": null,
//    "establishTime": "12312",
//    "name": "沃尔沃",
//    "remark": "121",
//    "unitNum": "121212121",
//    "address": "惠州",
//    "telephone": "1212"
    var businessName = ""
    
//    "id": 2,
//    "departmentName": "销售部",
//    "departmentNum": "DP201803280007357"
    var departmentName = ""
    //  格式 ：    ”单位id_部门id“    明确的某个部门ID。
    var departmentId = ""
    
//    "positionName": "财务总监",
//    "realName": "颜赵东",
//    "portrait": "portrait/",
//    "staffId": 4
    var realName = ""
    var positionName = ""
    
    override init() {
        super.init()
    }
    
    init(_ json: JSON, type: AddressBookType) {
        super.init()
        self.type = type
        
        switch type {
        case .region:
            id = json["id"].intValue
            staffCount = json["staffCount"].intValue
            regionName = json["regStr"].stringValue
            name = regionName
        case .business:
            id = json["id"].intValue
            staffCount = json["staffCount"].intValue
            portrait = json["iconUrl"].stringValue
            businessName = json["name"].stringValue
            name = businessName
        case .department:
            id = json["id"].intValue
            staffCount = json["staffCount"].intValue
            departmentId = json["id"].stringValue
            portrait = json["iconUrl"].stringValue
            departmentName = json["name"].stringValue
            name = departmentName
        case .contact:
            id = json["staffId"].intValue
            realName = json["realName"].stringValue
            portrait = json["portrait"].stringValue
            positionName = json["positionName"].stringValue
            regionName = json["regStr"].stringValue/// 所在区域信息 如："广东省-惠州市-惠城区-沃尔沃-销售部"
        default:
            break
        }
    }
    
    init(staffJson: JSON) {
        super.init()
        self.type = .contact
        id = staffJson["id"].intValue
        realName = staffJson["realName"].stringValue
        portrait = staffJson["portrait"].stringValue
        positionName = staffJson["posName"].stringValue
        regionName = staffJson["regStr"].stringValue
    }
    
    init(name: String, id: Int, count: Int? = nil) {
        super.init()
        self.id = id
        self.name = name
        if let count = count {
            self.staffCount = count
        }
    }
}
