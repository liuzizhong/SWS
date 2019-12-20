//
//  SW_WorkReportModel.swift
//  SWS
//
//  Created by jayway on 2018/7/5.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_WorkReportModel: NSObject, NSCoding {

    /// 报告类型:0:每日 1:月度 2:年度 
    var reportType = WorkReportType.day
    
    var ownerType = WorkReportOwner.mine
    
    /// 工作报告id 修改必填
    var id = ""
    
    /// 主标题 报告类型为1,2时必传
    var title = ""
    
    /// 报告说明
    var content = ""
    
    /// 工作类型id数组 工作日志必填
    var workTypes = [NormalModel]()
    
    /// 工作报告发送的图片url数组
    var images = [String]()
    
    /// 工作报告发送的图片url的前缀 ，上传前替换使用
    var imagePrefix = ""
    
    /// 接收人数组
    var receivers = [SW_RangeModel]()
    
    ///----分割线   上面是编辑时需要的属性   下面是详情页显示的内容
    
    /// 是否可以修改  json中 0：可以   1：不可以
    var isModify = false
    
    var createDate: TimeInterval = 0
    
    
    //收到的工作报告
    ///收到的代表我是否审阅了，
    var isCheck = false
    //报告发起人的名字
    var reporterName = ""
    
    ///我审阅的内容
    var comment = ""
    ///我审阅的时间
    var checkDate: TimeInterval = 0
    ///已审阅人数
    var checkCount = 0
    ///接收人人数
    var receiverTotal = 0
    
    override init() {
        super.init()
    }
    
    init(_ type: WorkReportType, ownerType: WorkReportOwner, json: JSON? = nil) {
        super.init()
        self.reportType = type
        self.ownerType = ownerType
        if let json = json {
            id = json["id"].stringValue
            title = json["title"].stringValue
            reporterName = json["reporterName"].stringValue
            comment = json["comment"].stringValue
            content = json["content"].stringValue
            createDate = json["createDate"].doubleValue
            checkDate = json["checkDate"].doubleValue
            isCheck = json["isCheck"].intValue == 0
            isModify = json["isModify"].intValue == 0
            imagePrefix = json["imagePrefix"].stringValue
            images = json["imageList"].arrayValue.map({ return imagePrefix + $0["imgUrl"].stringValue })
            receivers = json["receiverList"].arrayValue.map({ return SW_RangeModel(commentJson: $0) })
            workTypes = json["workTypes"].arrayValue.map({ return NormalModel($0) })
            checkCount = json["checkCount"].intValue
            receiverTotal = json["receiverTotal"].intValue
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(reportType.rawValue, forKey: "reportType")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(content, forKey: "content")
        aCoder.encode(imagePrefix, forKey: "imagePrefix")
        aCoder.encode(images, forKey: "images")
        aCoder.encode(receivers, forKey: "receivers")
    }
    
    required init?(coder aDecoder: NSCoder) {
        reportType = WorkReportType(rawValue:  aDecoder.decodeInteger(forKey: "reportType")) ?? .day
        title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
        content = aDecoder.decodeObject(forKey: "content") as? String ?? ""
        imagePrefix = aDecoder.decodeObject(forKey: "imagePrefix") as? String ?? ""
        images = aDecoder.decodeObject(forKey: "images") as? [String] ?? []
        receivers = aDecoder.decodeObject(forKey: "receivers") as? [SW_RangeModel] ?? []
    }
}

//MARK: - NSCopying
extension SW_WorkReportModel: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copyObj = SW_WorkReportModel()
        copyObj.reportType = reportType
        copyObj.ownerType = ownerType
        copyObj.id = id
        copyObj.title = title
        copyObj.content = content
        copyObj.imagePrefix = imagePrefix
        copyObj.images = images
        copyObj.workTypes = workTypes.map({ return $0.copy() as! NormalModel })
        copyObj.receivers = receivers.map({ return $0.copy() as! SW_RangeModel })
        return copyObj
    }
    
}


