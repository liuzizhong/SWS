//
//  SW_InformManageViewController.swift
//  SWS
//
//  Created by jayway on 2018/4/26.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit


class SW_InformManageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var currentIndex = 0
    
    /// 搜索出来的数据 搜索的直接放这里面
    private var searchDatas = [SW_InformModel]()
    
     private var SW_InformListCellID = "SW_InformListCellID"
    
    private lazy var searchBar: SW_NewSearchBar = {
        let sbar =  Bundle.main.loadNibNamed(String(describing: SW_NewSearchBar.self), owner: nil, options: nil)?.first as! SW_NewSearchBar
        sbar.placeholderString = "搜索"
        return sbar
    }()
    
    lazy var searchTableView: UITableView = {
        let tbv = UITableView.init(frame: .zero, style: .plain)
        tbv.isHidden = true
        tbv.delegate = self
        tbv.dataSource = self
        tbv.backgroundColor = UIColor.white
        tbv.separatorStyle = .none
        tbv.keyboardDismissMode = .onDrag
        if #available(iOS 11.0, *) {
            tbv.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        tbv.registerNib(SW_InformListCell.self, forCellReuseIdentifier: SW_InformListCellID)
        tbv.estimatedRowHeight = 300
        tbv.rowHeight = UITableView.automaticDimension
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
    
    private var pageTitles = ["集团公告","单位通知","部门通知"]
    
    private var pageControllers = [SW_InformListViewController(.group),SW_InformListViewController(.business),SW_InformListViewController(.department)]
    
    private lazy var layout: LTLayout = {
        let layout = LTLayout()
//        layout.isAverage = true
        /* 更多属性设置请参考 LTLayout 中 public 属性说明 */
        return layout
    }()
    
    private func managerReact() -> CGRect {
        let Y: CGFloat = NAV_HEAD_INTERVAL + 74
        let H: CGFloat = SCREEN_HEIGHT - NAV_HEAD_INTERVAL - 74
        return CGRect(x: 0, y: Y, width: view.bounds.width, height: H)
    }
    
    private lazy var advancedManager: LTAdvancedManager = {
        let advancedManager = LTAdvancedManager(frame: managerReact(), viewControllers: pageControllers, titles: pageTitles, currentViewController: self, layout: layout, headerViewHandle: { [weak self] in
            guard let strongSelf = self else { return UIView() }
            let headerView = BigTitleSectionHeaderView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 80))
            headerView.title = "公告管理"
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
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    func setup() {
        view.backgroundColor = UIColor.white
        automaticallyAdjustsScrollViewInsets = false
        
        if (SW_UserCenter.shared.user!.auth.messageAuth.first?.authDetails.count ?? 0) > 0 {        
            searchBar.setUpAddBtn("发公告", image: #imageLiteral(resourceName: "icon_bulletin"), action: { [weak self] in
                self?.sendInform()
            })
        }
        
        searchBar.addBtn.setTitleColor(UIColor.v2Color.blue, for: UIControl.State())
        searchBar.cancelBtn.setTitleColor(UIColor.v2Color.lightBlack, for: UIControl.State())
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
            self.requsertInformDatas(self.searchBar.searchText)
        }
        
        view.addSubview(advancedManager)
        advancedManagerConfig()
        
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(NAV_HEAD_INTERVAL + 74)
        }
        
        view.addSubview(searchTableView)
        searchTableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom)
        }
        searchTableView.mj_header = SW_RefreshHeader.init(refreshingBlock: { [weak self] in
            guard let self = self else { return }
            self.requsertInformDatas(self.searchBar.searchText)
        })
    }
    
    
    func requsertInformDatas(_ keyword: String = "") {
        if keyword.isEmpty {
            self.tap.isEnabled = true
            self.searchTableView.isHidden = true
            return
        }
        SW_WorkingService.getInformList(currentIndex, staffId: SW_UserCenter.shared.user!.id, businessUnitId: SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId, departmentId: SW_UserCenter.shared.user!.staffWorkDossier.departmentId, keyWord: keyword, max: 99999).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                let datas = json["list"].arrayValue.map({ (value) -> SW_InformModel in
                    return SW_InformModel(value)
                })
                if keyword == self.searchBar.searchText {
                    if !datas.isEmpty {
                        self.searchDatas = datas
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
                }
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
            self.searchTableView.mj_header.endRefreshing()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func sendInform() {
        let vc = SW_SendInformTwoViewController("")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SW_InformListCellID, for: indexPath) as! SW_InformListCell
        cell.model = searchDatas[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc =  SW_InformWebViewController(urlString: searchDatas[indexPath.row].showUrl, informId: searchDatas[indexPath.row].id)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

extension SW_InformManageViewController: LTAdvancedScrollViewDelegate {
    
    //MARK: 具体使用请参考以下
    private func advancedManagerConfig() {
        //MARK: 选中事件
        advancedManager.advancedDidSelectIndexHandle = { [weak self] in
//            print("选中了 -> \($0)")
            self?.currentIndex = $0
        }
        
    }
    
    func glt_scrollViewOffsetY(_ offsetY: CGFloat) {
//        print("offset --> ", offsetY)
    }
}





