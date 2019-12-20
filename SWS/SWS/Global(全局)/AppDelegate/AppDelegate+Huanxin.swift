//
//  AppDelegate+Huanxin.swift
//  SWS
//
//  Created by jayway on 2018/10/9.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import Foundation



//MARK: - EMGroupManagerDelegate
extension AppDelegate: EMGroupManagerDelegate {
    
    func setUpChatDelegate() {
        EMClient.shared()?.chatManager.add(self, delegateQueue: nil)
        EMClient.shared()?.groupManager.add(self, delegateQueue: nil)
    }
    
    /// 用户被踢出群时回调  -- 暂时没有踢群逻辑
    ///
    /// - Parameters:
    ///   - aGroup: 被踢出的群
    ///   - aReason: 原因
    func didLeave(_ aGroup: EMGroup!, reason aReason: EMGroupLeaveReason) {
        PrintLog("didLeave")
    }
    
    func didJoin(_ aGroup: EMGroup!, inviter aInviter: String!, message aMessage: String!) {
        let msg = EMMessage(conversationID: aGroup.groupId, from: aInviter, to: aGroup.groupId, body: EMTextMessageBody(text: aInviter + " 邀请你加入群聊"), ext: [:])//EaseSDKHelper.getTextMessage(aInviter + " " + st3, to: aGroup.groupId, messageType: EMChatTypeGroupChat, messageExt: [:])
        msg?.chatType = EMChatTypeGroupChat
        msg?.direction = EMMessageDirectionReceive
        msg?.status = EMMessageStatusSucceed
        msg?.messageId = UUID.init().uuidString
        msg?.isRead = false
        
        let conversation = EMClient.shared()?.chatManager.getConversation(aGroup.groupId, type: EMConversationTypeGroupChat, createIfNotExist: true)
        conversation?.insert(msg, error: nil)
        
        if let _ = tabbarVc, tabbarVc?.hadDidLoad == true {
            tabbarVc?.playSoundAndVibration()
            tabbarVc?.conversationListVC.tableViewDidTriggerHeaderRefresh()
//            messagesDidReceive([msg as Any])
        }
    }
    
    /// 本人所在群组改变时回调
    ///
    /// - Parameter aGroupList: 所有群组list
    func groupListDidUpdate(_ aGroupList: [Any]!) {
        PrintLog("groupListDidUpdate")
        //发出通知刷新页面   如果在群组页面则会重新拉取数据   自己创建群也会在这里通知更新
        NotificationCenter.default.post(name: Notification.Name.Ex.UserGroupListDidUpdate, object: nil)
    }
    
}


//MARK: - EMChatManagerDelegate
extension AppDelegate: EMChatManagerDelegate {
    /// 会话列表发送改变时回调
    ///
    /// - Parameter aConversationList: 所有会话list
    func conversationListDidUpdate(_ aConversationList: [Any]!) {
        guard tabbarVc?.hadDidLoad == true, tabbarVc?.conversationListVC.creatingConversation == false else { return }
        tabbarVc?.setupUnreadMessageCount()
        //会话列表更新，获取数据
        tabbarVc?.conversationListVC.tableViewDidTriggerHeaderRefresh()
    }
    
    //统计是否需要发送通知
    func needShowNotification(fromChatter: String, type: EMChatType) -> Bool {
        switch type {
        case EMChatTypeChat:
            return !SW_IgnoreManager.isIgnoreStaff(fromChatter)
        case EMChatTypeGroupChat:
            var error: EMError? = nil
            if let ignoredGroupIds = EMClient.shared().groupManager.getGroupsWithoutPushNotification(&error) as? [String]  {
                return !ignoredGroupIds.contains(fromChatter)
            }
        default:
            return true
        }
        return true
    }
    
    /// 收到别的的消息时都会回调这里  如果没有会话会调用上面的会话更新方法
    ///
    /// - Parameter aMessages: 收到的消息 一般一次都是一条
    func messagesDidReceive(_ aMessages: [Any]!) {
        let msgs = aMessages as! [EMMessage]
        
        var isRefreshCons = true
        
        for msg in msgs {
            if msg.conversationId == "admin" {//如果是admin则是公告类型的消息  另外保存起来
                PrintLog(msg.ext)
                if let dict = msg.ext as NSDictionary?, let msgTypeId = dict["msgTypeId"] as? Int {
                    SW_DefaultConversations.saveInform(msgTypeId, message: msg)
                }
            } else {
                //正常用户发的消息
                if var dict = msg.ext,
                   let name = dict["REAL_NAME"] as? String,
                   let id = dict["STAFF_ID"] as? Int {//取出拓展消息保存头像
                    dict["ChatUserId"] = msg.from
//                    showAlertMessage("收到拓展消息：REAL_NAME=\(name),STAFF_ID=\(id)", MYWINDOW)
                    PrintLog("收到拓展消息：REAL_NAME=\(name),STAFF_ID=\(id)")
                    UserCacheManager.save(dict)
                } else {
                    var error: EMError? = nil
                    PrintLog("没有收到拓展消息")/// 视频通话通知是没有拓展消息的，删除消息
                    EMClient.shared()?.chatManager.getConversation(msg.conversationId, type: EMConversationTypeChat, createIfNotExist: true)?.deleteMessage(withId: msg.messageId, error: &error)
                    if error != nil {
                        showAlertMessage(error!.debugDescription, MYWINDOW)
                    }
//                        self.tabbarVc?.conversationListVC.tableViewDidTriggerHeaderRefresh()
//                        showAlertMessage("删除了消息--\(error?.errorDescription)", MYWINDOW)
                    return
                }
            }
            
            let state = UIApplication.shared.applicationState
            //判断是否需要通知
            if tabbarVc?.hadDidLoad == true, needShowNotification(fromChatter: msg.conversationId, type: msg.chatType) {
                #if !TARGET_IPHONE_SIMULATOR
                switch state {
                case .active:
                    tabbarVc?.playSoundAndVibration()
                case .inactive:
                    tabbarVc?.playSoundAndVibration()
                case .background:
                    tabbarVc?.showNotificationWithMessage(message: msg)
                }
                #endif
            }
            
            var isChatting = false
            if let chatVC = tabbarVc?.getCurrentChatView() {
                isChatting = chatVC.conversation.conversationId == msg.conversationId
            }
            
            if tabbarVc?.getCurrentChatView() == nil || state == .background || !isChatting {
                //                handleReceivedAtMessage(message: msg)
                if tabbarVc?.hadDidLoad == true {
                    tabbarVc?.conversationListVC.refreshAndSortView()
                    tabbarVc?.setupUnreadMessageCount()
                }
            }
            if isChatting {
                isRefreshCons = false
            }
        }
        
        if isRefreshCons, tabbarVc?.hadDidLoad == true {
            tabbarVc?.setupUnreadMessageCount()
            ///可以对会话列表进行sort一次在更新
            tabbarVc?.conversationListVC.refreshAndSortView()
        }
    }
    
    
}
