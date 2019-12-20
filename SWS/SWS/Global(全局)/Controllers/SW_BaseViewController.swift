//
//  SW_BaseViewController.swift
//  SWS
//
//  Created by jayway on 2017/12/23.
//  Copyright © 2017年 yuanrui. All rights reserved.
//  [自定义Vc] -> [SWS]

import UIKit

class SW_BaseViewController: UIViewController {

//    var navView: SW_NavView?    //导航栏
    weak var tabbarView: SW_TabBarView?  //底部导航栏
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAttributeToBaseVc()    //设置属性
        // Do any additional setup after loading the view.
    }
    
    //MARK: -设置页面属性
    func setupAttributeToBaseVc() -> Void {
        view.backgroundColor = HexStringToColor("#FFFFFF")  //登录控制器背景颜色

        guard let tabbarController = tabBarController else { return }
        
        let tabbarVc: SW_TabBarController = tabbarController as! SW_TabBarController
        tabbarView = tabbarVc.tabBarView
        
    }

    //MARK: -页面消失
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //取消所有网络请求
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    /**
     禁止具体某个viewController的旋转
     */
    open override var shouldAutorotate : Bool {
//        if isIPad {//  ???  ipad  才旋转？？
//            return super.shouldAutorotate
//        } else {
            return true
//        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        if isIPad {
//            return .all
//        } else {
            return .portrait
//        }
    }
}



extension UIViewController {
    
    private struct AssociatedKeys {
        static var isHideTabBarKey = "UIViewController.isHideTabBar"
    }
    
    var isHideTabBar: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.isHideTabBarKey) as? Bool ?? true
        }
        set (isHide) {
            objc_setAssociatedObject(self, &AssociatedKeys.isHideTabBarKey, isHide, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    
    func isCurrentViewControllerVisible() -> Bool {
        return isViewLoaded && view.window != nil
    }
}
