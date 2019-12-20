//
//  SW_FilterRegionModel.swift
//  SWS
//
//  Created by jayway on 2018/7/27.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_FilterRegionModel: NSObject {
    
    var regionId = 0
    
    var regionName = ""
    
    var bUnitList = [SW_FilterUnitModel]()
    
    init(_ json: JSON) {
        super.init()
        regionId = json["regionId"].intValue
        regionName = json["regionName"].stringValue
        bUnitList = json["bUnitList"].arrayValue.map({ return SW_FilterUnitModel($0) })
    }
}
