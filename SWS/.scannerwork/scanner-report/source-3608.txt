//
//  SW_RepairOrderRecordListModel.swift
//  SWS
//
//  Created by jayway on 2019/2/26.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_RepairOrderRecordListModel: NSObject {
    
    /// 维修单编号
    var repairOrderNum = ""
    /// 维修单id
    var repairOrderId = ""

    /// 完成时间
    var completeDate: TimeInterval = 0
    /// 预计出厂时间
    var predictDate: TimeInterval = 0
    /// 里程数
    var mileage = 0
    
    var complaintState: ComplaintState = .pass
    
    override init() {
        super.init()
    }
    
    init(_ json: JSON) {
        super.init()
        repairOrderId = json["repairOrderId"].stringValue
        repairOrderNum = json["repairOrderNum"].stringValue
        completeDate = json["completeDate"].doubleValue
        predictDate = json["predictDate"].doubleValue
        mileage = json["mileage"].intValue
        complaintState = ComplaintState(rawValue: json["complaintState"].intValue) ?? .pass
    }
    
}
