//
//  SW_CustomerScoreManagerViewController.swift
//  SWS
//
//  Created by jayway on 2019/7/25.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_CustomerScoreManagerViewController: UIViewController {
    
    private var pageTitles = ["评分项目","非评分项目"]
    
    private var pageControllers: [UIViewController]!
    
    private lazy var layout: LTLayout = {
        let layout = LTLayout()
        //        layout.isAverage = true
        /* 更多属性设置请参考 LTLayout 中 public 属性说明 */
        return layout
    }()
    
    private func managerReact() -> CGRect {
        let H: CGFloat = SCREEN_HEIGHT - NAV_TOTAL_HEIGHT
        return CGRect(x: 0, y: 0, width: view.width, height: H)
    }
    
    private lazy var advancedManager: LTAdvancedManager = {
        let advancedManager = LTAdvancedManager(frame: managerReact(), viewControllers: pageControllers, titles: pageTitles, currentViewController: self, layout: layout, headerViewHandle: { [weak self] in
            guard let strongSelf = self else { return UIView() }
            let headerView = BigTitleSectionHeaderView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 80))
            headerView.title = "回访记录"
            return headerView
        })
        /* 设置代理 监听滚动 */
        advancedManager.delegate = self
        /* 点击切换滚动过程动画 */
        advancedManager.isClickScrollAnimation = true
        return advancedManager
    }()
    
    private var scoreItems = [SW_CustomerScoreModel]()
    
    private var nonScoreItems = [SW_NonGradedItemsModel]()
    
    init(_ scoreItems: [SW_CustomerScoreModel], nonScoreItems: [SW_NonGradedItemsModel]) {
        super.init(nibName: nil, bundle: nil)
        self.scoreItems = scoreItems
        self.nonScoreItems = nonScoreItems
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        if scoreItems.count > 0 && nonScoreItems.count > 0 {
            pageControllers = [SW_CustomerScoreViewController(scoreItems, isShowHeader: false),SW_CustomerNonScoreViewController.creatVc(nonScoreItems, isShowHeader: false)]
            view.addSubview(advancedManager)
            advancedManagerConfig()
        } else if scoreItems.count > 0 {
            let vc = SW_CustomerScoreViewController(scoreItems, isShowHeader: true)
            addChild(vc)
            view.addSubview(vc.view)
            vc.didMove(toParent: self)
        } else {
            let vc = SW_CustomerNonScoreViewController.creatVc(nonScoreItems, isShowHeader: true)
            addChild(vc)
            view.addSubview(vc.view)
            vc.didMove(toParent: self)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    deinit {
        PrintLog("deinit")
    }
}

extension SW_CustomerScoreManagerViewController: LTAdvancedScrollViewDelegate {
    
    //MARK: 具体使用请参考以下
    private func advancedManagerConfig() {
        //MARK: 选中事件
        //        advancedManager.advancedDidSelectIndexHandle = {
        //            print("选中了 -> \($0)")
        //        }
    }
    
    func glt_scrollViewOffsetY(_ offsetY: CGFloat) {
        //        print("offset --> ", offsetY)
    }
}

