//
//  SW_MeneCollectionManagerController.swift
//  SWS
//
//  Created by jayway on 2019/1/30.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_MineCollectionManagerController: UIViewController {
    
    private var pageTitles = ["内部公告","共享资料"]
    
    private var pageControllers: [UIViewController]!// [SW_InformListViewController(.group),SW_InformListViewController(.group)]
    
    private lazy var layout: LTLayout = {
        let layout = LTLayout()
        //        layout.isAverage = true
        /* 更多属性设置请参考 LTLayout 中 public 属性说明 */
        return layout
    }()
    
    private func managerReact() -> CGRect {
        let Y: CGFloat = 0//NAV_HEAD_INTERVAL + 74
        let H: CGFloat = SCREEN_HEIGHT - NAV_TOTAL_HEIGHT// - NAV_HEAD_INTERVAL - 74
        return CGRect(x: 0, y: Y, width: view.bounds.width, height: H)
    }
    
    private lazy var advancedManager: LTAdvancedManager = {
        let advancedManager = LTAdvancedManager(frame: managerReact(), viewControllers: pageControllers, titles: pageTitles, currentViewController: self, layout: layout, headerViewHandle: { [weak self] in
            guard let strongSelf = self else { return UIView() }
            let headerView = BigTitleSectionHeaderView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 80))
            headerView.title = "收藏"
            return headerView
        })
        /* 设置代理 监听滚动 */
        advancedManager.delegate = self
        
        /* 设置悬停位置 */
        //        advancedManager.hoverY = 64
        
        /* 点击切换滚动过程动画 */
        advancedManager.isClickScrollAnimation = true
        
        /* 代码设置滚动到第几个位置 */
        //        advancedManager.scrollToIndex(index: viewControllers.count - 1)
        
        return advancedManager
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setup() {
        view.backgroundColor = UIColor.white
        automaticallyAdjustsScrollViewInsets = false
        let vc1 = UIStoryboard(name: "Mine", bundle: nil).instantiateViewController(withIdentifier: "SW_MineCollectionViewController") as! SW_MineCollectionViewController
        pageControllers = [vc1,SW_DataShareCollectionViewController()]
        
        view.addSubview(advancedManager)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        PrintLog("deinit")
    }
    
}

extension SW_MineCollectionManagerController: LTAdvancedScrollViewDelegate {
    
    //MARK: 具体使用请参考以下
//    private func advancedManagerConfig() {
        //MARK: 选中事件
//        advancedManager.advancedDidSelectIndexHandle = { [weak self] in
            //            print("选中了 -> \($0)")
//        }
        
//    }
    
    func glt_scrollViewOffsetY(_ offsetY: CGFloat) {
        //        print("offset --> ", offsetY)
    }
}
