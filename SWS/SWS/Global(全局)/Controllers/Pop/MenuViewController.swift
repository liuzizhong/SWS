//
//  MenuViewController.swift
//  UDPhone
//
//  Created by 刘健 on 2017/3/8.
//  Copyright © 2017年 115.com. All rights reserved.
//

import Foundation
import UIKit

struct MenuItem {
    
    let title: String
    let image: UIImage?
    let isShowRedDot: Bool? 
    let action: ()->Void
}

class OCMenuItem: NSObject {
    let menuItem: MenuItem
    init(title: String, image: UIImage?, isShowRedDot: Bool, action:@escaping ()->()) {
        menuItem = MenuItem(title: title, image: image, isShowRedDot: isShowRedDot, action: action)
        super.init()
    }
}

class MenuPopoverBackgroundView: UIPopoverBackgroundView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.shadowColor = UIColor.clear.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override static func contentViewInsets() -> UIEdgeInsets {
        return UIEdgeInsets(top: -12, left: 0, bottom: 9, right: 0)
    }
    
    static override func arrowHeight() -> CGFloat {
        return 20
    }
    
    override static func arrowBase() -> CGFloat {
        return 0
    }
    
    override var arrowDirection: UIPopoverArrowDirection {
        get {
            return .up
        }
        set {
            
        }
    }
    
    override var arrowOffset: CGFloat {
        get {
            return 30
        }
        set {
            
        }
    }
    
}

class MenuViewController: PopViewController {
    
    let items: [MenuItem]
    var selectedItem: MenuItem?

    override var style: PopControllerStyle {
        return .popover
    }
    
    override var cornerRadius: CGFloat {
        return 2
    }
    
    var menuRowHeight: CGFloat = 37
    
    init(items: [MenuItem]) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }
    
    init(ocItems: [OCMenuItem]) {
        var items = [MenuItem]()
        for ocItem in ocItems {
            items.append(ocItem.menuItem)
        }
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }
    
    init(items: [MenuItem], selectedItem: MenuItem? = nil) {
        self.items = items
        self.selectedItem = selectedItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dimmingView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.2)
        self.view.backgroundColor = UIColor(r: 255, g: 255, b: 255, alpha: 1)
        self.popoverPresentationController?.backgroundColor = UIColor.clear
        self.popoverPresentationController?.popoverBackgroundViewClass = MenuPopoverBackgroundView.self
        self.preferredContentSize = CGSize(width: 124, height: 120)
        self.layoutViews()
        self.updateSelectBtn()
    }
    
    deinit {
        print("MenuViewController deinit")
    }
    
    private func layoutViews() {
        var titleWidths = items.map({($0.title.size(UIFont.systemFont(ofSize: 15), width: CGFloat.greatestFiniteMagnitude)).width})
        var maxWidth = titleWidths.max() ?? 70
        let hasIcon = (items.filter{$0.image != nil}).count > 0
        if hasIcon {
            maxWidth += 40
        }
        if self.selectedItem != nil {
            maxWidth += 20
        }
        self.preferredContentSize = CGSize(width: maxWidth + 40, height: menuRowHeight * CGFloat(items.count))
        for (offset, item) in items.enumerated() {
            let button = UIButton(type: .custom)
            button.setImage(item.image, for: .normal)
            button.setTitle(item.title, for: .normal)
            button.adjustsImageWhenHighlighted = false
            button.setTitleColor(UIColor.mainColor.darkBlack, for: .normal)
            button.frame = CGRect(x: 0, y: CGFloat(offset) * menuRowHeight, width: (self.selectedItem != nil) ? self.preferredContentSize.width - 30 : self.preferredContentSize.width, height: menuRowHeight)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.addTarget(self, action: #selector(self.buttonAction(button:)), for: .touchUpInside)
            button.tag = 1155 + offset
            view.addSubview(button)
//            let highlightedImage = UIImage.solidImage(with: UIColor(r: 240, g: 240, b: 240), size: CGSize(width: button.width, height: button.height))
//            button.setBackgroundImage(highlightedImage, for: .highlighted)
            
            if let _ = self.selectedItem {
                let selectBtn = UIButton(type: .custom)
                selectBtn.adjustsImageWhenHighlighted = false
                selectBtn.frame = CGRect(x: self.preferredContentSize.width - 34, y: CGFloat(offset) * menuRowHeight, width: 20, height: menuRowHeight)
                selectBtn.addTarget(self, action: #selector(self.buttonAction(button:)), for: .touchUpInside)
                selectBtn.tag = 1355 + offset
                view.addSubview(selectBtn)
            }
            
            if item.isShowRedDot  == true {
                let redDotImgeView = UIView()
                redDotImgeView.backgroundColor = .red
                redDotImgeView.frame = CGRect(x: button.frame.width * 0.2 , y: button.frame.height * 0.2 , width: 9, height: 9)
                button.addSubview(redDotImgeView)
            }
            
            let titleWidth = titleWidths[offset]
            let contentWidth = (item.image?.size.width ?? 0) + titleWidth
            var edge = (self.preferredContentSize.width - ((self.selectedItem != nil) ? 30 : 0) - contentWidth) / 2 - 20
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -edge, bottom: 0, right: edge)
            edge -= 15
            if(hasIcon) {
                button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -edge, bottom: 0, right: edge)
            } else {
                button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -edge - 16, bottom: 0, right: 0)
            }
            if offset != items.count - 1 {
                let line = UIView(frame: CGRect(x: 20, y: CGFloat(offset + 1) * menuRowHeight, width: (self.selectedItem != nil) ? self.view.width - 40 + 44 : self.view.width - 40, height: 1 / UIScreen.main.scale))
                line.autoresizingMask = .flexibleWidth
                line.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
                view.addSubview(line)
            }
        }
    }
    
    private func updateSelectBtn() {
        guard let selectedItem = self.selectedItem else {
            return
        }
        for subView in self.view.subviews {
            let index = subView.tag - 1355
            if index >= 0 && items.count > index {
                if let btn = subView as? UIButton {
                    btn.setImage(nil, for: .normal)
                    if selectedItem.title == self.items[index].title {
                        btn.setImage(#imageLiteral(resourceName: "Main_select").rt_tintedImage(with: UIColor.mainColor.blue) , for: .normal)
                    }
                }
            }
        }
    }
    
    @objc private func buttonAction(button: UIButton) {
        if button.tag >= 1355, let _ = self.selectedItem  {
            let index = button.tag - 1355
            if items.count > index {
                removeDimmingView()
                dismiss(animated: true, completion: {
                    self.items[index].action()
                })
            }
        } else {
            let index = button.tag - 1155
            if items.count > index {
                removeDimmingView()
                dismiss(animated: true, completion: {
                    self.items[index].action()
                })
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeShadow()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeDimmingView()
    }
    
    //MARK: -移除自带的阴影，添加黑色半透明背景蒙层
    let dimmingView = UIView()
    
    /// 移除自带的阴影
    func removeShadow() {
        if let window = UIApplication.shared.delegate?.window {
            let transitionView = window?.subviews.filter({ (subview) -> Bool in
                type(of: subview) == NSClassFromComponents("UI", "Transition", "View")
            }).first
            let patchView = transitionView?.subviews.filter({ (subview) -> Bool in
                type(of: subview) == NSClassFromComponents("_", "UI", "Mirror", "Nine", "PatchView")
            }).first
            if let imageViews = patchView?.subviews.filter({ (subview) -> Bool in
                type(of: subview) == UIImageView.self
            }) {
                for imageView in imageViews {
                    imageView.isHidden = true
                }
            }
        }
    }
    
    private func removeDimmingView() {
        for subView in self.view.subviews {
            let index = subView.tag - 1355
            if index >= 0 && items.count > index {
                subView.alpha = 0
                subView.removeFromSuperview()
            }
        }
        UIView.animate(withDuration: 0.1, animations: {
            self.dimmingView.alpha = 0
        }) { (complete) in
            if complete {
                self.dimmingView.removeFromSuperview()
            }
        }
    }
    
    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        if let presentingViewController = presentingViewController {
            dimmingView.frame = presentingViewController.view.bounds
            dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            dimmingView.alpha = 0
            presentingViewController.view.addSubview(dimmingView)
            let transitionCoordinator = presentingViewController.transitionCoordinator
            transitionCoordinator?.animate(alongsideTransition: { (context) in
                self.dimmingView.alpha = 1
            }, completion: nil)
        }
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        removeDimmingView()
        return true
    }
}
