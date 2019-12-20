//
//  BaseTool.swift
//  Project
//
//  Created by macbook pro on 2017/11/3.
//  Copyright © 2017年 cn.test.www. All rights reserved.
//

import UIKit

import CoreLocation
import SAMKeychain

/// 判断是否是手机号码
///
/// - Parameter hexStr: 输入的内容
/// - Returns: 是否是手机号码
func isPhoneNumber(_ hexStr: String) -> Bool {
//    let regex = "^((13[0-9])|(14[5,7])|(15[0-3,5-9])|(17[0,3,5-8])|(18[0-9])|166|198|199|(147))\\d{8}$"
     let regex = "^(110|(13[0-9])|(14[0-9])|(15[0-3,5-9])|(16[5,6,7])|(17[0-9])|(18[0-9])|(19[1,8,9]))\\d{8}$"
    let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
    let isPhonenum = predicate.evaluate(with: hexStr)
    return isPhonenum
}

func secondsToHoursMinutesSeconds(seconds: Int) -> String {
    var dateString = ""
    let hms = (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    if hms.0 > 0 {
        dateString = "\(hms.0)时"
    }
    if hms.1 > 0 {
        dateString += "\(hms.1)分"
    }
    if hms.2 > 0 {
        dateString += "\(hms.2)秒"
    }
    return dateString
}

/// 提示框  可自定义
///
/// - Parameters:
///   - string: 提示框内容
///   - view: 提示框的父控件
func showAlertMessage(_ string: String, _ view: UIView?) -> Void {
    dispatch_async_main_safe {
        MBProgressHUD.showText(InternationStr(string))
    }
}

/// alertcontroller显示
func alertControllerShow(title:String?,message:String?,rightTitle:String,rightBlock:((QMUIAlertController?,QMUIAlertAction?)->Void)?,leftTitle:String,leftBlock:((QMUIAlertController?,QMUIAlertAction?)->Void)?) {
    let alert = QMUIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(QMUIAlertAction(title: rightTitle, style: .default, handler: { (controller, action) in
        rightBlock?(controller, action)
    }))
    alert.addAction(QMUIAlertAction(title: leftTitle, style: .default, handler: { (controller, action) in
        leftBlock?(controller, action)
    }))
    var attr = alert.alertButtonAttributes
    attr?[NSAttributedString.Key.foregroundColor] = UIColor.v2Color.blue
    attr?[NSAttributedString.Key.font] = Font(16)
    alert.alertButtonAttributes = attr
    alert.showWith(animated: true)
}


/// 全局搜索无数据提示语
///
/// - Parameters:
///   - keyword: 关键词
///   - module: 模块字符串
/// - Returns: 0：提示语  1 frame
func getSearchNoDataTipString(_ keyword: String, module: String) -> (NSMutableAttributedString, CGRect) {
    
    
    let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
    paragraphStyle.lineBreakMode = .byTruncatingTail
    paragraphStyle.alignment = .center
    
    let normalDic = [NSAttributedString.Key.font:Font(14),NSAttributedString.Key.foregroundColor:UIColor.v2Color.darkGray,
                     .paragraphStyle : paragraphStyle]
    return (NSMutableAttributedString(string: "抱歉，没有找到相关内容", attributes: normalDic), CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 30, height: "抱歉，没有找到相关内容".size(Font(14), width: SCREEN_WIDTH - 30).height))
//    let attrStr = NSMutableAttributedString(string: "没有找到\"", attributes: normalDic)
//    attrStr.add(str: keyword, dic: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 14),NSAttributedString.Key.foregroundColor:UIColor.v2Color.blue,.paragraphStyle : paragraphStyle])
//    attrStr.add(str: "\"相关\(module)", dic: normalDic)
//    let frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 30, height: "没有找到\"\(keyword)\"相关\(module)".size(Font(14), width: SCREEN_WIDTH - 30).height)
//    return (attrStr, frame)
}

//字母、数字、特殊字符最少2种组合（不能有中文和空格）
//(?!.*[\u4E00-\u9FA5\s])(?!^[a-zA-Z]+$)(?!^[\d]+$)(?!^[^a-zA-Z\d]+$)^.{6,16}$
/// 判断输入的是否符合密码规则
///
/// - Parameter password: 密码
/// - Returns: 是否符合规则
func IsPassword(_ password: String) -> Bool {
    let regex = "(?!.*[\u{4E00}-\u{9FA5}\\s])(?!^[a-zA-Z]+$)(?!^[\\d]+$)(?!^[^a-zA-Z\\d]+$)^.{8,20}$"//"^[a-zA-Z0-9]{8,20}"//"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,20}$"
    let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
    let isValid = predicate.evaluate(with: password)
    return isValid
}


/// 16进制颜色转换
///
/// - Parameter hexStr: 16进制颜色字符串, RGB模式 <#ffff00 或 ffff00>
/// - Returns: 返回16进制字符串代表的颜色
func HexStringToColor(_ hexStr: String) -> UIColor {
    //1,首先判断十六进制字符串格式是否符合规则
    let regex = "#?[A-Fa-f0-9]{6}"
    let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
    let isValid = predicate.evaluate(with: hexStr)
    //如果不能匹配正则表达式,那么久返回透明颜色
    if isValid == false {
        PrintLog("您输入的颜色不符合规范,请检查后重新输入")
        return UIColor.clear
    }
    //能够正确匹配正则表达式
    var startSlicingIndex: String.Index?
    if hexStr.contains("#") {
//        PrintLog("删除#")
        startSlicingIndex = hexStr.index(hexStr.startIndex, offsetBy: 1)
    } else {
        startSlicingIndex = hexStr.index(hexStr.startIndex, offsetBy: 0)
    }
    //截串后的纯16进制数字 eg. ff0000
    let subValues = hexStr[startSlicingIndex!...]
    
    
    //截取蓝色的16进制字符
    startSlicingIndex = subValues.index(subValues.startIndex, offsetBy: 4)

    let blue = subValues[startSlicingIndex!...]
    
    //截取红色16进制字符串
    startSlicingIndex = subValues.index(subValues.startIndex, offsetBy: 0)

    let red = subValues[startSlicingIndex! ..< subValues.index(subValues.startIndex, offsetBy: 2)]
    
    //截取绿色16进制字符串
    startSlicingIndex = subValues.index(subValues.startIndex, offsetBy: 2)
    
    let green = subValues[startSlicingIndex! ..< subValues.index(subValues.startIndex, offsetBy: 4)]
    
    //16进制字符串转换为10进制Int类型数据
    let r = hexTodec(String(red))
    let g = hexTodec(String(green))
    let b = hexTodec(String(blue))
    
    //返回颜色值
    return UIColor.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
}



/// 16进制字符串转10进制
///
/// - Parameter num: 16进制字符串
/// - Returns: 10进Int类型数据
func hexTodec(_ num:String) -> Int {
    let str = num.uppercased()
    var sum = 0
    for i in str.utf8 {
        sum = sum * 16 + Int(i) - 48 // 0-9 从48开始
        if i >= 65 {                 // A-Z 从65开始，但有初始值10，所以应该是减去55
            sum -= 7
        }
    }
    return sum
}


/// 自定义字体大小
///
/// - Parameter font: 字体大小
/// - Returns: 返回UIFont对象
func Font(_ font: CGFloat) -> UIFont {
    return UIFont.systemFont(ofSize: font)
}

/// 加粗字体大小
///
/// - Parameter font: 字体大小
/// - Returns: 返回UIFont对象
func MediumFont(_ font: CGFloat) -> UIFont {
    return UIFont(name: "PingFangSC-Medium", size: font)!
}//"PingFangSC-Medium""HelveticaNeue-Medium"

func BlackFont(_ font: CGFloat) -> UIFont {
    return UIFont.boldSystemFont(ofSize: font)
}


/// 返回经过国际化的字符串
///
/// - Parameter string: 原字符串
/// - Returns: 经过国际化的字符串
func InternationStr(_ string: String) -> String {
    //设置字体间距
    return NSLocalizedString(string, comment: "default")
}



/// 获取IDFV <不同手机获取到不同的值>
///
/// - Returns: IDFV
func AcquireIDFV() -> String {
    let idfv = UIDevice.current.identifierForVendor?.uuidString

    guard let idfvStr = idfv else {
        return "-1"
    }
    return idfvStr

}


/// 根据字典生成字符串
///
/// - Parameter dictionary: 字典参数
/// - Returns: json字符串
func getJSONStringFromDictionary(dictionary:NSDictionary) -> String {
    if (!JSONSerialization.isValidJSONObject(dictionary)) {
        print("无法解析出JSONString")
        return ""
    }
    let data : NSData! = try? JSONSerialization.data(withJSONObject: dictionary, options: []) as NSData?
    let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
    return JSONString! as String
    
}

/// 根据字典生成json
///
/// - Parameter dictionary: 字典参数
/// - Returns: json
func getJSONFromDictionary(_ dictionary: [String: Any]) -> Data {
    if (!JSONSerialization.isValidJSONObject(dictionary)) {
        print("无法解析出JSONString")
        return Data()
    }
    return (try? JSONSerialization.data(withJSONObject: dictionary, options: [])) ?? Data()
}


/// RSA加密
///
/// - Parameter string: 需要加密的字符串
/// - Returns: 返回加密后的字符串
func rsaEncryptWithString(_ string: String) -> String {
    return RSA.encryptString(string, publicKey: RSA_PUBLICK_KEY)
}


/// 创建键值对保存到沙盒
///
/// - Parameters:
///   - value: 值
///   - key: 键
func InsertMessageToPerform(_ value: Any, _ key: String) -> Void {
    // 1、利用NSUserDefaults存储数据
    let defaults = UserDefaults.standard
    // 2、存储数据
    defaults.set(value, forKey: key)
    // 3、同步数据
    defaults.synchronize()
}


/// 根据key从沙盒获取值
///
/// - Parameter key: 沙盒中保存数据的key值
/// - Returns: 取到的值
func AcquireValueFromPerform(_ key: String) -> Any {
    let defaults = UserDefaults.standard
    guard let value = defaults.value(forKey: key) else { return "" }
    return value
}

/// 创建键值对保存到沙盒
///
/// - Parameters:
///   - value: 值
///   - key: 键
func RemoveMessageToPerform(_ key: String) -> Void {
    // 1、利用NSUserDefaults存储数据
    let defaults = UserDefaults.standard
    // 2、删除数据
    defaults.removeObject(forKey: key)
    // 3、同步数据
    defaults.synchronize();
}


//MARK: -清除缓存功能
func clearCache() -> Void {
    
}

///获取设备的唯一标识
func getDeviceId() -> String {
    //保存一个UUID字符串到钥匙串：
    let uuid = CFUUIDCreate(nil)
    assert(uuid != nil)
    CFUUIDCreateString(nil, uuid)
//    SAMKeychain.setPassword(uuidStr! as String, forService: "com.sws.yuanruiwangluo", account: "user")
        var currentDeviceUUIDStr = SAMKeychain.password(forService: "com.sws.yuanruiwangluo", account: "user")
        if currentDeviceUUIDStr == nil || currentDeviceUUIDStr?.count == 0 {
            let currentDeviceUUID = UIDevice.current.identifierForVendor
            currentDeviceUUIDStr = currentDeviceUUID?.uuidString
            currentDeviceUUIDStr = currentDeviceUUIDStr?.replacingOccurrences(of: "-", with: "")
            currentDeviceUUIDStr = currentDeviceUUIDStr?.lowercased()
            SAMKeychain.setPassword(currentDeviceUUIDStr!, forService: "com.sws.yuanruiwangluo", account: "user")
        }
        return currentDeviceUUIDStr!

}



/// 将汉字转为拼音
///
/// - Parameter chinese: 需要转换的汉字
/// - Returns: 转换后的拼音
func switchToSpell(_ chinese: String) -> String {
    
    return ""
}

extension String{
    func transformToPinYin()->String{
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        let string = String(mutableString)
        return string
//        return string.stringByReplacingOccurrencesOfString(" ", withString: "")
    }
}





