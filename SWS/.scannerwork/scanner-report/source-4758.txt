//
//  Badge.swift
//  UDPhone
//
//  Created by 曹理鹏 on 2017/8/16.
//  Copyright © 2017年 115.com. All rights reserved.
//

//  ================================================文档============================================================================
//
//                                  给一个View，tabBarItem，barButtonItem设置红点                                                  ||
//
//          1. 不带数字的小红点)一般用户通知数据)                instance.badgeView(state:true)  // false隐藏，true显示                 ||
//
//          2. 带数字的小红点(一般用于消息数据)                  instance.badgeValue(number: 10) // 0隐藏，非0显示                      ||
//
//          3. 当这个空间被设置过两种不同类型的红点使用            instance.badgeClear()                                                ||
//
//          2. 带数字小红点对应的红点值                         instance.badgeCount                                                  ||
//
//          3. 当这个空间被设置过两种不同类型的红点使用            instance.badgeMaxValue(number: 0) // 0无限制，非0代限制对应的值，默认99    ||
//
//          4. 设置红点的宽度,直径(默认已经是8)                  instance.badgeWidth = 8                                              ||
//
//          5. 设置红点的偏移,中心点y值(默认右上角合并)            instance.badgeOffset = CGPoint(x:10, y:0)                            ||
//
//  ==================================================说明==========================================================================

import UIKit

protocol UDBadge {
    
    /// 显示一个红点
    ///
    /// - Parameter isShow: 如果为true则显示，否则隐藏
    func badgeView(state: Bool)
    
    /// 显示一个带数字的红点
    ///
    /// - Parameter number: 如果数字大于0则显示，否则隐藏
    func badgeValue(number: Int)
    
    /// 清空红点：不管是否有数字都会被清除
    func badgeClear()
    
    /// 获取数值红点对应的红点数
    ///
    /// - Returns: 数字红点上对应的数值（Int）
    func badgeCount() -> Int
    
//    /// - Returns: 设置控制最大限度红点数
//    func badgeMaxValue(number: Int)
    
    /// 设置红点的宽度
    ///
    /// - Parameter width: 红点正常宽度（直径），如果设置数字并且数字超过9宽度会自适应
    var badgeWidth: CGFloat { get set }
    
    /// 设置红点的偏移量
    ///
    /// - Parameter point: 以当前控件右上角边界为中心点
    var badgeOffset: CGPoint { get set }
    
}

// MARK: - UIView红点控制
extension UIView: UDBadge {
    
    func badgeView(state: Bool) {
        self.ac_showRedDot(state)
    }
    
    func badgeValue(number: Int) {
        self.ac_showBadge(with: .number(with: number))
    }
    
    func badgeClear() {
        self.ac_clearBadge()
    }
    
    func badgeCount() -> Int {
        return self.ac_badgeCount()
    }
    
//    func badgeMaxValue(number: Int) {
//        self.ac_badgeMaximumNumber = number
//    }
    
    var badgeOffset: CGPoint {
        get {
            return self.ac_badgeCenterOffset
        }
        set {
            self.ac_badgeCenterOffset = newValue
        }
    }
    
    var badgeWidth: CGFloat {
        get {
            return self.ac_badgeRedDotWidth
        }
        set {
            self.ac_badgeRedDotWidth = newValue
        }
    }
    
}

// MARK: - UITabBarItem红点控制
extension UITabBarItem: UDBadge {
    
    func badgeView(state: Bool) {
        self.ac_showRedDot(state)
    }
    
    func badgeValue(number: Int) {
        self.ac_showBadge(with: .number(with: number))
    }
    
    func badgeClear() {
        self.ac_clearBadge()
    }
    
    func badgeCount() -> Int {
        return self.ac_badgeCount()
    }
    
//    func badgeMaxValue(number: Int) {
//        self.ac_badgeMaximumNumber = number
//    }
    
    var badgeOffset: CGPoint {
        get {
            return self.ac_badgeCenterOffset
        }
        set {
            self.ac_badgeCenterOffset = newValue
        }
    }
    
    var badgeWidth: CGFloat {
        get {
            return self.ac_badgeRedDotWidth
        }
        set {
            self.ac_badgeRedDotWidth = newValue
        }
    }
    
}

// MARK: - UIBarButtonItem红点控制
extension UIBarButtonItem: UDBadge {
    
    func badgeView(state: Bool) {
        self.ac_showRedDot(state)
    }
    
    func badgeValue(number: Int) {
        self.ac_showBadge(with: .number(with: number))
    }
    
    func badgeClear() {
        self.ac_clearBadge()
    }
    
    func badgeCount() -> Int {
        return self.ac_badgeCount()
    }
    
//    func badgeMaxValue(number: Int) {
//        self.ac_badgeMaximumNumber = number
//    }
    
    var badgeOffset: CGPoint {
        get {
            return self.ac_badgeCenterOffset
        }
        set {
            self.ac_badgeCenterOffset = newValue
        }
    }
    
    var badgeWidth: CGFloat {
        get {
            return self.ac_badgeRedDotWidth
        }
        set {
            self.ac_badgeRedDotWidth = newValue
        }
    }
    
}

