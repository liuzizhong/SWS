//
//  SW_TransferGroupViewController.swift
//  SWS
//
//  Created by jayway on 2019/6/20.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_TransferGroupViewController: UIViewController {
    
    private var keyWord = "" {
        didSet {
            if keyWord != oldValue {
                getListAndReload(keyWord)
            }
        }
    }
    
    private let rangeCellId = "sw_rangeCellId"
    
    private lazy var searchBar: SW_SearchBar = {
        let sbar = SW_SearchBar()
        sbar.backgroundColor = .white
        sbar.searchField.placeholder = "搜索"
        return sbar
    }()
    
    private lazy var emptyView: LYEmptyView = {
        return SW_NoDataEmptyView.creat()
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        //        if #available(iOS 11.0, *) {
        //            tableView.contentInsetAdjustmentBehavior = .never
        //        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.registerNib(SW_RangeCell.self, forCellReuseIdentifier: self.rangeCellId)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.white
        return tableView
    }()
    
    private var groupNum: String = ""
    private var isRequesting = false
    private var currentList = [SW_RangeModel]()
    private var selectMember: SW_RangeModel?
    
    init(_ groupNum: String) {
        super.init(nibName: nil, bundle: nil)
        self.groupNum = groupNum
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getListAndReload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupView() {
        automaticallyAdjustsScrollViewInsets = false
        navigationItem.title = "选择新群主"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(transferGroupAction(_:)))
        searchBar.changeCancelBtnHiddenState(isShow: false)
        ///搜索按钮点击
        searchBar.searchBlock = { [weak self] in
            if let key = self?.searchBar.searchField.text {//让当前显示的控制器进行搜索
                self?.keyWord = key
            }
        }
        ///输入框内容改变
        searchBar.searchMessageBlock = { [weak self] (keyWord) in
            if keyWord?.isEmpty == true {///让输入框未空时刷新一下数据显示全部
                self?.keyWord = ""
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
        ScrollToTopButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), scrollView: tableView)
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    /// 获取当前页面的数据
    ///
    /// - Parameter
    private func getListAndReload(_ keyword: String = "") {
        SW_GroupService.getGroupMemberList(groupNum, keyWord: keyword, max: 99999, offset: 0, type: 1).response({ (json, isCache, error) in
            self.emptyView.contentViewOffset = -(self.tableView.height - 250) * 0.1
            self.tableView.ly_emptyView = self.emptyView
            if let json = json as? JSON, error == nil {
                self.currentList = json.arrayValue.map({ return SW_RangeModel($0, type: .staff) })
                self.selectMember = nil
                self.tableView.reloadData()
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
    }
    
    /// 删除群成员事件
    ///
    /// - Parameter sender: 右边按钮
    @objc private func transferGroupAction(_ sender: UIBarButtonItem) {
        guard let selectMember = selectMember else {
            showAlertMessage("请选择新群主", self.view)
            return
        }
        guard !isRequesting else { return }
        isRequesting = true
        QMUITips.showLoading("正在转让", in: self.view)
        
        SW_GroupService.transferChatGroupOwner(groupNum, ownerId: selectMember.id).response({ (json, isCache, error) in
            QMUITips.hideAllTips(in: self.view)
            if let _ = json as? JSON, error == nil {
                showAlertMessage("转让成功", self.view)

                NotificationCenter.default.post(name: Notification.Name.Ex.GroupOwnerHadChange, object: nil, userInfo: ["groupNum": self.groupNum])
                self.navigationController?.popViewController(animated: true)
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
            self.isRequesting = false
        })
    }
    
    
}

extension SW_TransferGroupViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rangeCellId, for: indexPath) as! SW_RangeCell
        cell.rangeModel = currentList[indexPath.row]
        cell.isSelect = currentList[indexPath.row].id == selectMember?.id
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = currentList[indexPath.row]
        if currentList[indexPath.row].id == selectMember?.id {
            selectMember = nil
        } else {
            selectMember = model
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 79
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    
}


