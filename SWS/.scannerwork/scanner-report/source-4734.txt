
//
//  AppDelegate.swift
//  SWS
//
//  Created by jayway on 2017/12/23.
//  Copyright © 2017年 yuanrui. All rights reserved.
//

import UIKit
import UserNotifications
import CloudPushSDK

/// 全局网络监听管理
let netManager = NetworkReachabilityManager()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    weak var tabbarVc: SW_TabBarController?
    
    var window: UIWindow?
    
    /// 用于网络不可用时的d提示
    weak var networkAlert: UIAlertController? = nil
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ///启动request
        SWSRequest.prepareRequest()
        prepareBugly()
        ///初始化环信
        setupIM(application, didFinishLaunchingWithOptions: launchOptions)
        ///初始化移动推送
        setupCloudPushSDK(launchOptions)
        ///APP默认渲染样式
        setupAppearanced()
        ///初始化根控制器 根据登录历史判断是否进入登录界面
        setupRootVc()
        ///初始化网络全局监听
        setupReachabilityListener()
        ///开启禁止全局事件同时点击
        UIView.appearance().isExclusiveTouch = true
        ///开启全局按钮防快速点击，默认时间差0.5s  - 需要优化才可以用，目前不完善有bug
//        UIButton.enableInsensitiveTouch()
        ///初始化环信delegate 全局监听
        setUpChatDelegate()
        AMapServices.shared()?.apiKey = "6e5c114d206fb7f9c8619d10918f9046"
        return true
    }
    
    //MARK: -生命周期方法
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .allButUpsideDown
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//        EMClient.shared().applicationDidEnterBackground(application)
        UIImage.nameImages.removeAll()
        netManager?.stopListening()
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//        EMClient.shared().applicationWillEnterForeground(application)
        netManager?.startListening()
        dealNetStateChange(state: netManager?.networkReachabilityStatus ?? .unknown)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if let _ = tabbarVc {
            tabbarVc?.setupUnreadMessageCount()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        Bugly.report(NSException(name: NSExceptionName("applicationWillTerminate"), reason: "applicationWillTerminate", userInfo: [:]))
        
    }
    
    
}
