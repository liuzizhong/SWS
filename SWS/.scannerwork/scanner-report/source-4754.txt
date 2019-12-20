//
//  UIView+ACBadge.swift
//  ACBadgeDemo
//
//  Created by ac on 2017/5/7.
//  Copyright © 2017年 ac. All rights reserved.
//

import UIKit

extension UIView {
    
    private static var ac_badgeBackgroundColorKey: Character!
    private static var ac_badgeTextColorKey: Character!
    private static var ac_badgeKey: Character!
    private static var ac_badgeRedDotWidthKey: Character!
    private static var ac_badgeCenterOffsetKey: Character!
    private static var ac_badgeFontKey: Character!
    private static var ac_badgeMaximumNumberKey: Character!
    private static var ac_badgeTextKey: Character!
    
    public var ac_badgeBackgroundColor: UIColor {
        set {
            objc_setAssociatedObject(self, &UIView.ac_badgeBackgroundColorKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            if let badge = ac_badge {
                badge.backgroundColor = newValue
                setNeedsLayout()
            }
        }
        get {
            return (objc_getAssociatedObject(self, &UIView.ac_badgeBackgroundColorKey) as? UIColor) ?? ACBadge.default.backgroundColor
        }
    }
    
    public var ac_badgeTextColor: UIColor {
        set {
            objc_setAssociatedObject(self, &UIView.ac_badgeTextColorKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            if let badge = ac_badge {
                badge.setTitleColor(newValue, for: .normal)
                setNeedsLayout()
            }
        }
        get {
            return (objc_getAssociatedObject(self, &UIView.ac_badgeTextColorKey) as? UIColor) ?? ACBadge.default.textColor
        }
    }
    
    public var ac_badgeRedDotWidth: CGFloat {
        set {
            objc_setAssociatedObject(self, &UIView.ac_badgeRedDotWidthKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return (objc_getAssociatedObject(self, &UIView.ac_badgeRedDotWidthKey) as? CGFloat) ?? ACBadge.default.redDotWidth
        }
    }
    
    public var ac_badge: UIButton? {
        set {
            objc_setAssociatedObject(self, &UIView.ac_badgeKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &UIView.ac_badgeKey) as? UIButton
        }
    }
    
    public var ac_badgeCenterOffset: CGPoint {
        set {
            objc_setAssociatedObject(self, &UIView.ac_badgeCenterOffsetKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            if let badge = ac_badge {
                if tag != UITabBarItem.ac_imgViewTag && superview != nil {
                    badge.center = CGPoint(x: frame.maxX + newValue.x, y: frame.origin.y + newValue.y)
                } else {
                    badge.center = CGPoint(x: frame.width + newValue.x, y: newValue.y)
                }
                setNeedsLayout()
            }
        }
        get {
            return (objc_getAssociatedObject(self, &UIView.ac_badgeCenterOffsetKey) as? CGPoint) ?? CGPoint.zero
        }
    }
    
    public var ac_badgeFont: UIFont {
        set {
            objc_setAssociatedObject(self, &UIView.ac_badgeFontKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            if let badge = ac_badge {
                badge.titleLabel?.font = newValue
                setNeedsLayout()
            }
        }
        get {
            return (objc_getAssociatedObject(self, &UIView.ac_badgeFontKey) as? UIFont) ?? ACBadge.default.font
        }
    }
    
    // badge的最大值，如果超过最大值，显示“最大值+”，比如最大值为99，超过99，显示“99+”，默认为0（没有最大值）
    public var ac_badgeMaximumNumber: Int {
        set {
            objc_setAssociatedObject(self, &UIView.ac_badgeMaximumNumberKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return (objc_getAssociatedObject(self, &UIView.ac_badgeMaximumNumberKey) as? Int) ?? ACBadge.default.maximumNumber
        }
    }
    
    // 仅适用于type为number的bagde
    public var ac_badgeText: Int {
        set {
            objc_setAssociatedObject(self, &UIView.ac_badgeTextKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            if ac_badge != nil && ac_badge!.tag == UIView.ac_numberTag {
                ac_showBadge(with: .number(with: newValue))
                setNeedsLayout()
            }
        }
        get {
            return (objc_getAssociatedObject(self, &UIView.ac_badgeTextKey) as? Int) ?? 0
        }
    }
    
    func ac_badgeCount() -> Int {
        if let badge = ac_badge, let titleLabel = badge.titleLabel, let text = titleLabel.text  {
            return Int(text)!
        }
        return 0
    }
}

extension UIView {
    
    fileprivate static let ac_redDotTag = 1001
    fileprivate static let ac_numberTag = 1002
    
    public func ac_showBadge(with type: ACBadge.ACBadgeType) {
        switch type {
        case .redDot:
            ac_showRedDotBadge()
        case .number(with: let num):
            ac_showNumberBadge(with: num)
        }
    }
    
    public func ac_clearBadge() {
        ac_badge?.isHidden = true
    }
    
    // 让之前clear过的badge重新出现，badge的值为clear之前的值
    public func ac_resumeBadge() {
        if let badge = ac_badge, badge.isHidden {
            badge.isHidden = false
        }
    }
    
    public func ac_showRedDot(_ isShow: Bool) {
        isShow ? ac_showBadge(with: .redDot) : ac_clearBadge()
    }
    
    private func ac_showRedDotBadge() {
        ac_initBadgeView(UIView.ac_redDotTag)
        ac_badge?.setTitle("", for: .normal)
        ac_badge?.isHidden = false
        
        superview?.bringSubviewToFront(ac_badge!)
    }
    
    private func ac_showNumberBadge(with num: Int) {
        if num < 0 { return }
        ac_initBadgeView(UIView.ac_numberTag)
        ac_badge?.tag = UIView.ac_numberTag
        ac_badge?.isHidden = (num == 0)
        ac_badge?.titleLabel?.font = ac_badgeFont
        if ac_badgeMaximumNumber > 0 {
            ac_badge?.setTitle(num > ac_badgeMaximumNumber ? "\(ac_badgeMaximumNumber)+" : "\(num)", for: .normal)
        } else {
            ac_badge?.setTitle("\(num)", for: .normal)
        }
        let att = NSMutableAttributedString(string: ac_badge?.titleLabel?.text ?? "")
        att.addAttributes([NSAttributedString.Key.font: ac_badge!.titleLabel?.font ?? 11], range: NSRange(location: 0, length: (ac_badge?.titleLabel?.text ?? "").count))
        ac_badge?.frame = att.boundingRect(with: CGSize.zero, options: [.usesLineFragmentOrigin,.usesFontLeading], context: nil)
        ac_badge?.frame.size.width = CGFloat(Int(ac_badge!.frame.size.width)) + 8
        ac_badge?.frame.size.height = CGFloat(Int(ac_badge!.frame.size.height)) + 4
        if ac_badge!.frame.size.width < ac_badge!.frame.size.height {
            ac_badge!.frame.size.width = ac_badge!.frame.size.height
        }
        
        layoutIfNeeded()
        if let superView = superview, tag != UITabBarItem.ac_imgViewTag {
            superView.layoutIfNeeded()
            ac_badge!.center = CGPoint(x: frame.maxX + ac_badgeCenterOffset.x, y: frame.origin.y + ac_badgeCenterOffset.y)
        } else {
            ac_badge?.center = CGPoint(x: frame.width + ac_badgeCenterOffset.x, y: ac_badgeCenterOffset.y)
        }
        ac_badge?.layer.cornerRadius = ac_badge!.frame.height / 2
        
        superview?.bringSubviewToFront(ac_badge!)
    }
    
    private func ac_initBadgeView(_ type: Int) {
        if ac_badge?.tag != type {
            if ac_badge == nil {
                ac_badge = UIButton()
            }
            ac_badge?.layer.masksToBounds = true
            ac_badge?.layer.borderColor = UIColor.white.cgColor
            ac_badge?.layer.borderWidth = 1
            ac_badge?.frame = CGRect(x: frame.width, y: -ac_badgeRedDotWidth, width: ac_badgeRedDotWidth, height: ac_badgeRedDotWidth)
            ac_badge!.titleLabel?.textAlignment = .center
//            ac_badge!.backgroundColor = ac_badgeBackgroundColor
            ac_badge!.setBackgroundImage(UIImage.image(solidColor: #colorLiteral(red: 1, green: 0.2509803922, blue: 0.2509803922, alpha: 1), size: CGSize(width: 16, height: 16)), for: .normal)
            ac_badge!.setTitleColor(ac_badgeTextColor, for: .normal)
            ac_badge?.isUserInteractionEnabled = false
            ac_badge!.tag = UIView.ac_redDotTag
            layoutIfNeeded()
            ac_badge!.layer.cornerRadius = ac_badge!.frame.height / 2
            if let superView = superview, tag != UITabBarItem.ac_imgViewTag {
                superView.layoutIfNeeded()
                ac_badge!.center = CGPoint(x: frame.maxX + ac_badgeCenterOffset.x, y: frame.origin.y + ac_badgeCenterOffset.y)
                superView.addSubview(ac_badge!)
                superView.bringSubviewToFront(ac_badge!)
            } else {
                ac_badge!.center = CGPoint(x: frame.width + ac_badgeCenterOffset.x, y: ac_badgeCenterOffset.y)
                addSubview(ac_badge!)
                bringSubviewToFront(ac_badge!)
            }
            superview?.bringSubviewToFront(ac_badge!)
        }
    }
    
}


