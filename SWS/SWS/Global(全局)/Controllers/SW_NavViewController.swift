//
//  SW_NavViewController.swift
//  SWS
//
//  Created by jayway on 2017/12/23.
//  Copyright © 2017年 yuanrui. All rights reserved.
//

import UIKit

class SW_NavViewController: MLNavigationController {
    weak var tabBarVc: SW_TabBarController? //当前控制器的tabBarVc
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        defer {
            //2.获取tabBar
            tabBarVc = tabBarController as? SW_TabBarController
            
            if children.count > 1 {
                //隐藏tabBar
                tabBarVc?.showAndHideTabBar(!self.topViewController!.isHideTabBar, animated: animated)
            } else {
                tabBarVc?.showAndHideTabBar(true, animated: animated)
            }
        }
        return super.popToViewController(viewController, animated: animated)
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        defer {
            //2.获取tabBar
            tabBarVc = tabBarController as? SW_TabBarController
            tabBarVc?.showAndHideTabBar(true, animated: animated)
        }
        return super.popToRootViewController(animated: animated)
    }
    
    @discardableResult override func popViewController(animated: Bool) -> UIViewController? {
        let vc = super.popViewController(animated: animated)
        //2.获取tabBar
        tabBarVc = tabBarController as? SW_TabBarController
        
        if children.count > 1 {
            //隐藏tabBar
            tabBarVc?.showAndHideTabBar(!self.topViewController!.isHideTabBar, animated: animated)
        } else {
            tabBarVc?.showAndHideTabBar(true, animated: animated)
        }
        return vc
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        //不隐藏 底部会多出一部分tabbar
        viewController.hidesBottomBarWhenPushed = true
        //判断当前控制器的自控制器
        //2.获取tabBar
        tabBarVc = tabBarController as? SW_TabBarController
        
        if children.count > 1 {
            //隐藏tabBar
            tabBarVc?.showAndHideTabBar(!viewController.isHideTabBar, animated: animated)
            if viewController.navigationItem.leftBarButtonItem == nil {
                viewController.navigationItem.leftBarButtonItem = creatBackBtn()
            }
        } else {
            tabBarVc?.showAndHideTabBar(true, animated: animated)
        }
    }

    @objc func popSelf() {
        self.popViewController(animated: true)
    }
    
    func creatBackBtn() -> UIBarButtonItem {
        return UIBarButtonItem(image: #imageLiteral(resourceName: "nav_back").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popSelf))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    open override var childForStatusBarHidden : UIViewController? {
        return self.topViewController
    }
    
    open override var childForStatusBarStyle : UIViewController? {
        return self.topViewController
    }
    
    /**
     禁止具体某个viewController的旋转
     */
    open override var shouldAutorotate : Bool {
//        if isIPad {//  ???  ipad  才旋转？？
//            if ((self.topViewController?.responds(to: #selector(getter: UIViewController.shouldAutorotate))) != nil) {
//                return (self.topViewController?.shouldAutorotate)!
//            }
//            return super.shouldAutorotate
//        } else {
            return true
//        }
    }
    
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
//        if ((self.topViewController?.responds(to: #selector(getter: UIViewController.supportedInterfaceOrientations))) != nil) {
//            return (self.topViewController?.supportedInterfaceOrientations)!
//        }
//        return super.supportedInterfaceOrientations
    }
    
    open override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return .portrait
//        if ((self.topViewController?.responds(to: #selector(getter: UIViewController.preferredInterfaceOrientationForPresentation))) != nil) {
//            return (self.topViewController?.preferredInterfaceOrientationForPresentation)!
//        }
//        return super.preferredInterfaceOrientationForPresentation
    }
    
}
