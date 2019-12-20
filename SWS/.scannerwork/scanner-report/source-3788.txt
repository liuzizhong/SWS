//
//  Foundation.swift
//  CloudOffice
//
//  Created by 王珊 on 3/13/17.
//  Copyright © 2017 115.com. All rights reserved.
//

import Foundation

/// 模拟器判断
struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif
        return isSim
    }()
}

extension UIDevice {
    public func isiPhoneX() -> Bool {
        if UIDevice().userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436 {
            return true
        }
        return false
    }
}

// MARK: String的工具类
extension String {
    /// 字符串去掉前后空格
    ///
    /// - Returns: 去掉前后空格的字串
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// 字串的长度，print("\("22222😄😁".length)") ==> 7
    var length: Int {
        return count
    }
    
    /// 判断这个字段是否是纯数字
    var isNumber: Bool {
        let scan = Scanner(string: self)
        var val: Int64 = 0
        return scan.scanInt64(&val) && scan.isAtEnd
    }
    
    /// 判断这个字段是否是Double类型
    var isDouble: Bool {
        let scan = Scanner(string: self)
        var val: Double = 0
        return scan.scanDouble(&val) && scan.isAtEnd
    }
    
    /// String转成NSString后字串的长度(String和NSString的length算出来是不一样的, String:"22222😄😁😆" ==> 8, NSString: "22222😄😁😆" ==> 11)
    var lengthByConvertToNSString: Int {
        return (self as NSString).length
    }
 
    /// 来通过下标的方式获得子字符串(开区间let ceshi = "22222😄😁😆" print(ceshi[0..<7]) ==> "22222😄😁")
    ///
    /// - Parameter r: 字串的区间
    subscript (r: Range<Int>) -> String {
        if r.upperBound > self.length {
            assert(false, "越界了")
            return self
        } else if (r.lowerBound < 0) {
            assert(false, "下边界越界了")
            return self
        } else {
            let start = index(startIndex, offsetBy: r.lowerBound)
            let end = index(start, offsetBy: r.upperBound - r.lowerBound)
            return String(self[(start ..< end)])
        }
    }
    
    /// 来通过下标的方式获得子字符串(闭区间let ceshi = "22222😄😁😆" print(ceshi[0..<7]) ==> "22222😄😁😄")
    ///
    /// - Parameter r: 字串的区间
    subscript (r: ClosedRange<Int>) -> String {
        if r.upperBound >= self.length {
            assert(false, "越界了")
            return self
        } else if (r.lowerBound < 0) {
            assert(false, "下边界越界了")
            return self
        } else {
            let start = index(startIndex, offsetBy: r.lowerBound)
            let end = index(start, offsetBy: r.upperBound - r.lowerBound)
            return String(self[(start ... end)])
        }
    }
    
    /// 根据NSRange取子串
    ///
    /// - Parameter range: 子串的范围
    /// - Returns: 返回传入的Range所对应的子串
    func substringWithNSRange(_ range: NSRange) -> String {
        if (self as NSString).length >= range.location + range.length {
            return (self as NSString).substring(with: range) as String
        }
        assert(false, "越界了")
        return self
    }
    
//     + "?imageView2/1/w/156/h/156"
    /// 七牛图片添加缩略图
    func thumbnailString(_ wh: Int = 156) -> String {
        return isEmpty ? self : self + "?imageView2/1/w/\(wh)/h/\(wh)"
    }
    
    /// 如果是金额的字符串 转换为添加隔3位加，号的字符串
    ///
    /// - Returns: 转换后的字符串
    func decimalString() -> String {
        let format = NumberFormatter()
        //设置numberStyle（有多种格式）
//        format.numberStyle = .decimal
        format.positiveFormat = ",###.00;"
        //转换后的string
        return format.string(from: NSNumber(value: (self as NSString).doubleValue)) ?? ""
    }
    
    /// 计算字串的高度
    ///
    /// - Parameters:
    ///   - width: 宽度
    ///   - font: 字体
    /// - Returns: 返回字串的高度
    func heightWithConstrainedWidth(_ width: CGFloat, font: UIFont) -> CGFloat {
        if self == "" {
            return 0
        }
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let str = self as NSString
        let boundingBox = str.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    /// 计算字符串显示大小，结果取整以方便设计 UIView 的 frame
    ///
    /// - Parameters:
    ///   - font  字体，不能为空
    ///   - width 最大显示宽度，为 0 时不限制宽度
    /// - Returns: 返回的大小会取整，如实际高度是 115.15 时，会返回 116.0
    func size(_ font: UIFont, width: CGFloat) -> CGSize {
        if self == "" {
            return CGSize.zero
        }
        if width > 0 {
            let rect = (self as NSString).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil)
            return CGSize(width: ceil(rect.size.width), height: ceil(rect.size.height))
        } else {
            let size = (self as NSString).size(withAttributes: [NSAttributedString.Key.font : font])
            return CGSize(width: ceil(size.width), height: ceil(size.height))
        }
    }
    
    /// 验证手机时，如果该手机号为国内号码，则不需要显示前面的区号。
    ///
    /// - Parameter code: 区号码
    /// - Returns: 显示的手机信息
    /// https://yun.115.com/5/T284601.html#
    func formatPhone(code: String) -> String {
        if code == "" || code == "86" {
            return self
        } else {
            return String(format: "+%@ %@", code, self)
        }
    }
}

// MARK: NSString的工具类
@objc extension NSString {
    
    /// 判断这个字段是否是纯数字
    func isNumber() -> Bool {
        let scan = Scanner(string: self as String)
        var val: Int64 = 0
        return scan.scanInt64(&val) && scan.isAtEnd
    }
    
    /// 判断这个字段是否是Double类型
    var isDouble: Bool {
        let scan = Scanner(string: self as String)
        var val: Double = 0
        return scan.scanDouble(&val) && scan.isAtEnd
    }
    
    /// 字符串去掉前后空格
    ///
    /// - Returns: 去掉前后空格的字串
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// 字符串是否匹配正则
    ///
    /// - Parameter regex: 正则表达式
    /// - Returns: 返回Bool值
    func contains(regex: String) -> Bool {
        let regular = try? NSRegularExpression.cachedPattern(regex, options: .caseInsensitive)
        if let matches = regular?.matches(in: self as String, options: [], range: NSMakeRange(0, self.length)) {
            return matches.count > 0
        } else {
//            "[\ud83c\udc00-\ud83c\udfff]|[\ud83d\udc00-\ud83d\udfff]|[\u2600-\u27ff]"
            return false
        }
    }
    
    /// 返回正则匹配到的第一个子串
    ///
    /// - Parameter regex: 正则表达式
    /// - Returns: 返回匹配的子串
    func substring(regex: String) -> String? {
        let regular = try? NSRegularExpression.cachedPattern(regex, options: .caseInsensitive)
        if let match = regular?.matches(in: self as String, options: [], range: NSMakeRange(0, self.length)).first {
            return self.substring(with: match.range(at: 0))
        }
        return nil;
    }

    /// 验证手机时，如果该手机号为国内号码，则不需要显示前面的区号。
    ///
    /// - Parameter code: 区号码
    /// - Returns: 显示的手机信息
    /// https://yun.115.com/5/T284601.html#
    func formatPhone(code: String) -> String {
        return (self as String).formatPhone(code: code)
    }
}




// MARK: NSRegularExpression
@objc extension NSRegularExpression {
    
    // web端链接检测正则参考：([^\\w]|^)((http[s]?:\\/\\/([\\w-]+\\.)+[\\w-]+|www\\.([\\w-]+\\.)+[\\w-]+|magnet:\\?|(ed2k|thunder):\\/\\/)([\\w-.\\/;()@\+,\|\\[\\]#\-\$_\*~!:?%&=]*[\\w-.\\/;@\+,\|#\-\$_\*~!:?%&=]+)?)
    /// 检测普通链接，包括如 115.com 格式，使用时要 NSRegularExpressionCaseInsensitive
    static var RegularLink:    String { return "(http[s]?://([\\w-]+\\.)+[\\w-]+([\\w-.\\|\\/;()@+,#-$_!:?%&=]*)?)|(([a-zA-Z0-9_-]+\\.)+(com|cn|net|org|asia|cc|biz|tv|me|pw|wang|im|hk|info|mobi|name|gov|fm)(/[a-zA-Z0-9_/.\\|\\-?%&amp;=:]*)?)" }

    /// 检测可离线的链接，包括磁力链接、电驴、迅雷格式，使用时要 NSRegularExpressionCaseInsensitive
    static var RegularMagnet:  String { return "(magnet:\\?[\\w\\+\\?\\.&=:%-]+[a-zA-Z0-9])|(ed2k://[^\\s]*)|(thunder://[^\\s]*)" }
    
    /// 邮箱正则
    static var RegularEmail:   String { return "\\w[-\\w.+]*@([A-Za-z0-9][-A-Za-z0-9]+\\.)+[A-Za-z]{2,14}" }
    
//    /// 115组织域名正则
//    static var RegularOOFLink: String { return "http[s]?://yun.115[r]?[c]?.com/\\d*\\?.*?url=(.*)&?" }
    
    /// 表情正则
    static var RegularEmoji: String { return "[\\ud83c\\udc00-\\ud83c\\udfff]|[\\ud83d\\udc00-\\ud83d\\udfff]|[\\u2600-\\u27ff].*?"}
    
    private static let cache = NSCache<NSString, NSRegularExpression>()
    
    /// NSRegularExpression的初始化(优先取缓存，没有创建)
    ///
    /// - Parameters:
    ///   - pattern: 正则串
    ///   - options: NSRegularExpression.Options
    /// - Returns: 返回'NSRegularExpression'实例
    /// - Throws: 异常处理
    class func cachedPattern(_ pattern: String, options: NSRegularExpression.Options) throws -> NSRegularExpression {
        let key = pattern + "-NSRegularExpressionOptions:\(options.rawValue)" as NSString
        if let regular = cache.object(forKey: key) {
            return regular
        } else {
            let regular = try NSRegularExpression(pattern: pattern, options: options)
            cache.setObject(regular, forKey: key)
            return regular
        }
    }
    
}

// MARK: 数组去重
extension Array {
    func filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({filter($0)}).contains(key) {
                result.append(value)
            }
        }
        return result
    }
   
//    subscript (safe index: Int) -> Element? {
//        return indices.contains(index) ? self[index] : nil//(0..<count).contains(index) ? self[index] : nil
//    }
    
}

extension Collection {
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}


extension Array where Element: Equatable {
    func removingDuplicates() -> Array {
        return reduce(into: []) { result, element in
            if !result.contains(element) {
                result.append(element)
            }
        }
    }
    
    mutating func append(safe newElement: Array.Element?) {
        if let newElement = newElement {
            append(newElement)
        }
    }
}


//业务需求相关的
// MARK: String的工具类
extension String {
    //传进来的字串，是否是图片的后缀名
    func isPicSuffix() -> Bool {
        let upString = self.uppercased()
        if upString == "GIF" || upString == "JPEG" || upString == "PNG" || upString == "WEBP" || upString == "TIFF" || upString == "BMP" || upString == "JPG" || upString == "SVG" {
            return true
        }
        return false
    }
}

// MARK: NSString的工具类
extension NSString {
    //传进来的字串，是否是图片的后缀名
    func isPicSuffix() -> Bool {
        let upString = self.uppercased
        return upString.isPicSuffix()
    }
}

// MARK: Double的工具类
extension Double {
    
    /// 返回保留多少位小数的double
    ///
    /// - Parameter places: 保留的小数位数
    /// - Returns: 处理后的double
    func roundTo(places:Int) -> Double {
        return NSDecimalNumber(value: self).rounding(accordingToBehavior: NSDecimalNumberHandler(roundingMode: .plain, scale: Int16(places), raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)).doubleValue
//        let divisor = pow(10.0, Double(places))
//        return (self * divisor).rounded() / divisor
    }
    
    
    /// 将Double类型*10000转成Int类型  double运算会有精度问题，因此需要该方法转换
    ///
    /// - Returns: 一个已经*10000的int值
    func toServiceInt() -> Int {
        var str = toAmoutString()
//        if str == "0" {
//            return 0
//        }
        let arr = str.components(separatedBy: ".")
        if arr.count > 1 {
            str = arr[0] + arr[1]
            for _ in 0..<(4-arr[1].count) {
                str = str + "0"
            }
        } else {
            str = str + "0000"
        }
        return Int(str) ?? 0
    }
    
    func toAmoutString(places: Int = 4) -> String {
        if self == 0 {
            return "0"
        }
        let str = String(format: "%.\(places)f", self)
        
        if str.count > 1, str.components(separatedBy: ".").count == 2 {/// 有小数点
            
            let strArr = str.components(separatedBy: ".")
            /// 小数部分
            var last = strArr[1]
            /// 几位小数循环几遍
            for _ in 0..<places {
                /// 判断最后一位是否为0， 0这移除最后一位
                if last.last == "0" {
                    _ = last.popLast()
                } else {
                    /// 如果不是直接退出循环
                    break
                }
            }
//            判断最后一位是否为”“空字符串,空则返回前办部分
            if last.isEmpty {
                return strArr[0]
            } else {
                return strArr[0] + "." + last
            }
        }
        return str
    }
}

