//
//  SWSApiCenter.swift
//  SWS
//
//  Created by jayway on 2018/4/13.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SWSApiCenter: NSObject {
    ///判断是否有新版本可以更新   true 有
    static var isHadNewVersion = false
    
    /// 是否处于审核状态  默认是不在审核状态，主要是防止无网络的情况下会导致注册按钮显示出来，外界用户可能会进行注册
    static var isReview = false {
        didSet {
            if isReview != oldValue {//状态改变则发出通知，如果在登录页面则刷新页面
//                登录页面底部需封装一个方法
                NotificationCenter.default.post(name: NSNotification.Name.Ex.ReviewStateHadChange, object: nil)
            }
        }
    }
    
    /// 是否通过过token的校验，只有正在校验通过才算登录成功，有网络时调用checklogintoken接口，无网络时允许进入APP，当校验token失效时，才清空用户信息，调用logout方法
    static var hasCheckLoginToken = false
    
    /// 标记是否获取过App Store信息了，获取过就不再请求了。
    static var hadGetReviewState = false
    
    /// 标记是否显示过更新提醒的view
    static var hadShowUpdateView = false
    
    /// App Store上获取的version
    static var appStoreVersion = ""
    /// App Store上获取的版本更新描述
    static var appStoreDesc = ""
    /// 自己服务器记录更新版本
    static var updateVersion = ""
    /// 自己服务器版本更新描述
    static var desc = ""
    /// 是否强制更新
    static var isForce = false
    
    private static var isRequesting = false
    
    /// 是否测试区环境
    static var isTestEnvironment = UserDefaults.standard.bool(forKey: isTestEnvironmentKey) {
        didSet {
            InsertMessageToPerform(isTestEnvironment, isTestEnvironmentKey)
        }
    }
    
    /// 自定义ip
    static var localIP = UserDefaults.standard.string(forKey: localIPKey) ?? "" {
        didSet {
            InsertMessageToPerform(localIP, localIPKey)
        }
    }
     /// 自定义端口
    static var localPort = UserDefaults.standard.string(forKey: localPortKey) ?? DefaultPort {
        didSet {
            InsertMessageToPerform(localPort, localPortKey)
        }
    }
    
    //玮哥ip：new:  "http://192.168.1.108:9090/yr-sw-oa"
    
    //东哥ip: new: "http://192.168.1.106:9090/yr-sw-oa"
    
    /// 获取测试区的baseUrl
    ///
    /// - Returns: 测试区的baseUrl
    static func getTestEnvironmentBaseUrl() -> String {//"https://test-oamng.yuanruiteam.com"
        return !localIP.isEmpty ? "http://\(localIP):\(localPort)/yr-sw-oa" : "https://test-oamng.yuanruiteam.com"//"https://oamng.yuanruiteam.com"
    }
    
    /// 获取OA系统baseUrl
    ///
    /// - Returns: OA系统baseUrl
    static func getBaseUrl() -> String {//"https://test-oamng.yuanruiteam.com"
        return isTestEnvironment ? getTestEnvironmentBaseUrl() : "https://oamng.yuanruiteam.com"//"https://oamng.yuanruiteam.com"
    }
    
    /// 获取财务系统BaseUrl
    ///
    /// - Returns: 财务系统BaseUrl
    static func getFinanceBaseUrl() -> String {//"https://test-finance.yuanruiteam.com"
        return isTestEnvironment ? "https://test-finance.yuanruiteam.com" : "https://finance.yuanruiteam.com"
    }
    
    //客户端版本
    static func getSWSVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    /// 请求App Store与服务器版本信息
    static func getAppReviewState() {
        guard !hadGetReviewState else { return }
        guard !isRequesting else { return }
        isRequesting = true
        
        let group = DispatchGroup()
        group.enter()
        request(URL(string: "https://itunes.apple.com/lookup")!, method: .post, parameters: ["id":AppAppleID]).responseData { response in
            if let _ = response.result.error {//请求出错  网络问题
                hadGetReviewState = false
            } else if let data = response.data {//获取到数据
                hadGetReviewState = true
                let json = JSON(data)
                PrintLog(json)
                if let dictJSON = json["results"].arrayValue.first {//获取到了版本信息 有上线版本
                    appStoreVersion = dictJSON["version"].stringValue
                    // releaseNotes   --- 更新信息
                    appStoreDesc = dictJSON["releaseNotes"].stringValue
                    
                    let currentVersion = getSWSVersion()//当前App version
                    if appStoreVersion.compare(currentVersion) == .orderedDescending  {//appstore 版本大 线上版本   ///安装旧版本在这里- 提示版本更新
                        isHadNewVersion = true
                        isReview = false
                    } else if appStoreVersion == currentVersion {
                        ///安装的是最新的版本
                        isReview = false
                    } else {///
                        ///审核期间
                        isReview = true
                        PrintLog("App Store小")
                    }
                }  else {///没有获取到版本信息  还没上线版本
                    isReview = true
                }
            }
            group.leave()
        }

        group.enter()
        SWSApiCenter.checkAppVersion().response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                updateVersion = json["appVersion"].stringValue
                desc = json["desc"].stringValue
                isForce = json["isForce"].boolValue ||
                (json["lastForceVersion"].stringValue.compare(getSWSVersion()) == .orderedDescending)
            }
            group.leave()
        })
        
        group.notify(queue: DispatchQueue.main) {
            isRequesting = false
//            发送通知。让对应的页面去显示弹窗
            NotificationCenter.default.post(name: NSNotification.Name.Ex.HadGetAppStoreVersion, object: nil)
        }
    }
    
    /// 检查是否需要添加更新View到window
    static func checkShouldUpdateTipAlert() {
        /// 没有获取到App Store信息不显示
        guard hadGetReviewState, !updateVersion.isEmpty else { return }
        guard !hadShowUpdateView else { return }/// 没有显示过才进来
        hadShowUpdateView = true
        if isHadNewVersion {/// App Store 有新版本，提示更新
            if appStoreVersion == updateVersion || isForce {
                /// 线上版本服务器版本一致，显示服务器数据
                showUpdateTipAlert(msg: desc, currentVersion: updateVersion, isForce: isForce)
            } else {
                ////  这种情况提示更新，但是属于可跳过的更新。
                ////  更新提示信息显示appstore上的信息
                showUpdateTipAlert(msg: appStoreDesc, currentVersion: appStoreVersion, isForce: false)
            }
        }
    }
    
    /// 显示前往App Store弹窗，一个版本只显示一次，在设置页中也可以跳转
    ///
    /// - Parameter msg: 版本更新的信息
    /// - Parameter currentVersion: 当前App Store的版本号
    /// - Parameter isForce: 是否强制更新
    static func showUpdateTipAlert(msg: String, currentVersion: String, isForce: Bool) {
        let lastVersion = UserDefaults.standard.string(forKey: "LastTipUpdateVersion") ?? "0"///上次显示过提示的版本
        if currentVersion.compare(lastVersion) == .orderedDescending || isForce {//如果大于上次提示版本，则显示更新提醒
            UserDefaults.standard.set(currentVersion, forKey: "LastTipUpdateVersion")
            MYWINDOW?.endEditing(true)
            SW_TipUpdateModalView.show(msg: msg, currentVersion: currentVersion, isForce: isForce)
        }
    }
    
    
    /// 检测版本更新
    ///  /api/app/appVersion/checkAppVersion.json
    /// - Returns: 请求对象
    class func checkAppVersion() -> SWSRequest {
        let request = SWSRequest(resource: "checkAppVersion.json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/appVersion"
        request["type"] = 0
        request.send(.post).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
        }
        return request
    }
}
