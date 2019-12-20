//
//  SW_TabBarController.swift
//  SWS
//
//  Created by jayway on 2017/12/23.
//  Copyright © 2017年 yuanrui. All rights reserved.
//  [自定义tabBarController] -> [SWS]

import UIKit
import UserNotifications

@objc class SW_TabBarController: UITabBarController {
    
    ///上次提示的时间
    private var lastPlaySoundDate: Date?
    
    //两次提示的默认间隔
    static let kDefaultPlaySoundInterval:TimeInterval = 4
    
    var tabBarView = SW_TabBarView()              //底部的tabBar
    private var titles = [InternationStr("消息"), InternationStr("通讯录"),InternationStr("统计") ,InternationStr("工作"), InternationStr("我的")]    //底部标题数组
    private var images = [#imageLiteral(resourceName: "TabBar_Message"), #imageLiteral(resourceName: "TabBar_AddressBook"), #imageLiteral(resourceName: "TabBar_statistical"), #imageLiteral(resourceName: "TabBar_Working"), #imageLiteral(resourceName: "TabBar_Mine")]                //底部图片数组
    private var selectImage = [#imageLiteral(resourceName: "TabBar_Message_Selected"), #imageLiteral(resourceName: "TabBar_AddressBook_Selected"), #imageLiteral(resourceName: "TabBar_statistical_Selected"), #imageLiteral(resourceName: "TabBar_Working_Selected"), #imageLiteral(resourceName: "TabBar_Mine_Selected")]           //底部选中图片数组
    private var childVcs: [UIViewController]?            //子控制器数组
    private var tabbarButtons = [SW_TabBarButton]()      //底部tabBar按钮
    
    var conversationListVC: SW_MessageViewController!
    
    var hadDidLoad = false
    private var hadAddObserver = false
    
    private var workIndex = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置属性
        setupAttribute()
        //创建子控件
        creatChildView()
        hadDidLoad = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hadAddObserver {
            hadAddObserver = true
            NotificationCenter.default.addObserver(forName: Notification.Name.Ex.HadGetAppStoreVersion, object: nil, queue: nil) { (notifa) in
                SWSApiCenter.checkShouldUpdateTipAlert()
            }
        }
        SW_PrivacyPolicyViewController.checkAgreedPrivacyPolicyAndShow(self.selectedViewController ?? self)
        SWSApiCenter.checkShouldUpdateTipAlert()
        if let nav = selectedViewController as? SW_NavViewController, let visibleVc = nav.visibleViewController {
            showAndHideTabBar(!visibleVc.isHideTabBar, animated: animated)
        }
    }
    
    //MARK: -设置属性，创建子控件
    func setupAttribute() -> Void {
        tabBar.isHidden = true  //隐藏系统自带的TabBar
        
        conversationListVC = SW_MessageViewController()
//        if SW_UserCenter.shared.user!.auth.statisticsAuth.count > 0 {
//            childVcs = [SW_NavViewController.init(rootViewController: conversationListVC), SW_NavViewController.init(rootViewController: SW_AddressBookHomeViewController()), SW_NavViewController.init(rootViewController: SW_StatisticalMainViewController()), SW_NavViewController.init(rootViewController: SW_WorkingViewController ()), SW_NavViewController.init(rootViewController: SW_MineViewController())]
//        } else {
            childVcs = [SW_NavViewController.init(rootViewController: conversationListVC), SW_NavViewController.init(rootViewController: SW_AddressBookHomeViewController()), SW_NavViewController.init(rootViewController: SW_WorkingViewController ()), SW_NavViewController.init(rootViewController: SW_MineViewController())]
            workIndex = 2
            titles.remove(at: 2)
            images.remove(at: 2)
            selectImage.remove(at: 2)
//        }
    }
    
    //MARK: -创建子控件
    func creatChildView() -> Void {
        //初始化子定义tabBar
        view.addSubview(tabBarView)
        tabBarView.snp.makeConstraints { (make) -> Void in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(0)
            make.height.equalTo(TABBAR_HEIGHT + TABBAR_BOTTOM_INTERVAL)
        }
        
        guard let childVcs = childVcs else { return }
        for index in 0..<titles.count {
            creatChildVc(childVcs[index], index)
        }
        
        (UIApplication.shared.delegate as? AppDelegate)?.tabbarVc = self
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] (notifi) in
            if let nav = self?.selectedViewController as? SW_NavViewController, let visibleVc = nav.visibleViewController {
                if visibleVc is UIAlertController {/// 如果是alertcontroller则忽略
                    return
                }
                self?.showAndHideTabBar(!visibleVc.isHideTabBar, animated: false)
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.RedDotNotice, object: nil, queue: nil) {  [weak self]  (notifi) in
            self?.tabbarButtons[self?.workIndex ?? 3].badgeView(state: SW_BadgeManager.shared.workBadge.workModule)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.SetupUnreadMessageCount, object: nil, queue: nil) { [weak self] (notifi) in
            self?.setupUnreadMessageCount()
        }
        /// 环信登录成功
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.HuanXinHadLogin, object: nil, queue: nil) { [weak self] (notifi) in
            self?.setupUnreadMessageCount()
            self?.conversationListVC.tableViewDidTriggerHeaderRefresh()
        }
        //登录成功后设置推送显示样式
        EMClient.shared().pushOptions.displayStyle = EMPushDisplayStyleMessageSummary
        EMClient.shared().updatePushNotificationOptionsToServer(completion: nil)
        EMClient.shared().setApnsNickname(SW_UserCenter.shared.user!.realName + "(\(SW_UserCenter.shared.user!.position))")
        
        ///设置消息按钮红点位置
        let offSetX = -(SCREEN_WIDTH - CGFloat(tabbarButtons.count * 30)) / CGFloat(tabbarButtons.count * 2)
        tabbarButtons.forEach { (button) in
            button.ac_badgeMaximumNumber = 99
            button.badgeOffset = CGPoint(x: offSetX,y: 10)
        }
        //启动时计算一次未读数
        setupUnreadMessageCount()
        
        DemoCallManager.shared().mainController = self
        /// 开启定时器，定时获取红点通知状态，
        SW_BadgeManager.shared.run()
        ///  方法先获取一次接待列表，如果有接待列表则开启定时器，通知刷新页面，否则不开启定时器
        SW_CustomerAccessingManager.shared.tabBarVc = self
        SW_CustomerAccessingManager.shared.getAccessingList()
        
    }
    
    deinit {
        SW_BadgeManager.shared.stop()
        DemoCallManager.shared().mainController = nil
        SW_CustomerAccessingManager.shared.destroy()
        (UIApplication.shared.delegate as? AppDelegate)?.tabbarVc = nil
        NotificationCenter.default.removeObserver(self)
        PrintLog("deinit")
    }

    //MARK: -创建子控制器方法
    func creatChildVc(_ childVc: UIViewController, _ index: Int) -> Void {
        //2.添加子控制器
        addChild(childVc)
        let tabbarButton = SW_TabBarButton()
        tabBarView.tabBar.addSubview(tabbarButton)
        tabbarButton.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(CGFloat(index) * SCREEN_WIDTH / CGFloat(titles.count))
            make.width.equalTo(SCREEN_WIDTH / CGFloat(titles.count))
            make.bottom.equalToSuperview().offset(-TABBAR_BOTTOM_INTERVAL)
        }
        tabbarButton.tag = index
        tabbarButton.addTarget(self, action: #selector(cutCurrentVc(_:)), for: .touchDown)
        tabbarButton.setTitle(titles[index], for: UIControl.State())

        tabbarButton.setImage(images[index], for: UIControl.State())
        tabbarButton.setImage(selectImage[index], for: .selected)
        tabbarButton.setImage(selectImage[index], for: .highlighted)
        tabbarButton.isSelected = index == 0
        tabbarButtons.append(tabbarButton)
    }
    
    //点击按钮事件
    @objc func cutCurrentVc(_ button: UIButton) -> Void {
        guard let childVcs = childVcs else { return }
        selectedViewController = childVcs[button.tag]
        for tabBarButton in tabbarButtons {
            tabBarButton.isSelected = false
        }
        tabbarButtons[button.tag].isSelected = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //控制屏幕旋转
    override var shouldAutorotate: Bool {
        return self.selectedViewController?.shouldAutorotate ?? false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.selectedViewController?.supportedInterfaceOrientations ?? .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return self.selectedViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
    
}

// MARK: - 隐藏，显示tabbarview动画效果
extension SW_TabBarController {
    
    /// 隐藏或者显示tabbar
    ///
    /// - Parameters:
    ///   - show: 是否显示tabbar  false隐藏
    ///   - animated:  是否添加动画i效果
    func showAndHideTabBar(_ show: Bool, animated: Bool = true, duration: TimeInterval = TabbarAnimationDuration) {
        let transform = show ? CGAffineTransform.identity : CGAffineTransform(translationX: 0, y: tabBarView.height)
        
        if animated {
            UIView.animate(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {
                self.tabBarView.transform = transform
            }, completion: nil)
        } else {
            tabBarView.transform = transform
        }
    }
    
    /// 显示接待悬浮条
    func showAccessListView() {
        if let nav = selectedViewController as? SW_NavViewController, nav.visibleViewController?.isHideTabBar == true {/// 如果页面是隐藏tabbar的
            tabBarView.transform = CGAffineTransform(translationX: 0, y: SHOWACCESS_TABBAR_HEIGHT + TABBAR_BOTTOM_INTERVAL)
            tabBarView.snp.removeConstraints()
            tabBarView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().offset(0)
                make.height.equalTo(SHOWACCESS_TABBAR_HEIGHT + TABBAR_BOTTOM_INTERVAL)
            }
        } else {
            tabBarView.transform = CGAffineTransform.identity
            tabBarView.snp.removeConstraints()
            tabBarView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().offset(0)
                make.height.equalTo(SHOWACCESS_TABBAR_HEIGHT + TABBAR_BOTTOM_INTERVAL)
            }
        }
        
        
        tabBarView.accessingListView.accessingList = SW_CustomerAccessingManager.shared.accessingList
        tabBarView.showAccessListView()
    }
    
    /// 隐藏接待悬浮条
    func hideAccessListView() {
        tabBarView.snp.removeConstraints()
        tabBarView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(0)
            make.height.equalTo(TABBAR_HEIGHT + TABBAR_BOTTOM_INTERVAL)
        }
        
        tabBarView.accessingListView.accessingList = SW_CustomerAccessingManager.shared.accessingList
        tabBarView.hideAccessListView()
    }
    
}

extension SW_TabBarController: DemoCallManagerDelegate {
    func getTopViewController() -> UIViewController! {
        return self.selectedViewController
    }
    
    func getCurrentNaVController() -> UINavigationController! {
        return self.selectedViewController?.navigationController
    }
}

//MARK: - Notification
extension SW_TabBarController {
    
    //// 统计未读消息数
    func setupUnreadMessageCount() {
        guard SW_UserCenter.shared.user?.huanxin.huanxinAccount.isEmpty == false else {
            var unreadCount:Int = 0
            unreadCount += SW_DefaultConversations.getAllInformUnreadCount()
            /// 用户有待办事项权限，计入未读数
            if let user = SW_UserCenter.shared.user, user.auth.backLogAuth.count > 0 {
                unreadCount += SW_BadgeManager.shared.backLogModel.totalCount
            }
            
            tabbarButtons[0].badgeValue(number: unreadCount)
            UIApplication.shared.applicationIconBadgeNumber = unreadCount
            return
        }
        guard let conversations = EMClient.shared().chatManager.getAllConversations() as? [EMConversation] else { return }
        var unreadCount:Int = 0
        for conversation in conversations {
            if conversation.conversationId != "admin" {
                unreadCount += Int(conversation.unreadMessagesCount)
            }
        }
        unreadCount += SW_DefaultConversations.getAllInformUnreadCount()
        /// 用户有待办事项权限，计入未读数
        if let user = SW_UserCenter.shared.user, user.auth.backLogAuth.count > 0 {
            unreadCount += SW_BadgeManager.shared.backLogModel.totalCount
        }
        
        tabbarButtons[0].badgeValue(number: unreadCount)
        
        UIApplication.shared.applicationIconBadgeNumber = unreadCount
    }
    
    ///播放声音  计算时间间隔
    func playSoundAndVibration() {
        if let lastPlaySoundDate = lastPlaySoundDate {
            let timeInterval = Date().timeIntervalSince(lastPlaySoundDate)
            if timeInterval < SW_TabBarController.kDefaultPlaySoundInterval {
                //如果距离上次响铃和震动时间太短, 则跳过响铃
                PrintLog("skip ringing & vibration\(timeInterval)")
                return
            }
        }
        
        //保存最后一次响铃时间
        lastPlaySoundDate = Date()
        
        // 收到消息时，播放音频
        if !UserDefaults.standard.bool(forKey: "UnPlayMsgVoice") {
            EMCDDeviceManager.sharedInstance().playNewMessageSound()
        }
        
        // 收到消息时，震动
        if !UserDefaults.standard.bool(forKey: "UnPlayVibration") {
            EMCDDeviceManager.sharedInstance().playVibration()
        }
    }
    
    func handleReceivedAtMessage(message: EMMessage) {
        //    - (void)_handleReceivedAtMessage:(EMMessage*)aMessage
        //    {
        //    if (aMessage.chatType != EMChatTypeGroupChat || aMessage.direction != EMMessageDirectionReceive) {
        //    return;
        //    }
        //
        //    NSString *loginUser = [EMClient sharedClient].currentUsername;
        //    NSDictionary *ext = aMessage.ext;
        //    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:aMessage.conversationId type:EMConversationTypeGroupChat createIfNotExist:NO];
        //    if (loginUser && conversation && ext && [ext objectForKey:kGroupMessageAtList]) {
        //    id target = [ext objectForKey:kGroupMessageAtList];
        //    if ([target isKindOfClass:[NSString class]] && [(NSString*)target compare:kGroupMessageAtAll options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        //    NSNumber *atAll = conversation.ext[kHaveUnreadAtMessage];
        //    if ([atAll intValue] != kAtAllMessage) {
        //    NSMutableDictionary *conversationExt = conversation.ext ? [conversation.ext mutableCopy] : [NSMutableDictionary dictionary];
        //    [conversationExt removeObjectForKey:kHaveUnreadAtMessage];
        //    [conversationExt setObject:@kAtAllMessage forKey:kHaveUnreadAtMessage];
        //    conversation.ext = conversationExt;
        //    }
        //    }
        //    else if ([target isKindOfClass:[NSArray class]]) {
        //    if ([target containsObject:loginUser]) {
        //    if (conversation.ext[kHaveUnreadAtMessage] == nil) {
        //    NSMutableDictionary *conversationExt = conversation.ext ? [conversation.ext mutableCopy] : [NSMutableDictionary dictionary];
        //    [conversationExt setObject:@kAtYouMessage forKey:kHaveUnreadAtMessage];
        //    conversation.ext = conversationExt;
        //    }
        //    }
        //    }
        //    }
        //    }
    }
    
    ///根据消息显示通知
    func showNotificationWithMessage(message: EMMessage) {
        let options = EMClient.shared().pushOptions
        if options?.noDisturbStatus == EMPushNoDisturbStatusDay {
            ///开启免打扰
            return
        }
        
        var alertBody: String = ""
        var title = UserCacheManager.getNickName(message.from) ?? (message.from ?? "")
        var messageStr: String = ""
        if options?.displayStyle == EMPushDisplayStyleMessageSummary {
            
            if message.conversationId == "admin" {//如果是admin则是公告类型的消息  另外保存起来
                title = "管理员"
                messageStr = message.ext["title"] as? String ?? ""
            } else {
                //正常用户发的消息
                let messageBody = message.body
                switch (messageBody?.type) {
                case EMMessageBodyTypeText:
                    let didReceiveText = EaseConvertToCommonEmoticonsHelper.convert(toSystemEmoticons: (messageBody as! EMTextMessageBody).text)
                    messageStr = didReceiveText ?? ""
                case EMMessageBodyTypeImage:
                    messageStr = "[图片]"
                case EMMessageBodyTypeLocation:
                    messageStr = "[位置]"
                case EMMessageBodyTypeVoice:
                    messageStr = "[语音]"
                case EMMessageBodyTypeVideo:
                    messageStr = "[视频]"
                default:
                    break
                }
                
                if (message.chatType == EMChatTypeGroupChat) {
                    if let groupArray = EMClient.shared().groupManager.getJoinedGroups() as? [EMGroup] {
                        for group in groupArray {
                            if message.conversationId == group.groupId {
                                title = "\(group.subject ?? "工作群")"
                                break
                            }
                        }
                    }
                }
            }
            alertBody = "\(String(describing: title)):\(messageStr)"
        } else {
            alertBody = "您有一条新消息"//NSLocalizedString(@"receiveMessage", @"you have a new message")
        }
        var playSound = false
        if let lastPlaySoundDate = lastPlaySoundDate {
            let timeInterval = Date().timeIntervalSince(lastPlaySoundDate)
            if timeInterval >= SW_TabBarController.kDefaultPlaySoundInterval {
                playSound = true
                self.lastPlaySoundDate = Date()
            }
        } else {
            playSound = true
            lastPlaySoundDate = Date()
        }
        
        var userInfo = [String:Any]()
        userInfo["MessageType"] = message.chatType.rawValue
        userInfo["ConversationChatter"] = message.conversationId
        userInfo["messageTitle"] = title
        
        //发送本地推送
        if (NSClassFromString("UNUserNotificationCenter") != nil) {
            if #available(iOS 10.0, *) {
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
                
                let content = UNMutableNotificationContent()
                if playSound {
                    content.sound = UNNotificationSound.default
                }
                content.body = alertBody
                content.userInfo = userInfo
                let request = UNNotificationRequest(identifier: message.messageId, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                
            } else {
                // Fallback on earlier versions
            }
        } else {
            let notification = UILocalNotification()
            notification.fireDate = Date()
            notification.alertBody = alertBody
            notification.alertAction = "打开"
            notification.timeZone = NSTimeZone.default
            if playSound {
                notification.soundName = UILocalNotificationDefaultSoundName
            }
            notification.userInfo = userInfo
            //发送通知
            UIApplication.shared.scheduleLocalNotification(notification)
            
        }
    }
    
    ///获取当前聊天界面
    func getCurrentChatView() -> SW_ChatViewController? {
        guard let nav = selectedViewController as? SW_NavViewController else { return nil }
        var chatViewContrller: SW_ChatViewController? = nil
        for vc in nav.viewControllers {
            if let vc = vc as? SW_ChatViewController {
                chatViewContrller = vc
            }
        }
        return chatViewContrller
    }
    
    ///跳转至聊天界面
    func jumpToChatList() {
        guard let nav = selectedViewController as? SW_NavViewController else { return }
        if nav.topViewController is SW_ChatViewController {
        } else {
            nav.popToRootViewController(animated: false)
            cutCurrentVc(tabbarButtons[0])
            showAndHideTabBar(true)
        }
    }
    
    //点击本地通知打开APP  后台点击通知进入APP 触发通知动作时回调，比如点击、删除通知和点击自定义action（< iOS 10）
    func didReceiveLocalNotification(notification: UILocalNotification) {
        guard let nav = selectedViewController as? SW_NavViewController else { return }
        
        nav.popToRootViewController(animated: false)
        cutCurrentVc(tabbarButtons[0])
        showAndHideTabBar(true)
        return
    }
    
    //点击本地通知打开APP 触发通知动作时回调，比如点击、删除通知和点击自定义action(iOS 10+)
    @available(iOS 10.0, *)
    func didReceiveUserNotification(notification: UNNotification) {
        guard let nav = selectedViewController as? SW_NavViewController else { return }
        
        nav.popToRootViewController(animated: false)
        cutCurrentVc(tabbarButtons[0])
        showAndHideTabBar(true)
        return
        
    }
    
}







