//
//  SW_FilterUnitModel.swift
//  SWS
//
//  Created by jayway on 2018/7/27.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_FilterUnitModel: NSObject {

    var bUnitId = 0
    
    var bUnitName = ""
    
    var deptList = [SW_FilterDeptModel]()
    
    init(_ json: JSON) {
        super.init()
        bUnitId = json["bUnitId"].intValue
        bUnitName = json["bUnitName"].stringValue
        deptList = json["deptList"].arrayValue.map({ return SW_FilterDeptModel($0) })
    }
    
}
