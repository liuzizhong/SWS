//
//  SW_WorkReportManageViewController.swift
//  SWS
//
//  Created by jayway on 2018/7/5.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

enum WorkReportOwner: Int {
    case received = 0       //收到的工作报告
    case mine               //我的工作报告
    
    var rawTitle: String {
        switch self {
        case .received:
            return "收到的工作报告"
        case .mine:
            return "我的工作报告"
        }
    }
}

/// 工作报告类型
///
/// - day: 工作日志
/// - month: 月度报告
/// - year: 年度报告
enum WorkReportType: Int {
    case day    = 0
    case month
    case year
    
    var rawTitle: String {
        switch self {
        case .day:
            return "工作日志"
        case .month:
            return "月度报告"
        case .year:
            return "年度报告"
        }
    }
}

class SW_WorkReportManageViewController: UIViewController {
    
    private var ownerType = WorkReportOwner.received
    
    private var pageTitles = ["工作日志","月度报告","年度报告"]
    
    private var pageControllers: [UIViewController]!
    
    private lazy var layout: LTLayout = {
        let layout = LTLayout()
        //        layout.isAverage = true
        /* 更多属性设置请参考 LTLayout 中 public 属性说明 */
        return layout
    }()
    
    private func managerReact() -> CGRect {
        let H: CGFloat = SCREEN_HEIGHT - TABBAR_BOTTOM_INTERVAL - TABBAR_HEIGHT - NAV_TOTAL_HEIGHT
        return CGRect(x: 0, y: 0, width: view.width, height: H)
    }
    
    private lazy var advancedManager: LTAdvancedManager = {
        let advancedManager = LTAdvancedManager(frame: managerReact(), viewControllers: pageControllers, titles: pageTitles, currentViewController: self, layout: layout, headerViewHandle: {[weak self] in
            guard let strongSelf = self else { return UIView() }
            let headerView = BigTitleSectionHeaderView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 80))
            headerView.title = strongSelf.ownerType.rawTitle
            return headerView
        })
        /* 设置代理 监听滚动 */
        advancedManager.delegate = self
        /* 点击切换滚动过程动画 */
        advancedManager.isClickScrollAnimation = true
        return advancedManager
    }()
    
    init(_ ownerType: WorkReportOwner) {
        super.init(nibName: nil, bundle: nil)
        self.ownerType = ownerType
        if ownerType == .received {
            self.pageControllers = [SW_ReceiveWorkReportListViewController(.day),SW_ReceiveWorkReportListViewController(.month),SW_ReceiveWorkReportListViewController(.year)]
        } else {
            self.pageControllers = [SW_WorkReportListViewController(.day),SW_WorkReportListViewController(.month),SW_WorkReportListViewController(.year)]
        }
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
        
        view.addSubview(advancedManager)
        advancedManagerConfig()
        
        let offSetX = 6// -(SCREEN_WIDTH - 200)/6
        advancedManager.titleView.glt_buttons.forEach({
            $0.badgeOffset = CGPoint(x: offSetX, y: 15)
            $0.badgeWidth = 10
        })
        
        setBadgeState()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.RedDotNotice, object: nil, queue: nil) {  [weak self]  (notifi) in
            self?.setBadgeState()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func setBadgeState() {
        if ownerType == .received {
            advancedManager.titleView.glt_buttons[0].badgeView(state: SW_BadgeManager.shared.workBadge.receiveDay)
            advancedManager.titleView.glt_buttons[1].badgeView(state: SW_BadgeManager.shared.workBadge.receiveMonth)
            advancedManager.titleView.glt_buttons[2].badgeView(state: SW_BadgeManager.shared.workBadge.receiveYear)
        } else {
            advancedManager.titleView.glt_buttons[0].badgeView(state: SW_BadgeManager.shared.workBadge.myDay)
            advancedManager.titleView.glt_buttons[1].badgeView(state: SW_BadgeManager.shared.workBadge.myMonth)
            advancedManager.titleView.glt_buttons[2].badgeView(state: SW_BadgeManager.shared.workBadge.myYear)
        }
    }
    
    deinit {
        PrintLog("deinit")
        NotificationCenter.default.removeObserver(self)
    }
}

extension SW_WorkReportManageViewController: LTAdvancedScrollViewDelegate {
    
    //MARK: 具体使用请参考以下
    private func advancedManagerConfig() {
        //MARK: 选中事件
    }
    
    func glt_scrollViewOffsetY(_ offsetY: CGFloat) {
//        print("offset --> ", offsetY)
    }
}
