//
//  SW_ConversationModel.swift
//  SWS
//
//  Created by jayway on 2018/5/18.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_ConversationModel: NSObject, IConversationModel {
    var conversation: EMConversation!
    
    var title: String!
    /// 个人消息有职务
    var position = ""
    
    var avatarURLPath: String!
    
    var avatarImage: UIImage!
    
//    var realName = ""
//    var posName = ""
//    var portrait = ""
    var regionStr = ""
    var groupState = true
//    var groupName = ""
//    var imageUrl = ""
    
    required init!(conversation: EMConversation!) {
        self.conversation = conversation
        self.title = conversation.conversationId
        switch conversation.type {
        case EMConversationTypeGroupChat:
            avatarImage = UIImage(named: "icon_groupavatar")
        case EMConversationTypeChat:
            avatarImage = UIImage(named: "icon_personalavatar")
        default:
            avatarImage = UIImage(named: "icon_groupavatar")
        }
    }
    
    func setInfo(json: JSON) {
        switch conversation.type {
        case EMConversationTypeGroupChat:
            avatarURLPath = json["imageUrl"].stringValue
            title = json["groupName"].stringValue
            groupState = json["groupState"].intValue != 2
            if !groupState {
                conversation.markAllMessages(asRead: nil)
            }
            if URL(string: avatarURLPath) == nil {
                avatarImage = UIImage(named: "icon_groupavatar")
            }
        case EMConversationTypeChat:
            avatarURLPath = json["portrait"].stringValue
            title = json["realName"].stringValue
            position = "(\(json["posName"].stringValue))"
            regionStr = json["regionStr"].stringValue
            if URL(string: avatarURLPath) == nil {
                avatarImage = UIImage(named: "icon_personalavatar")
            }
        default:
            title = conversation.conversationId
        }
        
    }
    
    
}
