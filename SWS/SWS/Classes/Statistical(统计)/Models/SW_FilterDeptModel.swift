//
//  SW_FilterDeptModel.swift
//  SWS
//
//  Created by jayway on 2018/7/27.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_FilterDeptModel: NSObject {

    var deptId = 0
    
    var deptName = ""
    
    
    init(_ json: JSON) {
        super.init()
        deptId = json["deptId"].intValue
        deptName = json["deptName"].stringValue
    }
    
}
