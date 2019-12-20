//
//  GlobalConstant.swift
//  Project
//
//  Created by jayway on 2017/11/30.
//  Copyright © 2017年 cn.test.www. All rights reserved.
//

import UIKit

/// RSA的公钥key
let RSA_PUBLICK_KEY = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDy+Izjh4ONL1+Kkhs0RuPeNS2ke/kGsjlU0IVRpnjy36UFExpixcIne6wTQ20jj6Oy3eEchSMgVzoxxFzAcIIRcHp2jUX5U6HjYA4X+9BZFlRNXxs2pPD6UqobnF6tGeFnvQuQ9Z9i4WIhAwXo0YFl7HOv0Zum42396pBvBNlnKwIDAQAB"

///融云的APPKEY
//let RCIM_APPKEY = "8luwapkv8r08l"
///融云的APPSecret
//let RCIM_APP_SECRET = "yE5Ew5iBV2p7F"

/// appstore 的跳转链接 本app
let AppStoreLink = "itms-apps://itunes.apple.com/us/app/%E6%95%88%E7%8E%87/id1395231539?l=zh&ls=1&mt=8"

/// 效率+在App Store中的ID可以生成跳转App Store链接        "1088172893"//  114啦的
let AppAppleID = "1395231539"//

let HuanxinAppKey = { () -> String in
    if SWSApiCenter.isTestEnvironment {
        return "1123180401146835#sanoa"
    } else {
        return "1123180401146835#sanoa-production"
    }
}()

/// Bugly-APPID
let BuglyAPPId = "7410b5dd13"

let ApnsCertName = { () -> String in
    #if DEBUG
    return "develop"
    #else
    return "product"
    #endif
}()

///保存登陆成功后的用户信息
let USERDATAKEY = "defaults_user_data"

///保存用户名的key
let USERNAMEKEY = "Username"

//保存用户头像url的key
let ICON_IMAGE = "Icon_Image"

let LastVersionKey = "lastversion"

let isTestEnvironmentKey = "isTestEnvironmentKey"
let localIPKey = "localIPKey"
let localPortKey = "localPortKey"
let DefaultPort = "9090"

/********************************************屏幕, 机型相关****************************************************/
//MARK: -屏幕, 机型相关
/// 屏幕高度
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

/// 屏幕宽度
let SCREEN_WIDTH = UIScreen.main.bounds.size.width

/// 判断是否是ipad
let isIPad = UI_USER_INTERFACE_IDIOM() == .pad

/// 判断是否是iPhone
let isIPhone = UI_USER_INTERFACE_IDIOM() == .phone

/// 判断是否是iPhone5
let isPhone5 = SCREEN_HEIGHT == 568.0

/// 判断是否是iPhone6
let isPhone6 = SCREEN_HEIGHT == 667.0

/// 判断是否是iPhone6P
let isPhone6P = SCREEN_HEIGHT == 736.0

/// 判断是否是iPhoneX
//let isPhoneX = SCREEN_HEIGHT == 812.0 || SCREEN_HEIGHT == 896.0

let AUTO_IPHONE6_HEIGHT_667 = SCREEN_HEIGHT / 667

let AUTO_IPHONE6_WIDTH_375 = SCREEN_WIDTH / 375

/// nav高度
let NAV_HEIGHT: CGFloat = 44.0

///nav距离头部间距
let NAV_HEAD_INTERVAL: CGFloat = UIApplication.shared.statusBarFrame.height//isPhoneX ? 44.0 : 20.0

///nav的总高度<页面内容距离顶部高度>
let NAV_TOTAL_HEIGHT = NAV_HEAD_INTERVAL + NAV_HEIGHT

/// tabBar高度
let TABBAR_HEIGHT: CGFloat = 49.0
/// 显示销售接待条时的tabbar高度
let SHOWACCESS_TABBAR_HEIGHT: CGFloat = 114.0

/// tabBar距离底部间距
let TABBAR_BOTTOM_INTERVAL: CGFloat = {
    if #available(iOS 11.0, *) {//if @available(iOS 11.0, *) {
        return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
    } else {
        return 0
    }
}()//isPhoneX ? 34.0 : 0.0

let MYWINDOW = UIApplication.shared.keyWindow

/// 分割线高度
let SingleLineWidth = 1.0 / UIScreen.main.scale

/// 系统动画时长
let SystemAnimationDuration: TimeInterval = 0.3

/// TABBAR动画时长
let TabbarAnimationDuration: TimeInterval = 0.4

///文档主路径
let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

/// 用户数据缓存
let UserCache = YYCache(path: documentPath + "/UserData.db")

/// 统计模块最小时间戳
let StatisticalMinTimeInterval: TimeInterval = 1420041600000

// 加载列表loading图
let LoadindImgName = "loading.gif"
let LoadingImgWH: CGFloat = 40
