//
//  AppDelegate+PushService.swift
//  SWS
//
//  Created by jayway on 2018/8/29.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Foundation
import UserNotifications
import CloudPushSDK

///消息通知推送代理
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func setupCloudPushSDK(_ launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        #if DEBUG
        CloudPushSDK.turnOnDebug()//打开调试信息
        #endif
        CloudPushSDK.autoInit { (result) in
            if let result = result {
                if (result.success) {
                    print("Push SDK init success, deviceId: \(CloudPushSDK.getDeviceId()!)")
                } else {
                    print("Push SDK init failed, error: \(result.error!).")
                }
            }
        }
        listenOnChannelOpened()
        registerMessageReceive()
        CloudPushSDK.sendNotificationAck(launchOptions)
    }
    
    // 监听推送通道是否打开
    func listenOnChannelOpened() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(channelOpenedFunc(notification:)),
                                               name: Notification.Name("CCPDidChannelConnectedSuccess"),
                                               object: nil)
        
    }
    
    @objc func channelOpenedFunc(notification: Notification) {
        print("Push SDK channel opened.")
    }
    
    // 注册消息到来监听
    func registerMessageReceive() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        } else {
            // Fallback on earlier versions
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onMessageReceivedFunc(notification:)),
                                               name: Notification.Name("CCPDidReceiveMessageNotification"),
                                               object: nil)
    }
    
    // 处理推送消息
    @objc func onMessageReceivedFunc(notification : Notification) {
        print("Receive one message.")
        let pushMessage: CCPSysMessage = notification.object as! CCPSysMessage
        let title = String.init(data: pushMessage.title, encoding: String.Encoding.utf8)
        if let body = String.init(data: pushMessage.body, encoding: String.Encoding.utf8) {
            dispatch_async_main_safe {
                let bodyJson = JSON(parseJSON: body)
                let bodyData = bodyJson["data"]
                switch bodyJson["type"].intValue {
                case 1:///工作群禁用启用
                    NotificationCenter.default.post(name:  NSNotification.Name.Ex.GroupStateHadChange, object: nil, userInfo: ["groupNum": bodyData["groupNum"].stringValue, "groupState": bodyData["groupState"].intValue])
                case 2:///销售接待被后台结束
                    NotificationCenter.default.post(name:  NSNotification.Name.Ex.SalesReceptionHadBeenEnd, object: nil, userInfo: ["recordId": bodyData["accessCustomerRecordId"].stringValue, "customerId": bodyData["customerId"].stringValue, "lastAccessDate": bodyData["lastAccessDate"].doubleValue])
                    SW_CustomerAccessingManager.shared.getAccessingList()
                case 3:///销售接待  后台开始新接待会自动开始接待
                    /// 新建客户成功  列表页面需要刷新
                    NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadCreateCustomer, object: nil)
                    SW_CustomerAccessingManager.shared.getAccessingList()
                default:
                    break
                }
            }
            print("Message title: \(title!), body: \(body).")
        }
        
    }
    
    
    // 将得到的deviceToken传给SDK
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Get deviceToken from APNs success.")
        CloudPushSDK.registerDevice(deviceToken) { (res) in
            if (res?.success == true) {
                print("Upload deviceToken to Push Server, deviceToken: \(CloudPushSDK.getApnsDeviceToken()!)")
            } else {
                print("Upload deviceToken to Push Server failed, error: \(String(describing: res?.error))")
            }
        }
        
        EMClient.shared().bindDeviceToken(deviceToken)
    }
    
    // 注册deviceToken失败
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        PrintLog(error)
        print("Get deviceToken from APNs failed, error: \(error).")
    }
    
    ///    didReceiveRemoteNotification
    /// App处于启动状态时，通知打开回调（< iOS 10）
    //TODO: 前台也会在这里收到通知  前后台都会进入这里 《 ios10
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("Receive one notification.")
        let aps = userInfo["aps"] as! [AnyHashable : Any]
        let alert = aps["alert"] ?? "none"
        let badge = aps["badge"] ?? 0
        let sound = aps["sound"] ?? "none"
        let extras = userInfo["Extras"]
        // 设置角标数为0
        application.applicationIconBadgeNumber = 0
        // 同步角标数到服务端
        // self.syncBadgeNum(0)
        CloudPushSDK.sendNotificationAck(userInfo)
        print("Notification, alert: \(alert), badge: \(badge), sound: \(sound), extras: \(String(describing: extras)).")
        
//        if let _ = tabbarVc {
//            tabbarVc?.jumpToChatList()
//        }
        EaseSDKHelper.share().hyphenateApplication(application, didReceiveRemoteNotification: userInfo)
        
        completionHandler(.noData)
    }
    
    
    /// 后台点击通知进入APP 触发通知动作时回调，比如点击、删除通知和点击自定义action（< iOS 10）
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        if let _ = tabbarVc {
            tabbarVc?.didReceiveLocalNotification(notification: notification)
        }
    }
    
    // 处理iOS 10通知(iOS 10+)
    @available(iOS 10.0, *)
    func handleiOS10Notification(_ notification: UNNotification) {
        let content: UNNotificationContent = notification.request.content
        let userInfo = content.userInfo
        // 通知时间
        let noticeDate = notification.date
        // 标题
        let title = content.title
        // 副标题
        let subtitle = content.subtitle
        // 内容
        let body = content.body
        // 角标
        let badge = content.badge ?? 0
        // 取得通知自定义字段内容，例：获取key为"Extras"的内容
        let extras = userInfo["Extras"]
        // 设置角标数为0
        UIApplication.shared.applicationIconBadgeNumber = 0
        // 同步角标数到服务端
        // self.syncBadgeNum(0)
        // 通知打开回执上报
        CloudPushSDK.sendNotificationAck(userInfo)
        
        print("Notification, date: \(noticeDate), title: \(title), subtitle: \(subtitle), body: \(body), badge: \(badge), extras: \(String(describing: extras)).")
    }
    
    // App处于前台时收到通知(iOS 10+)
    // 前台时 环信不会发送通知，使用的是长连接； 移动推送会发通知，可以做处理
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("Receive a notification in foreground.")
        handleiOS10Notification(notification)
        // 通知不弹出
//        completionHandler([])
        // 通知弹出，且带有声音、内容和角标
        completionHandler([.alert, .badge, .sound])
        
        EaseSDKHelper.share().hyphenateApplication(UIApplication.shared, didReceiveRemoteNotification: notification.request.content.userInfo)
    }
    
    // 触发通知动作时回调，比如点击、删除通知和点击自定义action(iOS 10+)
    // 环信与移动推送都会进入这个回调，需要区分处理
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userAction = response.actionIdentifier
        if userAction == UNNotificationDefaultActionIdentifier {
            print("User opened the notification.")
            // 处理iOS 10通知，并上报通知打开回执
            handleiOS10Notification(response.notification)
        }
        
//        if userAction == UNNotificationDismissActionIdentifier {
//            print("User dismissed the notification.")
//        }
        
//        if let _ = tabbarVc {///判断点击的是否是环信消息，是才调用
//            tabbarVc?.didReceiveUserNotification(notification: response.notification)
//        }
        completionHandler()
    }
    
}
