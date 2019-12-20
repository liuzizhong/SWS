//
//  SW_TopConversationManager.swift
//  SWS
//
//  Created by jayway on 2018/6/13.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit


class SW_TopConversationManager: NSObject {
    
    static let topConversationsDBPath = documentPath + "/TopConversations.db"
    
    static let topConversationsCache = YYCache(path: topConversationsDBPath)
    
    /// 添加置顶会话
    ///
    /// - Parameter staffAccount: 添加置顶的会话ID
    class func addTopConversation(_ conversationId: String, chatType: EMConversationType) {
        let topConversationsCacheKey =  "topConversationsCacheKey\(SW_UserCenter.getUserCachePath())"
        let conversation = TopConversationModel(conversationId, chatType: chatType)
        
        if var topConversations = SW_TopConversationManager.topConversationsCache?.object(forKey: topConversationsCacheKey) as? [TopConversationModel] {
            if !topConversations.contains(where: { (model) -> Bool in
                return conversation.conversationId == model.conversationId && conversation.chatType == model.chatType
            }) {
                topConversations.append(conversation)
            }
            SW_TopConversationManager.topConversationsCache?.setObject(topConversations as NSCoding, forKey: topConversationsCacheKey)
        } else {
            SW_TopConversationManager.topConversationsCache?.setObject([conversation] as NSCoding, forKey: topConversationsCacheKey)
        }
        EMClient.shared().chatManager.getConversation(conversationId, type: chatType, createIfNotExist: true)
    }
    
    /// 删除置顶会话
    ///
    /// - Parameter staffAccount: 删除置顶的会话ID
    class func removeTopConversation(_ conversationId: String, chatType: EMConversationType) {
        let topConversationsCacheKey =  "topConversationsCacheKey\(SW_UserCenter.getUserCachePath())"
        let conversation = TopConversationModel(conversationId, chatType: chatType)
        if var topConversations = SW_TopConversationManager.topConversationsCache?.object(forKey: topConversationsCacheKey) as? [TopConversationModel] {
            if let index = topConversations.index(where: { (model) -> Bool in
                return conversation.conversationId == model.conversationId && conversation.chatType == model.chatType
            }) {
                topConversations.remove(at: index)
            }
            SW_TopConversationManager.topConversationsCache?.setObject(topConversations as NSCoding, forKey: topConversationsCacheKey)
        }
    }
    
    /// 判断会话是置顶会话
    ///
    /// - Parameter staffAccount: 判断的会话iD
    /// - Returns: true 是置顶  false  不是置顶
    class func isTopConversation(_ conversationId: String, chatType: EMConversationType) -> Bool {
        let topConversationsCacheKey =  "topConversationsCacheKey\(SW_UserCenter.getUserCachePath())"
        let conversation = TopConversationModel(conversationId, chatType: chatType)
        if let topConversations = SW_TopConversationManager.topConversationsCache?.object(forKey: topConversationsCacheKey) as? [TopConversationModel] {
            return topConversations.contains(where: { (model) -> Bool in
                return conversation.conversationId == model.conversationId && conversation.chatType == model.chatType
            })
        } else {
            return false
        }
    }
    
    /// 获取所有置顶会话
    ///
    /// - Returns: 所有置顶会话列表
    class func getAllTopConversations() -> [TopConversationModel] {
        let topConversationsCacheKey =  "topConversationsCacheKey\(SW_UserCenter.getUserCachePath())"
        if let topConversations = SW_TopConversationManager.topConversationsCache?.object(forKey: topConversationsCacheKey) as? [TopConversationModel] {
            return topConversations
        } else {
            return []
        }
    }
}

class TopConversationModel:NSObject,NSCoding {
    var conversationId = ""
    var chatType = EMConversationTypeChat
    
    init(_ conversationId: String, chatType: EMConversationType) {
        super.init()
        self.conversationId = conversationId
        self.chatType = chatType
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(conversationId, forKey: "conversationId")
        aCoder.encode(Int32(chatType.rawValue), forKey: "chatType")
    }
    
    required init?(coder aDecoder: NSCoder) {
        conversationId = aDecoder.decodeObject(forKey: "conversationId") as? String ?? ""
        chatType = EMConversationType(UInt32(aDecoder.decodeInt32(forKey: "chatType")))
    }
}
