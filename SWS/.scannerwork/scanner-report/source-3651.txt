//
//  SW_WorkGroupListViewController.swift
//  SWS
//
//  Created by jayway on 2018/5/30.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_WorkGroupListViewController: SW_TableViewController {

    private var groupDatas = [SW_GroupModel]()
    
    private var searchDatas = [SW_GroupModel]()
    
    lazy var searchBar: SW_NewSearchBar = {
       let sbar =  Bundle.main.loadNibNamed(String(describing: SW_NewSearchBar.self), owner: nil, options: nil)?.first as! SW_NewSearchBar
        sbar.placeholderString = "搜索群"
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

        tbv.registerNib(SW_AddressBookMainCell.self, forCellReuseIdentifier: "SW_AddressBookMainCellID")
        tbv.rowHeight =  79
        tbv.estimatedRowHeight = 79
        return tbv
    }()
    
    private lazy var searchEmptyView: LYEmptyView = {
        let emptyView = LYEmptyView.empty(withImageStr: "", titleStr: "抱歉，没有找到相关内容", detailStr: "")
        emptyView?.titleLabTextColor = UIColor.v2Color.darkGray
        emptyView?.titleLabFont = Font(14)
        emptyView?.contentViewY = 60
        return emptyView!
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
    
    //MARK: - setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupNotification()
        requesrGroupData()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    deinit {
        PrintLog("deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: - setup
    /// 控制器的一些初始化方法
    private func setup() {
       
        tableView.removeFromSuperview()
        tableView = UITableView.init(frame: .zero, style: .grouped)
        view.addSubview(tableView)
        setTableViewInset()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none

        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = 79
        tableView.estimatedRowHeight = 79
        tableView.registerNib(SW_AddressBookMainCell.self, forCellReuseIdentifier: "SW_AddressBookMainCellID")
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = false
        }
        
        searchBar.setUpAddBtn("建群", image: UIImage(named: "icon_groupchat")!, action: { [weak self] in
            if SW_UserCenter.shared.user!.huanxin.huanxinAccount.isEmpty {
                SW_UserCenter.shared.showAlert(message: "请联系管理员或稍后重试")
                SW_UserCenter.loginHuanXin()
                return
            }
            let vc = SW_NewSelectPeopleViewController(nil, navTitle: "选择联系人",type: .creatGroup)
            let nav = SW_NavViewController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self?.present(nav, animated: true, completion: nil)
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
            
            self.requesrGroupData(keyword: self.searchBar.searchText, isSearch: true)
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
        tableView.ly_emptyView = SW_LoadingEmptyView.creat()
        tableView.ly_emptyView.contentViewOffset = -(SCREEN_HEIGHT - 250) * 0.15
        tableView.mj_header = SW_RefreshHeader.init(refreshingBlock: { [weak self] in
            self?.requesrGroupData()
        })
        searchTableView.mj_header = SW_RefreshHeader.init(refreshingBlock: { [weak self] in
            guard let self = self else { return }
            self.requesrGroupData(keyword: self.searchBar.searchText, isSearch: true)
        })
    }
    
    private func setupNotification() {
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserGroupListDidUpdate, object: nil, queue: nil, using: { [weak self] (notifa) in
            self?.requesrGroupData()
        })
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadChangeGroupName, object: nil, queue: nil) { [weak self] (notification) in
            let groupNum = notification.userInfo?["groupNum"] as? String ?? ""
            if let index = self?.groupDatas.firstIndex(where: { $0.groupNum == groupNum }) {
                self?.groupDatas[index].groupName  = notification.userInfo?["groupName"] as? String ?? ""
                self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
            
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadChangeGroupIcon, object: nil, queue: nil) { [weak self] (notification) in
            let groupNum = notification.userInfo?["groupNum"] as? String ?? ""
            
            if let index = self?.groupDatas.firstIndex(where: { $0.groupNum == groupNum }) {
                self?.groupDatas[index].imageUrl  = notification.userInfo?["groupIcon"] as? String ?? ""
                self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
        /// 工作群状态修改 {"groupId":131,"groupNum":"80242616107009","groupState":1}
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.GroupStateHadChange, object: nil, queue: nil) { [weak self] (notification) in
            let groupNum = notification.userInfo?["groupNum"] as? String ?? ""
            let groupState = notification.userInfo?["groupState"] as? Int ?? 1
            if let index = self?.groupDatas.firstIndex(where: { $0.groupNum == groupNum }) {
                self?.groupDatas[index].groupState = groupState != 2
                self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
            if let index = self?.searchDatas.firstIndex(where: { $0.groupNum == groupNum }) {
                self?.searchDatas[index].groupState = groupState != 2
                self?.searchTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
    }
    
    ///获取请求数据
    private func requesrGroupData(keyword: String = "", isSearch: Bool = false) {
        SW_AddressBookService.getGroupList(SW_UserCenter.shared.user!.id, keyWord: keyword).response({ (json, isCache, error) in
            self.emptyView.contentViewOffset = -(self.tableView.height - 250) * 0.1
            self.tableView.ly_emptyView = self.emptyView
            self.tableView.mj_header.endRefreshing()
            self.searchTableView.mj_header.endRefreshing()
            if let json = json as? JSON, error == nil {
                if !json["groupList"].arrayValue.isEmpty {
                    let datas = json["groupList"].arrayValue.map({ (json) -> SW_GroupModel in
                        return SW_GroupModel(json)
                    })
                    if isSearch {
                        if keyword == self.searchBar.searchText {
                            self.searchDatas = datas
                            self.searchTableView.reloadData()
                            self.searchTableView.setContentOffset(CGPoint.zero, animated: false)
                            self.searchTableView.isHidden = false
                            self.tap.isEnabled = false
                        }
                    } else {
                        self.groupDatas = datas
                        self.tableView.reloadData()
                    }
                } else if isSearch {
                    self.tap.isEnabled = keyword.isEmpty
                    self.searchTableView.isHidden = keyword.isEmpty
                    if !keyword.isEmpty {
                        self.searchDatas = []
                        self.searchTableView.ly_emptyView = self.searchEmptyView///
                        self.searchTableView.reloadData()
                    }
                }
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
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
    
    //MARK: - tableview delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchTableView {
            return searchDatas.count
        }
        return groupDatas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SW_AddressBookMainCellID", for: indexPath) as! SW_AddressBookMainCell
        var model: SW_GroupModel
        if tableView == searchTableView {
            guard  searchDatas.count > indexPath.row else { return cell }
            model = searchDatas[indexPath.row]
        } else {
            guard  groupDatas.count > indexPath.row else { return cell }
            model = groupDatas[indexPath.row]
        }
        cell.model = nil
        cell.separaterLine.isHidden = true
        cell.groupModel = model
        cell.isForbinden = !model.groupState
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var model: SW_GroupModel
        if tableView == searchTableView {
            guard  searchDatas.count > indexPath.row else { return }
            model = searchDatas[indexPath.row]
        } else {
            guard  groupDatas.count > indexPath.row else { return }
            model = groupDatas[indexPath.row]
        }
        if !model.groupState {
            showAlertMessage("该工作群已被停用，不能聊天", MYWINDOW)
            return
        }
        if SW_UserCenter.shared.user!.huanxin.huanxinAccount.isEmpty {
            SW_UserCenter.shared.showAlert(message: "请联系管理员或稍后重试")
            SW_UserCenter.loginHuanXin()
            return
        } else {
            SW_UserCenter.loginHuanXin()
        }
        if model.groupNum.isEmpty {
            showAlertMessage("网络异常，请稍后重试", MYWINDOW)
            return
        }
        let vc = SW_ChatViewController(conversationChatter: model.groupNum, conversationType: EMConversationTypeGroupChat)
        vc?.title = model.groupName
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 79
//    }
    
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
            view.title = "工作群"
            view.backgroundColor = .white
            return view
        }
        let view = BigTitleSectionHeaderView(frame: CGRect(x: 0, y: 0, width: 1, height: 70))
        view.title = "工作群"
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
