//
//  SW_BoutiquesAccessoriesModel.swift
//  SWS
//
//  Created by jayway on 2019/3/23.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_BoutiquesAccessoriesModel: NSObject {
    /// 当时是配件还是精品
    var type: ProcurementType = .boutiques

    /// 精品配件 启用状态 1 启用 2 禁用
//    var state = 1
    
    /// 添加数量，默认是1
    var addCount: Double = 1
    
    /// 配件增项时输入的数量，可以是小数
    var saleCount: Double = 0
    
    /// 精品配件ID
    var id = ""
    /// 精品配件名称
    var name = ""
    /// 条形码
    var code = ""
    /// 精品编号
    var num = ""
    /// 配件种类
    var accessoriesTypeName = ""
    /// 配件种类的ID   保存时要用
    var accessoriesTypeId = ""
    /// 精品种类
    var boutiqueTypeName = ""
    /// 精品种类的ID   保存时要用
    var boutiqueTypeId = ""
    /// 供应商名称
    var supplier = ""
    /// 供应商id
    var supplierId = ""
    
    /// 精品、配件的库存ID，在盘点时需要传给后台
    var stockId = ""
    
    /// "适用车型类别 1 通用型  2 指定车型"
    var forCarModelType = 1 {
        didSet {
            if forCarModelType != oldValue, forCarModelType == 1 {
                carBrand = ""
                carBrandId = ""
                carSeries = ""
            }
        }
    }
    
    /// 汽车品牌
    var carBrand = ""
    /// 汽车品牌ID
    var carBrandId = ""
    /// 汽车系列
    var carSeries = ""
    /// 汽车系列ID
    var carSeriesId = ""
    /// 所在仓库名称
    var warehouseName = ""
    /// 仓库id
    var warehouseId = "" {
        didSet {
            if warehouseId != oldValue {
                areaNum = ""
                shelfNum = ""
                layerNum = ""
                seatNum = ""
            }
        }
    }
    
    /// 区域号
    var areaNum = ""
    /// 货架号
    var shelfNum = ""
    /// 层号
    var layerNum = ""
    /// 位号
    var seatNum = "" {
        didSet {
            if seatNum.isEmpty {
                warehousePositionNum = ""
            } else {
                warehousePositionNum = "\(areaNum)/\(shelfNum)/\(layerNum)/\(seatNum)"
            }
        }
    }
    /// 仓位号
    var warehousePositionNum = ""
    /// 精品度量单位
    var unit = ""
    /// 规格 可选值
    var specification = ""
    /// 零售价
    var retailPrice: Double = 0
    /// 含税成本价
    var costPriceTax: Double = 0
    /// 索赔价
    var claimPrice: Double = 0
    /// 工时费
    var hourlyWage: Double = 0
    /// 缓存的cell高度
    var cacheHeight: CGFloat?
    /// 库存数量
    var stockNum: Double = 0
    
    override init() {
        super.init()
    }
    
    init(code: String, type: ProcurementType) {
        super.init()
        self.code = code
        self.type = type
    }
    
    init(_ json: JSON, type: ProcurementType) {
        super.init()
        self.type = type
        id = json["id"].stringValue
        if  type == .boutiques {
            name = json["name"].stringValue
            code = json["boutiqueCode"].stringValue
            num = json["boutiqueNum"].stringValue
            if !json["boutiqueName"].stringValue.isEmpty {
                name = json["boutiqueName"].stringValue
            }
            boutiqueTypeName = json["boutiqueTypeName"].stringValue
            forCarModelType = json["forCarModelType"].intValue == 0 ? 1 : json["forCarModelType"].intValue
        } else {
            if !json["accessoriesId"].stringValue.isEmpty {
                id = json["accessoriesId"].stringValue
            }
            name = json["accessoriesName"].stringValue
            code = json["accessoriesCode"].stringValue
            num = json["accessoriesNum"].stringValue
            accessoriesTypeName = json["accessoriesTypeName"].stringValue
            forCarModelType = json["beApplicableType"].intValue == 0 ? 1 : json["beApplicableType"].intValue
            stockId = json["accessoriesStockId"].stringValue
        }
        supplier = json["supplierName"].stringValue
        supplierId = json["supplierId"].stringValue
        if stockId.isEmpty {        
            stockId = json["stockId"].stringValue
        }
        carBrand = json["carBrand"].stringValue
        carBrandId = json["carBrandId"].stringValue
        carSeries = json["carSeries"].stringValue
        warehouseName = json["warehouseName"].stringValue
        warehouseId = json["warehouseId"].stringValue
        areaNum = json["areaNum"].stringValue
        shelfNum = json["shelfNum"].stringValue
        layerNum = json["layerNum"].stringValue
        seatNum = json["seatNum"].stringValue
        if !json["warehousePositionNum"].stringValue.isEmpty {
            warehousePositionNum = json["warehousePositionNum"].stringValue
        } else {
            warehousePositionNum = "\(areaNum)/\(shelfNum)/\(layerNum)/\(seatNum)"
        }
        unit = json["unit"].stringValue
        specification = json["specification"].stringValue
        
        retailPrice = json["retailPrice"].doubleValue/10000.0
        costPriceTax = json["costPriceTax"].doubleValue/10000.0
        claimPrice = json["claimPrice"].doubleValue/10000.0
        hourlyWage = json["hourlyWage"].doubleValue/10000.0
        stockNum = json["stockNum"].doubleValue
    }
    
    
}
