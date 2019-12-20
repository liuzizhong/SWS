//
//  SW_SalesContractListViewController.swift
//  SWS
//
//  Created by jayway on 2019/5/22.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_SalesContractListViewController: SW_TableViewController {
    
    private var type: ContractBusinessType = .insurance
    
    private var SW_SalesContractListCellID = "SW_SalesContractListCellID"
    
    /// 现在出来的数据 搜索的直接放这里面
    private var salesContracts = [SW_SalesContractListModel]()
    
    private var searchDatas = [SW_SalesContractListModel]()
    
    private lazy var searchBar: SW_NewSearchBar = {
        let sbar =  Bundle.main.loadNibNamed(String(describing: SW_NewSearchBar.self), owner: nil, options: nil)?.first as! SW_NewSearchBar
        sbar.placeholderString = "搜索销售合同"
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
        tbv.registerNib(SW_SalesContractListCell.self, forCellReuseIdentifier: SW_SalesContractListCellID)
        tbv.registerNib(SW_AssgnationCarListCell.self, forCellReuseIdentifier: "SW_AssgnationCarListCellID")
        //        tbv.rowHeight = UITableView.automaticDimension
        tbv.estimatedRowHeight = type.rowHeight
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
                self?.requestContractList(byAppend: true)
            }
    //        footer?.isAutomaticallyHidden = false
            footer?.isHidden = true
            footer?.triggerAutomaticallyRefreshPercent = -10
            return footer!
        }()
        
        lazy var searchFooterView: MJRefreshAutoNormalFooter = {
            let searchFooter = MJRefreshAutoNormalFooter.init { [weak self] in
                guard let self = self else { return }
                self.requestContractList(self.searchBar.searchText, isSearch: true, byAppend: true)
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
    
    lazy var tipView: SW_SearchKeyWordTipView = {
        let view = Bundle.main.loadNibNamed("SW_SearchKeyWordTipView", owner: nil, options: nil)?.first as! SW_SearchKeyWordTipView
        if self.type == .assgnationCar {
            view.tipLb.text = "搜索客户姓名、合同编号、手机号"
        } else {
            view.tipLb.text = "搜索客户姓名、合同编号、手机号、车架号"
        }
        return view
    }()
    
    lazy var searchBgView: UIView = {
        let v = UIView()
        v.addGestureRecognizer(tap)
        v.alpha = 0
        v.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8)
        /// 添加searchtipview
        v.addSubview(tipView)
        tipView.snp.makeConstraints({ (make) in
            make.top.leading.trailing.equalToSuperview()
        })
        v.addSubview(searchTableView)
        searchTableView.snp.makeConstraints({ (make) in
            make.top.leading.trailing.bottom.equalToSuperview()
        })
        return v
    }()
    
    var scrollTopBtn: UIButton = {
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
    
    init(_ type: ContractBusinessType) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupNotification()
        requestContractList()
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
        /// 列表更新
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.SalesContractBusinessDandling, object: nil, queue: nil) { [weak self] (notifa) in
            self?.requestContractList()
            
            guard let self = self, !self.searchBar.searchText.isEmpty else { return }
            self.requestContractList(self.searchBar.searchText, isSearch: true)
            
        }
    }
    
    private func setup() {
        tableView.removeFromSuperview()
        tableView = UITableView.init(frame: .zero, style: .grouped)
        view.addSubview(tableView)
        tableView.registerNib(SW_SalesContractListCell.self, forCellReuseIdentifier: SW_SalesContractListCellID)
        tableView.registerNib(SW_AssgnationCarListCell.self, forCellReuseIdentifier: "SW_AssgnationCarListCellID")
//        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = type.rowHeight
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        
        setTableViewInset()
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = false
        }
        
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
            self.requestContractList(self.searchBar.searchText, isSearch: true)
        }
        
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(NAV_HEAD_INTERVAL + 74)
        }
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.top.equalToSuperview()
        }
        view.addSubview(scrollTopBtn)
        scrollTopBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(44)
            make.trailing.equalTo(-25)
            make.bottom.equalTo(-15 - TABBAR_BOTTOM_INTERVAL)
        }
        tableView.ly_emptyView = SW_LoadingEmptyView.creat()
        tableView.ly_emptyView.contentViewOffset = -(SCREEN_HEIGHT - 250) * 0.15
        
        ///下拉刷新数据
        tableView.mj_header = SW_RefreshHeader.init(refreshingBlock: { [weak self] in
            self?.requestContractList()
        })
        searchTableView.mj_header = SW_RefreshHeader.init(refreshingBlock: { [weak self] in
            guard let self = self else { return }
            self.requestContractList(self.searchBar.searchText, isSearch: true)
        })
        tableView.mj_footer = footerView
        searchTableView.mj_footer = searchFooterView
    }
    
    func requestContractList(_ keyword: String = "", isSearch: Bool = false, byAppend: Bool = false) {
        let offSet = byAppend ?  (isSearch ? searchDatas.count : salesContracts.count) : 0
        
        var request: SWSRequest!
        switch type {
        case .insurance:
            request = SW_SalesContractService.getSaleInsuranceContractList(keyword, max: 20, offset: offSet)
        case .mortgageLoans:
            request = SW_SalesContractService.getSaleMortgageContractList(keyword, max: 20, offset: offSet)
        case .assgnationCar:
            request = SW_AddressBookService.getCarSalesContractRecordList("", appKeyWord:keyword, max: 20, offset: offSet)
        default:
            request = SW_SalesContractService.getSaleCarNumContractList(keyword, type: type.rawValue-1, max: 20, offset: offSet)
        }
        
        request.response({ (json, isCache, error) in
            self.emptyView.contentViewOffset = -(self.tableView.height - 250) * 0.1
            self.tableView.ly_emptyView = self.emptyView
            if let json = json as? JSON, error == nil {
                let totalCount = json["count"].intValue
                if byAppend {
                    let datas = json["list"].arrayValue.map({ (value) -> SW_SalesContractListModel in
                        return SW_SalesContractListModel(value, type: self.type)
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
                        self.salesContracts.append(contentsOf: datas)
                        if self.salesContracts.count >= totalCount {
                            self.tableView.mj_footer.endRefreshingWithNoMoreData()
                            self.tableView.mj_footer.isHidden = true
                        } else {
                            self.tableView.mj_footer.endRefreshing()
                        }
                        self.tableView.reloadData()
                    }
                } else {
                    
                    let datas = json["list"].arrayValue.map({ (value) -> SW_SalesContractListModel in
                        return SW_SalesContractListModel(value, type: self.type)
                    })
                    
                    if isSearch {
                        if keyword == self.searchBar.searchText {
                            if !datas.isEmpty {
                                self.searchDatas = datas
                                /// 加载完毕
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
                        self.salesContracts = datas
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
            self.searchTableView.mj_header.endRefreshing()
            self.tableView.mj_header.endRefreshing()
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
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func setTableViewInset() {
        tableView.contentInset = UIEdgeInsets(top: NAV_HEAD_INTERVAL + 74, left: 0, bottom: TABBAR_BOTTOM_INTERVAL , right: 0)
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
        return salesContracts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var model: SW_SalesContractListModel
        
        if tableView == searchTableView {
            guard  searchDatas.count > indexPath.row else { return UITableViewCell() }
            model = searchDatas[indexPath.row]
        } else {
            guard  salesContracts.count > indexPath.row else { return UITableViewCell() }
            model = salesContracts[indexPath.row]
        }
        if model.type == .assgnationCar {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SW_AssgnationCarListCellID", for: indexPath) as! SW_AssgnationCarListCell
            cell.contractModel = model
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: SW_SalesContractListCellID, for: indexPath) as! SW_SalesContractListCell
            cell.contractModel = model
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var model: SW_SalesContractListModel
        if tableView == searchTableView {
            guard  searchDatas.count > indexPath.row else { return }
            model = searchDatas[indexPath.row]
        } else {
            guard  salesContracts.count > indexPath.row else { return }
            model = salesContracts[indexPath.row]
        }
        if model.type == .assgnationCar {
            navigationController?.pushViewController(SW_AssgnationCarDetailViewController(model.contractId) { (contractId, state) in
                if let index = self.salesContracts.firstIndex(where: { $0.contractId == contractId }) {
                    self.salesContracts[index].assignationState = state
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
                if let index = self.searchDatas.firstIndex(where: { $0.contractId == contractId }) {
                    self.searchDatas[index].assignationState = state
                    self.searchTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
            }, animated: true)
            
        } else{
            navigationController?.pushViewController(SW_SalesContractDetailViewController(model.contractId, type: type), animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return type.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == searchTableView {
            return 44
        }
        return 70
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        /// 两种头部view
        if tableView == searchTableView {
            let view = SectionHeaderView(frame: CGRect(x: 0, y: 0, width: 1, height: 44))
            if type == .assgnationCar {
                view.title = "合同车辆分配"
            } else {
                view.title = type.rawTitle + "办理"
            }
            view.backgroundColor = .white
            return view
        }
        let view = BigTitleSectionHeaderView(frame: CGRect(x: 0, y: 0, width: 1, height: 70))
        if type == .assgnationCar {
            view.title = "合同车辆分配"
        } else {
            view.title = type.rawTitle + "办理"
        }
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
            if offSet <= 70 || offSet > scrollView.contentSize.height - SCREEN_HEIGHT - 20 {//滚动到最上面就直接显示
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
