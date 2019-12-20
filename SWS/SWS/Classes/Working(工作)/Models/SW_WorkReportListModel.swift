//
//  SW_WorkReportListModel.swift
//  SWS
//
//  Created by jayway on 2018/7/11.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_WorkReportListModel: NSObject {

    /// 收到的还是我发的类型
    var ownerType = WorkReportOwner.received
    
    /// 报告的类型 年月日
    var type = WorkReportType.day
    ///公用的
    var id = ""
    var workTypeStr = ""
    var title = ""
    var content = ""
    var createDate: TimeInterval = 0
    var isCheck = false
    ///收到的
    var reporterName = ""
    var reporterId = 0
    var portrait = ""
    ///我发起的
    var isNewCheck = false
    var checkCount = 0
    var receiverTotal = 0
    
    init(_ type: WorkReportType, ownerType: WorkReportOwner, json: JSON) {
        super.init()
        self.ownerType = ownerType
        self.type = type

        id = json["id"].stringValue
        title = json["title"].stringValue
        workTypeStr = json["workTypeStr"].stringValue
        content = json["content"].stringValue
        createDate = json["createDate"].doubleValue
        isCheck = json["isCheck"].intValue == 0
        switch ownerType {
        case .received:
            reporterName = json["reporterName"].stringValue
            portrait = json["portrait"].stringValue
            reporterId = json["reporterId"].intValue
        default:
            isNewCheck = json["isNewCheck"].intValue == 0
            checkCount = json["checkCount"].intValue
            receiverTotal = json["receiverTotal"].intValue
        }
//        reportDateString = Date.dateWith(timeInterval: reportDate).stringWith(formatStr: "yyyy.MM.dd")
//        reportCreateDateString = Date.dateWith(timeInterval: reportCreateDate).stringWith(formatStr: "yyyy.MM.dd")
    }
    
    
}
