//
//  SW_AccessRecordListModel.swift
//  SWS
//
//  Created by jayway on 2018/8/21.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_AccessRecordListModel: NSObject {

    /// 记录id
    var id = ""
    /// 访问方式  有五种
    var accessType = AccessType.none
    /// 结束时间
    var endDate: TimeInterval = 0
    /// 访问时间是周几
    var whatDay = ""
    /// 记录内容
    var recordContent = ""
    /// 试乘试驾记录内容
    var testDriveContent = ""
    /// 接访时长
    var duration = ""
    /// 投诉待处理状态处理
    var complaintState: ComplaintState = .pass
    
    init(_ json: JSON) {
        super.init()
        id = json["id"].stringValue
        accessType = AccessType(rawValue: json["accessType"].intValue) ?? .none
        endDate = json["endDate"].doubleValue
        whatDay = json["whatDay"].stringValue
        recordContent = json["recordContent"].stringValue
        testDriveContent = json["testDriveContent"].stringValue
        complaintState = ComplaintState(rawValue: json["complaintState"].intValue) ?? .pass
        duration = json["duration"].stringValue
    }
    
    
}
