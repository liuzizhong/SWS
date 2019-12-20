//
//  SW_DefaultConversations.swift
//  SWS
//
//  Created by jayway on 2018/5/19.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit
//import WCDBSwift

class SW_DefaultConversations: NSObject {
    
    static let informDBPath = documentPath + "/InformList.db"
    
    static let informCache = YYCache(path: informDBPath)
    
    var conversations = [informConversationModel(.group),informConversationModel(.business),informConversationModel(.department)]
    
    override init() {
        super.init()
    }
    
    //        Optional([AnyHashable("summary"): hhhhhh, AnyHashable("imgUrl"): http://img-test.yuanruiteam.com/message/201805/123., AnyHashable("title"): hhhhhh, AnyHashable("showUrl"): http://test-oamng.yuanruiteam.com/message/show/123, AnyHashable("msgTypeId"): 0])
    class func saveInform(_ msgTypeId: Int, message: EMMessage) {
        let type = InformType(rawValue: msgTypeId) ?? .group
        if var informData = message.ext as? [String: Any] {
            informData["timestamp"] = message.timestamp
            if message.isRead {//
                setUnreadCount(type, isClear: true)
            } else {
                setUnreadCount(type, isClear: false)
            }
            if var informs = SW_DefaultConversations.informCache?.object(forKey: type.msgListTableName) as? [SW_InformModel] {
                informs.append(SW_InformModel(dict: informData))
                SW_DefaultConversations.informCache?.setObject(informs as NSCoding, forKey: type.msgListTableName)
            } else {
                SW_DefaultConversations.informCache?.setObject([SW_InformModel(dict: informData)] as NSCoding, forKey: type.msgListTableName)
            }
        }
    }
    
    /// 获取某种公告的所有消息
    class func getInform(_ msgType: InformType) -> [SW_InformModel] {
        if let informs = SW_DefaultConversations.informCache?.object(forKey: msgType.msgListTableName) as? [SW_InformModel] {
            return informs
        } else {
            return []
        }
    }
    
    //获取某种公告的最后一条消息  order  获取时间最大值？
    class func getLastInform(_ msgType: InformType) -> SW_InformModel? {
        if let informs = SW_DefaultConversations.informCache?.object(forKey: msgType.msgListTableName) as? [SW_InformModel] {
            return informs.last
        } else {
            return nil
        }
    }
    
    class func getAllInformMsgAndSord() -> [SW_InformModel] {
        var allInform = [SW_InformModel]()
        allInform.append(contentsOf: getInform(.group))
        allInform.append(contentsOf: getInform(.business))
        allInform.append(contentsOf: getInform(.department))
        return allInform.sorted { (obj1, obj2) -> Bool in
            return obj1.timestamp > obj2.timestamp
        }
    }
    
    /// 获取3个公告中最新的一条公告消息
    class func getAllLastInformMsg() -> SW_InformModel? {
        return [getLastInform(.group),getLastInform(.business),getLastInform(.department)].sorted { (obj1, obj2) -> Bool in
            if let msg1 = obj1, let msg2 = obj2 {
                return msg1.timestamp > msg2.timestamp
            } else if (obj1) != nil {
                return true
            } else if (obj2) != nil {
                return false
            } else {
                return false
            }
        }.first!
    }
    
    //设置消息未读数  +1  或者  清空
    class func setUnreadCount(_ msgType: InformType, isClear: Bool) {
        if isClear {
            UserDefaults.standard.set(0, forKey: msgType.unReadCountCachePath)
            return
        }
        let unRead = UserDefaults.standard.integer(forKey: msgType.unReadCountCachePath)
        UserDefaults.standard.set(unRead + 1, forKey: msgType.unReadCountCachePath)
    }
    
    /// 获取对应消息未读数
    class func getUnreadCount(_ msgType: InformType) -> Int {
        return UserDefaults.standard.integer(forKey: msgType.unReadCountCachePath)
    }
    
    /// 获取所有公告的未读数 返回
    class func getAllInformUnreadCount() -> Int {
        var unreadCount = 0
        let types = [InformType.group,InformType.business,InformType.department]
        for type in types {
            unreadCount += getUnreadCount(type)
        }
        return unreadCount
    }
    
    /// 进入内部公告清空所有未读数
    class func clearAllInformUnreadCount() {
        setUnreadCount(.group, isClear: true)
        setUnreadCount(.business, isClear: true)
        setUnreadCount(.department, isClear: true)
    }
}

class informConversationModel: NSObject {
    var type = InformType.group
    var title = ""
    var iconUrl = ""
    
    init(_ type: InformType) {
        super.init()
        self.type = type
        switch type {
        case .group:
            title = type.rawTitle
//            iconUrl = SW_UserCenter.shared.user!.blocIcon
        case .business:
            title = SW_UserCenter.shared.user!.businessUnitName.isEmpty ? type.rawTitle : InternationStr(SW_UserCenter.shared.user!.businessUnitName)
//            iconUrl = SW_UserCenter.shared.user!.busIcon
        case .department:
            title = SW_UserCenter.shared.user!.departmentName.isEmpty ? type.rawTitle : InternationStr(SW_UserCenter.shared.user!.departmentName)
//            iconUrl = SW_UserCenter.shared.user!.depIcon
        }
        
    }
    
    
    //获取最后一条消息数据  需要  未读数   最后一条的内容  最后一条的时间  返回字典？？？
//    func getLastInformMessage() {
//        let adminMessage = EMClient.shared().chatManager.getConversation("admin", type: EMConversationTypeChat, createIfNotExist: true)
//
//    }
}
