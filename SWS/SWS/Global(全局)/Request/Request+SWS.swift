//
//  Request+SWS.swift
//  SWS
//
//  Created by jayway on 2018/4/2.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Foundation
import FMDB

let kDefaultRequetIDCKey = "kDefaultRequetIDCKey"

class RequestConfigation: NSObject {
    
    static let defaultConfigation = RequestConfigation()
    var idcConfigs: [(String, Date?)] = [("", nil)]
    
    private(set) var idc = ""
    var boundIdc = UserDefaults.standard.string(forKey: "idc_yun.sws.com")
    var boundMsgIdc = UserDefaults.standard.string(forKey: "idc_yunmsg.sws.com")
    private var updateTimer: Foundation.Timer?
    private var lastUpdateTime = Date()
    
    override init() {
        super.init()
//        if let list = UserDefaults.standard.array(forKey: kDefaultRequetIDCKey) as? [String] {
//            updateIDCList(list)
//        } else {
//            requestIDCList()
//        }
//        self.updateTimer = Foundation.Timer.scheduledTimer(withTimeInterval: 60, block: { (timer) in
//            if Date().timeIntervalSince(self.lastUpdateTime) > 30 * 60 {
//                self.requestIDCList()
//            }
//        }, repeats: true)
//        LanguageService.shared.appendCookie()
    }
    
//    let requestDefaultEngine = MKNetworkEngine()
    let request_cache_operation_queue = DispatchQueue(label: "com.sws.cache.dbcenter", attributes: [])
    let requestDB = FMDatabase(path: String(format: "%@/Library/Caches/%@", NSHomeDirectory(), "RequestCache.db"))
    
    static var encryptAPI = true
    
    func requestFinish(_ error: Error?) {
        if let error = error {
            guard [NSURLErrorTimedOut, NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost].contains(error.code) else {
                return
            }
        }
        if let index = idcConfigs.index(where: {$0.0 == idc && $0.1 == nil}) {
            idcConfigs.remove(at: index)
            idcConfigs.append((idc, nil))
        }
        if error != nil {
            updateIDC()
        }
    }
    
    func updateIDC() {
        if let useable = idcConfigs.filter({$0.1 == nil}).first {
            idc = useable.0
        } else {
            idcConfigs = idcConfigs.map({($0.0, nil)})
            idc = ""
        }
    }
    
    func updateIDCList(_ list: [String]) {
        var list = list
        if list.count > 0 {
            UserDefaults.standard.set(list, forKey: kDefaultRequetIDCKey)
            UserDefaults.standard.synchronize()
            list.insert("", at: 0)
            idcConfigs = list.map{ ($0, nil) }
        }
    }
    
    func requestIDCList() {
        lastUpdateTime = Date()
        let request = SWSRequest(resource: "auth/idc_list")
        request.encryptAPI = false
        request.otherGroup("").send(.get).completion { (json, error) -> Any? in
            return json?["list"].array?.flatMap {
                $0.string
            }
            }.response { (idcList, isCache, error) in
                if let list = idcList as? [String], list.count > 0 {
                    self.updateIDCList(list)
                    self.updateIDC()
                }
        }
    }
    
}

extension SWSRequest {
    
    class func cacheQueue() -> DispatchQueue {
        return RequestConfigation.defaultConfigation.request_cache_operation_queue
    }
    
    class func cacheDatabase() -> FMDatabase {
        return RequestConfigation.defaultConfigation.requestDB
    }
    
    class func defaultApiURL() -> String {
        return "http://120.79.72.253:8080"
    }
    
    func appendCookies() {
//        for cookie in UDNetwork.shared.cookies {
//            if let cookie = cookie as? HTTPCookie {
//                HTTPCookieStorage.shared.setCookie(cookie)
//            }
//        }
    }
    
    func buildURLString() -> String {
        if self.apiResource.count == 0 {
            return self.apiURL
        }else{
            return self.apiURL + "/" + self.apiResource
        }
    }
    
}

extension SWSRequest {  //response
    
    var errorKeys: [String] {
        get {
            return ["code", "errno"]
        }
    }
    
    var errorMessageKeys: [String] {
        get {
            return ["msg", "error"]
        }
    }
    
    func responseFlag(_ json: inout JSON) {
        if customURLString == nil && !disableParse {
            var aJSON = json
            aJSON["data"] = JSON.null
            if json["data"].array != nil {
                json = JSON(["list": json["data"]])
            } else {
                json = json["data"]
            }
            json["_other_data_"] = aJSON
        }
    }
    
    
    /* see xcdoc://?url=developer.apple.com/library/prerelease/ios/documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Constants/index.html#//apple_ref/doc/constant_group/URL_Loading_System_Error_Codes */
    
    func errorFlag(_ error: inout NSError) -> Bool {
        var handled = true
        switch error.code {
            
//        case 601, 602, 603, 701, 801 :
//            var userInfo = [String: Any]()
//            userInfo["code"] = self.responseSwiftyJSON?["code"].int
//            userInfo["update_url"] = responseSwiftyJSON?["update_url"].string
//            userInfo["message"] = responseSwiftyJSON?["message"].string
//            NotificationCenter.default.post(name: Notification.Name(rawValue: kDidReceiveSystemError), object: self, userInfo: userInfo)
       
        case 404: // Resource not found
            error = error.errorByChangeMessage(NSLocalizedString("此功能开发中", comment: ""))
            
        case -.max ..< 0 where error.domain as String != NSURLErrorDomain:
            //            BuglyLog.level(.info, logs: String(describing: self.originRequest.url)) // todo get final url
//            Bugly.reportError(error)
            if error.code != -1 {
                error = (error as NSError).errorByChangeMessage(NSLocalizedString("服务器开小差了，请稍后重试！", comment: ""))
            }
        
        default:
            handled = false
        }
        
        if error.domain == NSURLErrorDomain {
            handled = true
//            SW_UserCenter.shared.showAlert(message: "网络错误：localizedDescription：\(error.localizedDescription)---localizedFailureReason：\(error.localizedFailureReason)---localizedRecoverySuggestion：\(error.localizedRecoverySuggestion)-------------code：\(error.code)---domain：\(error.domain)")
            error = error.errorByChangeMessage(NSLocalizedString("网络异常，请重试", comment: ""))
        }
        
        if error.localizedDescription == "" {
            error = (error as NSError).errorByChangeMessage(NSLocalizedString("服务器开小差了，请稍后重试！", comment: ""))
        }
        
        let codeString = String(error.code)
        if codeString.length == 8 && codeString.hasPrefix("5") { // 服务端内部错误
            error = (error as NSError).errorByChangeMessage(NSLocalizedString("服务器开小差了，请稍后重试！", comment: ""))
        }
        
        return handled
    }
}

extension SWSRequest {
    
    func getAsyncWithCompleteHandle(_ completionHandle: @escaping (Any?, Error?) -> Void) {
        self.responseDictionary(completionHandle).send(.get)
    }
    
    func postAsyncWithCompleteHandle(_ completionHandle: @escaping (Any?, Error?) -> Void) {
        self.responseDictionary(completionHandle).send(.post)
    }
    
    
    func getAsyncWithURLString(_ urlString: String, completionHandle: @escaping (Any?, Error?) -> Void) {
        self.useCustomURLString(urlString).responseDictionary(completionHandle).send(.get)
    }
    
    func downloadFileAtPath(_ url: URL, completionHandle: @escaping (Any?, Error?) -> Void) {
        self.encryptAPI = false // TODO: 下载文件不使用加密，流下载文件还的解密还没有支持
        self.downloadFile(to: url).responseDictionary(completionHandle)
    }
}

extension NSError {
    
    func errorByChangeMessage(_ message: String) -> NSError {
        var userInfo = self.userInfo
        userInfo[NSLocalizedDescriptionKey] = message
        return NSError(domain: domain, code: code, userInfo: userInfo)
    }
    
}
