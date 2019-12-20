//
//  NSObjectExtension.swift
//  Browser
//
//  Created by 西方 on 2018/1/18.
//  Copyright © 2018年 114la.com. All rights reserved.
//

import UIKit

extension NSObject {
    
    /// 移除所以的QMUIAlertController
    func removeAllQMUIAlertController() {
        UIApplication.shared.windows.forEach({ (window) in
            if let window = window as? QMUIModalPresentationWindow {
                window.removeAllSubviews()
                window.isHidden = true
                window.rootViewController = nil
            }
        })
    }

    
    /// 获取顶层的viewControler
    ///
    /// - Returns: 顶层vc
    func getTopVC() -> UIViewController {
        let rootVC = UIApplication.shared.keyWindow?.rootViewController
        let currentVC = self.getCurrentViewConroller(from: rootVC!)
        return currentVC
    }
    
    /// 循环找到最顶部的viewController
    ///
    /// - Parameter from: 需要寻找这个vc是否是最上层的
    /// - Returns: 返回最顶层的vc
    fileprivate func getCurrentViewConroller(from:UIViewController) -> UIViewController {
        
        var currentVC = from
        
        if (from.presentedViewController != nil) {
            currentVC = from.presentedViewController!
        }
        
        if let tab = currentVC as? UITabBarController {
            currentVC = self.getCurrentViewConroller(from:tab.selectedViewController!)
        }
        if let nav = currentVC as? UINavigationController {
            currentVC = self.getCurrentViewConroller(from: nav.visibleViewController!)
        }
        
        return currentVC
        
    }
    
    
    // Retrieves an array of property names found on the current object
    func propertyNames() -> [String] {
        var results = [String]()
        
        // retrieve the properties via the class_copyPropertyList function
        var count: UInt32 = 0
        let myClass: AnyClass = self.classForCoder
        let properties = class_copyPropertyList(myClass, &count)!
        
        // iterate each objc_property_t struct
        for i in 0 ..< count {
            let property = properties[Int(i)]
            let cname = property_getName(property)
            
            //convert the c string into a Swift string
            let name = String(cString: cname)
            results.append(name)
        }
        
        
        return results
    }
}

