//
//  SW_PurchaseCarRecordListModel.swift
//  SWS
//
//  Created by jayway on 2019/6/3.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_PurchaseCarRecordListModel: NSObject {
    
    /// 合同编号
    var contractNum = ""
    /// 合同id
    var contractId = ""
    
    /// "payState":"合同状态 1 未付款 2 已付定金 3 已付全款",
    var payState: PayState = .noPay
    
    /// 车架号
    var vin = ""
    /// 厂商品牌
    var carBrand = ""
    /// 车系
    var carSeries = ""
    /// 车型
    var carModel = ""
    /// 车颜色
    var carColor = ""
    
    var car: String {
        get {
            if carBrand.isEmpty {
                return "无"
            }
            return carBrand + " " + carSeries + " " + carModel + " " + carColor
        }
    }
    
    var complaintState: ComplaintState = .pass
    
    override init() {
        super.init()
    }
    
    init(_ json: JSON) {
        super.init()
        contractId = json["contractId"].stringValue
        contractNum = json["contractNum"].stringValue
        payState = PayState(rawValue: json["payState"].intValue) ?? .noPay
        vin = json["vin"].stringValue
        carBrand = json["carBrand"].stringValue
        carSeries = json["carSeries"].stringValue
        carModel = json["carModel"].stringValue
        carColor = json["carColor"].stringValue
        complaintState = ComplaintState(rawValue: json["complaintState"].intValue) ?? .pass
    }
    
}

struct SW_PurchaseCarRecordDetailModel {
    //MARK: - 公用属性
    /// 合同号
    var contractNum = ""
    /// 合同id
    var contractId = ""
    
    /// contractType：合同类型 1 个人 2组织
    var contractType = 1
    /// paymentWay：合同支付方式 1 按揭 2 全款
    var paymentWay = 1
    /// 预计交车时间
    var deliveryDate: TimeInterval = 0
    
    /// 厂商品牌
    var carBrand = ""
    /// 车系
    var carSeries = ""
    /// 车型
    var carModel = ""
    /// 车颜色
    var carColor = ""
    /// 车架号
    var vin = ""
    /// 车牌号
    var numberPlate = ""
    /// "payState":"合同状态 1 未付款 2 已付定金 3 已付全款",
    var payState: PayState = .noPay
    /// invoiceState：1未开发票 2 已开发票
    var invoiceState = 1
    /// mortgageState：1未办理 2 已办理
    var mortgageState = 1
    
    /// 保险状态 1 未提交 2 待审核 3 已通过 4 已驳回  - 状态
    var insuranceState: AuditState = .noCommit
    /// carPurchaseState：办理购置税 1未办理 2已办理
    var carPurchaseState = 1
    /// carNumState：办理上牌 1未办理 2已办理
    var carNumState = 1
    
    /// 精品信息
    var boutiqueContractList = [SW_BoutiqueContractModel]()
    /// 投诉处理状态
    var complaintState: ComplaintState = .pass
    /// 客户评分项目
    var customerServingItemScores = [SW_CustomerScoreModel]()
    /// 客户非评分项目
    var nonGrandedItems = [SW_NonGradedItemsModel]()
    /// 客户投诉记录
    var complaintRecords = [SW_ComplaintsModel]()
    
    var getScore: Double {
        get {
            return customerServingItemScores.reduce(0, { (result, model) -> Double in
                return result + model.score
            })
        }
    }
    //MARK: - 销售合同审核新增
    /// 审核状态
    var auditState: AuditState = .noCommit
    /// 作废状态  界面要优先判断是否有作废
    var invalidAuditState: AuditState = .noCommit
    /// 作废原因
    var invalidRemark = ""
    /// 修改原因
    var modifyRemark = ""
    /// 客户名称
    var realName = ""
    /// 联系方式
    var phoneNum = ""
    /// 所属单位
    var bUnitName = ""
    /// 销售顾问
    var saleName = ""
    /// 按揭期数
    var mortgagePeriod = 0
    /// 按揭金额
    var mortgageAmount: Double = 0
    /// 车辆零售价
    var retailPrice: Double = 0
    /// 应收总额
    var receivableAmount: Double = 0
    /// 合同总额
    var contractAmount: Double = 0
    /// 已付总额
    var paidAmount: Double = 0
    /// 未收总额
    var uncollectedAmount: Double = 0
    /// 车辆金额
    var carAmount: Double = 0
    /// 精品金额
    var boutiqueAmount: Double = 0
    /// 车船税类型
    var carShipTaxType = ""
    /// 车船税金额
    var carShipTaxAmount: Double = 0
    /// 交强险类型
    var compulsoryInsuranceType = ""
    /// 交强险金额
    var compulsoryInsuranceAmount: Double = 0
    /// 商业险类型
    var commercialInsuranceType = ""
    /// 商业险金额
    var commercialInsuranceAmount: Double = 0
    /// 上牌类型
    var carNumType = ""
    /// 上牌金额
    var carNumAmount: Double = 0
    /// 购置税类型
    var carPurchaseTaxType = ""
    /// 购置税金额
    var carPurchaseTaxAmount: Double = 0
    /// 按揭类型
    var mortgageCostType = ""
    /// 按揭手续费金额
    var mortgageHandlingAmount: Double = 0
    /// 其他费用金额
    var otherAmount: Double = 0
    /// 附加条款1
    var codicil1 = ""
    /// 附加条款2
    var codicil2 = ""
    
    /// 其他费用列表数据
    var otherInfoContractList = [SW_OtherInfoContractItemModel]()
    /// 保险信息列表数据
    var insuranceList = [SW_InsuranceItemModel]()
    
    //MAR: - 初始化方法
    init(_ json: JSON) {
        realName = json["realName"].stringValue
        contractNum = json["contractNum"].stringValue
        contractId = json["contractId"].stringValue
        contractType = json["contractType"].intValue
        paymentWay = json["paymentWay"].intValue
        deliveryDate = json["deliveryDate"].doubleValue
        carBrand = json["carBrand"].stringValue
        carSeries = json["carSeries"].stringValue
        carModel = json["carModel"].stringValue
        carColor = json["carColor"].stringValue
        payState = PayState(rawValue: json["payState"].intValue) ?? .noPay
        numberPlate = json["numberPlate"].stringValue
        vin = json["vin"].stringValue
        
        invoiceState = json["invoiceState"].intValue
        mortgageState = json["mortgageState"].intValue
        carPurchaseState = json["carPurchaseState"].intValue
        carNumState = json["carNumState"].intValue
        insuranceState = AuditState(rawValue: json["insuranceState"].intValue) ?? .noCommit
        
        customerServingItemScores = json["customerServingItemScores"].arrayValue.map({ (item) -> SW_CustomerScoreModel in
            return SW_CustomerScoreModel(item)
        })
        nonGrandedItems = json["customerServingItemNonScores"].arrayValue.map({ (item) -> SW_NonGradedItemsModel in
            return SW_NonGradedItemsModel(item)
        })
        complaintRecords = json["complaintRecords"].arrayValue.map({ (item) -> SW_ComplaintsModel in
            return SW_ComplaintsModel(item)
        })
        if complaintRecords.count > 0 {
            complaintState = complaintRecords.first!.auditState
        }
        /// 表格数据
        boutiqueContractList = json["boutiqueContractList"].arrayValue.map({ return SW_BoutiqueContractModel($0) })
        insuranceList = json["insuranceList"].arrayValue.map({ (item) -> SW_InsuranceItemModel in
            return SW_InsuranceItemModel(item)
        })
        otherInfoContractList = json["otherInfoContractList"].arrayValue.map({ (item) -> SW_OtherInfoContractItemModel in
            return SW_OtherInfoContractItemModel(item)
        })
        invalidRemark = json["invalidRemark"].stringValue
        modifyRemark = json["modifyRemark"].stringValue
        invalidAuditState = AuditState(rawValue: json["invalidAuditState"].intValue) ?? .noCommit
        auditState = AuditState(rawValue: json["contractAuditState"].intValue) ?? .noCommit
        phoneNum = json["phoneNum"].stringValue
        bUnitName = json["bUnitName"].stringValue
        saleName = json["saleName"].stringValue
        mortgagePeriod = json["mortgagePeriod"].intValue
        boutiqueAmount = json["boutiqueAmount"].doubleValue/10000.0
        carAmount = json["carAmount"].doubleValue/10000.0
        uncollectedAmount = json["uncollectedAmount"].doubleValue/10000.0
        paidAmount = json["paidAmount"].doubleValue/10000.0
        contractAmount = json["contractAmount"].doubleValue/10000.0
        receivableAmount = json["receivableAmount"].doubleValue/10000.0
        retailPrice = json["retailPrice"].doubleValue/10000.0
        mortgageAmount = json["mortgageAmount"].doubleValue/10000.0
        carPurchaseTaxType = json["carPurchaseTaxType"].stringValue
        carPurchaseTaxAmount = json["carPurchaseTaxAmount"].doubleValue/10000.0
        carShipTaxType = json["carShipTaxType"].stringValue
        carShipTaxAmount = json["carShipTaxAmount"].doubleValue/10000.0
        compulsoryInsuranceType = json["compulsoryInsuranceType"].stringValue
        compulsoryInsuranceAmount = json["compulsoryInsuranceAmount"].doubleValue/10000.0
        commercialInsuranceType = json["commercialInsuranceType"].stringValue
        commercialInsuranceAmount = json["commercialInsuranceAmount"].doubleValue/10000.0
        carNumType = json["carNumType"].stringValue
        carNumAmount = json["carNumAmount"].doubleValue/10000.0
        carPurchaseTaxType = json["carPurchaseTaxType"].stringValue
        carPurchaseTaxAmount = json["carPurchaseTaxAmount"].doubleValue/10000.0
        mortgageCostType = json["mortgageCostType"].stringValue
        mortgageHandlingAmount = json["mortgageHandlingAmount"].doubleValue/10000.0
        otherAmount = json["otherAmount"].doubleValue/10000.0
        codicil1 = json["codicil1"].stringValue
        codicil2 = json["codicil2"].stringValue
    }
    
    
}

//MARK: - 合同精品模型
class SW_BoutiqueContractModel: NSObject {
    /// 精品名称
    var name = ""
    /// 销售数量
    var count: Double = 0
//    isInstall：是否安装 1未安装 2 已安装
    var isInstall = false
    /// 安装数量
    var installCount: Double = 0
    /// 销售类型
    var saleType = ""
    /// 零售总价
    var retailAmount: Double = 0
    /// 工时费
    var hourlyWageAmount: Double = 0
    /// 成交总价
    var dealAmount: Double = 0
    /// 折扣
    var discount: Double = 0
    /// 表格的高度缓存
    var cellHeight: CGFloat?
    
    /// new
    /// 精品编号
    var boutiqueNum = ""
    /// 实际出库数量
    var concreteOutStockNum: Double = 0
    /// 本次安装数量 ，输入了才有值，不输入为nil
    var nowInstallCount: Double?
    /// 合同精品id
    var boutiqueContractId = ""
    /// 精品库存id
    var boutiqueStockId = ""
//    "boutiqueContractId":"合同精品id",
    //            "count":"安装数量",
    //            "boutiqueStockId":"精品库存id"
    init(_ json: JSON) {
        super.init()
        name = json["boutiqueName"].stringValue
        boutiqueNum = json["boutiqueNum"].stringValue
        count = json["saleCount"].doubleValue.roundTo(places: 4)
        isInstall = json["isInstall"].intValue == 2
        saleType = json["saleType"].stringValue
        retailAmount = json["retailAmount"].doubleValue/10000.0
        hourlyWageAmount = json["hourlyWageAmount"].doubleValue/10000.0
        dealAmount = json["dealAmount"].doubleValue/10000.0
        discount = json["discount"].doubleValue
        installCount = json["installCount"].doubleValue.roundTo(places: 4)
        concreteOutStockNum = json["concreteOutStockNum"].doubleValue.roundTo(places: 4)
        boutiqueStockId = json["boutiqueStockId"].stringValue
        boutiqueContractId = json["boutiqueContractId"].stringValue
    }
}

//MARK: - 销售合同其他费用模型
class SW_OtherInfoContractItemModel: NSObject {
    /// 费用名称
    var name = ""
    /// 销售类型
    var saleType = ""
    /// 应收金额
    var receivableAmount: Double = 0
    /// 成本金额
    var costAmount: Double = 0
    
    var cellHeight: CGFloat?
    
    init(_ json: JSON) {
        name = json["name"].stringValue
        saleType = json["saleType"].stringValue
        receivableAmount = json["receivableAmount"].doubleValue/10000.0
        costAmount = json["costAmount"].doubleValue/10000.0
    }
}
