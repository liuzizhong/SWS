//
//  SW_DataShareListModel.swift
//  SWS
//
//  Created by jayway on 2019/1/21.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_DataShareListModel: NSObject {

//    "articleTypeId": "4028cb81685ace9a01685fb7d4e40002",
//    "articleTypeName": "保险知识",
    
    /// 发布者姓名
    var publisher = ""
    /// 发布者头像
    var publisherPortrait = ""
    //发布者职务
    var positionName = ""
    //发布者的id
    var publisherId = -1
    /// 文章的id
    var id = ""
    
    /// 文章标题
    var title = ""
    /// 文章内容
    var content = ""
    /// 文章摘要
    var summary = ""
    /// 封面图片
    var coverImg = ""
    /// 文章跳转链接
    var showUrl = ""
    /// 文章发布时间
    var publishDate: TimeInterval = 0
    /// 文章收藏时间
    var collectorDate: TimeInterval = 0
    /// 文章阅读数
    var readedCount = 0
    /// 文章收藏数
    var collectCount = 0
    
    var isCollect = false
    init(_ json: JSON) {
        super.init()
        publisher = json["publisher"].stringValue
        publisherPortrait = json["publisherPortrait"].stringValue
        positionName = json["positionName"].stringValue
        publisherId = json["publisherId"].intValue
        id = json["id"].stringValue
        title = json["title"].stringValue
        content = json["content"].stringValue
        summary = json["summary"].stringValue
        coverImg = json["coverImg"].stringValue
        showUrl = json["showUrl"].stringValue
        publishDate = json["publishDate"].doubleValue
        collectorDate = json["collectorDate"].doubleValue
        readedCount = json["readedCount"].intValue
        collectCount = json["collectCount"].intValue
        isCollect = json["isCollect"].boolValue
    }
}
