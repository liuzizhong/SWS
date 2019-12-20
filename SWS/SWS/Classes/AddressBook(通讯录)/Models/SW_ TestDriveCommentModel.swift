
//
//  SW_ TestDriveCommentModel.swift
//  SWS
//
//  Created by jayway on 2018/8/27.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_TestDriveCommentModel: NSObject {
    
    /// 记录ID
    var recordId = ""
    /// 试驾评价意见
    var testDriveContent = ""
    /// 客户id
    var customerId = ""
    /// 车辆评价项目
    var carItems = [NormalModel]()
    /// 服务评价项目
    var serviceItems = [NormalModel]()
    
    
}
