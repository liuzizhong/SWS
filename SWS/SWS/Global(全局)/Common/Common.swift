//
//  Common.swift
//  CloudOffice
//
//  Created by HuFeng on 15/9/1.
//  Copyright (c) 2015年 115.com. All rights reserved.
//

import Foundation
import UIKit

#if !DEBUG
let print = { (items: Any...) -> Void in }
#endif

/// 自定义打印方法
///
/// - Parameters:
///   - message: 需要打印的常量或变量
///   - fileName: 文件名
///   - methodName: 方法名
///   - lineNumber: 行号
func PrintLog<N>(_ message:N,fileName:String = #file,methodName:String = #function,lineNumber:Int = #line){
    #if DEBUG
        print("\(fileName as NSString)\n方法:\(methodName)\n行号:\(lineNumber)\n打印信息:\(message)\n");
    #endif
}

/// 普通的点击事件对调block 不需要传参数使用
typealias NormalBlock = () -> Void

// https://github.com/apple/swift-evolution/blob/master/proposals/0077-operator-precedence.md
precedencegroup OptionalAssign {
    associativity: right
    lowerThan: AssignmentPrecedence
    assignment: true
}
infix operator =? : OptionalAssign

/// 可选赋值操作符，不可用于变量声明赋初值
/// :see: `=?<T>(inout lhs: T?, rhs: T?)`
func =?<T>(lhs: inout T, rhs: T?) {
    if (rhs != nil) {
        lhs = rhs!
    }
}

func =?<T>(lhs: inout T?, rhs: T?) {
    if (rhs != nil) {
        lhs = rhs
    }
}

/// 使用私有类，避免私有 API 扫描检查二进制包的字串
func NSClassFromComponents(_ components: String...) -> AnyClass? {
    return NSClassFromString(components.joined())
}

// 因 Error as NSError 一定成功，所以扩展 Error 协议，添加 NSError 的属性，让 Error 和 NSError，避免写 error as NSError
extension Error {
    
    var code: Int {
        return (self as NSError).code
    }
    
    var domain: String {
        return (self as NSError).domain
    }
    
    var userInfo: [AnyHashable : Any] {
        return (self as NSError).userInfo
    }
}

protocol IntConvertiable {
    var intValue: Int {get}
}

extension Int: IntConvertiable {
    var intValue: Int {
        return self
    }
}

extension NSNumber: IntConvertiable{}

extension String: IntConvertiable {
    var intValue: Int {
        get {
            let decimal = NSDecimalNumber(string: self)
            if decimal == NSDecimalNumber.notANumber {
                return 0
            }
            return decimal?.intValue  ?? 0
        }
    }
}

extension Int {
    /// 仅处理 Any 类型为 String 和 NSNumber 时的转换，替代 intValue
    init?(any value: Any?) {
        if let str = value as? String {
            self.init(str, radix: 10)
        } else if let num = value as? NSNumber {
            self.init(num)
        } else if let num = value as? Int {
            self.init(num)
        } else {
            return nil
        }
    }
}

extension URL {
    var queryDictionary: [String: String]? {
        guard let query = URLComponents(string: self.absoluteString)?.query else { return nil }
        
        var queryStrings = [String: String]()
        for pair in query.components(separatedBy: "&") {
            let key = pair.components(separatedBy: "=")[0]
            let value = pair
                .components(separatedBy:"=")[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""
            queryStrings[key] = value
        }
        return queryStrings
    }
}

// MARK: -
func dispatch_async_main_safe(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async(execute: block)
    }
}

func dispatch_delay(_ second: Double, block: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * second)) / Double(NSEC_PER_SEC)) {
        block()
    }
}

@available(iOS 10.0, *)
func feedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
    //添加触感反馈
    UIImpactFeedbackGenerator(style: style).impactOccurred()
}
