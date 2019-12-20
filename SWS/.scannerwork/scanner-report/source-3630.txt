//
//  SW_ CustomerAddressBookViewController.swift
//  SWS
//
//  Created by jayway on 2018/8/14.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_CustomerAddressBookViewController: SW_TableViewController {
    
    private var SW_CustomerAddressBookListCellID = "SW_CustomerAddressBookListCellID"
    
    /// 现在出来的数据 搜索的直接放这里面
    private var customers = [SW_CustomerListModel]()
    
    private var searchDatas = [SW_CustomerListModel]()
    
    private lazy var searchBar: SW_NewSearchBar = {
        let sbar =  Bundle.main.loadNibNamed(String(describing: SW_NewSearchBar.self), owner: nil, options: nil)?.first as! SW_NewSearchBar
        sbar.placeholderString = "搜索客户"
        return sbar
    }()
    
    private lazy var emptyView: LYEmptyView = {
        return SW_NoDataEmptyView.creat()
    }()
    
    lazy var searchTableView: UITableView = {
        let tbv = UITableView.init(frame: .zero, style: .grouped)
        tbv.isHidden = true
        tbv.delegate = self
        tbv.dataSource = self
        tbv.backgroundColor = UIColor.white
        tbv.separatorStyle = .none
        tbv.keyboardDismissMode = .onDrag
        tbv.registerNib(SW_CustomerAddressBookListCell.self, forCellReuseIdentifier: "SW_CustomerAddressBookListCellID")
        tbv.registerNib(SW_TempCustomerListCell.self, forCellReuseIdentifier: "SW_TempCustomerListCellID")
        tbv.rowHeight = 79
        return tbv
    }()
    
    private lazy var searchEmptyView: LYEmptyView = {
        let emptyView = LYEmptyView.empty(withImageStr: "", titleStr: "抱歉，没有找到相关内容", detailStr: "")
        emptyView?.titleLabTextColor = UIColor.v2Color.darkGray
        emptyView?.titleLabFont = Font(14)
        emptyView?.contentViewY = 60
        return emptyView!
    }()
    
    lazy var footerView: MJRefreshAutoNormalFooter = {
        let footer = MJRefreshAutoNormalFooter.init { [weak self] in
            self?.requsertcustomers(byAppend: true)
        }
//        footer?.isAutomaticallyHidden = false
        footer?.isHidden = true
        footer?.triggerAutomaticallyRefreshPercent = -10
        return footer!
    }()
    
    
    lazy var filterView: SW_SalesContactsFilterHeaderView = {
        let view = Bundle.main.loadNibNamed("SW_SalesContactsFilterHeaderView", owner: self, options: nil)?.first as! SW_SalesContactsFilterHeaderView
        return view
    }()
    
    lazy var searchFooterView: MJRefreshAutoNormalFooter = {
        let searchFooter = MJRefreshAutoNormalFooter.init { [weak self] in
            guard let self = self else { return }
            self.requsertcustomers(self.searchBar.searchText, isSearch: true, byAppend: true)
        }
//        searchFooter?.isAutomaticallyHidden = false
        searchFooter?.isHidden = true
        searchFooter?.triggerAutomaticallyRefreshPercent = -10
        return searchFooter!
    }()
    
    lazy var tap: UITapGestureRecognizer = {
        let t = UITapGestureRecognizer(actionBlock: { [weak self] (gesture) in
            self?.searchBar.cancelBtnClick(UIButton())
        })
        return t!
    }()
    
    
    lazy var searchBgView: UIView = {
        let v = UIView()
        v.addGestureRecognizer(self.tap)
        v.alpha = 0
        v.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8)
        v.addSubview(searchTableView)
        searchTableView.snp.makeConstraints({ (make) in
            make.top.leading.trailing.bottom.equalToSuperview()
        })
        return v
    }()
    
    var scrollTopBtn: UIButton = {
        //        icon_backtotop
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "icon_backtotop"), for: UIControl.State())
        btn.alpha = 0
        btn.addTarget(self, action: #selector(scrollToTopAction), for: .touchUpInside)
        return btn
    }()
    
    /// 用于计算上下滑动方向
    private var lastOffset: CGFloat = 0
    
    /// 当前是否显示搜索框，默认显示
    private var currentShowState = true
    
    var selectType = 1
    var selectLevel: CustomerLevel = .none
    var selectDataPercent = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupNotification()
        requsertcustomers()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNotification() {
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] (notifi) in
            self?.requsertcustomers(max: self?.customers.count ?? 20)
        }
        /// 用户新增客户 刷新列表
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadCreateCustomer, object: nil, queue: nil) { [weak self] (notifa) in
            self?.filterView.getCutomerCount()
            self?.requsertcustomers(max: self?.customers.count ?? 20)
        }
        /// 编辑了客户意向  暂时只有客户等级要更新
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadEditCustomerIntention, object: nil, queue: nil) { [weak self] (notifa) in
            let id = notifa.userInfo?["customerId"] as! String
            if let index = self?.customers.firstIndex(where: { return $0.id == id }) {
                self?.customers[index].level = notifa.userInfo?["level"] as! CustomerLevel
                self?.customers[index].dataPercentage = notifa.userInfo?["dataPercentage"] as! Int
                self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
        /// 修改了客户头像
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadSaveCustomerPortrait, object: nil, queue: nil) { [weak self] (notifa) in
            let id = notifa.userInfo?["customerId"] as! String
            if let index = self?.customers.firstIndex(where: { return $0.id == id }) {
                self?.customers[index].portrait = notifa.userInfo?["portrait"] as! String
                self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
        /// 关注了某个客户
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadFollowCustomer, object: nil, queue: nil) { [weak self] (notifa) in
            let id = notifa.userInfo?["customerId"] as! String
            if let index = self?.customers.firstIndex(where: { return $0.id == id }) {
                self?.customers[index].isFollow = notifa.userInfo?["isFollow"] as! Bool
                self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
        /// 销售接待被后台结束 更新页面数据
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.SalesReceptionHadBeenEnd, object: nil, queue: nil) { [weak self] (notifa) in
            let id = notifa.userInfo?["customerId"] as! String
            if let index = self?.customers.firstIndex(where: { return $0.id == id }) {
                self?.customers[index].accessing = false
                self?.customers[index].lastAccessDate = notifa.userInfo?["lastAccessDate"] as! Double
                self?.customers[index].processRecordId = notifa.userInfo?["recordId"] as! String
                self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
        /// 结束了销售接待 更新页面数据
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadEndSalesReception, object: nil, queue: nil) { [weak self] (notifa) in
            let id = notifa.userInfo?["customerId"] as! String
            if let index = self?.customers.firstIndex(where: { return $0.id == id }) {
                self?.customers[index].lastAccessDate = notifa.userInfo?["endDate"] as! Double
                self?.customers[index].processRecordId = ""
                self?.customers[index].accessState = 0
                self?.customers[index].accessing = false
                self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
        /// 结束了试乘试驾 更新页面数据
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadEndTryDriving, object: nil, queue: nil) { [weak self] (notifa) in
            let id = notifa.userInfo?["customerId"] as! String
            if let index = self?.customers.firstIndex(where: { return $0.id == id }) {
                self?.customers[index].lastAccessDate = notifa.userInfo?["endDate"] as! Double
                self?.customers[index].accessState = 0
                self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
        /// 添加访问记录 更新页面数据
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadAddAccessRecord, object: nil, queue: nil) { [weak self] (notifa) in
            let id = notifa.userInfo?["customerId"] as! String
            if let index = self?.customers.firstIndex(where: { return $0.id == id }) {
                let endDate = notifa.userInfo?["endDate"] as! Double
                if endDate > (self?.customers[index].lastAccessDate ?? 0) {
                    self?.customers[index].lastAccessDate = endDate
                }
                self?.customers[index].accessState = 0
                self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
        /// 开始销售接待 更新页面数据
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadStartSalesReception, object: nil, queue: nil) { [weak self] (notifa) in
            let id = notifa.userInfo?["customerId"] as! String
            if let index = self?.customers.firstIndex(where: { return $0.id == id }) {
                self?.customers[index].accessing = true
                self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
        /// 客户已经被转移，删除该客户
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.CustomerHadBeenChange, object: nil, queue: nil) { [weak self] (notifa) in
            let id = notifa.userInfo?["customerId"] as! String
            if let index = self?.customers.firstIndex(where: { return $0.id == id }) {
                self?.customers.remove(at: index)
                self?.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
        /// 处理了客户投诉 更新页面数据
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadHandleComplaints, object: nil, queue: nil) { [weak self] (notifa) in
            self?.requsertcustomers(max: self?.customers.count ?? 20)
        }
    }
    
    private func setup() {
        tableView.removeFromSuperview()
        tableView = UITableView.init(frame: .zero, style: .grouped)
        view.addSubview(tableView)
        tableView.registerNib(SW_TempCustomerListCell.self, forCellReuseIdentifier: "SW_TempCustomerListCellID")
        tableView.registerNib(SW_CustomerAddressBookListCell.self, forCellReuseIdentifier: SW_CustomerAddressBookListCellID)
        tableView.estimatedRowHeight = 79
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        setTableViewInset()
        tableView.ly_emptyView = SW_LoadingEmptyView.creat()
        tableView.ly_emptyView.contentViewOffset = -(SCREEN_HEIGHT - 250) * 0.1
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = false
        }

        searchBar.setUpAddBtn("新增", image: UIImage(named: "icon_addition")!, action: { [weak self] in
            
            alertControllerShow(title: "是否新增客户？", message: nil, rightTitle: "确 定", rightBlock: { (_, _) in
                SW_AddressBookService.createTempCustomer().response({ (json, isCache, error) in
                    if let json = json as? JSON, error == nil {
                        self?.filterView.getCutomerCount()
                        self?.requsertcustomers(max: (self?.customers.count ?? 19) + 1)
                        let vc =  SW_TempCustomerDetailViewController(json["id"].stringValue, customerTempNum: json["customerTempNum"].stringValue, consultantInfoId: json["consultantInfoId"].intValue, createDate: json["createDate"].doubleValue)
                        self?.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                    }
                })
            }, leftTitle: "取 消", leftBlock: nil)
            
        })
        searchBar.backActionBlock = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        searchBar.becomeFirstBlock = { [weak self] in
            guard let self = self else { return }
            
            self.view.addSubview(self.searchBgView)
            self.searchBgView.snp.makeConstraints({ (make) in
                make.leading.trailing.bottom.equalToSuperview()
                make.top.equalTo(self.searchBar.snp.bottom)
            })
            UIView.animate(withDuration: 0.4, animations: {
                self.searchBgView.alpha = 1
            }, completion: nil)
        }
        searchBar.cancelActionBlock = { [weak self] in
            guard let self = self else { return }
            
            self.tap.isEnabled = true
            self.searchTableView.isHidden = true
            self.searchDatas = []
            self.searchTableView.reloadData()
            self.searchTableView.mj_footer.isHidden = true
            UIView.animate(withDuration: 0.4, animations: {
                self.searchBgView.alpha = 0
            }, completion: { (finish) in
                self.searchBgView.removeFromSuperview()
            })
        }
        searchBar.textChangeBlock = { [weak self] in
            guard let self = self else { return }
            self.tap.isEnabled = self.searchBar.searchText.isEmpty
            self.searchTableView.isHidden = self.searchBar.searchText.isEmpty
            if self.searchBar.searchText.isEmpty {
                self.searchDatas = []
                self.searchTableView.ly_emptyView = nil
                self.searchTableView.reloadData()
            }
        }
        
        searchBar.searchBlock = { [weak self] in
            guard let self = self else { return }
            
            self.requsertcustomers(self.searchBar.searchText, isSearch: true)
        }
        
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(NAV_HEAD_INTERVAL + 74)
        }
        
        filterView.selectValueChange = { [weak self] (type,level,dataPercent) in
            self?.selectType = type
            self?.selectLevel = level
            self?.selectDataPercent = dataPercent
            self?.requsertcustomers()
        }
        
        
        filterView.stateChangeBlock = { [weak self] (currentIsDown) in
            self?.filterView.snp.updateConstraints({ (update) in
                update.height.equalTo(currentIsDown ? 70 : 170)
            })
            UIView.animate(withDuration: 0.2) {
                self?.view.layoutIfNeeded()
            }
        }
        view.addSubview(filterView)
        filterView.snp.makeConstraints { (make) in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(70)//70  145
        }
        
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(filterView.snp.bottom)
        }
        
        view.addSubview(scrollTopBtn)
        scrollTopBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(44)
            make.trailing.equalTo(-25)
            make.bottom.equalTo(-15 - TABBAR_BOTTOM_INTERVAL)
        }
        
        ///下拉刷新数据
        tableView.mj_header = SW_RefreshHeader.init(refreshingBlock: { [weak self] in
            SW_CustomerAccessingManager.shared.getAccessingList()
            self?.requsertcustomers()
            self?.filterView.getCutomerCount()
        })
        
        tableView.mj_footer = footerView
        searchTableView.mj_footer = searchFooterView
        searchTableView.mj_header = SW_RefreshHeader.init(refreshingBlock: { [weak self] in
            guard let self = self else { return }
            self.requsertcustomers(self.searchBar.searchText, isSearch: true)
        })
    }
    
    func requsertcustomers(_ keyword: String = "", isSearch: Bool = false, byAppend: Bool = false, max: Int = 20) {
        let offSet = byAppend ?  (isSearch ? searchDatas.count : customers.count) : 0
        
        SW_AddressBookService.getCustomerList(keyword, type: selectType, level: selectLevel.rawValue, dataPercent: selectDataPercent, max: max, offset: offSet).response({ (json, isCache, error) in
            self.emptyView.contentViewOffset = -(self.tableView.height - 250) * 0.15
            self.tableView.ly_emptyView = self.emptyView
            if let json = json as? JSON, error == nil {
                let totalCount = json["count"].intValue
                
                if byAppend {
                    let datas = json["list"].arrayValue.map({ (value) -> SW_CustomerListModel in
                        return SW_CustomerListModel(value)
                    })
                    if isSearch {
                        if keyword == self.searchBar.searchText {
                            self.searchDatas.append(contentsOf: datas)
                            if self.searchDatas.count >= totalCount {
                                self.searchTableView.mj_footer.endRefreshingWithNoMoreData()
                                self.searchTableView.mj_footer.isHidden = true
                            } else {
                                self.searchTableView.mj_footer.endRefreshing()
                            }
                            self.searchTableView.reloadData()
                        }
                    } else {
                        self.customers.append(contentsOf: datas)
                        if self.customers.count >= totalCount {
                            self.tableView.mj_footer.endRefreshingWithNoMoreData()
                            self.tableView.mj_footer.isHidden = true
                        } else {
                            self.tableView.mj_footer.endRefreshing()
                        }
                        self.tableView.reloadData()
                    }
                } else {
                    
                    let datas = json["list"].arrayValue.map({ (value) -> SW_CustomerListModel in
                        return SW_CustomerListModel(value)
                    })
                    
                    if isSearch {
                        if keyword == self.searchBar.searchText {
                            if !datas.isEmpty {
                                self.searchDatas = datas
                                /// 加载完毕
                                if datas.count < totalCount {
                                    self.searchTableView.mj_footer.isHidden = false
                                    self.searchTableView.mj_footer.state = MJRefreshState(rawValue: 1)!
                                    /// 进入时判断是否显示了销售接待条 控制偏移量
                                } else {
                                    self.searchTableView.mj_footer.endRefreshingWithNoMoreData()
                                    self.searchTableView.mj_footer.isHidden = true
                                }
                                self.searchTableView.reloadData()
                                self.searchTableView.setContentOffset(CGPoint.zero, animated: false)
                                self.searchTableView.isHidden = false
                                self.tap.isEnabled = false
                            } else {
                                self.tap.isEnabled = keyword.isEmpty
                                self.searchTableView.isHidden = keyword.isEmpty
                                if !keyword.isEmpty {
                                    self.searchDatas = []
                                    self.searchTableView.ly_emptyView = self.searchEmptyView///
                                    self.searchTableView.reloadData()
                                }
                            }
                            self.searchTableView.mj_footer.state = MJRefreshState(rawValue: 1)!
                        }
                    } else {
                        self.customers = datas
                        /// 加载完毕
                        if datas.count < totalCount {
                            self.tableView.mj_footer.isHidden = false
                            self.tableView.mj_footer.state = MJRefreshState(rawValue: 1)!
                            /// 进入时判断是否显示了销售接待条 控制偏移量
                        } else {
                            self.tableView.mj_footer.endRefreshingWithNoMoreData()
                            self.tableView.mj_footer.isHidden = true
                        }
                        self.tableView.reloadData()
                    }
                }
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
            self.tableView.mj_header.endRefreshing()
            self.searchTableView.mj_header.endRefreshing()
        })
    }
    
    @objc func scrollToTopAction() {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        lastOffset = 0
        showOrHideSearchBar(show: true)
        tableView.scrollToTop(animated: true)
    }
    
    
    private func showOrHideSearchBar(show: Bool) {
        /// 状态相同return
        guard currentShowState != show else { return }
        guard isCurrentViewControllerVisible() else { return }
        
        currentShowState = show
        
        searchBar.showOrHideSubView(show: show, duration: 0.3)
        searchBar.snp.updateConstraints { (update) in
            update.height.equalTo(show ? NAV_HEAD_INTERVAL + 74 : NAV_HEAD_INTERVAL)
        }
//        filterView.alpha = show ? 1 : 0
        
        filterView.snp.updateConstraints({ (update) in
            update.height.equalTo(show ? (self.filterView.currentIsDown ? 70 : 170) : 0)
        })
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
//            self.filterView.alpha = show ? 1 : 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func setTableViewInset() {
        tableView.contentInset = UIEdgeInsets(top: 0/*NAV_HEAD_INTERVAL + 74 + 70*/, left: 0, bottom: TABBAR_BOTTOM_INTERVAL , right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: NAV_HEAD_INTERVAL + 74, left: 0, bottom: TABBAR_BOTTOM_INTERVAL, right: 0)
        searchTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL, right: 0)
        searchTableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL, right: 0)
    }
    
    deinit {
        PrintLog("deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchTableView {
            return searchDatas.count
        }
        return customers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var model: SW_CustomerListModel
        if tableView == searchTableView {
            guard  searchDatas.count > indexPath.row else { return UITableViewCell() }
            model = searchDatas[indexPath.row]
        } else {
            guard  customers.count > indexPath.row else { return UITableViewCell() }
            model = customers[indexPath.row]
        }
        if model.customerType == .real {
            let cell = tableView.dequeueReusableCell(withIdentifier: SW_CustomerAddressBookListCellID, for: indexPath) as! SW_CustomerAddressBookListCell
            cell.customerModel = model
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SW_TempCustomerListCellID", for: indexPath) as! SW_TempCustomerListCell
            cell.customerModel = model
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var model: SW_CustomerListModel
        if tableView == searchTableView {
            guard  searchDatas.count > indexPath.row else { return }
            model = searchDatas[indexPath.row]
        } else {
            guard  customers.count > indexPath.row else { return }
            model = customers[indexPath.row]
        }
        if model.customerType == .real {
            let vc =  SW_CustomerDetailViewController(model.id, consultantInfoId: model.consultantInfoId)
            navigationController?.pushViewController(vc, animated: true)
        } else if model.applyChangeState {
            showAlertMessage("申请调档中", MYWINDOW)
        } else if !model.processRecordId.isEmpty {
            self.navigationController?.pushViewController(SW_EndSalesReceptionViewController(model.processRecordId, customerId: model.id, clearView: true, customerTempNum: model.customerTempNum, consultantInfoId: model.consultantInfoId, createDate: model.createDate), animated: true)
        } else {
            let vc =  SW_TempCustomerDetailViewController(model.id, customerTempNum: model.customerTempNum, consultantInfoId: model.consultantInfoId, createDate: model.createDate)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        var model: SW_CustomerListModel
        if tableView == searchTableView {
            guard  searchDatas.count > indexPath.row else { return false }
            model = searchDatas[indexPath.row]
        } else {
            guard  customers.count > indexPath.row else { return false }
            model = customers[indexPath.row]
        }
        return model.customerType == .real
    }
    
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
            var model: SW_CustomerListModel
            if tableView == searchTableView {
                guard  searchDatas.count > indexPath.row else { return nil }
                model = searchDatas[indexPath.row]
            } else {
                guard  customers.count > indexPath.row else { return nil }
                model = customers[indexPath.row]
            }
            var actions = [UIContextualAction]()
            if !model.accessing {
                let accessAction = UIContextualAction(style: .normal, title: "接待") { (action, view, completionHandler) in
                    completionHandler(true)
                    if SW_CustomerAccessingManager.shared.accessingList.count == 5 {
                        showAlertMessage("保存失败，接待人数不能超过5个，请先结束相关接待。", MYWINDOW)
                        return
                    }
                    let record = SW_AccessCustomerRecordModel()
                    record.accessType = .salesReception
                    record.customerId = model.id
                    record.startDate = Date().getCurrentTimeInterval()
                    SW_AddressBookService.saveAccessCustomerRecord(record).response({ (json, isCache, error) in
                        if error == nil {
                            model.accessing = true
                            self.tableView.reloadRows(at: [indexPath], with: .automatic)
                            /// 在这个页面开启销售接待，可能要添加过渡动画到tabbar
                            NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadStartSalesReception, object: nil, userInfo: ["customerId": model.id])
                        } else {
                            showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                        }
                    })
                    
                    
                }
                accessAction.backgroundColor = UIColor.v2Color.blue
                actions.append(accessAction)
            }
            let followAction = UIContextualAction(style: .normal, title: model.isFollow ? "取消关注": "关注") { (action, view, completionHandler) in
                SW_AddressBookService.followCustomer(model.id, isFollow: !model.isFollow).response({ (json, isCache, error) in
                    if  error == nil {
                        model.isFollow = !model.isFollow
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                    }
                })
                completionHandler(true)
            }
            followAction.backgroundColor = #colorLiteral(red: 0.6274509804, green: 0.6745098039, blue: 0.7529411765, alpha: 1)
            actions.append(followAction)
            
            
            let config = UISwipeActionsConfiguration(actions: actions)
            config.performsFirstActionWithFullSwipe = false
            return config
        
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        var model: SW_CustomerListModel
        if tableView == searchTableView {
            guard  searchDatas.count > indexPath.row else { return [] }
            model = searchDatas[indexPath.row]
        } else {
            guard  customers.count > indexPath.row else { return [] }
            model = customers[indexPath.row]
        }
        var actions = [UITableViewRowAction]()

        if !model.accessing {
            let accessAction = UITableViewRowAction(style: .default, title: "接待") { (rowAction, indexP) in
                if SW_CustomerAccessingManager.shared.accessingList.count == 5 {
                    showAlertMessage("保存失败，接待人数不能超过5个，请先结束相关接待。", MYWINDOW)
                    return
                }
                let record = SW_AccessCustomerRecordModel()
                record.accessType = .salesReception
                record.customerId = model.id
                record.startDate = Date().getCurrentTimeInterval()
                SW_AddressBookService.saveAccessCustomerRecord(record).response({ (json, isCache, error) in
                    if error == nil {
                        model.accessing = true
                        self.tableView.reloadRows(at: [indexP], with: .automatic)
                        /// 在这个页面开启销售接待，可能要添加过渡动画到tabbar
                        NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadStartSalesReception, object: nil, userInfo: ["customerId": model.id])
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                    }
                })
            }
            accessAction.backgroundColor = UIColor.v2Color.blue
            actions.append(accessAction)
        }
        let followAction = UITableViewRowAction(style: .default, title: model.isFollow ? "取消关注": "关注") { (rowAction, indexP) in
            SW_AddressBookService.followCustomer(model.id, isFollow: !model.isFollow).response({ (json, isCache, error) in
                if error == nil {
                    model.isFollow = !model.isFollow
                    self.tableView.reloadRows(at: [indexP], with: .automatic)
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                }
            })
        }
        followAction.backgroundColor = #colorLiteral(red: 0.6274509804, green: 0.6745098039, blue: 0.7529411765, alpha: 1)
        actions.append(followAction)

        return actions
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 79
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {/// 70   44
        if tableView == searchTableView {
            return 44
        }
        return 70
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        /// 两种头部view
        if tableView == searchTableView {
            let view = SectionHeaderView(frame: CGRect(x: 0, y: 0, width: 1, height: 44))
            view.title = "销售客户通讯录"
            view.backgroundColor = .white
            return view
        }
        let view = BigTitleSectionHeaderView(frame: CGRect(x: 0, y: 0, width: 1, height: 70))
        view.title = "销售客户通讯录"
        return view
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let tbv = scrollView as? UITableView, tbv == tableView {
            //阴影线
            searchBar.showOrHideShadow(show: scrollView.contentOffset.y > 70)

            scrollTopBtn.showOrHide(show: scrollView.contentOffset.y > 300)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastOffset = scrollView.contentOffset.y
    }
    
    ///  隐藏显示tabbar
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let tbv = scrollView as? UITableView, tbv == tableView {
            ////  最终滚动停留的位置offset
            let offSet = targetContentOffset.pointee.y
            if offSet <= 0  {//滚动到最上面就直接显示
                isShowSearchBar = true
            } else {
                isShowSearchBar = offSet - lastOffset < 0
            }
            lastOffset = offSet
        }
    }
    
    private var isShowSearchBar = true
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if let tbv = scrollView as? UITableView, tbv == tableView {
            lastOffset = 0
            showOrHideSearchBar(show: true)
        }
        return true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let tbv = scrollView as? UITableView, tbv == tableView {
            showOrHideSearchBar(show: isShowSearchBar)
        }
    }
    
}
