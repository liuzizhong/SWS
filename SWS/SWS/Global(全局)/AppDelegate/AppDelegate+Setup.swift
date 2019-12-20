//
//  AppDelegate+Setup.swift
//  SWS
//
//  Created by jayway on 2018/8/29.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

// MARK: - APPdelegate 的初始化方法
extension AppDelegate {

    
    //MARK: - 初始化环信
    func setupIM(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        EaseSDKHelper.share().hyphenateApplication(application, didFinishLaunchingWithOptions: launchOptions, appkey: HuanxinAppKey, apnsCertName: ApnsCertName, otherConfig: nil)
    }
    
    //MARK: -根据登录历史判断是否进入登录界面
    func setupRootVc() -> Void {
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        window?.rootViewController = SW_LaunchViewController(nibName: String(describing: SW_LaunchViewController.self), bundle: nil)
        window?.makeKeyAndVisible()
        
        if let dict = AcquireValueFromPerform(USERDATAKEY) as? [String: Any] {//历史储存的数据，换中方式储存
            UserCache?.setObject(dict as NSCoding, forKey: USERDATAKEY)
            RemoveMessageToPerform(USERDATAKEY)
        }
        
        if let dict = UserCache?.object(forKey: USERDATAKEY) as? [String: Any] {//登录着账号 直接去首页
            SW_UserCenter.loginSucceedLater(dict, isShowTip: false, isAutoLogin: true)
        } else {//未登录去登录页面
            SW_NewLoginViewController.changeRootViewToLogin()
        }
        
    }
    
    //打开Bugly崩溃日志
    func prepareBugly() {
        #if DEBUG
        let isDEBUG = true
        #else
        let isDEBUG = false
        #endif
        let config = BuglyConfig()
        config.channel = isDEBUG ? "isDEBUG" : "AppStore"
//        config.viewControllerTrackingEnable = false
        Bugly.start(withAppId: BuglyAPPId, developmentDevice: isDEBUG, config: config)
        let buildVersionString = "\(SWSApiCenter.getSWSVersion())" + "\(isDEBUG ? " Beta" : "")"
        Bugly.setUserValue(buildVersionString, forKey: "Version")
    }
    
    /// 初始化全局网络监听
    func setupReachabilityListener() {
        netManager?.startListening()
        netManager?.listener = { [weak self] (state) in
            self?.dealNetStateChange(state: state)
        }
    }
    
    func dealNetStateChange(state: NetworkReachabilityManager.NetworkReachabilityStatus) {
        switch state{
        case .notReachable:
            if self.networkAlert == nil {
                let alert = UIAlertController.init(title: nil, message: InternationStr("当前网络不可用，请检查网络设置"), preferredStyle: .alert)
                self.networkAlert = alert
                alert.addAction(UIAlertAction(title: "我知道了", style: .default, handler: nil))
                self.getTopVC().present(alert, animated: true, completion: nil)
            }
            PrintLog("the noework is not reachable")
        case .unknown:
            PrintLog("It is unknown whether the network is reachable")
            if netManager?.isReachable == true {
                SWSApiCenter.getAppReviewState()
                self.tryCheckLoginToken()
                self.networkAlert?.dismiss(animated: true, completion: nil)
            }
        case .reachable(.ethernetOrWiFi):
            PrintLog("通过WiFi链接")
            self.tryCheckLoginToken()
            SWSApiCenter.getAppReviewState()
            self.networkAlert?.dismiss(animated: true, completion: nil)
        case .reachable(.wwan):
            PrintLog("通过移动网络链接")
            self.tryCheckLoginToken()
            SWSApiCenter.getAppReviewState()
            self.networkAlert?.dismiss(animated: true, completion: nil)
        }
        /// 网络改变判断是否需要重试
        SW_CustomerAccessingManager.shared.retry()
    }
    
    /// 当有网络时，尝试校验token
    func tryCheckLoginToken() {
        /// 已经进行过check则不再check
        guard !SWSApiCenter.hasCheckLoginToken else { return }
        /// 有user才进行check
        guard let user = SW_UserCenter.shared.user else { return }
        SWSApiCenter.hasCheckLoginToken = true
        // 如果是自动登录 调用 检查token 是否过期
        SWSLoginService.checkLoginToken(user.token, staffId: user.id).response { (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                // token有效  会返回更新用户信息
                if let _ = json.dictionary {
                    SW_UserCenter.shared.user?.updateUserData(json)
                    /// 用户数据发送改变，界面需要刷新，权限可能会改变
                    NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadCheckAndUpdate, object: nil)
                }
//              还要判断环信是否登陆成功，没有要重新登录环信
                SW_UserCenter.loginHuanXin()
            } else {
                //code==1说明token已失效，退出登录
                if let json = json as? JSON, json["code"].intValue == 1 {
                    /// 判断code是否为1，1代表失效，其余情况忽略，
                    SW_UserCenter.logout({
                        SW_UserCenter.shared.showAlert(message: "您的登录已失效，请重新登录！")
                    })
                } else {
                    /// 这里可能是因为网络不好导致的失败，超时等其他情况，可以延时几s后重试
                    SWSApiCenter.hasCheckLoginToken = false
                    dispatch_delay(2, block: {
                        self.tryCheckLoginToken()
                    })
                }
            }
        }
    }
    
    // APP主要渲染设置
    func setupAppearanced() {
        UIButton.appearance().isExclusiveTouch = true
        
        UINavigationBar.appearance().tintColor = UIColor.v2Color.darkGray
        //        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6)
//        UINavigationBar.appearance().backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.v2Color.lightBlack, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        
        UINavigationBar.appearance().setBackgroundImage(UIImage.image(solidColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), size: CGSize(width: 5, height: 64)), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()//UIImage.image(solidColor: #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1), size: CGSize(width: 1, height: 1.0 / UIScreen.main.scale))
       
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.v2Color.lightBlack,NSAttributedString.Key.font: Font(16)], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: Font(16)], for: .highlighted)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.v2Color.disable,NSAttributedString.Key.font: Font(16)], for: .disabled)
        
        UIApplication.shared.keyWindow?.tintColor = UIColor.v2Color.blue
        
        // easeUI 的一些控件样式
        EaseConversationCell.appearance().titleLabelColor = UIColor.v2Color.lightBlack
        EaseConversationCell.appearance().titleLabelFont = MediumFont(16)
        EaseConversationCell.appearance().positionLabelColor = UIColor.v2Color.lightGray
        EaseConversationCell.appearance().positionLabelFont = MediumFont(14)
        
        EaseConversationCell.appearance().detailLabelColor = UIColor.v2Color.lightGray
        EaseConversationCell.appearance().detailLabelFont = Font(14)
        EaseConversationCell.appearance().timeLabelColor = UIColor.v2Color.lightGray
        EaseConversationCell.appearance().timeLabelFont = Font(12)
        
        EaseMessageTimeCell.appearance().titleLabelFont = MediumFont(12)
        EaseMessageTimeCell.appearance().titleLabelColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        
        EaseImageView.appearance().imageCornerRadius = 27
        EaseImageView.appearance().badgeSize = 18
        EaseImageView.appearance().badgeFont = Font(11)
        EaseImageView.appearance().badgeTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        PDTSimpleCalendarViewCell.appearance().textDefaultFont = UIFont.boldSystemFont(ofSize: 16)
        PDTSimpleCalendarViewCell.appearance().textDisabledColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        PDTSimpleCalendarViewCell.appearance().textSelectedColor = UIColor.white
        PDTSimpleCalendarViewCell.appearance().textTodayColor = UIColor.white
        PDTSimpleCalendarViewCell.appearance().circleSelectedColor = UIColor.v2Color.blue
        PDTSimpleCalendarViewCell.appearance().circleTodayColor = UIColor.clear
        
        PDTSimpleCalendarViewWeekdayHeader.appearance().textColor = UIColor.v2Color.lightBlack
        PDTSimpleCalendarViewWeekdayHeader.appearance().textFont = Font(16)
        
        PDTSimpleCalendarViewWeekdayHeader.appearance().headerBackgroundColor = UIColor.white
        
        PDTSimpleCalendarViewHeader.appearance().separatorColor = UIColor.clear
        PDTSimpleCalendarViewHeader.appearance().textColor = UIColor.v2Color.lightGray
        
        PDTSimpleCalendarViewHeader.appearance().textFont = UIFont.boldSystemFont(ofSize: 16)
        
    }
}
