//
//  SW_ProcurementListModel.swift
//  SWS
//
//  Created by jayway on 2019/3/20.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

enum FromType: Int {
    case none
    case manufacturer = 1
    case outside
    
    var rawTitle: String {
        switch self {
        case .none:
            return ""
        case .manufacturer:
            return "厂家"
        case .outside:
            return "外采"
        }
    }
}

//payType：支付类型 (维修单时:1 即结 2 挂账)
enum PayType: Int {
    case none
    case now
    case credit
    
    var rawTitle: String {
        switch self {
        case .none:
            return ""
        case .now:
            return "即结"
        case .credit:
            return "挂账"
        }
    }
}

//invoiceType 发票类型 1 增值税发票 2 普通发票  3 机动车发票
enum InvoiceType: Int {
    case none
    case VAT = 1
    case common
    case car
    
    var rawTitle: String {
        switch self {
        case .none:
            return ""
        case .VAT:
            return "增值税发票"
        case .common:
            return "普通发票"
        case .car:
            return "机动车发票"
        }
    }
}

class SW_ProcurementListModel: NSObject {
    
    var type: ProcurementType = .boutiques
    
    /// 供应商
    var supplier = ""
    /// 供应商id
    var supplierId = ""
    /// 采购单id
    var purchaseOrderId = ""
    /// 采购单编号
    var orderNo = ""
    /// 采购时间
    var buyDate: TimeInterval = 0 {
        didSet {
            buyDateString = Date.dateWith(timeInterval: buyDate).stringWith(formatStr: "yyyy.MM.dd HH:mm")
        }
    }
    var buyDateString = ""
    
    /// 采购类型  fromType：采购类型 1厂家 2外采
    var fromType: FromType = .none
    /// 支付类型 payType：支付类型 (维修单时:1 即结 2 挂账)
    var payType: PayType = .none
    /// 发票类型 invoiceType 发票类型 1 增值税发票 2 普通发票  3 机动车发票
    var invoiceType: InvoiceType = .none
    /// 税率
    var rate = 0
    /// 采购单位
    var bUnitName = ""
    /// 入库人
    var warehousePeople = ""
    /// 备注
    var remark = ""
    /// 采购入库人
    var purchaser = ""
    
    override init() {
        super.init()
    }
    
    init(_ json: JSON, type: ProcurementType) {
        super.init()
        self.type = type
        orderNo = json["orderNo"].stringValue
        purchaseOrderId = json["id"].stringValue
        supplier = json["supplierName"].stringValue
        supplierId = json["supplierId"].stringValue
        buyDate = json["purchaseDate"].doubleValue
        buyDateString = Date.dateWith(timeInterval: buyDate).stringWith(formatStr: "yyyy.MM.dd HH:mm")
        purchaser = json["purchaser"].stringValue
        bUnitName = json["bUnitName"].stringValue
        fromType = FromType(rawValue: json["fromType"].intValue) ?? .none
        remark = json["remark"].stringValue
        payType = PayType(rawValue: json["payType"].intValue) ?? .none
        rate = json["taxRate"].intValue
        invoiceType = InvoiceType(rawValue: json["invoiceType"].intValue) ?? .none
    }
}
