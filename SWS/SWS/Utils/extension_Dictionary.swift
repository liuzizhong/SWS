//
//  extension_Dictionary.swift
//  SWS
//
//  Created by jayway on 2018/4/10.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Foundation

extension Array {
    
    func changeNull() -> [Any] {
        /// 值对应的是个数组，要遍历数组
        var newArray = [Any]()
        self.forEach { (subValue) in
            if subValue is NSNull {
                newArray.append("")
            } else if subValue is Dictionary<String, Any> {
                newArray.append((subValue as! Dictionary<String, Any>).changeNull())
            } else if subValue is Array<Any> {
                newArray.append((subValue as! Array<Any>).changeNull())
            } else {
                newArray.append(subValue as Any)
            }
        }
        return newArray
    }
    
}

extension Dictionary {
    //清除字典中的null值,有null可能会引起崩溃 暂时这样写 写法不好
    func changeNull() -> [String:Any] {
        var newDict = [String:Any]()
        for (key, value) in self {
            if (key is String) {
                if value is NSNull {
                    newDict[key as! String] = ""
                } else if value is Dictionary {
                    newDict[key as! String] = (value as! Dictionary).changeNull()
                } else if value is Array<Any> {
                    newDict[key as! String] = (value as! Array<Any>).changeNull()
                } else {
                    newDict[key as! String] = value as Any
                }
            }
        }
        return newDict
    }
    
    func toJSONString() -> String {
        if let data = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions.prettyPrinted) {
            return String(data: data, encoding: String.Encoding.utf8) ?? ""
        } else {
            return ""
        }
    }
    
}
