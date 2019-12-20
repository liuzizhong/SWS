//
//  SW_InformModel.swift
//  SWS
//
//  Created by jayway on 2018/4/27.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit
//import WCDBSwift

enum InformType: Int/*, TableCodable*/ {
    case group       = 0    // 集团公告
    case business           // 单位公告
    case department         // 部门公告
    
//    enum CodingKeys: String, CodingTableKey {
//        typealias Root = InformType
//        static let objectRelationalMapping = TableBinding(CodingKeys.self)
//        case group
//        case business
//        case department
//    }
    var defaultImage: UIImage {
        switch self {
        case .group:
            return #imageLiteral(resourceName: "blocIcon")
        case .business:
            return #imageLiteral(resourceName: "company_notifacation")
        case .department:
            return #imageLiteral(resourceName: "departmentIcon")
        }
    }
    
    
    init(_ title: String) {
        switch title {
        case InternationStr("集团公告"):
            self = .group
        case InternationStr("单位通知"):
            self = .business
        case InternationStr("部门通知"):
            self = .department
        default:
            self = .group
        }
    }
    
    var rawTitle: String {
        switch self {
        case .group:
            return InternationStr("集团公告")
        case .business:
            return InternationStr("单位通知")
        case .department:
            return InternationStr("部门通知")
        }
    }
    
    var rangeTableName: String {
        switch self {
        case .group:
            return "groupRangeTable\(SW_UserCenter.getUserCachePath())"
        case .business:
            return "businessRangeTable\(SW_UserCenter.getUserCachePath()))"
        case .department:
            return "departmentRangeTable\(SW_UserCenter.getUserCachePath()))"
        }
    }
    
    var unReadCountCachePath: String {
        switch self {
        case .group:
            return "groupUnReadCount\(SW_UserCenter.getUserCachePath()))"
        case .business:
            return "businessUnReadCount\(SW_UserCenter.getUserCachePath()))"
        case .department:
            return "departmentUnReadCount\(SW_UserCenter.getUserCachePath()))"
        }
    }
    
    var msgListTableName: String {
        switch self {
        case .group:
            return "groupMsgList\(SW_UserCenter.getUserCachePath()))"
        case .business:
            return "businessMsgList\(SW_UserCenter.getUserCachePath()))"
        case .department:
            return "departmentMsgList\(SW_UserCenter.getUserCachePath())"
        }
    }
}


class SW_InformModel: NSObject, NSCoding/*, TableCodable*/ {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(coverImg, forKey: "coverImg")
        aCoder.encode(summary, forKey: "summary")
        aCoder.encode(content, forKey: "content")
        aCoder.encode(showUrl, forKey: "showUrl")
        aCoder.encode(timestamp, forKey: "timestamp")
    }
    
    required init?(coder aDecoder: NSCoder) {
        title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
        coverImg = aDecoder.decodeObject(forKey: "coverImg") as? String ?? ""
        summary = aDecoder.decodeObject(forKey: "summary") as? String ?? ""
        content = aDecoder.decodeObject(forKey: "content") as? String ?? ""
        showUrl = aDecoder.decodeObject(forKey: "showUrl") as? String ?? ""
        timestamp = aDecoder.decodeInt64(forKey: "timestamp")
        id = aDecoder.decodeInteger(forKey: "id")
    }
    
    
//    enum CodingKeys: String, CodingTableKey {
//        typealias Root = SW_InformModel
//        static let objectRelationalMapping = TableBinding(CodingKeys.self)
////        case msgType = "messageType"
//        case title
//        case coverImg
//        case summary
//        case showUrl
//        case timestamp
//    }
    
    //发布者姓名
//    var publisher = ""
    //发布者部门
//    var department = ""
    //发布者的id
    var publisherId = -1
    //公告的类型
    var msgType = InformType.group
    
    var title = ""
    var content = ""
    var summary = ""
    var coverImg = ""//封面图片
    var showUrl = ""
    var publishDate: TimeInterval = 0//公告发布时间
    var msgCollectDate: TimeInterval = 0//公告收藏时间
    var id = -1//该条公告的id
//    var readedCount = 0
//    var acceptCount = 0
    
    var timestamp: Int64 = 0
    
    init(_ json: JSON) {
        super.init()
//        publisher = json["publisher"].stringValue
//        department = json["department"].stringValue
        publisherId = json["publisherId"].intValue
        msgType = InformType(rawValue: json["msgTypeId"].intValue) ?? .group
        title = json["title"].stringValue
        content = json["content"].stringValue
        summary = json["summary"].stringValue
        coverImg = json["coverImg"].stringValue
        showUrl = json["showUrl"].stringValue
        publishDate = json["publishDate"].doubleValue
        msgCollectDate = json["msgCollectDate"].doubleValue
        id = json["id"].intValue
//        readedCount = json["readedCount"].intValue
//        acceptCount = json["acceptCount"].intValue
    }
    
//    Optional([AnyHashable("summary"): hhhhhh, AnyHashable("imgUrl"): http://img-test.yuanruiteam.com/message/201805/123., AnyHashable("title"): hhhhhh, AnyHashable("showUrl"): http://test-oamng.yuanruiteam.com/message/show/123, AnyHashable("msgTypeId"): 0])
    init(dict: [String: Any]) {
        super.init()
        msgType = InformType(rawValue: dict["msgTypeId"] as? Int ?? 0) ?? .group
        title = dict["title"] as? String ?? ""
        summary = dict["summary"] as? String ?? ""
        content = dict["content"] as? String ?? ""
        coverImg = dict["imgUrl"] as? String ?? ""
        showUrl = dict["showUrl"] as? String ?? ""
        id = dict["msgId"] as? Int ?? 0
        timestamp = dict["timestamp"] as? Int64 ?? 0
    }
    
}


struct SW_ReadRecordStaffModel {
//    "staffName": "蔡景裕",
//    "positionName": "销售经理",
//    "portrait": "http://img-test.yuanruiteam.com/portrait/3/1558603254766.jpg",
//    "isRead": 0
    var staffName = ""
    var positionName = ""
    var portrait = ""
    //    是否已阅读 0 未阅读 1已阅读
    var isRead = false
    
    init(_ json: JSON) {
        staffName = json["staffName"].stringValue
        positionName = json["positionName"].stringValue
        portrait = json["portrait"].stringValue
        isRead = json["isRead"].intValue == 1
    }
}
