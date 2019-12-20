//
//  SW_IgnoreManager.swift
//  SWS
//
//  Created by jayway on 2018/6/13.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_IgnoreManager: NSObject {
    
    static let ignoreDBPath = documentPath + "/IgnoreList.db"
    
    static let ignoreCache = YYCache(path: ignoreDBPath)

    /// 添加免打扰的员工
    ///
    /// - Parameter staffAccount: 添加的员工环信账号
    class func addIgnoreStaff(_ staffAccount: String) {
        let ignoreCacheKey =  "ignoreCacheKey\(SW_UserCenter.getUserCachePath())"
        if var ignores = SW_IgnoreManager.ignoreCache?.object(forKey: ignoreCacheKey) as? [String] {
            ignores.append(staffAccount)
            SW_IgnoreManager.ignoreCache?.setObject(ignores as NSCoding, forKey: ignoreCacheKey)
        } else {
            SW_IgnoreManager.ignoreCache?.setObject([staffAccount] as NSCoding, forKey: ignoreCacheKey)
        }
    }
    
    /// 删除免打扰的员工
    ///
    /// - Parameter staffAccount: 删除的员工环信账号
    class func removeIgnoreStaff(_ staffAccount: String) {
        let ignoreCacheKey =  "ignoreCacheKey\(SW_UserCenter.getUserCachePath())"
        if var ignores = SW_IgnoreManager.ignoreCache?.object(forKey: ignoreCacheKey) as? [String] {
            if let index = ignores.index(of: staffAccount) {
                ignores.remove(at: index)
            }
            SW_IgnoreManager.ignoreCache?.setObject(ignores as NSCoding, forKey: ignoreCacheKey)
        }
    }
    
    /// 判断员工是否在免打扰列表
    ///
    /// - Parameter staffAccount: 判断的员工环信账号
    /// - Returns: true 免打扰用户  false  不是免打扰
    @objc class func isIgnoreStaff(_ staffAccount: String) -> Bool {
        let ignoreCacheKey =  "ignoreCacheKey\(SW_UserCenter.getUserCachePath())"
        if let ignores = SW_IgnoreManager.ignoreCache?.object(forKey: ignoreCacheKey) as? [String] {
            return ignores.contains(staffAccount)
        } else {
            return false
        }
    }
    
    /// 获取所有免打扰员工
    ///
    /// - Returns: 免打扰员工列表
    class func getAllIgnoreStaffs() -> [String] {
        let ignoreCacheKey =  "ignoreCacheKey\(SW_UserCenter.getUserCachePath())"
        if let ignores = SW_IgnoreManager.ignoreCache?.object(forKey: ignoreCacheKey) as? [String] {
            return ignores
        } else {
            return []
        }
    }
}
