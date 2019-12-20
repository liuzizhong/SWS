//
//  SW_ComplaintsModel.swift
//  SWS
//
//  Created by jayway on 2019/6/24.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit
//投诉审核状态 1待审核 2通过 3驳回  4 待处理
enum ComplaintState: Int {
    case waitAudit = 1
    case pass
    case rejected
    case waitHandle
    
    var rawTitle: String {
        switch self {
        case .waitAudit:
            return "待审核"
        case .waitHandle:
            return "待处理"
        case .pass:
            return "已处理"
        default:
            return ""
        }
    }
    
    var rawImage: UIImage? {
        switch self {
        case .waitAudit:
            return #imageLiteral(resourceName: "pop_complaint_audit")
        case .waitHandle:
            return #imageLiteral(resourceName: "pop_complaint_dispose")
        default:
            return nil
        }
    }
}

class SW_ComplaintsModel: NSObject {
//{
//    "content" : "12345",
//    "orderId" : "ff8080816b1b529a016b1c7ff378000e",
//    "id" : "402881f36ba10110016ba1271b78003d",
//    "feedback" : "",
//    "handleDate" : 0,
//    "complaintState" : 4,
//    "createDate" : 1561776823162,
//    }
    var id = ""
    var orderId = ""

    var content = ""
    var createDate: TimeInterval = 0
    var replyContent = ""//回复
    var replyDate: TimeInterval = 0
    
    /// complaintState：投诉审核状态 1待审核 2通过 3驳回  4 待处理
    ///   待处理（新增、驳回）   已处理（通过）
    var auditState: ComplaintState = .pass
    
    var complaintType: HandleComplaintType = .repairOrder
    init(_ json: JSON) {
        super.init()
        id = json["id"].stringValue
        orderId = json["orderId"].stringValue
        content = json["content"].stringValue
        createDate = json["createDate"].doubleValue
        replyContent = json["feedback"].stringValue
        replyDate = json["handleDate"].doubleValue
        auditState = ComplaintState(rawValue: json["complaintState"].intValue) ?? .pass
        complaintType = HandleComplaintType(rawValue: json["complaintType"].intValue) ?? .repairOrder
    }
    
}


class SW_CustomerScoreModel: NSObject {
    
    var name = ""
    var score: Double = 0//得分
    var totalScore = 0
    
    init(_ json: JSON) {
        super.init()
        name = json["name"].stringValue
        score = json["score"].doubleValue
        totalScore = json["scoreTotal"].intValue
    }
    
}

class SW_NonGradedItemsModel: NSObject {
    
    var name = ""
    var result = ""//回访结果
    
    init(_ json: JSON) {
        super.init()
        name = json["name"].stringValue
        result = json["result"].stringValue
    }
    
}
