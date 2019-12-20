//
//  SW_ChatViewController.swift
//  SWS
//
//  Created by jayway on 2018/5/22.
//  Copyright © 2018年 yuanrui. All rights reserved.
//   聊天界面控制器

import UIKit

class SW_ChatViewController: EaseMessageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setup() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "AddressBook_more"), style: .plain, target: self, action: #selector(chatSettingBtnAction(_:)))

        tableView.backgroundColor = UIColor.white
        ///修改群名称
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadChangeGroupName, object: nil, queue: nil) { [weak self] (notification) in
            let groupNum = notification.userInfo?["groupNum"] as? String ?? ""
            if self?.conversation.conversationId == groupNum {
                let groupName = notification.userInfo?["groupName"] as? String ?? ""
                self?.navigationItem.title = groupName
            }
        }
        
        //// 因为一个navigationcontroller可能存在多个相同的群聊天viewcontroller，所以需要判断navigationcontroller中只有第一个该会话的viewcontroller添加监听即可。
        
        if !isHadSameChatViewController() {
            /// 工作群状态修改 {"groupId":131,"groupNum":"80242616107009","groupState":1}
            NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.GroupStateHadChange, object: nil, queue: nil) { [weak self] (notification) in
                let groupNum = notification.userInfo?["groupNum"] as? String ?? ""
                let groupState = notification.userInfo?["groupState"] as? Int ?? 1
                if self?.conversation.conversationId == groupNum , groupState == 2 {/// 聊天是工作群，被禁用后提示退出
                    SW_UserCenter.shared.showAlert(message: "该工作群已被停用，不能聊天", str: "我知道了", action: { (_) in
                        if let index = self?.navigationController?.viewControllers.firstIndex(where: { return $0 is SW_WorkGroupListViewController }) {
                            self?.navigationController?.popToViewController(self!.navigationController!.viewControllers[index], animated: true)
                        } else {
                            self?.navigationController?.popToRootViewController(animated: true)
                        }
                        
                    })
                }
            }
        }
        
        ///清空聊天记录
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.ChatMessagesHadClear, object: nil, queue: nil) { [weak self] (notification) in
            let conversationId = notification.userInfo?["conversationId"] as? String ?? ""
            let chatType = notification.userInfo?["chatType"] as? EMConversationType ?? EMConversationTypeChat
            if self?.conversation.conversationId == conversationId && self?.conversation.type == chatType {
                self?.dataArray.removeAllObjects()
                self?.messageTimeIntervalTag = -1
                self?.messsagesSource.removeAllObjects()
                self?.tableView.reloadData()
            }
        }
        
        self.delegate = self
        self.dataSource = self
    }

    //MARK: - private method
    /// 聊天设置界面按钮
    ///
    /// - Parameter sender: 右边按钮
    @objc private func chatSettingBtnAction(_ sender: UIBarButtonItem) {
        let vc = SW_ChatInfoAndSettingViewController(conversation.conversationId, chatType: conversation.type)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 判断当前是否有相同的聊天控制器
    ///
    /// - Returns: true 存在
    private func isHadSameChatViewController() -> Bool {
        guard let nav = navigationController else { return false }
        for index in 0..<nav.viewControllers.count - 1 {
            if let vc = nav.viewControllers[index] as? SW_ChatViewController {
                return vc.conversation.conversationId == conversation.conversationId
            }
        }
        return false
    }
    
    deinit {
        PrintLog("deinit")
    }
}

extension SW_ChatViewController: EaseMessageViewControllerDelegate {
    
    func messageViewController(_ viewController: EaseMessageViewController!, didSelectAvatarMessageModel messageModel: IMessageModel!) {
        if !messageModel.nickname.isEmpty, UserCacheManager.getStaffId(messageModel.nickname).intValue != 0 {
            self.navigationController?.pushViewController(SW_StaffInfoViewController(UserCacheManager.getStaffId(messageModel.nickname).intValue), animated: true)
        }
        
        scrollToBottomWhenAppear = false
    }
    
}

extension SW_ChatViewController: EaseMessageViewControllerDataSource {
    /// 消息时间格式化
    ///
    /// - Parameter date: 需要格式化的时间
    /// - Returns: 格式化好后的时间字符串
    func messageViewController(_ viewController: EaseMessageViewController!, stringFor date: Date!) -> String! {
        return date.messageContentTimeString()
    }
    
    func messageViewController(_ viewController: EaseMessageViewController!, canLongPressRowAt indexPath: IndexPath!) -> Bool {
        return true
    }
}
