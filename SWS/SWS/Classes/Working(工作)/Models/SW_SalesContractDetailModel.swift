//
//  SW_SalesContractDetailModel.swift
//  SWS
//
//  Created by jayway on 2019/5/22.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

protocol SW_SalesContractDetailModelDelegate: NSObjectProtocol {
    func insuranceAmountDidChange(itemAmout: Double, allAmout: Double)
}

//"carKeyNum" : ""
struct SW_SalesContractDetailModel {
    var type: ContractBusinessType = .insurance
    
    weak var delegate: SW_SalesContractDetailModelDelegate?
    
    //MARK: - 公用属性
    /// 合同号
    var contractNum = ""
    /// 合同id
    var contractId = ""
    
    
    /// 业务结审状态 1 未提交 2 待审核 3 已通过 4 已驳回  - 状态
    var auditState: AuditState = .noCommit
    
    /// 合同作废状态，3表示作废成功
    var invalidAuditState = 1
//    ///  按揭办理状态  1 未提交 2  已通过
//    var state: AuditState = .noCommit
//    ///  上牌状态 1 未提交 2  已通过
//    var carNumState: AuditState = .noCommit
    /// 购置税状态 1 未提交 2  已通过
    var carPurchaseState: AuditState = .noCommit
    
    /// "payState":"合同状态 1 未付款 2 已付定金 3 已付全款",
    var payState: PayState = .noPay
    /// 预计交车时间
    var deliveryDate: TimeInterval = 0
    /// 业务处理时间， 保险办理时间，贷款办理时间，上牌时间，购置税办理时间
    var handleDate: TimeInterval = 0
    /// 单位名字
    var bUnitName = ""
    /// 单位id
    var bUnitId = 0
    /// customerName：客户姓名
    var customerName = ""
    /// 销售顾问名字
    var saleName = ""
    /// 证件号码
    var idCard = ""
    /// 联系方式
    var phoneNum = ""
    /// 客户地址
    var customerAddress = ""
    /// 车牌号
    var numberPlate = ""
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
    /// 附件图片  url list  路径需要加前缀
    var attachmentList = [String]()
    /// 附件图片url前缀
    var imagePrefix = ""
    //MARK: - 模块
    /// 保险公司
    var insuranceCompany = ""
    /// 保险公司id
    var insuranceCompanyId = ""
    /// 保单号
    var insuranceNum = ""
    /// 商业险单号
    var commercialInsuranceNum = ""
    /// 保险开始时间
    var insuranceStartDate: TimeInterval = 0
    /// 保险结束时间
    var insuranceEndDate: TimeInterval = 0
    
    /// 车船税  办理标注 0：不办理   1办理
    var carShipTaxTag = 0
    /// 车船税金额
    var carShipTaxAmount: Double = 0 {
        didSet {
            calculateInsuranceAmount()
        }
    }
    /// 交强险  办理标注 0：不办理   1办理
    var compulsoryInsuranceTag = 0
    /// 交强险 金额
    var compulsoryInsuranceAmount: Double = 0 {
        didSet {
            calculateInsuranceAmount()
        }
    }
    /// 保险项目
    var insuranceItems = [SW_InsuranceItemModel]()
    
    /// 商业险合计
    var insuranceItemsTotalAmount: Double = 0
    /// 保单合计
    var insuranceTotalAmount: Double = 0
    
    /// 购置税金额
    var carPurchaseTaxAmount: Double = 0
    
    /// 上牌成本
//    var carNumCostAmount: Double = 0
    
    /// 按揭金额
    var mortgageAmount: Double = 0
    /// 按揭成本金额
//    var mortgageCostAmount: Double = 0
    /// 批复金额
    var approvalAmount: Double = 0
    /// 按揭期数
    var mortgagePeriod = 0
    /// 金融机构名称
    var financialOrgName = ""
    /// 金融机构Id
    var financialOrgId = ""
    
    var carList = [SW_CarInfoModel]()
    
    init(type: ContractBusinessType) {
//        super.init()
        self.type = type
        auditState = .pass
    }
    
    init(_ json: JSON, type: ContractBusinessType) {
//        super.init()
        self.type = type
        contractNum = json["contractNum"].stringValue
        contractId = json["contractId"].stringValue
        bUnitId = json["bUnitId"].intValue
        invalidAuditState = json["invalidAuditState"].intValue
        switch type {
        case .insurance:
            auditState = AuditState(rawValue: json["insuranceAuditState"].intValue) ?? .noCommit
            insuranceCompany = json["insuranceCompany"].stringValue
            insuranceCompanyId = json["insuranceCompanyId"].stringValue
            insuranceNum = json["insuranceNum"].stringValue
            commercialInsuranceNum = json["commercialInsuranceNum"].stringValue
            insuranceStartDate = json["insuranceStartDate"].doubleValue
            insuranceEndDate = json["insuranceEndDate"].doubleValue
            carShipTaxTag = json["carShipTaxTag"].intValue
            compulsoryInsuranceTag = json["compulsoryInsuranceTag"].intValue
            carShipTaxAmount = json["carShipTaxAmount"].doubleValue/10000.0
            compulsoryInsuranceAmount = json["compulsoryInsuranceAmount"].doubleValue/10000.0
            insuranceItems = json["insuranceItems"].arrayValue.map({ return SW_InsuranceItemModel($0) })
            calculateInsuranceAmount()
        case .mortgageLoans:
            auditState = json["state"].intValue == 2 ? .pass : .noCommit
//            mortgageCostAmount = json["mortgageCostAmount"].doubleValue/10000.0
            approvalAmount = json["approvalAmount"].doubleValue/10000.0
            mortgagePeriod = json["mortgagePeriod"].intValue
            financialOrgName = json["financialOrgName"].stringValue
            financialOrgId = json["financialOrgId"].stringValue
            mortgageAmount = json["mortgageAmount"].doubleValue/10000.0
        case .registration:
            auditState = json["carNumState"].intValue == 2 ? .pass : .noCommit
            carPurchaseState = json["carPurchaseState"].intValue == 2 ? .pass : .noCommit
        case .purchaseTax:
            auditState = json["carPurchaseState"].intValue == 2 ? .pass : .noCommit
        case .assgnationCar:
            carList = json["carList"].arrayValue.map({ return SW_CarInfoModel($0) })
        }
        payState = PayState(rawValue: json["payState"].intValue) ?? .noPay
        deliveryDate = json["deliveryDate"].doubleValue
        handleDate = json["handleDate"].doubleValue
        
        bUnitName = json["bUnitName"].stringValue
        customerName = json["customerName"].stringValue
        saleName = json["saleName"].stringValue
        idCard = json["idCard"].stringValue
        phoneNum = json["phoneNum"].stringValue
        customerAddress = json["customerAddress"].stringValue
        numberPlate = json["numberPlate"].stringValue
        vin = json["vin"].stringValue
        carBrand = json["carBrand"].stringValue
        carSeries = json["carSeries"].stringValue
        carModel = json["carModel"].stringValue
        carColor = json["carColor"].stringValue
        
        carPurchaseTaxAmount = json["carPurchaseTaxAmount"].doubleValue/10000.0
//        carNumCostAmount = json["carNumCostAmount"].doubleValue/10000.0
        
        imagePrefix = json["imagePrefix"].stringValue
        attachmentList = json["attachmentList"].arrayValue.map({ return imagePrefix + $0.stringValue })
        
//        attachmentList = ["http://img-test.yuanruiteam.com/workReport/2/1558594180996.jpg","http://img-test.yuanruiteam.com/workReport/2/1558594180996.jpg","http://img-test.yuanruiteam.com/workReport/2/1558594180996.jpg","http://img-test.yuanruiteam.com/workReport/2/1558594180996.jpg"]
        
    }
    
    
    /// 计算商业险金额
    mutating func calculateInsuranceAmount() {
        insuranceTotalAmount = insuranceItems.reduce(0) { (rusult, insurance) -> Double in
            return rusult + insurance.insuredAmount
        }.roundTo(places: 4)
        insuranceItemsTotalAmount = (insuranceTotalAmount - carShipTaxAmount - compulsoryInsuranceAmount).roundTo(places: 4)
        delegate?.insuranceAmountDidChange(itemAmout: insuranceItemsTotalAmount, allAmout: insuranceTotalAmount)
    }
    
}


class SW_InsuranceItemModel: NSObject {
    /// 保险项目id
    var id = ""
    /// 保险项目金额
    var insuredAmount: Double = 0
    /// 保险项目名称
    var name = ""
    /// 保额备注
    var insuredRemark = ""
    
    var cellHeight: CGFloat?
    
    init(_ json: JSON) {
        id = json["id"].stringValue
        insuredAmount = json["insuredAmount"].doubleValue/10000.0
        name = json["name"].stringValue
        insuredRemark = json["insuredRemark"].stringValue
    }
}


class SW_CarInfoModel: NSObject {
    /// 车ID
    var carInfoId = ""
    /// 车架号
    var vin = ""
    /// 内饰颜色
    var upholsteryColor = ""
    /// 分配状态 1未  2已分配
    var assignationState = 1
    /// 在库天数    0-》在途
    var inStockDays = 0
    /// 展车精品数量
    var concretePlayCarBoutiqueOutCount: Double = 0
    
    init(_ json: JSON) {
        carInfoId = json["carInfoId"].stringValue
        vin = json["vin"].stringValue
        upholsteryColor = json["upholsteryColor"].stringValue
        assignationState = json["assignationState"].intValue
        inStockDays = json["inStockDays"].intValue
        concretePlayCarBoutiqueOutCount = json["concretePlayCarBoutiqueOutCount"].doubleValue
    }
}
