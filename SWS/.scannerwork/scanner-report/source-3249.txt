//
//  SW_InventoryListModel.swift
//  SWS
//
//  Created by jayway on 2019/4/7.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_InventoryListModel: NSObject {

    var type: ProcurementType = .boutiques
    
    /// 盘点单id
    var id = ""
    /// 盘点仓库
    var warehouseName = ""
    /// 盘点区域
    var areaNums = ""
    /// 盘点单编号
    var orderNo = ""
    /// 盘点时间
    var createDate: TimeInterval = 0 {
        didSet {
            createDateString = Date.dateWith(timeInterval: createDate).stringWith(formatStr: "yyyy.MM.dd HH:mm")
        }
    }
    var createDateString = ""
    
    /// 备注
    var remark = ""
    /// 盘点单位
    var bUnitName = ""
    /// 盘点人
    var staffName = ""
    
    override init() {
        super.init()
    }
    
    init(_ json: JSON, type: ProcurementType) {
        super.init()
        self.type = type
        orderNo = json["orderNo"].stringValue
        id = json["id"].stringValue
        warehouseName = json["warehouseName"].stringValue
        areaNums = json["areaNums"].stringValue
        createDate = json["createDate"].doubleValue
        createDateString = Date.dateWith(timeInterval: createDate).stringWith(formatStr: "yyyy.MM.dd HH:mm")
        bUnitName = json["bUnitName"].stringValue
        remark = json["remark"].stringValue
        staffName = json["staffName"].stringValue
    }
}
