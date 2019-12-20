//
//  SW_UserCenter.swift
//  SWS
//
//  Created by jayway on 2018/4/4.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_UserCenter: NSObject {
    
    static let shared = SW_UserCenter()
    
    var user: UserModel? 
    /// 判断是否登录成功环信
    var isLoginHuanXin = false
    /// 判断是否登录环信中
    var huanxinIsLogining = false
    
    private override init() {
        super.init()
        EMClient.shared().add(self, delegateQueue: nil)
    }
    
    /// 退出登录界面  清除用户信息
    ///
    /// - Parameter completion: 退出界面完成后进行回调
    class func logout(_ completion: NormalBlock?) {
        guard shared.user != nil else { return }
        
        // token有效  去更新用户信息
        shared.user = nil
        shared.isLoginHuanXin = false
        shared.huanxinIsLogining = false
        UserCache?.removeObject(forKey: USERDATAKEY)
        //退出环信  true会解除设备的绑定  也可能会失败
//        EMClient.shared().logout(true)
        EMClient.shared()?.logout(true, completion: { (error) in
            if error != nil {/// 退出登录失败重试一次
                EMClient.shared()?.logout(true, completion: nil)
            }
        })
        UIApplication.shared.applicationIconBadgeNumber = 0
        //退出到登录界面
        SW_NewLoginViewController.changeRootViewToLogin()
        
        completion?()
    }
    
    //MARK: -登录成功后调用方法
    class func loginSucceedLater(_ dict: [String: Any], isShowTip: Bool = true, isAutoLogin: Bool = false) -> Void {
        //将用户信息保存本地      isFirstLogin  会缓存  会导致每次重启都使用了这个缓存值进入修改页面。   成功修改密码后需要将这个dict的值变为1
        if !isAutoLogin {
            UserCache?.setObject(dict.changeNull() as NSCoding, forKey: USERDATAKEY)
        }
        ///登录环信
        dispatch_async_main_safe {
            //生成用户模型
             shared.user = UserModel(jsonDict: dict)
            
            //更新自己的头像
            UserCacheManager.save(shared.user!.huanxin.huanxinAccount, staffId: NSNumber(value: shared.user!.id), avatarUrl: shared.user!.portrait, nickName: shared.user!.realName + "(\(shared.user!.position))")
            
//            if isAutoLogin {
//                // 如果是自动登录 调用 检查token 是否过期
//                SWSLoginService.checkLoginToken(shared.user!.token, staffId: shared.user!.id).response { (json, isCache, error) in
//                    if let json = json as? JSON, error == nil {
//                        // token有效  会返回更新用户信息
//                        if let _ = json.dictionary {
//                            shared.user?.updateUserData(json)
//                        }
//                        goToRootView()
//                    } else {//token失效  退出登录
//                        logout({
//                            shared.showAlert(message: "您的登录已失效，请重新登录！")
//                        })
//                    }
//                }
//                goToRootView()
//            } else {
                /// 离线直接登陆，后面再checktoken
                goToRootView()
//            }
        }
    }
    
    /// 异步登录环信账号
    class func loginHuanXin() {
        guard let user = shared.user,
            !shared.isLoginHuanXin,
            !shared.huanxinIsLogining else { return }
        shared.huanxinIsLogining = true
        /// 如果环信账号为空，调用后台创建环信账号接口，再登录
        /// 创建的环信账号默认密码:HX123456
        if user.huanxin.huanxinAccount.isEmpty {
            SWSLoginService.registerHxUser(user.id).response({ (json, isCache, error) in
                shared.huanxinIsLogining = false
                if let json = json as? JSON, error == nil {
                    shared.user?.huanxin.huanxinAccount = json.arrayValue.first?["username"].stringValue ?? ""
                    shared.user?.huanxin.huanxinPwd = json.arrayValue.first?["password"].stringValue ?? ""
                    shared.user?.updateUserDataToCache()
                    if shared.user?.huanxin.huanxinAccount != "" {
                        loginHuanXin()
                    }
                }
            })
            return
        }

        EMClient.shared().options.isAutoLogin = false
        if !EMClient.shared().options.isAutoLogin {
            //这里使用异步登录   同步登录可能导致启动时长边长
            EMClient.shared()?.login(withUsername: user.huanxin.huanxinAccount, password: user.huanxin.huanxinPwd, completion: { (msg, error) in
                shared.huanxinIsLogining = false
                if error == nil {
//                    EMClient.shared().options.isAutoLogin = false

                    ///环信登录成功
                    shared.isLoginHuanXin = true
                    /// 登录成功后，通知刷新界面。
                    NotificationCenter.default.post(name: NSNotification.Name.Ex.HuanXinHadLogin, object: nil)
                } else {
                    shared.isLoginHuanXin = false
                }
            })
        }
    }

    /// 前往对应的页面，修改密码或者首页
    private class func goToRootView() {
        /// 异步登录环信，登录成功后发出通知。
        loginHuanXin()
        //绑定设备id
        saveDeviceId()
        /// 设置Bugly用户ID
        Bugly.setUserIdentifier("\(shared.user!.id)")
        //进入首页  需要判断是否第一次登陆。如果是则去修改密码，然后再去首页
        if shared.user?.isFirstLogin == false {
            MYWINDOW?.change(rootViewController: SW_TabBarController())
        } else {
            MYWINDOW?.change(rootViewController: SW_NavViewController(rootViewController: SW_ChangePwdViewController.creat("", staffId: shared.user?.id ?? 0, type: .first)))//去修改密码
        }
    }
    
    /// 绑定移动推送设备id，用于第三方推送，跟用户关联
    class func saveDeviceId() {
        SWSLoginService.saveDeviceId().response({ (json, isCache, error) in
            if let _ = json as? JSON, error == nil {
                PrintLog("successs")
            } else {
                dispatch_delay(5, block: {
                    guard let _ = SW_UserCenter.shared.user else { return }
                    saveDeviceId()
                })
            }
        })
    }
    
    class func updateUserInfo() {
        if let user = shared.user {
            SWSLoginService.getUserInfo(user.id).response { (json, isCache, error) in
                if let json = json as? JSON, error == nil {//
                    // token有效  去更新用户信息
                    shared.user?.updateUserData(json)
                }
            }
        }
    }
    
    class func getUserCachePath() -> String {
        if let user = shared.user {
            return "\(SWSApiCenter.isTestEnvironment)\(user.id)"
        }
        return ""
    }
}

extension SW_UserCenter: EMClientDelegate {
   
    func connectionStateDidChange(_ aConnectionState: EMConnectionState) {
        switch aConnectionState {
        case EMConnectionDisconnected:
            PrintLog("环信失去连接")
//            showAlertMessage("环信失去连接",  MYWINDOW)
        case EMConnectionConnected:
            PrintLog("环信连接成功")
//            showAlertMessage("环信连接成功",  MYWINDOW)
        default:
            PrintLog("未知状态")
//            showAlertMessage("环信连接未知状态",  MYWINDOW)
        }
    }
    
    func userAccountDidLoginFromOtherDevice() {
        SWSLoginService.delLoginToken(SW_UserCenter.shared.user?.token ?? "").response { (json, isCache, error) in
        }
        SW_UserCenter.logout({
            self.showAlert(message: "您的账号已在其他设备登录，请重新登录！如果非本人登录，建议修改密码")
        })
    }
    
    func userAccountDidRemoveFromServer() {
        SWSLoginService.delLoginToken(SW_UserCenter.shared.user?.token ?? "").response { (json, isCache, error) in
        }
        SW_UserCenter.logout({
            self.showAlert(message: "您的账号已经被服务器删除，如需登录，请联系管理员")
        })
    }
    
    func showAlert(message: String, str: String = InternationStr("确定"),action:((UIAlertAction)->Void)? = nil) {
        let alert = UIAlertController.init(title: nil, message: InternationStr(message), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: str, style: .default, handler: action))
        getTopVC().present(alert, animated: true, completion: nil)
    }
    
}
