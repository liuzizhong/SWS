//
//  StringExtensions.swift
//  Browser
//
//  Created by Boom Joe on 16/9/12.
//  Copyright © 2016年 114la.com. All rights reserved.
//



import Foundation

public extension String {
    
    /// 三惠密码加密规则
    ///
    /// - Returns: 加密后的密码字符串
    func passwordCoder() -> String {
        return (self.data(using: String.Encoding.utf8) as NSData? ?? NSData()).sha1().base64EncodedString()
    }
    
    func contains(_ other: String) -> Bool {
        // rangeOfString returns nil if other is empty, destroying the analogy with (ordered) sets.
        if other.isEmpty {
            return true
        }
        return self.range(of: other) != nil
    }
    
    /// 分割字符串，如果空字符串返回空数组
    ///
    /// - Parameter separate: 分割的字符串
    /// - Returns: 分割的数组
    func zzComponents(separatedBy separate: String) -> [String] {
        if self.isEmpty { return [] }
        
        return self.components(separatedBy: separate)
    }
    

    /// 时间字符串按照formatString转换为timeInterval
    ///
    /// - Parameter formatStr: 时间格式化字符串
    /// - Returns: 转换后的时间
    func toTimeInterval(formatStr: String) -> TimeInterval {
        if let date = Date.dateWith(formatStr: formatStr, dateString: self) {
            return date.timeIntervalSince1970*1000
        }
        return 0
    }
    
    /// 计算文字个数
    ///
    /// - Returns: 返回文字个数
    func calculateTextCount() -> Int {
        return self.trimmingCharacters(in: CharacterSet.whitespaces).count
    }
    
    /// 判断是否以某个字符串开头
    ///
    /// - Parameter other: 开头对比字符串
    /// - Returns: 是否是这个f字符串的开头
    func startsWith(_ other: String) -> Bool {
        // rangeOfString returns nil if other is empty, destroying the analogy with (ordered) sets.
        if other.isEmpty {
            return true
        }
        if let range = self.range(of: other,
                                          options: NSString.CompareOptions.anchored) {
            return range.lowerBound == self.startIndex
        }
        return false
    }
    
    /// 判断是否以某个字符串结尾
    ///
    /// - Parameter other: 结尾对比字符串
    /// - Returns: 是否是这个f字符串的结尾
    func endsWith(_ other: String) -> Bool {
        // rangeOfString returns nil if other is empty, destroying the analogy with (ordered) sets.
        if other.isEmpty {
            return true
        }
        if let range = self.range(of: other,
                                          options: [NSString.CompareOptions.anchored, NSString.CompareOptions.backwards]) {
            return range.upperBound == self.endIndex
        }
        return false
    }
    
    func escape() -> String {
        let raw: NSString = self as NSString
        let str = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                          raw,
                                                          "[]." as CFString, ":/?&=;+!@#$()',*" as CFString,
                                                          CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue))
        return str as String? ?? ""
    }
    
    func unescape() -> String {
        let raw: NSString = self as NSString
        let str = CFURLCreateStringByReplacingPercentEscapes(kCFAllocatorDefault, raw, "[]." as CFString)
        return str as String? ?? ""
    }
    
    ///返回字符串第一个字符
    func firstString() -> String {
        if self.count > 1 {
            return self[0...0]
        } else {
            return self
        }
    }
    
    /// 获取符合规则的数字字符串
    ///
    /// - Parameter intNum: 数字
    /// - Returns: 符合规则字符串
    static func toRelativeNumberString(intNum: Int) -> String {
        if intNum > 999999 {
            return "99w+"
        } else if intNum >= 100000 {
            return "\(intNum / 10000)w"
        } else if intNum > 999 {
            var str = "\(intNum / 1000)"
//            let doubleNum = intNum / 1000.0
//            return String(format: "%.1fk", doubleNum)//这种做法会进1 不精确
            let yushu = ((intNum % 1000) / 100)
            if yushu > 0 {
                str = str + ".\(yushu)"
            }
            str = str + "k"
            return  str
            
        } else if intNum > 0 {
            return "\(intNum)"
        } else {
            return ""
        }
        
    }
    /**
     Ellipsizes a String only if it's longer than `maxLength`
     
     "ABCDEF".ellipsize(4)
     // "AB…EF"
     
     :param: maxLength The maximum length of the String.
     
     :returns: A String with `maxLength` characters or less
     */
    func ellipsize(maxLength: Int) -> String {
        if (maxLength >= 2) && (self.count > maxLength) {
            let index1 = self.index(self.startIndex, offsetBy: (maxLength + 1) / 2) // `+ 1` has the same effect as an int ceil
            let index2 = self.index(self.endIndex, offsetBy: maxLength / -2)
            return String(self[..<index1]) + "…\u{2060}" + String(self[index2...])
//            return self.substring(to: index1) + "…\u{2060}" + self.substring(from: index2)
        }
        return self
    }
    
    fileprivate var stringWithAdditionalEscaping: String {
        return self.replacingOccurrences(of: "|", with: "%7C", options: NSString.CompareOptions(), range: nil)
    }
    
//    public var asURL: URL? {
//        // Firefox and NSURL disagree about the valid contents of a URL.
//        // Let's escape | for them.
//        // We'd love to use one of the more sophisticated CFURL* or NSString.* functions, but
//        // none seem to be quite suitable.
//        return URL(string: self) ??
//            URL(string: self.stringWithAdditionalEscaping)
//    }
    
    /// Returns a new string made by removing the leading String characters contained
    /// in a given character set.
    func stringByTrimmingLeadingCharactersInSet(_ set: CharacterSet) -> String {
        var trimmed = self
        while trimmed.rangeOfCharacter(from: set)?.lowerBound == trimmed.startIndex {
            trimmed.remove(at: trimmed.startIndex)
        }
        return trimmed
    }
    
    /// Adds a newline at the closest space from the middle of a string.
    /// Example turning "Mark as Read" into "Mark as\n Read"
    func stringSplitWithNewline() -> String {
        let mid = self.count/2
        
        let arr = self.indices.compactMap { (index) -> Int? in
            if let i = Int("\(index)"), self[index] == " " {
                return i
            }
            return nil
        }
        guard let closest = arr.enumerated().min(by: { abs($0.1 - mid) < abs($1.1 - mid)}) else {
            return self
        }
        var newString = self
        newString.insert("\n", at: newString.index(newString.startIndex, offsetBy: closest.element))
        return newString
    }
    
}

public extension String {
    func toBool() -> Bool {
        switch self.lowercased() {
        case "true", "yes", "1":
            return true
        case "false", "no", "0":
            return false
        default:
            return false
        }
    }
}

//MARK: - 常用key
public extension String {
    
    // MARK: - NSLocalized
    struct Localized
    {
        static let OK       = NSLocalizedString("OK", comment: "OK button")
        static let Cancel   = NSLocalizedString("Cancel", comment: "Label for Cancel button")
    }
    
    
    //SWS   app
    class Key {
//        static let umengAppKey      = "5a03c085aed1791c070002b6"
//        static let wechatAppId      = "wx0dfbe32c6ccd9e48"
//        static let wechatAppSecret  = "0fd0da047b4c30a2b40e0985aa75b63a"
//        static let qqAppId          = "1105423866"
//        static let qqAppKey         = "Pr75HyMTGYUqyvMG"
//        static let sinaWeiboAppId   = "797256859"
//        static let buglyAppId       = "d3cfe6dc3b"
//
//        static let laAppKey         = "f7a30e1a01944368e0e4"
//        static let talkingDataAppKey = "3AB3B10CC03B4F6EA03AA2E01CC6E873"
        
    }
    
    
//
//    //雨林木风app
//    public class KeyYLMF {
//        static let wechatAppId          = "wx28088a27d4d9eafd"
//        static let wechatAppSecret      = "a7bdd069a9411b2c869feee8096e1b0d"
//        //        static let sinaWeiboAppId       = "375380948"
//        //        static let sinaWeiboAppKey      = "797256859"
//        //        static let sinaWeiboAppSecret   = "41f6f7dd9c223a8ddf6c01fbc4f7745d"
//    }
}
