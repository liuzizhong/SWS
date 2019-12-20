//
//  SW_AuditRepairOrderDetailModel.swift
//  SWS
//
//  Created by jayway on 2019/8/23.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_AuditRepairOrderDetailModel: NSObject {
    
    /// 维修单编号
    var repairOrderNum = ""
    /// 维修单id
    var repairOrderId = ""
    
    /// 应收金额
    var receivableAmount: Double = 0
    /// 已收金额
    var paidedAmount: Double = 0
    /// 待收金额
    var uncollectedAmount: Double = 0
    /// 套餐金额
    var packageAmount: Double = 0
    /// 优惠券金额
    var deductibleTotalAmount: Double = 0
    
    /// 客户姓名
    var realName = ""
    /// 联系方式
    var phoneNum1 = ""
    /// 车牌号
    var numberPlate = ""
    /// 厂商品牌
    var carBrand = ""
    /// 车系
    var carSeries = ""
    /// 车型
    var carModel = ""
    /// 车颜色
    var carColor = ""

    /// 维修单类型 ： 0 个人  1 公户  2 新车
    var customerInfoType = 0
    
    /// 维修单状态   付款状态
    var payState: PayState = .noPay

    /// repairBusinessType：1.一般维修、2.定期保养、3.首次保养、4.店内活动、5.一般索赔、6.新车检测、7.内部维修、8.美容装潢、9.保险外拓、 10.保险自店、11.返修、12.乐车邦、
    var repairBusinessType = 0
    /// repairBusinessTypeStr
    var repairBusinessTypeStr = ""
    
    ///   支付类型 (维修单时:1 即结 2 挂账)
    var payType = 1
    /// 单位名称
    var bUnitName = ""
    /// 售后顾问姓名 sa
    var staffName = ""
    
    /// 入厂时间
    var inStockDate: TimeInterval = 0 {
        didSet {
            inStockDateString = Date.dateWith(timeInterval: inStockDate).stringWith(formatStr: "yyyy/MM/dd HH:mm")
        }
    }
    /// 入厂时间
    var inStockDateString = ""
    /// 出厂时间
    var completeDate: TimeInterval = 0 {
        didSet {
            completeDateString = Date.dateWith(timeInterval: completeDate).stringWith(formatStr: "yyyy/MM/dd HH:mm")
        }
    }
    /// 出厂时间
    var completeDateString = ""
    
    /// 单的审核状态
    var auditState: AuditState = .noCommit
    
    
    /// 维修项目列表
    var repairOrderItemList = [SW_RepairOrderItemModel]()
    /// 维修配件列表
    var repairOrderAccessoriesList = [SW_RepairOrderAccessoriesModel]()
    /// 维修精品列表
    var repairOrderBoutiquesList = [SW_RepairOrderBoutiquesModel]()
    /// 其他费用列表
    var repairOrderOtherInfoList = [SW_RepairOrderOtherInfoModel]()
    /// 活动套餐表格
    var repairPackageItemList = [SW_RepairPackageItemModel]()
    /// 优惠券
    var repairOrderCouponsList = [SW_RepairOrderCouponsModel]()

    override init() {
        super.init()
    }
    
    init(_ json: JSON) {
        super.init()
        let repairOrderInfo = json["repairOrderInfo"]
        repairOrderNum = repairOrderInfo["repairOrderNum"].stringValue
        repairOrderId = repairOrderInfo["repairOrderId"].stringValue
        receivableAmount = repairOrderInfo["receivableAmount"].doubleValue/10000.0
        paidedAmount = repairOrderInfo["paidedAmount"].doubleValue/10000.0
        uncollectedAmount = repairOrderInfo["uncollectedAmount"].doubleValue/10000.0
        packageAmount = repairOrderInfo["packageAmount"].doubleValue/10000.0
        deductibleTotalAmount = repairOrderInfo["deductibleTotalAmount"].doubleValue/10000.0
        payState = PayState(rawValue: repairOrderInfo["payState"].intValue) ?? .noPay
        repairBusinessType = repairOrderInfo["repairBusinessType"].intValue
        repairBusinessTypeStr = repairOrderInfo["repairBusinessTypeStr"].stringValue
        payType = repairOrderInfo["payType"].intValue
        
        bUnitName = repairOrderInfo["bUnitName"].stringValue
        staffName = repairOrderInfo["staffName"].stringValue
        
        inStockDate = repairOrderInfo["inStockDate"].doubleValue
        inStockDateString = Date.dateWith(timeInterval: inStockDate).stringWith(formatStr: "yyyy/MM/dd HH:mm")
        
        auditState = AuditState(rawValue: repairOrderInfo["orderAuditState"].intValue) ?? .noCommit
        
        let customerInfo = json["customerInfo"]
        
        /// 内部新车
        if customerInfo["id"].stringValue.isEmpty {
            realName = "内部新车"
            customerInfoType = 2
        } else {
            realName = customerInfo["realName"].stringValue
            customerInfoType = customerInfo["type"].intValue
            phoneNum1 = customerInfo["phoneNum1"].stringValue
        }
        
        let repairCarInfo = json["repairCarInfo"]
        carBrand = repairCarInfo["carBrand"].stringValue
        carSeries = repairCarInfo["carSeries"].stringValue
        carModel = repairCarInfo["carModel"].stringValue
        carColor = repairCarInfo["carColor"].stringValue
        numberPlate = repairCarInfo["numberPlate"].stringValue
        completeDate = repairCarInfo["completeDate"].doubleValue
        completeDateString = Date.dateWith(timeInterval: completeDate).stringWith(formatStr: "yyyy/MM/dd HH:mm")
        
        repairOrderItemList = json["repairOrderItemList"].arrayValue.map({ (value) -> SW_RepairOrderItemModel in
            return SW_RepairOrderItemModel(value)
        })
        if repairOrderItemList.count > 0 {
            /// 需求列表最后有一项合计，需要自己计算
            let combinedItem = SW_RepairOrderItemModel()
            combinedItem.name = "合计"
            combinedItem.hourlyWageAmount = repairOrderItemList.reduce(0, { (result, model) -> Double in
                return result + model.hourlyWageAmount
            })
            combinedItem.hourlyWageDealAmount = repairOrderItemList.reduce(0, { (result, model) -> Double in
                return result + model.hourlyWageDealAmount
            })
            repairOrderItemList.append(combinedItem)
        }
        
        repairOrderAccessoriesList = json["repairOrderAccessoriesList"].arrayValue.map({ (value) -> SW_RepairOrderAccessoriesModel in
            return SW_RepairOrderAccessoriesModel(value)
        })
        if repairOrderAccessoriesList.count > 0 {
            /// 需求列表最后有一项合计，需要自己计算
            let combinedAccessories = SW_RepairOrderAccessoriesModel()
            combinedAccessories.name = "合计"
            combinedAccessories.retailAmount = repairOrderAccessoriesList.reduce(0, { (result, model) -> Double in
                return result + model.retailAmount
            })
            combinedAccessories.dealAmount = repairOrderAccessoriesList.reduce(0, { (result, model) -> Double in
                return result + model.dealAmount
            })
            repairOrderAccessoriesList.append(combinedAccessories)
        }
        
        repairOrderBoutiquesList = json["repairOrderBoutiquesList"].arrayValue.map({ (value) -> SW_RepairOrderBoutiquesModel in
            return SW_RepairOrderBoutiquesModel(value)
        })
        if repairOrderBoutiquesList.count > 0 {
            /// 需求列表最后有一项合计，需要自己计算
            let combinedBoutiques = SW_RepairOrderBoutiquesModel()
            combinedBoutiques.name = "合计"
            combinedBoutiques.retailAmount = repairOrderBoutiquesList.reduce(0, { (result, model) -> Double in
                return result + model.retailAmount
            })
            combinedBoutiques.dealAmount = repairOrderBoutiquesList.reduce(0, { (result, model) -> Double in
                return result + model.dealAmount
            })
            combinedBoutiques.hourlyWageAmount = repairOrderBoutiquesList.reduce(0, { (result, model) -> Double in
                return result + model.hourlyWageAmount
            })
            combinedBoutiques.subtotal = repairOrderBoutiquesList.reduce(0, { (result, model) -> Double in
                return result + model.subtotal
            })
            repairOrderBoutiquesList.append(combinedBoutiques)
        }
        
        repairOrderOtherInfoList = json["repairOrderOtherInfoList"].arrayValue.map({ (value) -> SW_RepairOrderOtherInfoModel in
            return SW_RepairOrderOtherInfoModel(value)
        })
        /// 还有优惠券
        repairOrderCouponsList = json["repairOrderCoupons"].arrayValue.map({ (value) -> SW_RepairOrderCouponsModel in
            return SW_RepairOrderCouponsModel(value)
        })
        
        /// 新增活动套餐
        repairPackageItemList = json["repairPackageItemList"].arrayValue.map({ (item) -> SW_RepairPackageItemModel in
            return SW_RepairPackageItemModel(item)
        })
        if repairPackageItemList.count > 0 {
            /// 需求列表最后有一项合计，需要自己计算
            let combinedPackage = SW_RepairPackageItemModel()
            combinedPackage.activityRepairPackageName = "合计"
            combinedPackage.retailPrice = repairPackageItemList.reduce(0, { (result, model) -> Double in
                return result + model.retailPrice
            })
            repairPackageItemList.append(combinedPackage)
        }
    }
    
}
