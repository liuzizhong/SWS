//
//  SW_RepairOrderRecordDetailModel.swift
//  SWS
//
//  Created by jayway on 2019/2/26.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_RepairOrderRecordDetailModel: NSObject {
    
    /// 维修单编号
    var repairOrderNum = ""
    /// 维修单id
    var repairOrderId = ""
    /// orderType 维修单状态 1保存 2确认
    var orderType = 1
    /// 维修单所在单位id，用于查班组信息
    var bUnitId = 0
    /// 车架号
    var vin = ""
    /// 售后顾问m姓名 sa
    var staffName = ""
    /// 付款状态
    var payStateStr = ""
    /// 付款类型
    var payTypeStr = ""
    /// 维修状态
    var repairStateStr = ""
    /// 质检状态
    var qualityStateStr = ""
    /// qualityState：质量检测状态 1 未提交 2 待质检 3 已通过
    var qualityState: QualityStateType = .noCommit
    
    var predictDate: TimeInterval = 0 {
        didSet {
            predictDateString = Date.dateWith(timeInterval: predictDate).stringWith(formatStr: "yyyy/MM/dd HH:mm")
        }
    }
    var predictDateString = ""
    /// 车牌号
    var numberPlate = ""
    /// 客户姓名
    var customerName = ""
    /// 客户等级 0-10
    var customerLevel = 0
    /// 客户性别
    var customerSex: Sex = .man
    /// 客户头像
    var customerPortrait = ""
    /// 客户手机号
    var customerPhoneNum = ""
    /// 送修人手机号
    var senderPhone = ""
    /// 送修人
    var sender = ""
    /// 应收金额
    var receivableAmount: Double = 0
    /// 支付金额
    var paidedAmount: Double = 0
    
    /// 完成时间
    var completeDate: TimeInterval = 0
    /// 入厂时间
    var createDate: TimeInterval = 0
    /// 里程数
    var mileage = 0
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
    /// 建议项目列表
    var suggestItemList = [SW_SuggestItemInfoModel]()
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
    /// 维修记录新增数据
    /// 接车备注
    var remark = ""
    /// 业务类型 str
    var repairBusinessTypeStr = ""
    /// 业务员
    var insuranceName = ""
    /// 赔付公司
    var repairInsuranceCompanys = [SW_RepairInsuranceCompanyModel]()
    
    override init() {
        super.init()
    }
    
    init(_ json: JSON, shouldCombined: Bool = false) {
        super.init()
        repairOrderId = json["repairOrderId"].stringValue
        repairOrderNum = json["repairOrderNum"].stringValue
        orderType = json["orderType"].intValue
        staffName = json["staffName"].stringValue
        bUnitId = json["bUnitId"].intValue
        vin = json["vin"].stringValue
        payTypeStr = json["payTypeStr"].stringValue
        payStateStr = json["payStateStr"].stringValue
        repairStateStr = json["repairStateStr"].stringValue
        qualityStateStr = json["qualityStateStr"].stringValue
        qualityState = QualityStateType(rawValue: json["qualityState"].intValue) ?? .noCommit
        numberPlate = json["numberPlate"].stringValue
        customerName = json["customerName"].stringValue       
        customerPortrait = json["customerPortrait"].stringValue
        customerSex = Sex(rawValue: json["customerSex"].intValue) ?? .man
        customerLevel = json["customerLevel"].intValue
        predictDate = json["predictDate"].doubleValue
        predictDateString = Date.dateWith(timeInterval: predictDate).stringWith(formatStr: "yyyy/MM/dd HH:mm")
        customerPhoneNum = json["customerPhoneNum"].stringValue
        sender = json["sender"].stringValue
        senderPhone = json["senderPhone"].stringValue
        receivableAmount = json["receivableAmount"].doubleValue/10000
        paidedAmount = json["paidedAmount"].doubleValue/10000
        completeDate = json["completeDate"].doubleValue
        createDate = json["createDate"].doubleValue
        mileage = json["mileage"].intValue
        /// new
        insuranceName = json["insuranceName"].stringValue
        remark = json["remark"].stringValue
        repairBusinessTypeStr = json["repairBusinessTypeStr"].stringValue
        repairInsuranceCompanys = json["repairInsuranceCompanys"].arrayValue.map({ (item) -> SW_RepairInsuranceCompanyModel in
            return SW_RepairInsuranceCompanyModel(item)
        })
        
        repairOrderItemList = json["repairOrderItemList"].arrayValue.map({ (value) -> SW_RepairOrderItemModel in
            return SW_RepairOrderItemModel(value)
        })
        
        repairOrderAccessoriesList = json["repairOrderAccessoriesList"].arrayValue.map({ (value) -> SW_RepairOrderAccessoriesModel in
            return SW_RepairOrderAccessoriesModel(value)
        })
        
        repairOrderBoutiquesList = json["repairOrderBoutiquesList"].arrayValue.map({ (value) -> SW_RepairOrderBoutiquesModel in
            return SW_RepairOrderBoutiquesModel(value)
        })
        
        repairOrderOtherInfoList = json["repairOrderOtherInfoList"].arrayValue.map({ (value) -> SW_RepairOrderOtherInfoModel in
            return SW_RepairOrderOtherInfoModel(value)
        })
        
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
        
        //        new add  优惠券 有问题
        repairPackageItemList = json["repairPackageItemList"].arrayValue.map({ (item) -> SW_RepairPackageItemModel in
            return SW_RepairPackageItemModel(item)
        })
        
        repairOrderCouponsList = json["repairOrderCouponList"].arrayValue.map({ (value) -> SW_RepairOrderCouponsModel in
            return SW_RepairOrderCouponsModel(value)
        })
        
        suggestItemList = json["suggestProjects"].arrayValue.map({ (value) -> SW_SuggestItemInfoModel in
            return SW_SuggestItemInfoModel(value)
        })
        
        if shouldCombined {
            if repairOrderItemList.count > 0 {
                /// 需求列表最后有一项合计，需要自己计算
                let combinedItem = SW_RepairOrderItemModel()
                combinedItem.repairItemNum = "合计"
                combinedItem.hourlyWageAmount = repairOrderItemList.reduce(0, { (result, model) -> Double in
                    return result + model.hourlyWageAmount
                })
                combinedItem.workingHours = repairOrderItemList.reduce(0, { (result, model) -> Double in
                    return result + model.workingHours
                })
                combinedItem.hourlyWageDealAmount = repairOrderItemList.reduce(0, { (result, model) -> Double in
                    return result + model.hourlyWageDealAmount
                })
                repairOrderItemList.append(combinedItem)
            }
            if repairOrderAccessoriesList.count > 0 {
                /// 需求列表最后有一项合计，需要自己计算
                let combinedAccessories = SW_RepairOrderAccessoriesModel()
                combinedAccessories.accessoriesNum = "合计"
                combinedAccessories.saleCount = repairOrderAccessoriesList.reduce(0, { (result, model) -> Double in
                    return result + model.saleCount
                })
                combinedAccessories.retailAmount = repairOrderAccessoriesList.reduce(0, { (result, model) -> Double in
                    return result + model.retailAmount
                })
                combinedAccessories.dealAmount = repairOrderAccessoriesList.reduce(0, { (result, model) -> Double in
                    return result + model.dealAmount
                })
                repairOrderAccessoriesList.append(combinedAccessories)
            }
            if repairOrderBoutiquesList.count > 0 {
                /// 需求列表最后有一项合计，需要自己计算
                let combinedBoutiques = SW_RepairOrderBoutiquesModel()
                combinedBoutiques.boutiqueNum = "合计"
                combinedBoutiques.saleCount = repairOrderBoutiquesList.reduce(0, { (result, model) -> Double in
                    return result + model.saleCount
                })
                combinedBoutiques.retailAmount = repairOrderBoutiquesList.reduce(0, { (result, model) -> Double in
                    return result + model.retailAmount
                })
                combinedBoutiques.dealAmount = repairOrderBoutiquesList.reduce(0, { (result, model) -> Double in
                    return result + model.dealAmount
                })
                combinedBoutiques.hourlyWageAmount = repairOrderBoutiquesList.reduce(0, { (result, model) -> Double in
                    return result + model.hourlyWageAmount
                })
                repairOrderBoutiquesList.append(combinedBoutiques)
            }
            if repairOrderOtherInfoList.count > 0 {
                /// 需求列表最后有一项合计，需要自己计算
                let combinedOtherInfo = SW_RepairOrderOtherInfoModel()
                combinedOtherInfo.name = "合计"
                combinedOtherInfo.receivableAmount = repairOrderOtherInfoList.reduce(0, { (result, model) -> Double in
                    return result + model.receivableAmount
                })
                repairOrderOtherInfoList.append(combinedOtherInfo)
            }
            if repairPackageItemList.count > 0 {
                /// 需求列表最后有一项合计，需要自己计算
                let combinedPackage = SW_RepairPackageItemModel()
                combinedPackage.activityRepairPackageName = "合计"
                combinedPackage.retailPrice = repairPackageItemList.reduce(0, { (result, model) -> Double in
                    return result + model.retailPrice
                })
                repairPackageItemList.append(combinedPackage)
            }
            if repairOrderCouponsList.count > 0 {
                /// 需求列表最后有一项合计，需要自己计算
                let combinedCoupon = SW_RepairOrderCouponsModel()
                combinedCoupon.batchNo = "合计"
                combinedCoupon.deductibleAmount = repairOrderCouponsList.reduce(0, { (result, model) -> Double in
                    return result + model.deductibleAmount
                })
                repairOrderCouponsList.append(combinedCoupon)
            }
            if suggestItemList.count > 0 {
                /// 需求列表最后有一项合计，需要自己计算
                let combinedSuggest = SW_SuggestItemInfoModel()
                combinedSuggest.projectNum = "合计"
                combinedSuggest.retailPrice = suggestItemList.reduce(0, { (result, model) -> Double in
                    return result + model.retailPrice
                })
                suggestItemList.append(combinedSuggest)
            }
        }
    }
    
    var customerNameHeight: CGFloat {
        return customerName.size(MediumFont(24), width: SCREEN_WIDTH - 122).height
    }
    
}

/// 维修单表格的类型
///
/// - item: 维修项目
/// - accessories: 维修配件
/// - boutiques: 维修精品
/// - other: 其他费用
/// - packages: 活动套餐
/// - coupons: 优惠券
/// - suggest: 建议项目
enum SW_RepairOrderFormType {
    case item
    case accessories
    case boutiques
    case other
    case packages
    case coupons
    case suggest
    
    var headerArr: [String] {
        switch self {
        case .item:
            return ["项目名称","工时","项目状态"]
        case .accessories:
            return ["配件编号","配件名称","数量","出库数量"]
        case .boutiques:
            return ["精品编号","精品名称","数量","出库数量"]
        case .other:
            return ["费用名称","应收金额"]
        case .packages:
            return ["活动套餐名称","套餐项目"]
        case .coupons:
            return ["批次","优惠券名称"]
        case .suggest:
            return ["建议项目","类别"]
        }
    }
}

class SW_RepairOrderFormBaseModel: NSObject {
    var type: SW_RepairOrderFormType = .item
    
    var cellHeight: CGFloat?
    
    var name = ""
}

enum RepairStateType: Int {
    case noStart = 1
    case start
    case completed
    
    var stateStr: String {
        switch self {
        case .noStart:
            return "未开工"
        case .start:
            return "已开工"
        case .completed:
            return "已完工"
        }
    }
}

/// qualityState：质量检测状态 1 未提交 2 待质检 3 已通过
enum QualityStateType: Int {
    case noCommit = 1
    case waitQuality
    case qualified
    case unqualified
    
    var stateStr: String {
        switch self {
        case .noCommit:
            return "未质检"
        case .waitQuality:
            return "待质检"
        case .qualified:
            return "已通过"
        case .unqualified:
            return "未通过"
        }
    }
}

/// 维修项目模型
class SW_RepairOrderItemModel: SW_RepairOrderFormBaseModel {

    /// 工时
    var workingHours: Double = 0
    /// 项目状态
    var itemStateStr = ""
    
    /// 该项目是否可以修改，  施工单中，只有组长可以修改自己组中的项目状态，组员只能看自己组中的维修项目，其他组的项目不可以看，廖哥说有问题就叼他。---后面有暂时不要这个限定，后端一直返回true
    var isModify = false
    /// 是否未后面新增项
    var isAppend = false
    
    /// repairState：维修状态 1 未开工 2 已开工 3 已完工
    var itemState: RepairStateType = .noStart
    /// 维修项目id
    var repairOrderItemId = ""
    /// qualityState：质量检测状态 1 未提交 2 待质检 3 已通过
    var qualityState: QualityStateType = .noCommit
//    "3 合格、通过 4 不合格、不通过",
    
    /// 默认全部合格
    var isQualified = true
    /// 用于判断 该项目是否被确认，  1 已确认   2 未确认----- 只有确认的项目才能派工和开工完工
    var state = 2
    
    /// 是否被删除
    var isDel = false
    
    /// 班组id
    var afterSaleGroupId = ""
    /// 班组名字
    var afterSaleGroupName = ""
    /// 工位名字
    var areaNum = ""
    
    //MARK: - new
    /// 折扣
    var discount:Double = 0
    /// 工时费
    var hourlyWageAmount:Double = 0
    /// 折后工时费
    var hourlyWageDealAmount : Double = 0
    /// 子帐
    var accountTypeName = ""
    /// 维修种类
    var repairTypeName = ""
    /// 维修套餐
//    var repairPackageName = ""
    /// 备注
    var remark = ""
    /// 项目编号
    var repairItemNum = ""
    override init() {
        super.init()
        type = .item
    }
    
    init(_ json: JSON) {
        super.init()
        type = .item
        name = json["repairOrderItemName"].stringValue
        repairOrderItemId = json["repairOrderItemId"].stringValue
        itemStateStr = json["itemStateStr"].stringValue
        isModify = json["isModify"].boolValue
        workingHours = json["workingHours"].doubleValue
        itemState = RepairStateType(rawValue: json["itemState"].intValue) ?? .noStart
        qualityState = QualityStateType(rawValue: json["qualityState"].intValue) ?? .noCommit
        isAppend = json["isAppend"].intValue == 1
        isDel = json["isDel"].intValue == 1
        afterSaleGroupId = json["afterSaleGroupId"].stringValue
        afterSaleGroupName = json["afterSaleGroupName"].stringValue
        areaNum = json["areaNum"].stringValue
        state = json["state"].intValue
        
        discount = json["discount"].doubleValue
        hourlyWageAmount = json["hourlyWageAmount"].doubleValue/10000.0
        hourlyWageDealAmount = json["hourlyWageDealAmount"].doubleValue/10000.0
        accountTypeName = json["accountTypeName"].stringValue
        repairTypeName = json["repairTypeName"].stringValue
//        repairPackageName = json["repairPackageName"].stringValue
        repairItemNum = json["repairItemNum"].stringValue
        remark = json["remark"].stringValue
    }
}

/// 维修配件模型
class SW_RepairOrderAccessoriesModel: SW_RepairOrderFormBaseModel {
    
    ///  数量
    var saleCount: Double = 0
    /// 出库数量
    var outCount: Double = 0
    /// 是否未后面新增项
    var isAppend = false
    /// 是否被删除
    var isDel = false
    
    //MARK: - new
    /// 零售总价  折前总价
    var retailAmount: Double = 0
    /// 折扣
    var discount:Double = 0
    /// 折后总价
    var dealAmount: Double = 0
    /// 子帐
    var accountTypeName = ""
    /// 维修种类
    var repairTypeName = ""
    /// 维修套餐
//    var repairPackageName = ""
    /// 增项班组名称
    var afterSaleGroupName = ""
    /// 配件编号
    var accessoriesNum = ""
    
    override init() {
        super.init()
        type = .accessories
    }
    
    init(_ json: JSON) {
        super.init()
        type = .accessories
        name = json["accessoriesName"].stringValue
        accessoriesNum = json["accessoriesNum"].stringValue
        afterSaleGroupName = json["afterSaleGroupName"].stringValue
        saleCount = json["saleCount"].doubleValue
        outCount = json["outCount"].doubleValue
        isAppend = json["isAppend"].intValue == 1
        isDel = json["isDel"].intValue == 1
        discount = json["discount"].doubleValue
        retailAmount = json["retailAmount"].doubleValue/10000.0
        dealAmount = json["dealAmount"].doubleValue/10000.0
        accountTypeName = json["accountTypeName"].stringValue
        repairTypeName = json["repairTypeName"].stringValue
//        repairPackageName = json["repairPackageName"].stringValue
    }
}


/// 维修精品模型
class SW_RepairOrderBoutiquesModel: SW_RepairOrderFormBaseModel {
    
    /// 数量
    var saleCount: Double = 0
    /// 出库数量
    var outCount: Double = 0
    
    /// 精品编号
    var boutiqueNum = ""
    //MARK: - new
    ///  折前总价
    var retailAmount: Double = 0
    /// 折扣
    var discount:Double = 0
    /// 折后总价
    var dealAmount: Double = 0
    /// 总工时费
    var hourlyWageAmount: Double = 0
    
    /// 小计  折后总价+总工时费
    var subtotal: Double = 0
    
    override init() {
        super.init()
        type = .boutiques
    }
    
    init(_ json: JSON) {
        super.init()
        type = .boutiques
        name = json["boutiqueName"].stringValue
        saleCount = json["saleCount"].doubleValue
        outCount = json["outCount"].doubleValue
        boutiqueNum = json["boutiqueNum"].stringValue
        discount = json["discount"].doubleValue
        retailAmount = json["retailAmount"].doubleValue/10000.0
        dealAmount = json["dealAmount"].doubleValue/10000.0
        hourlyWageAmount = json["hourlyWageAmount"].doubleValue/10000.0
        subtotal = dealAmount + hourlyWageAmount
    }
}


/// 其他费用模型
class SW_RepairOrderOtherInfoModel: SW_RepairOrderFormBaseModel {
    ///  应收金额
    var receivableAmount: Double = 0
    /// 备注
    var remark = ""
    
    override init() {
        super.init()
        type = .other
    }
    
    init(_ json: JSON) {
        super.init()
        type = .other
        name = json["otherInfoName"].stringValue
        if name.isEmpty {
            name = json["name"].stringValue
        }
        receivableAmount = Double(json["receivableAmount"].intValue)/10000.0
        remark = json["remark"].stringValue
    }
}

/// 活动套餐模型
class SW_RepairPackageItemModel: SW_RepairOrderFormBaseModel {
    ///  单价
    var retailPrice: Double = 0
    /// 备注
    var remark = ""
    var activityRepairPackageName = ""
    
    override init() {
        super.init()
        type = .packages
    }
    
    init(_ json: JSON) {
        super.init()
        type = .packages
        name = json["name"].stringValue
        remark = json["remark"].stringValue
        activityRepairPackageName = json["activityRepairPackageName"].stringValue
        retailPrice = Double(json["retailPrice"].intValue)/10000.0
    }
}

/// 优惠券模型
class SW_RepairOrderCouponsModel: SW_RepairOrderFormBaseModel {
    ///  抵扣金额
    var deductibleAmount: Double = 0
    /// 过期时间
    var expDate: TimeInterval = 0
    /// 备注
    var remark = ""
    /// 发放批次
    var batchNo = ""
    override init() {
        super.init()
        type = .coupons
    }
    
    init(_ json: JSON) {
        super.init()
        type = .coupons
        name = json["name"].stringValue
        remark = json["remark"].stringValue
        batchNo = json["batchNo"].stringValue
        expDate = json["expDate"].doubleValue
        deductibleAmount = Double(json["deductibleAmount"].intValue)/10000.0
    }
}

enum SuggestItemType: Int {
    case repair  =  1
    case accessories
    case boutiques
    
    var rawString: String {
        switch self {
        case .repair:
            return "维修项目"
        case .accessories:
            return "配件"
        case .boutiques:
            return "精品"
        }
    }
}

/// 建议项目模型
class SW_SuggestItemInfoModel: SW_RepairOrderFormBaseModel {
    
    ///  建议项目类型 type 1维修项目   2配件  3精品
    var itemType: SuggestItemType = .repair
    
    /// 零售价
    var retailPrice: Double = 0
    /// 项目编号
    var projectNum = ""
    
    override init() {
        super.init()
        type = .suggest
    }
    
    init(_ json: JSON) {
        super.init()
        type = .suggest
        name = json["name"].stringValue
        projectNum = json["projectNum"].stringValue
        retailPrice = Double(json["retailPrice"].intValue)/10000.0
        itemType = SuggestItemType(rawValue: json["type"].intValue) ?? .repair
    }
}

/// 维修赔付公司模型
class SW_RepairInsuranceCompanyModel: NSObject {
    
    var name = ""
    var percent = 0
    
    override init() {
        super.init()
    }
    
    init(_ json: JSON) {
        super.init()
        name = json["name"].stringValue
        percent = json["percent"].intValue
    }
}
