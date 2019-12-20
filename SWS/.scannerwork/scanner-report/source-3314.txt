//
//  SW_AppendRepairItemViewController.swift
//  SWS
//
//  Created by jayway on 2019/6/12.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_AppendRepairItemViewController: UIViewController {
    
    private var repairOrderId = ""
    
    private var isRequesting = false
    
    private var cellId = "SW_RepairItemCellID"
    
    /// 选择了的维修项目
    var selectItems = [SW_RepairItemModel]() {
        didSet {
//            if selectItems.count == 0 {
//                navigationItem.rightBarButtonItem?.title = InternationStr("确定")
//            } else {
                navigationItem.rightBarButtonItem?.title = InternationStr("确定(\(selectItems.count))")
//            }
        }
    }
    
    var currentList = [SW_RepairItemModel]()
    
    var keyWord = ""
    
    private var totalCount = 0
    
    lazy var sectionHeader: SW_RepairItemHeaderView = {
        let view = Bundle.main.loadNibNamed("SW_RepairItemHeaderView", owner: nil, options: nil)?.first as! SW_RepairItemHeaderView
        return view
    }()
    
    lazy var searchBar: SW_SearchBar = {
        let sbar = SW_SearchBar()
        sbar.searchField.placeholder = "输入项目编号/名称"
        return sbar
    }()
    
    lazy var footerView: MJRefreshAutoNormalFooter = {
        let ftv = MJRefreshAutoNormalFooter.init { [weak self] in
            self?.requsetData(self?.keyWord ?? "", byAppend: true)
        }
//        ftv?.isAutomaticallyHidden = false
        ftv?.isHidden = true
        ftv?.triggerAutomaticallyRefreshPercent = -10
        return ftv!
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.registerNib(SW_RepairItemCell.self, forCellReuseIdentifier: self.cellId)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = UITableView.automaticDimension
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        return tableView
    }()
    private var successBlock: NormalBlock?
    
    init(_ repairOrderId: String, successBlock: NormalBlock?) {
        super.init(nibName: nil, bundle: nil)
        self.repairOrderId = repairOrderId
        self.successBlock = successBlock
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        requsetData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    private func setup() {
        view.backgroundColor = UIColor.white
        navigationItem.title = "维修项目"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: InternationStr("确定(0)"), style: .plain, target: self, action: #selector(doneAction(_:)))
        
        searchBar.changeCancelBtnHiddenState(isShow: false)
        ///搜索按钮点击
        searchBar.searchBlock = { [weak self] in
            if let key = self?.searchBar.searchField.text {//让当前显示的控制器进行搜索
                self?.keyWord = key
                self?.requsetData(key, byAppend: false)
            }
        }
        ///输入框内容改变
        searchBar.searchMessageBlock = { [weak self] (keyWord) in
            if keyWord?.isEmpty == true {///让输入框未空时刷新一下数据显示全部
                self?.keyWord = ""
                self?.requsetData("", byAppend: false)
            }
        }
        
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(64)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom)
        }
        
        ///上拉加载更多
        tableView.mj_footer = footerView
        
        let emptyView = LYEmptyView.empty(withImageStr: "", titleStr: "暂无数据", detailStr: "")
        emptyView?.titleLabTextColor = UIColor.v2Color.lightGray
        emptyView?.titleLabFont = Font(14)
        tableView.ly_emptyView = emptyView
    }
    
    /// 获取当前页面的数据
    ///
    /// - Parameter append: true 加载更多    false ： 重新获取数据
    private func requsetData(_ keyword: String = "", byAppend: Bool = false) {
        let offSet = byAppend ? currentList.count : 0
        
        SW_AfterSaleService.getRepairItemList(keyword, offset: offSet).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.totalCount = json["count"].intValue
                if byAppend {
                    self.currentList.append(contentsOf: json["list"].arrayValue.map({ (value) -> SW_RepairItemModel in
                        return SW_RepairItemModel(value)
                    }))
                    if self.currentList.count >= self.totalCount {
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                        self.tableView.mj_footer.isHidden = true
                    } else {
                        self.tableView.mj_footer.endRefreshing()
                    }
                } else {
                    self.currentList = json["list"].arrayValue.map({ (value) -> SW_RepairItemModel in
                        return SW_RepairItemModel(value)
                    })
                    /// 加载完毕
                    if self.currentList.count < self.totalCount {
                        self.tableView.mj_footer.isHidden = false
                        self.tableView.mj_footer.state = MJRefreshState(rawValue: 1)!
                        /// 进入时判断是否显示了销售接待条 控制偏移量
                    } else {
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                        self.tableView.mj_footer.isHidden = true
                    }
                }
                self.tableView.reloadData()
            } else {
                if self.currentList.count >= self.totalCount {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    self.tableView.mj_footer.isHidden = true
                } else {
                    self.tableView.mj_footer.endRefreshing()
                }
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
    }
    
    
    @objc func doneAction(_ sender: UIBarButtonItem) {
        if selectItems.count == 0 {
            showAlertMessage("请选择维修项目", MYWINDOW)
            return
        }
        
        dealSelectItem()
    }
    
    
    /// 提交新增维修项目
    func dealSelectItem() {
        guard !isRequesting else { return }
        isRequesting = true
        SW_AfterSaleService.appendRepairItem(repairOrderId, repairItemList: selectItems).response({ (json, isCache, error) in
            if let _ = json as? JSON, error == nil {
                showAlertMessage("保存成功", MYWINDOW)
                self.successBlock?()
                self.navigationController?.popViewController(animated: true)
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
            self.isRequesting = false
        })
    }
    
    deinit {
        PrintLog("deinit--")
    }
}

extension SW_AppendRepairItemViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SW_RepairItemCell
        let item = currentList[indexPath.row]
        cell.item = item
        cell.isSelect = selectItems.contains(where: { return $0.repairItemId == item.repairItemId })
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = currentList[indexPath.row]
        if let index = selectItems.firstIndex(where: { return $0.repairItemId == model.repairItemId }) {
            selectItems.remove(at: index)
        } else {
            selectItems.append(model)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionHeader
    }
    
}

