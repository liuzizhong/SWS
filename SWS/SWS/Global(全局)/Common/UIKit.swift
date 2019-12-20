//
//  UIKit.swift
//  CloudOffice
//
//  Created by 王珊 on 3/13/17.
//  Copyright © 2017 115.com. All rights reserved.
//

import Foundation
import UIKit


@objc protocol CurrentControllerProtocol {
    func currentController() -> UIViewController
}

// MARK: - UIApplication
extension UIApplication {
    func open(scheme: String) {
        if let url = URL(string: scheme) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                    print("Open \(scheme): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(scheme): \(success)")
            }
        }
    }
    
    func openSetting() {
        self.open(scheme: UIApplication.openSettingsURLString)
    }
}

private func objcast<T>(_ obj: AnyObject) -> T {
    return obj as! T
}

private extension NSObject {
    class var className: String {
        return (NSStringFromClass(self) as NSString).pathExtension
    }
}



extension UIView {
    class func instantiateWithNib() -> Self {
        let view = Bundle.main.loadNibNamed(self.className, owner: nil, options: nil)?.first
        assert(view != nil, "初始化失败，请确认xib文件与view同名切在xib里第一位")
        return objcast(view! as AnyObject)
    }
    
    /// 当前 view 所在的 UIViewController，只有被 addSubview 后才能获取到
    var viewController: UIViewController? {
        var responder = self.next
        while responder != nil {
            if let viewController = responder as? UIViewController {
                assert(self.isDescendant(of: viewController.view), "UIView.viewController找到了错误的UIViewControler")
                return viewController
            }
            responder = responder?.next
        }
        return nil
    }

}

extension UITableView {
    
    func registerNib(_ nibClass: AnyClass, forCellReuseIdentifier identifier: String) {
        self.register(UINib(nibName: String(describing: nibClass), bundle: nil), forCellReuseIdentifier: identifier)
    }
    
    /// 刷新数据并渐变出现
    func reloadAndFadeAnimation() {
        self.alpha = 0
        self.reloadData()
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.alpha = 1
        }, completion: nil)
    }
    
    //MARK: - 刷新页面 并保留原来的位置
    func reloadDataAndScrollOriginal(_ block: NormalBlock?) {
        let originalOffSet = contentOffset
        block?()
        /// 原来有偏移才处理，没偏移不处理
        guard originalOffSet.y != 0 else { return }
        let maxOff = max(contentSize.height - self.height + contentInset.bottom, 1)
        if originalOffSet.y > maxOff {
            setContentOffset(CGPoint(x: 0, y: maxOff), animated: true)
        } else {
            setContentOffset(originalOffSet, animated: false)
        }
    }
}

extension UICollectionView {
    
    func registerNib(_ nibClass: AnyClass, forCellReuseIdentifier identifier: String) {
        self.register(UINib(nibName: String(describing: nibClass), bundle: nil), forCellWithReuseIdentifier: identifier)
    }
    
}

extension UIView {
    
    /// 添加阴影
    func addShadow(_ color: UIColor = UIColor(r: 48, g: 55, b: 80, alpha: 1).withAlphaComponent(0.3)) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 3
        layer.shadowOffset = CGSize.init(width: 0, height: 0)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    func addSubviews(_ views: [UIView]) {
        views.forEach(addSubview)
    }
    
    /// 添加虚线边框
    ///
    /// - Parameter cornerRadius: 圆角
    @discardableResult
    func addDottedLine(cornerRadius: CGFloat = 0) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.frame = bounds
        layer.backgroundColor = UIColor.clear.cgColor
        let path = UIBezierPath(roundedRect: layer.frame, cornerRadius: cornerRadius)
        layer.path = path.cgPath
        layer.lineWidth = 0.5
        layer.lineDashPattern = [2,2]
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.v2Color.lightGray.cgColor
        self.layer.addSublayer(layer)
        return layer
    }
    
    func showOrHide(show: Bool) {
        let alpha: CGFloat = show ? 1 : 0
        if self.alpha != alpha {
            UIView.animate {
                self.alpha = alpha
            }
        }
    }
    
    static func animate(_ animations: @escaping () -> Void) {
        animate(withDuration: SystemAnimationDuration, animations: animations)
    }
    
    @discardableResult
    func addTopLine(_ edgeInsets: UIEdgeInsets = .zero) -> UIView {
        let line = UIView()
        line.backgroundColor = UIColor.mainColor.separator
        addSubview(line)
        line.snp.makeConstraints { (make) in
            make.top.equalTo(edgeInsets.top)
            make.leading.equalTo(edgeInsets.left)
            make.trailing.equalTo(-edgeInsets.right)
            make.height.equalTo(SingleLineWidth)
        }
        return line
    }
    
    @discardableResult
    func addBottomLine(_ edgeInsets: UIEdgeInsets = .zero, height: CGFloat = SingleLineWidth) -> UIView  {
        let line = UIView()
        line.backgroundColor = UIColor.mainColor.separator
        addSubview(line)
        line.snp.makeConstraints { (make) in
            make.bottom.equalTo(-edgeInsets.bottom)
            make.leading.equalTo(edgeInsets.left)
            make.trailing.equalTo(-edgeInsets.right)
            make.height.equalTo(height)
        }
        return line
    }
    
    func addRoundedDottedBorder(_ lineDashPattern: [NSNumber] = [3,3], lineColor: UIColor = #colorLiteral(red: 0.7450980392, green: 0.7450980392, blue: 0.7450980392, alpha: 1), cornerRadius: Int = 0, lineWidth: CGFloat = 1) {
        layoutIfNeeded()
        let maskPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let border = CAShapeLayer()

        border.strokeColor = lineColor.cgColor
        border.masksToBounds = true
        
        border.fillColor = nil
        border.path = maskPath.cgPath
        border.frame = bounds
        border.lineWidth = lineWidth
        border.lineCap = .square//CAShapeLayerLineCap(rawValue: "square")
        border.lineDashPattern = lineDashPattern
        layer.addSublayer(border)
    }
}

extension UITextField {
    
    func setPlaceholderColor(_ color: UIColor) {
        let iVar = class_getInstanceVariable(UITextField.self, "_placeholderLabel")!
        let placeholderLabel = object_getIvar(self, iVar) as? UILabel
        placeholderLabel?.textColor = color
    }
    
}

// MARK: -
extension UIImage {
    
    /// 生成一张纯色图片
    class func image(solidColor: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        solidColor.set()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}

extension UIWindow {
    /// Fix for http://stackoverflow.com/a/27153956/849645
    func change(rootViewController newRootViewController: UIViewController) {
        let previousViewController = rootViewController
        rootViewController = newRootViewController
        if #available(iOS 13.0, *) {//if @available(iOS 11.0, *) {
            return
        }
        // Update status bar appearance using the new view controllers appearance - animate if needed
        if UIView.areAnimationsEnabled {
            UIView.animate(withDuration: CATransaction.animationDuration()) {
                newRootViewController.setNeedsStatusBarAppearanceUpdate()
            }
        } else {
            newRootViewController.setNeedsStatusBarAppearanceUpdate()
        }
        /// The presenting view controllers view doesn't get removed from the window as its currently transistioning and presenting a view controller
        if let transitionViewClass = NSClassFromString("UITransitionView") {
            for subview in subviews where subview.isKind(of: transitionViewClass) {
                subview.removeFromSuperview()
            }
        }
        if let previousViewController = previousViewController {
            // Allow the view controller to be deallocated
            previousViewController.dismiss(animated: false) {
                // Remove the root view in case its still showing
                previousViewController.view.removeFromSuperview()
            }
        }
        // 以上代码来源于 stackoverflow 答案，但实测都没有效果（仅iOS10上测试），但仍保留，可能其他系统版本上有效
        // 最终有效的代码只有以下一句
        previousViewController?.view.perform(#selector(UIView.removeFromSuperview), with: nil, afterDelay: 0.3)
    }
}

// MARK: - UIViewController
protocol UIViewControllerStoryboardProtocol {
    static func storyboardName() -> String
}

extension UIViewController: UIViewControllerStoryboardProtocol {
    class func instantiateWithStoryboard(_ storyboard: UIStoryboard?) -> Self {
        if let vc: UIViewController = storyboard?.instantiateViewController(withIdentifier: self.className) {
            return objcast(vc)
        } else {
            return objcast(UIStoryboard(name: self.storyboardName(), bundle: nil).instantiateViewController(withIdentifier: self.className))
        }
    }
    
    class func storyboardName() -> String {
        return ""
    }
    
    func closeViewController(animated: Bool, completion: (() -> Void)? = nil) {
        if let viewControllers = self.navigationController?.viewControllers, viewControllers.count > 1 {
            self.navigationController?.popViewController(animated: animated)
            completion?()
        } else {
            //如果是根目录就Dismiss
            self.dismiss(animated: animated, completion: completion)
        }
    }
}

//MARK: - 
extension UINavigationController {
    func removeViewController(_ classes: [AnyClass]) {
        let arrayVc: NSMutableArray = NSMutableArray(array: self.viewControllers)
        arrayVc.enumerateObjects(options: .reverse) { (vc, index, stop) in
            if classes.contains(where: { (aClass) -> Bool in
                return (vc as! UIViewController).classForCoder == aClass
            }) {
                arrayVc.remove(vc)
            }
        }
        self.viewControllers = arrayVc as! [UIViewController]
    }
}

// MARK: - UITableViewCell
protocol UITableViewCellDequeueProtocol {
    static func reuseIdentifier() -> String
}

extension UITableViewCell: UITableViewCellDequeueProtocol {
    class func dequeueReusableCellFromTableView(_ tableView: UITableView, forIndexPath: IndexPath) -> Self {
        return objcast(tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier(), for: forIndexPath))
    }
    
    class func reuseIdentifier() -> String {
        return NSStringFromClass(self.self)
    }
}

// MARK: - UICollectionReusableView
extension UICollectionReusableView: UITableViewCellDequeueProtocol {
    
    class func reuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
}

// MARK: - Collection
extension Collection {
    public func cascade<T>(_ initial: T, handle: (T, Self.Iterator.Element) -> T) -> T {
        var p = initial
        forEach {
            p = handle(p, $0)
        }
        return p
    }
    
}





