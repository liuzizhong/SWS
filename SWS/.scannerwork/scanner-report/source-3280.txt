//
//  SW_RevenueManageViewController.swift
//  SWS
//
//  Created by jayway on 2018/6/21.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit


/// 订单报表的类型 全局通用该枚举
///
/// - dayOrder: 每日订单报表
/// - dayNonOrder: 每日非订单报表
/// - monthNonOrder: 月度非订单报表
/// - yearNonOrder: 年度非订单报表
enum RevenueReportType: Int {
    case dayOrder        = 0
    case dayNonOrder
    case monthNonOrder
    case yearNonOrder
    
    var rawTitle: String {
        switch self {
        case .dayOrder:
            return "每日订单报表"
        case .dayNonOrder:
            return "每日非订单报表"
        case .monthNonOrder:
            return "月度非订单报表"
        case .yearNonOrder:
            return "年度非订单报表"
        }
    }
}


class SW_RevenueManageViewController: UIViewController {
    
    private let searchBar = SW_SearchBar(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 44))
    
    private var pageStyle: DNSPageStyle = {
        let style = DNSPageStyle()
        style.isTitleScrollEnable = true
        style.isScaleEnable = true
        style.isShowBottomLine = true
        return style
    }()
    
    private var pageTitles = ["每日订单报表","每日非订单报表","月度非订单报表","年度非订单报表"]
    
    private var pageControllers = [SW_RevenueListViewController(.dayOrder),SW_RevenueListViewController(.dayNonOrder),SW_RevenueListViewController(.monthNonOrder),SW_RevenueListViewController(.yearNonOrder)]
    
    private var pageView: DNSPageView!
    
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
        navigationItem.title = InternationStr("营收报表")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: InternationStr("新建报表"), style: .plain, target: self, action: #selector(creatRevenue(_:)))
        
        searchBar.changeCancelBtnHiddenState(isShow: false)
        ///搜索按钮点击
        searchBar.searchBlock = { [weak self] in
            guard let curVc = self?.pageView.currentVc as? SW_RevenueListViewController else { return }
            if let key = self?.searchBar.searchField.text {//让当前显示的控制器进行搜索
                curVc.keyWord = key
            }
        }
        ///输入框内容改变
        searchBar.searchMessageBlock = { [weak self] (keyWord) in
            if keyWord?.isEmpty == true {///让输入框未空时刷新一下数据显示全部公告
                guard let curVc = self?.pageView.currentVc as? SW_RevenueListViewController else { return }
                curVc.keyWord = ""
            }
        }
        
        self.view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(54)
        }
        
        pageView = DNSPageView(frame: CGRect.zero, style: pageStyle, titles: pageTitles, childViewControllers: pageControllers)
        pageView.contentView.reloader = self
        view.addSubview(pageView)
        pageView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(self.searchBar.snp.bottom)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func creatRevenue(_ sender: UIBarButtonItem) {
        if let vc = UIStoryboard(name: "Working", bundle: nil).instantiateViewController(withIdentifier: "SW_SelectRevenueReportTypeTableViewController") as? SW_SelectRevenueReportTypeTableViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    deinit {
        PrintLog("deinit")
    }
}

extension SW_RevenueManageViewController: DNSPageReloadable {

    func contentViewDidEndScroll() {
        self.searchBar.searchField.resignFirstResponder()
        if let key = self.searchBar.searchField.text, key.isEmpty {
            (pageView.currentVc as! SW_RevenueListViewController).keyWord = ""
        }
    }
}
