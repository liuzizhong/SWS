//
//  SW_TestCarListModel.swift
//  SWS
//
//  Created by jayway on 2018/11/22.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_TestCarListModel: NSObject {

//    "id": "ff80818166fb45fd0167022f70500015",
//    "carBrandId": "ff808181655be85b01655c89335142dc",
//    "carSeriesId": "ff808181656636c4016566c631e76c24",
//    "carModelId": "ff808181656636c4016566c632746c25",
//    "carBrandName": "阿斯顿·马丁",
//    "carSeriesName": "阿斯顿·马丁V12 Zagato",
//    "carModelName": "2012款 6.0L Zagato",
//    "bUnitId": 1
    
    var id = ""
    var carBrandId = ""
    var carSeriesId = ""
    var carModelId = ""
    var carBrandName = ""
    var carSeriesName = ""
    var carModelName = ""
    /// 单位id
    var bUnitId = 0
    var numberPlate = ""
    var keyNum = ""
    
    var testCar: String {
        get {
            return carBrandName + " " + carSeriesName + " " + carModelName
        }
    }
    
    init(_ json: JSON) {
        super.init()
        id = json["id"].stringValue
        bUnitId = json["bUnitId"].intValue
        carBrandId = json["carBrandId"].stringValue
        carSeriesId = json["carSeriesId"].stringValue
        carModelId = json["carModelId"].stringValue
        carBrandName = json["carBrandName"].stringValue
        carSeriesName = json["carSeriesName"].stringValue
        carModelName = json["carModelName"].stringValue
        keyNum = json["keyNum"].stringValue
        numberPlate = json["numberPlate"].stringValue
    }
    
    
}
