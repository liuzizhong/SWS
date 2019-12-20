

//
//  SW_CustomerReceptionChartModel.swift
//  SWS
//
//  Created by jayway on 2018/9/7.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_CustomerReceptionChartModel: SW_BaseChartModel {
    /// 客户接待数据 datatype：1
    var receptionDatas = [SW_ReceptionChartDataModel]()
    /// 接待总人数
    var receptionTotal = 0
    /// 客户留存数据 datatype：2
    var retainedDatas = [SW_ReceptionChartDataModel]()
    /// 接待总人数
    var retainedTotal = 0
    
    var dateString = ""
    
    init(_ lineChartModel:SW_CustomerLineChartModel, receptionJson: JSON?, retainedJson: JSON?) {
        super.init()
        if lineChartModel.data.count > 0 {/// 先生成对应的条数，具体数值后面设置
            receptionDatas = lineChartModel.data[0].value.map { (model) -> SW_ReceptionChartDataModel in
                return SW_ReceptionChartDataModel(model.id,color:model.color)
            }
            retainedDatas = lineChartModel.data[0].value.map { (model) -> SW_ReceptionChartDataModel in
                return SW_ReceptionChartDataModel(model.id,color:model.color)
            }
            setValue(receptionJson: receptionJson, retainedJson: retainedJson)
        }
    }
    
    /// 设置具体的数值
    ///
    /// - Parameters:
    ///   - receptionJson: 接待数据
    ///   - retainedJson: 留存数据
    func setValue(receptionJson: JSON?, retainedJson: JSON?) {
        if let receptionJson = receptionJson {
            receptionTotal = receptionJson["total"].intValue
            receptionJson["list"].arrayValue.forEach { (jsonDict) in
                if let index = self.receptionDatas.index(where: { return $0.id == jsonDict["id"].intValue }) {
                    self.receptionDatas[index].count = jsonDict["count"].intValue
                }
            }
        }
        if let retainedJson = retainedJson {
            retainedTotal = retainedJson["total"].intValue
            retainedJson["list"].arrayValue.forEach { (jsonDict) in
                if let index = self.retainedDatas.index(where: { return $0.id == jsonDict["id"].intValue }) {
                    self.retainedDatas[index].count = jsonDict["count"].intValue
                }
            }
        }
    }
}

class SW_ReceptionChartDataModel: NSObject {
    
    var id = 0
    var color = UIColor.clear
    var count = 0
    
    init(_ id: Int, color: UIColor) {
        super.init()
        self.id = id
        self.color = color
    }
    
}
