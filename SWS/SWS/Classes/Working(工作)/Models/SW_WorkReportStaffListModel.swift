//
//  SW_WorkReportStaffListModel.swift
//  SWS
//
//  Created by jayway on 2019/1/17.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_WorkReportStaffListModel: NSObject {
//    "realName": "张剑威",
//    "portrait": "http://img-test.yuanruiteam.com/portrait/109/1545384196030.jpg",
//    "staffId": 109
    var realName = ""
    var portrait = ""
    var staffId = 0
    
    init(_ json: JSON) {
        super.init()
        realName = json["realName"].stringValue
        portrait = json["portrait"].stringValue
        staffId = json["staffId"].intValue
    }
    
    
    
    
}
