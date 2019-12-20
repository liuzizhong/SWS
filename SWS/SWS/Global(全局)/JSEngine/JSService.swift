//
//  JSService.swift
//  CloudOffice
//
//  Created by Liu on 16/5/26.
//  Copyright © 2016年 115.com. All rights reserved.
//

import Foundation
import WebKit


private func serialize(_ object: AnyObject?) -> String {
    var obj: AnyObject? = object
    if let val = obj as? NSValue {
        obj = val as? NSNumber ?? val.nonretainedObjectValue as AnyObject?
    }
    if let o = obj as? XWVObject {
        return o.namespace
    } else if let s = obj as? String {
        let d = try? JSONSerialization.data(withJSONObject: [s], options: JSONSerialization.WritingOptions(rawValue: 0))
        let json = NSString(data: d!, encoding: String.Encoding.utf8.rawValue)!
        return json.substring(with: NSMakeRange(1, json.length - 2))
    } else if let n = obj as? NSNumber {
        if CFGetTypeID(n) == CFBooleanGetTypeID() {
            return n.boolValue.description
        }
        return n.stringValue
    } else if let date = obj as? Date {
        return "(new Date(\(date.timeIntervalSince1970 * 1000)))"
    } else if let _ = obj as? Data {
        // TODO: map to Uint8Array object
    } else if let a = obj as? [AnyObject] {
        return "[" + a.map(serialize).joined(separator: ", ") + "]"
    } else if let d = obj as? [String: AnyObject] {
        return "{" + d.keys.map{"'\($0)': \(serialize(d[$0]!))"}.joined(separator: ", ") + "}"
    } else if obj === NSNull() {
        return "null"
    } else if obj == nil {
        return "undefined"
    }
    return "'\(obj!.description)'"
}

extension String {
    
    func callJSFunction(_ arguments: [AnyObject], by webView: WebView) {
        let args = arguments.map(serialize)
        let js = self + "(" + args.joined(separator: ", ") + ")"
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
    
}

//在swift4.0中使用class_copyPropertyList来获取类里面的属性列表，结果发现获取的列表使用为空，count始终为0。
//后来通过查找资料发现是因为swift4.0中继承 NSObject 的 swift class 不再默认 BRIDGE 到 OC，如果我们想要使用的话我们就需要在class前面加上@objcMembers 这么一个关键字
@objcMembers class CommonJSObject: NSObject {
    private var identifiers = [String]() // 用于防止重复点击
    
    class JSCallback: NSObject {
        var message: String
        var callback: XWVScriptObject?
        init(message: String, callback: XWVScriptObject?) {
            self.callback = callback
            self.message = message
            super.init()
        }
    }
    
    private weak var target: JSPrototol?
//    var datePickerCallback: XWVScriptObject?
//    var itemCallback: JSCallback?
//    var player: AVAudioPlayer?
//    weak var webView: WKWebView?
//    var videoID: String?
    
//    private let netWorkState = NetWorkState.shareNetWork()
    
//    var imagePickerCallback: JSCallback?
    
    
//    fileprivate var imagePickerPopover: UIPopoverController?
    
    init(target: JSPrototol) {
        super.init()
        self.target = target
//        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(sensorStateChange(_:)), name: NSNotification.Name.UIDeviceProximityStateDidChange, object: nil)
//        observerNetwork()
    }
    
    deinit {
        
//        removeObserver()
    }
    
//    func observerNetwork() {
//        observe(netWorkState, keyPath: #keyPath(NetWorkState.netWorkStatus)) { [weak self] (weakSelf, oldValue, value) in
//            self?.networkDidChange()
//        }
//    }
    
//    func networkDidChange() {
//        let hasNetwork = netWorkState.netWorkStatus.rawValue != 0
//        webView?.evaluateJavaScript("window.networkStateJS(\(hasNetwork ? 1 : 0))", completionHandler: nil)
//    }
    
//    func getNetWorkState(_ callback: Any) {
//        guard let callback = callback as? XWVScriptObject else {
//            return
//        }
//        callback.call(arguments: [self.netWorkState.netWorkStatus.rawValue], completionHandler: nil)
//    }
    
//    func removeObserver() {
//        NotificationCenter.default.removeObserver(self)
//    }
 
    func updateReadCount(_ readCount: Any) {
        DispatchQueue.main.async {
            if let readCount = readCount as? Int {
                self.target?.updateReadCount?(readCount)
            }
        }
    }
    
    func showTitle(_ isShow: Any) {
        DispatchQueue.main.async {
            if let isShow = isShow as? Bool {
                self.target?.showTitle?(isShow as Any)
            }
        }
    }
    
    func show_user_info(_ userID: Any) {
        DispatchQueue.main.async {
            if let userID = userID as? String {
                self.target?.show_user_info?(userID)
            }
        }
    }
    
    func showUserInfoWithGid(_ userID: String, _ gid: String) {
        DispatchQueue.main.async {
            self.target?.showUserInfoWithGid?(userID, gid)
        }
    }
    
    var netWorkStatus: Int {
        return 0//Int(NetWorkState.shareNetWork().netWorkStatus.rawValue)
    }
    
    var applicationVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    func copyString(_ content: String) {
        DispatchQueue.main.async {
            let pasteBoard = UIPasteboard.general
            pasteBoard.setPersistent(true)
            if let stringType = UIPasteboard.typeListString.firstObject as? String {
                pasteBoard.setValue(content, forPasteboardType: stringType)
            } else {
                pasteBoard.string = content
            }
        }
    }
    
    func getStringInPasteboard(_ callback: XWVScriptObject) {
        let string = UIPasteboard.general.string ?? ""
        callback.call(arguments: [string], completionHandler: nil)
    }
    
//    func isInstallAppWithCallback(_ appName: String, _ callback: XWVScriptObject) {
//        let schemes = ["115": "oof.disk://", "115+": "oof.office://", "115browser": "oof.browser://", "115agency": "oof.agency://"]
//        let scheme = schemes[appName] ?? appName
//        dispatch_async_main_safe {
//            var installed = false
//            if let url = URL(string: scheme) {
//                installed = UIApplication.shared.canOpenURL(url)
//            }
//            callback.call(arguments: [installed], completionHandler: nil)
//        }
//    }
    
    var fontScaleValue: Double {
//        return COSettingFont.sharedInstance().fontScale
        return 0.1
    }
    
    
    
    
    
    var userInfo: [String: String] {
        if let info = target?.getUserInfo?() {
            return info
        } else {
            let user = SW_UserCenter.shared.user
            let info: [String: String] = ["id": "\(user?.id ?? 0)", "token": user?.token ?? ""]
//            if let userCenter = UDUserCenter.shared(), let userName = userCenter.allFriend(withID: user.userID, gid: UDNetwork.shared.currentGroupModel.gid)?.user_name {
//                info["name"] = userName
//            }
            return info
        }
    }
    
    
    
    
    
    
    
}







