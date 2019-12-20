//
//  SW_RevenueDetailModel.swift
//  SWS
//
//  Created by jayway on 2018/6/22.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

/// 营收报表-订单详情模型   用于创建订单-展示订单 每日订单报表模型
class SW_RevenueDetailModel: NSObject {
    //MARK: - 新建报表属性
    
    /// 报表的type
    var type = RevenueReportType.dayOrder
    /// 由uuid生成的唯一值,修改时必传
    var id = ""
    /// 订单编号
    var orderNo = ""
    /// 订单署期
    var orderDate: TimeInterval = 0
    /// 客户姓名
    var customerName = ""
    /// 订单类型 如1:销售订单 2:售后订单
    var orderType = OrderTypeModel()
    /// 订单归属部门id
    var fromDeptId = 0
    /// 订单归属部门名称
    var fromDeptName = ""
    /// 业务员姓名
    var salesman = ""
    /// 业务员ID
    var salesmanId = 0
    /// 汽车品牌
    var carBrand = NormalModel()
    /// 车系
    var carSerie = NormalModel()
    /// 车型
    var carModel = NormalModel()
    /// 车身颜色
    var carColor = NormalModel()
    /// 保险公司id
    var insuranceCompanyKey = "" {
        didSet {
            if insuranceCompanyKey != oldValue {
                if insuranceCompanyKey.isEmpty {//清空了保险公司
                    insuranceTypes = []
                } else {///选择了保险公司，则新建一个
                    insuranceTypes = [InsuranceModel()]
                }
            }
        }
    }
    /// 保险公司名称
    var insuranceCompanyName = ""
    
    /// [{"insuranceTypeId": "保险种类id","insuranceTypeName": "险种名称","limitDate": "保险到期时间"}]
    /// 数组--保险的一些参数 --可以用模型
    var insuranceTypes = [InsuranceModel]()
    
    /// [{"amount": "成本金额","typeName": "成本类型名字","typeId": "成本类型id"}]
    /// 数组--成本 --可以用模型
    var costList = [CostIncomeModel()]
    
    /// [{"amount": "收入金额","typeName": "收入类型名字","typeId": "收入类型id"}, {"amount": "收入金额","typeName": "收入类型名字","typeId": "收入类型id"}]
    /// 数组--收入 --可以用模型
    var revenueList = [CostIncomeModel()]
    
    
    //MARK: - 详情页面属性
    /// 是否可以修改  json中 0：可以   1：不可以
    var isModify = false
    /// 已经修改的次数
    var modifyCount = 0
    /// 订单创建时间
    var orderCreateDate: TimeInterval = 0
    /// 总收入金额
    var revenueAmount = ""
    /// 总成本金额
    var costAmount = ""
    
    
    
    //MARK: - 业务模块
    /// 判断是否符合提交条件 - 第一个变量 true 符合条件   false 不符合条件 第二个变量是 不符合的 - 提示语
    var isCanPost: (isCanPost:Bool,msg:String) {
        var count = 0
        for revenue in revenueList {
            //选择了收入类型
            if !revenue.typeName.isEmpty, revenue.amount.isEmpty {
                return (false,"请输入收入金额")
            }
            //输入了收入金额
            if revenue.typeName.isEmpty, !revenue.amount.isEmpty {
                return (false,"请选择收入类型")
            }
            //两项都填的计数+1
            if !revenue.typeName.isEmpty, !revenue.amount.isEmpty {
                count += 1
            }
        }
        //成本 选择了就一定要填金额  填了其中一项，另外一项必填
        for cost in costList {
            //选择了成本类型
            if !cost.typeName.isEmpty, cost.amount.isEmpty {
                return (false,"请输入成本金额")
            }
            //输入了成本金额
            if cost.typeName.isEmpty, !cost.amount.isEmpty {
                return (false,"请选择成本类型")
            }
            //两项都填的计数+1
            if !cost.typeName.isEmpty, !cost.amount.isEmpty {
                count += 1
            }
        }
        //必须要有填一个收入或者成本
        if count == 0 {
            return (false,"请填写收入或成本")
        }
        return (true,"")
    }
    
//    {id:"","recoderId":1,"salesmanId":1,orderNo:"123",orderDate:"12312312",customerName:"李四",fromDeptId:"1",fromDeptName:"销售部",orderTypeKey:"1",salesman:"威哥",carBrand:"沃尔沃", carSerie:"S90",carModel:"T8尊贵版",carColor:"黑色",insuranceCompanyKey:"1",insuranceCompanyName:"中国平安",insuranceTypes:[{insuranceTypeId:"222",insuranceTypeName:"交强险",limitDate:12313454654}], "costList": [{"amount": 1600,"typeName": "广告支出","typeId": "13456465"}],"revenueList": [{"amount": 1600,"typeName": "广告收入","typeId": "13456465"}] }
    
    override init() {
        super.init()
    }
    
    init(_ type: RevenueReportType, json: JSON? = nil) {
        super.init()
        self.type = type
        if let json = json {
            id = json["id"].stringValue
            modifyCount = json["modifyCount"].intValue
            isModify = json["isModify"].intValue == 1 ? false : true
            customerName = json["customerName"].stringValue
            fromDeptId = json["fromDeptId"].intValue
            fromDeptName = json["fromDeptName"].stringValue
            salesman = json["salesman"].stringValue
            salesmanId = json["salesmanId"].intValue
            orderCreateDate = json["orderCreateDate"].doubleValue
            revenueList = json["revenueList"].arrayValue.map({ return CostIncomeModel($0) })
            revenueAmount = json["revenueAmount"].stringValue
            if revenueList.count == 0 {
                revenueList = [CostIncomeModel()]
            }
            costList = json["costList"].arrayValue.map({ return CostIncomeModel($0) })
            costAmount = json["costAmount"].stringValue
            if costList.count == 0 {
                costList = [CostIncomeModel()]
            }
            if type == .dayOrder {///每日订单解析
                orderNo = json["orderNo"].stringValue
                orderDate = json["orderDate"].doubleValue
                insuranceCompanyKey = json["insuranceCompanyKey"].stringValue
                insuranceCompanyName = json["insuranceCompanyName"].stringValue
                insuranceTypes = json["InsuranceIncomeList"].arrayValue.map({ return InsuranceModel($0) })
                carBrand = NormalModel(json["carBrand"].stringValue, id: json["carBrandId"].stringValue)
                carSerie = NormalModel(json["carSerie"].stringValue, id: json["carSerieId"].stringValue)
                carModel = NormalModel(json["carModel"].stringValue, id: json["carModelId"].stringValue)
                carColor = NormalModel(json["carColor"].stringValue, id: json["carColorId"].stringValue)
                orderType = OrderTypeModel(json["orderTypeName"].stringValue, orderTypeKey: json["orderTypeKey"].intValue)
            } else {//非订单解析
                orderNo = json["flowNo"].stringValue
                orderDate = json["flowDate"].doubleValue
            }
        }
    }
    
}

//MARK: - NSCopying
extension SW_RevenueDetailModel: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copyObj = SW_RevenueDetailModel()
        copyObj.id = id
        copyObj.modifyCount = modifyCount
        copyObj.isModify = isModify
        copyObj.customerName = customerName
        copyObj.fromDeptId = fromDeptId
        copyObj.fromDeptName = fromDeptName
        copyObj.salesman = salesman
        copyObj.salesmanId = salesmanId
        copyObj.orderCreateDate = orderCreateDate
        copyObj.revenueList = revenueList.map({ return $0.copy() as! CostIncomeModel })
        copyObj.revenueAmount = revenueAmount
        copyObj.costList = costList.map({ return $0.copy() as! CostIncomeModel })
        copyObj.costAmount = costAmount
        copyObj.orderNo = orderNo
        copyObj.orderDate = orderDate
        copyObj.insuranceCompanyKey = insuranceCompanyKey
        copyObj.insuranceCompanyName = insuranceCompanyName
        copyObj.insuranceTypes = insuranceTypes.map({ return $0.copy() as! InsuranceModel })
        copyObj.carBrand = carBrand.copy() as! NormalModel
        copyObj.carSerie = carSerie.copy() as! NormalModel
        copyObj.carModel = carModel.copy() as! NormalModel
        copyObj.carColor = carColor.copy() as! NormalModel
        copyObj.orderType = orderType.copy() as! OrderTypeModel
        return copyObj
    }
    
}

extension InsuranceModel: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copyObj = InsuranceModel()
        copyObj.insuranceTypeId = insuranceTypeId
        copyObj.insuranceTypeName = insuranceTypeName
        copyObj.limitDate = limitDate
        return copyObj
    }
}

extension CostIncomeModel: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copyObj = CostIncomeModel()
        copyObj.amount = amount
        copyObj.typeName = typeName
        copyObj.typeId = typeId
        return copyObj
    }
}

extension OrderTypeModel: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copyObj = OrderTypeModel()
        copyObj.name = name
        copyObj.orderTypeKey = orderTypeKey
        return copyObj
    }
}

extension NormalModel: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copyObj = NormalModel()
        copyObj.name = name
        copyObj.id = id
        return copyObj
    }
}


//MARK: - 子模型
///  保险模型 {"insuranceTypeId": "保险种类id","insuranceTypeName": "险种名称","limitDate": "保险到期时间"}
class InsuranceModel: NSObject {
    /// 保险种类id"
    var insuranceTypeId = ""
    /// 险种名称
    var insuranceTypeName = ""
    /// "保险到期时间
    var limitDate: TimeInterval = 0
    
    override init() {
        super.init()
    }
    
    init(_ json: JSON) {
        super.init()
        insuranceTypeId = json["insuranceTypeId"].stringValue
        insuranceTypeName = json["insuranceTypeName"].stringValue
        limitDate = json["limitDate"].doubleValue
    }
    
    /// 转换为字典传参
    ///
    /// - Returns: 转换好的字典
    func toDict() -> [String: Any] {
        var dict = [String:Any]()
        dict["insuranceTypeId"] = insuranceTypeId
        dict["insuranceTypeName"] = insuranceTypeName
        dict["limitDate"] = limitDate
        return dict
    }
}

///  收入成本类型 [{"amount": "成本金额","typeName": "成本类型名字","typeId": "成本类型id"}]
class CostIncomeModel: NSObject {
    /// 成本/收入金额
    var amount = ""
    /// 成本/收入类型名字
    var typeName = ""
    /// 成本/收入类型id
    var typeId = ""
    
    override init() {
        super.init()
    }
    
    init(_ json: JSON) {
        super.init()
        amount = json["amount"].stringValue
        typeName = json["typeName"].stringValue
        typeId = json["typeId"].stringValue
    }
    
    /// 转换为字典传参
    ///
    /// - Returns: 转换好的字典
    func toDict() -> [String: Any] {
        var dict = [String:Any]()
        if amount.last == "." {//最后一个小数点去除
            dict["amount"] = amount.replacingOccurrences(of: ".", with: "")
        } else {
            dict["amount"] = amount
        }
        dict["typeName"] = typeName
        dict["typeId"] = typeId
        return dict
    }
}


/// 订单类型模型
class OrderTypeModel: NSObject {
    /// 订单类型名称
    var name = ""
    /// 订单类型ID
    var orderTypeKey = 0
    
    override init() {
        super.init()
    }
    
    init(_ json: JSON) {
        super.init()
        name = json["name"].stringValue
        orderTypeKey = json["value"].intValue
    }
    
    init(_ name: String, orderTypeKey: Int) {
        super.init()
        self.name = name
        self.orderTypeKey = orderTypeKey
    }
}


/// 通用的模型，只有name跟id时可以使用，现在用于汽车型号模块
class NormalModel: NSObject {
    var name = ""
    var id = ""
    
    /// 用于评价分数
    var value: CGFloat = 0
    /// 用于选择汽车厂商品牌时的首字母
    var firstChar = ""
    
    override init() {
        super.init()
    }
    
    init(_ json: JSON) {
        super.init()
        name = json["name"].stringValue
        id = json["id"].stringValue
        firstChar = json["firstChar"].stringValue
        if !"ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(firstChar) {
            firstChar = "#"
        }
    }
    
    init(_ name: String, id: String) {
        super.init()
        self.name = name
        self.id = id
    }
}
