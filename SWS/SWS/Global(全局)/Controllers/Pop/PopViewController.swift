//
//  PopViewController.swift
//  115组织
//
//  Created by 胡峰 on 2016/10/31.
//  Copyright © 2016年 115.com. All rights reserved.
//

import UIKit


/// PopViewController 弹出样式，效果和 UIAlertController 一致
///
/// - alert: 弹出在屏幕中间
/// - actionSheet: iPhone 上从底部弹出，iPad 上显示会显示为 .popover 样式，必须设置 popoverPresentationController 属性
/// - popover: iPhone 和 iPad 都指向位置弹出，必须设置 popoverPresentationController 属性
/// - actionSheetPad: iPhone iPad 都显示 actionSheet 样式（从底部弹出）
@objc enum PopControllerStyle: Int {
    case alert
    case actionSheet
    case popover
    case actionSheetPad
}

/// 全局弹出窗口，继承 `PopViewController` 以自定义弹出界面，支持 storyboard 中完成界面
///
/// iPhone 和 iPad 所有弹出界面都需要使用此类，不再使用 `UIView.addSubView(:)` 的方式
class PopViewController: UIViewController, UIViewControllerTransitioningDelegate, UIPopoverPresentationControllerDelegate {
    
    /// 弹出窗口圆角，会自动设置 clipsToBounds = true
    var cornerRadius: CGFloat { return 2.0 }
    
    /// 是否允许点击空白区域关闭弹窗
    var tapToDismiss: Bool { return true }
    
    /// 弹出方式，效果和 UIAlertController 一致
    var style: PopControllerStyle { return .alert }
    
    /// .actionSheet(iPad) 和 .popover 样式需要重新指向位置时的回调，通常在转屏和 SplitView 模式时需要调整
    var willRepositionPopover: ((_ popover: PopViewController, _ rect: CGRect, _ view: UIView) -> CGRect)?
    
    // MARK: -
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        if style == .popover || (style == .actionSheet && UIDevice.current.userInterfaceIdiom == .pad) {
            modalPresentationStyle = .popover
            popoverPresentationController?.delegate = self
        } else {
            modalPresentationStyle = .custom
            transitioningDelegate = self
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        if cornerRadius > 0 {
            view.layer.cornerRadius = CGFloat(cornerRadius)
            view.clipsToBounds = true
        }
        
        assert(style != .actionSheet || popoverPresentationController?.sourceView != nil || popoverPresentationController?.barButtonItem != nil || UIDevice.current.userInterfaceIdiom == .phone, "PopControllerStyle.actionSheet 方式必须设置 popover 相关的参数，iPad 上需要")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Keyboard
    private var keyboardFrame: CGRect?
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        if let keyboardFrame = keyboardFrame {
            popController?.updateKeyboard(keyboardFrame)
        }
    }
    
    // MARK: - Delegate
    private weak var popController: PopController?
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let popController = PopController(presentedViewController: presented, presenting: presenting)
        popController.tapToDimiss = { [weak self] in
            return self?.tapToDismiss ?? true
        }
        self.popController = popController
        popController.style = style
        if let keyboardFrame = keyboardFrame {
            popController.updateKeyboard(keyboardFrame)
        }
        return popController
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func presentationController(_ presentationController: UIPresentationController, willPresentWithAdaptiveStyle style: UIModalPresentationStyle, transitionCoordinator: UIViewControllerTransitionCoordinator?) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * 0.1)) / Double(NSEC_PER_SEC)) {
            self.popoverPresentationController?.passthroughViews = nil
        }
    }
    
    func popoverPresentationController(_ popoverPresentationController: UIPopoverPresentationController, willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>, in view: AutoreleasingUnsafeMutablePointer<UIView>) {
        if let willRepositionPopover = willRepositionPopover {
            rect.pointee = willRepositionPopover(self, rect.pointee, view.pointee)
        } else if let sourceView = popoverPresentationController.sourceView {
            let sourceRect = popoverPresentationController.sourceRect
            let originRect = sourceView.frame
            let xp = sourceRect.origin.x / rect.pointee.width
            let yp = sourceRect.origin.y / rect.pointee.height
            let widthP = sourceRect.width / rect.pointee.width
            let heightP = sourceRect.height / rect.pointee.height
            let newRect = CGRect(x: originRect.width * xp, y: originRect.height * yp, width: originRect.width * widthP, height: originRect.height * heightP)
            popoverPresentationController.sourceRect = newRect
            rect.pointee = newRect
        }
    }
    
}
