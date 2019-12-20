//
//  SW_AddressBookViewController.swift
//  SWS
//
//  Created by jayway on 2017/12/23.
//  Copyright © 2017年 yuanrui. All rights reserved.
//

import UIKit


enum AddressBookPage: Int { //该控制器的类型
    case main             = 0   //通讯录主页           -》   显示所有分区以及所有群
    case region                 //主页进入分区页面      -》   显示该分区所有单位
    case business               //分区页面进入单位页面   -》   显示该分区所有部门
    case department             //单位进入部门页面      -》   显示该部门所有成员
}

class SW_AddressBookViewController: SW_TableViewController {
    
    /// 员工数据
    private var staffDatas = [SW_AddressBookModel]()
    /// 区域筛选条件   --   n默认值是自己z所在的分区，单位，部门，
    private var selectRegion: SW_AddressBookModel? = SW_AddressBookModel(name: SW_UserCenter.shared.user!.regionInfo, id: SW_UserCenter.shared.user!.staffWorkDossier.regionInfoId)
    private var selectbUnit: SW_AddressBookModel? = SW_AddressBookModel(name: SW_UserCenter.shared.user!.businessUnitName, id: SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId)
    private var selectdept: SW_AddressBookModel? = nil
    
    lazy var searchBar: SW_NewSearchBar = {
        let sbar =  Bundle.main.loadNibNamed(String(describing: SW_NewSearchBar.self), owner: nil, options: nil)?.first as! SW_NewSearchBar
        sbar.placeholderString = "搜索联系人"
        sbar.isCanBecomeFirstResponder = false
        return sbar
    }()
    
    lazy var tableHeaderView: SW_SelectRegionTableHeaderView = {
        let headerV =  Bundle.main.loadNibNamed(String(describing: SW_SelectRegionTableHeaderView.self), owner: nil, options: nil)?.first as! SW_SelectRegionTableHeaderView
        headerV.titleLb.isHidden = true
        headerV.topConstraint.constant = 0
        headerV.setUpDatas(self.selectRegion, bunit: self.selectbUnit, dept: self.selectdept)
        return headerV
    }()
  
    var scrollTopBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "icon_backtotop"), for: UIControl.State())
        btn.alpha = 0
        btn.addTarget(self, action: #selector(scrollToTopAction), for: .touchUpInside)
        return btn
    }()
    
    private lazy var emptyView: LYEmptyView = {
        return SW_NoDataEmptyView.creat()
    }()
    
    /// 用于计算上下滑动方向
    private var lastOffset: CGFloat = 0
    
    /// 当前是否显示搜索框，默认显示
    private var currentShowState = true
    
    lazy var footerView: MJRefreshAutoNormalFooter = {
        let ftv = MJRefreshAutoNormalFooter.init { [weak self] in
            self?.requsetData(true)
        }
//        ftv?.isAutomaticallyHidden = false
        ftv?.isHidden = true
        ftv?.triggerAutomaticallyRefreshPercent = -10
        return ftv!
    }()
    
    /// 当前总人数
    private var totalCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildView()
        requsetData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    deinit {
        PrintLog("deinit")
//        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: -设置子控件
    private func setupChildView() -> Void {
        tableView.removeFromSuperview()
        tableView = UITableView.init(frame: .zero, style: .grouped)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: NAV_HEAD_INTERVAL + 74, left: 0, bottom: TABBAR_BOTTOM_INTERVAL, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: NAV_HEAD_INTERVAL + 74, left: 0, bottom: TABBAR_BOTTOM_INTERVAL, right: 0)
        tableView.keyboardDismissMode = .onDrag
        tableView.registerNib(SW_AddressBookMainCell.self, forCellReuseIdentifier: "SW_AddressBookMainCellID")
        tableView.estimatedRowHeight = 79
        
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
            //    前往搜索界面
            let vc = SW_SearchStaffViewController(self.selectRegion, unit: self.selectbUnit, dept: self.selectdept)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(NAV_HEAD_INTERVAL + 74)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.top.equalToSuperview()
//            make.top.equalTo(searchBar.snp.bottom)
        }
        
        view.addSubview(scrollTopBtn)
        scrollTopBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(44)
            make.trailing.equalTo(-25)
            make.bottom.equalTo(-15 - TABBAR_BOTTOM_INTERVAL)
        }
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 54))
        header.addSubview(tableHeaderView)
        tableHeaderView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tableHeaderView.rangeChangeBlock = { [weak self] (region, unit, dept) in
            self?.selectRegion = region
            self?.selectbUnit = unit
            self?.selectdept = dept
            self?.requsetData()
        }
        
        tableView.ly_emptyView = SW_LoadingEmptyView.creat()
        tableView.ly_emptyView.contentViewOffset = -(SCREEN_HEIGHT - 250) * 0.1
        tableView.mj_header = SW_RefreshHeader.init(refreshingBlock: { [weak self] in
            self?.requsetData()
        })
        tableView.mj_footer = footerView
        tableView.tableHeaderView = header
    }
    
    
//    获取当前页面显示数据   后期可能需要添加缓存
    private func requsetData(_ byAppend: Bool = false) {
        let offSet = byAppend ? staffDatas.count : 0
        
        SW_AddressBookService.searchStaff(regionId: selectRegion, bUnitId: selectbUnit, deptId: selectdept, max: 20, offset: offSet).response({ (json, isCache, error) in
            self.tableView.ly_emptyView = self.emptyView
            
            if let json = json as? JSON, error == nil {
                self.totalCount = json["count"].intValue
                if byAppend {
                    let datas = json["list"].arrayValue.map({ (value) -> SW_AddressBookModel in
                        return SW_AddressBookModel(value, type: .contact)
                    })
                    
                    self.staffDatas.append(contentsOf: datas)
                    if self.staffDatas.count >= self.totalCount {
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                        self.tableView.mj_footer.isHidden = true
                    } else {
                        self.tableView.mj_footer.endRefreshing()
                    }
                    self.tableView.reloadData()
                    
                } else {
                    
                    let datas = json["list"].arrayValue.map({ (value) -> SW_AddressBookModel in
                        return SW_AddressBookModel(value, type: .contact)
                    })
                    self.staffDatas = datas
                    /// 加载完毕
                    if datas.count < self.totalCount {
                        self.tableView.mj_footer.isHidden = false
                        self.tableView.mj_footer.state = MJRefreshState(rawValue: 1)!
                        /// 进入时判断是否显示了销售接待条 控制偏移量
                    } else {
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                        self.tableView.mj_footer.isHidden = true
                    }
                    self.tableView.reloadData()
                }
            } else {
                if self.staffDatas.count >= self.totalCount {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    self.tableView.mj_footer.isHidden = true
                } else {
                    self.tableView.mj_footer.endRefreshing()
                }
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
        })
        self.tableView.mj_header.endRefreshing()
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
        currentShowState = show
        
        searchBar.showOrHideSubView(show: show, duration: 0.3)
        searchBar.snp.updateConstraints { (update) in
            update.height.equalTo(show ? NAV_HEAD_INTERVAL + 74 : NAV_HEAD_INTERVAL)
        }

        UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return staffDatas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SW_AddressBookMainCellID", for: indexPath) as! SW_AddressBookMainCell
        cell.model = staffDatas[indexPath.row]
        cell.separaterLine.isHidden = true
        cell.groupModel = nil
        return cell
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = staffDatas[indexPath.row]
        let vc = SW_StaffInfoViewController(model.id)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {/// 70   44
        return 70
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = BigTitleSectionHeaderView(frame: CGRect(x: 0, y: 0, width: 1, height: 70))
        view.title = "内部通讯录"
        view.peopleCount = totalCount
        return view
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            //阴影线
        searchBar.showOrHideShadow(show: scrollView.contentOffset.y > 70)
        
        scrollTopBtn.showOrHide(show: scrollView.contentOffset.y > 300)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastOffset = scrollView.contentOffset.y
    }
    
    ///  隐藏显示tabbar
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        ////  最终滚动停留的位置offset
        let offSet = targetContentOffset.pointee.y
        if offSet <= 70 || offSet > scrollView.contentSize.height - SCREEN_HEIGHT - 20 {//滚动到最上面就直接显示
            isShowSearchBar = true
        } else {
            isShowSearchBar = offSet - lastOffset < 0
        }
        lastOffset = offSet
    }
    
    private var isShowSearchBar = true
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        lastOffset = 0
        showOrHideSearchBar(show: true)
        return true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        showOrHideSearchBar(show: isShowSearchBar)
    }

}

/// 小标题头部view
class SectionHeaderView: UIView {
    
    var title: String = "" {
        didSet {
            titleView.text = title
        }
    }
    
    lazy var titleView: UILabel = {
        let lb = UILabel()
        lb.font = Font(14)
        lb.textColor = UIColor.v2Color.darkGray
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.leading.equalTo(15)
            make.bottom.equalTo(-10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


/// 大标题的分区头部view
class BigTitleSectionHeaderView: UIView {
    
    var title: String = "" {
        didSet {
            titleView.text = title
        }
    }
    
    lazy var titleView: UILabel = {
        let lb = UILabel()
        lb.font = MediumFont(29)
        lb.textColor = UIColor.v2Color.lightBlack
        return lb
    }()
    
    var peopleCount: Int? {
        didSet {
            guard let peopleCount = peopleCount else { return }
            peopleLb.isHidden = false
            peopleLb.text = "(\(peopleCount)人)"
        }
    }
    
    private var peopleLb: UILabel = {
        let lb = UILabel()
        lb.font = Font(16)
        lb.isHidden = true
        lb.textColor = #colorLiteral(red: 0.1647058824, green: 0.1647058824, blue: 0.1647058824, alpha: 1)
        return lb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.leading.equalTo(15)
            make.centerY.equalToSuperview()
        }
        
        addSubview(peopleLb)
        peopleLb.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleView.snp.centerY)
            make.leading.equalTo(titleView.snp.trailing).offset(5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
