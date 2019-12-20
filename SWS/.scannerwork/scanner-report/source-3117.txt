//
//  SW_NewSelectPeopleViewController.swift
//  SWS
//
//  Created by jayway on 2018/12/1.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

/// 新的选人控制器，用于群列表
class SW_NewSelectPeopleViewController: UIViewController {

    private var navTitle = ""
    private var groupNum: String?
    private var type = SelectPeopleType.creatGroup
    private var isRequesting = false
    
    private var rangeCellId = "SW_RangeCellID"
    
    //存放当前模块选择的人范围  默认都是没有选人
    private var rangeManager = SW_RangeManager()
    
    var currentList = [SW_RangeModel]()
    
    lazy var searchBar: SW_SelectRangeSearchBar = {
        let sbar =  Bundle.main.loadNibNamed(String(describing: SW_SelectRangeSearchBar.self), owner: nil, options: nil)?.first as! SW_SelectRangeSearchBar
        sbar.placeholderString = "搜索联系人"
        sbar.rangeChangeBlock = { [weak self] in
            guard let self = self else { return }
            self.requsetData(self.searchBar.searchText)
        }
        return sbar
    }()
    
    lazy var sectionHeader: SW_SeletePeopleSectionHeader = {
        let view = Bundle.main.loadNibNamed(String(describing: SW_SeletePeopleSectionHeader.self), owner: nil, options: nil)?.first as! SW_SeletePeopleSectionHeader
        view.selectAllActionBlock = { [weak self] (isSelected) in
            guard let self = self else { return }
            if isSelected {/// 全选当前列表成员
                self.rangeManager.selectAllStaffs(staffs: self.currentList)
            } else {/// 取消全选当前列表成员
                self.rangeManager.cancelSelectAllStaffs(staffs: self.currentList)
            }
            self.tableView.reloadData()
            self.rangeChangeAction()
        }
        return view
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.registerNib(SW_RangeCell.self, forCellReuseIdentifier: self.rangeCellId)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.estimatedRowHeight = 79
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        return tableView
    }()
    
    /// 选人控制器初始化方法
    ///
    /// - Parameters:
    ///   - groupNum: 添加成员群ID
    ///   - navTitle: 标题栏文字
    ///   - type: 选人目的：创建群或者添加群成员
    init(_ groupNum: String?, navTitle: String = "选择联系人", type: SelectPeopleType) {
        super.init(nibName: nil, bundle: nil)
        self.groupNum = groupNum
        self.navTitle = navTitle
        self.type = type
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
        navigationItem.title = InternationStr(navTitle)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: InternationStr("取消"), style: .plain, target: self, action: #selector(cancelAction(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: InternationStr("完成"), style: .plain, target: self, action: #selector(doneAction(_:)))
        
        searchBar.textChangeBlock = { [weak self] in
            guard let self = self else { return }
            if self.searchBar.searchText.isEmpty {
                self.requsetData()
            }
        }
        
        searchBar.searchBlock = { [weak self] in
            guard let self = self else { return }
            self.requsetData(self.searchBar.searchText)
        }
        
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(123)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom)
        }
    }
    
    /// 获取当前页面的数据
    ///
    /// - Parameter append: true 加载更多    false ： 重新获取数据
    private func requsetData(_ keyword: String = "") {
        
        let typeIdStr = searchBar.getTypeAndIdStr()
        
        SW_RangeService.getAddGroupMemberList(typeIdStr.0, keyWord: keyword,GroupNum: groupNum, staffId: SW_UserCenter.shared.user!.id, idStr: typeIdStr.1).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.currentList = json["list"].arrayValue.map({ (value) -> SW_RangeModel in
                    return SW_RangeModel(value, type: .staff)
                })
                self.rangeChangeAction()
                self.tableView.reloadData()
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
    }
    
    /// 选择的人改变，判断是否全选，人数更新
    private func rangeChangeAction() {
        sectionHeader.selectAllBtn.isSelected = rangeManager.isSelectRangesAll(type: .staff, models: currentList)
        sectionHeader.peopleCount = rangeManager.selectStaffs.count
    }
    
    @objc func cancelAction(_ sender: UIBarButtonItem) {
        searchBar.dismissWithAnimation()
        dismiss(animated: true, completion: nil)
    }
    
    @objc func doneAction(_ sender: UIBarButtonItem) {
        searchBar.dismissWithAnimation()
        if rangeManager.selectStaffs.count == 0 {
            showAlertMessage("请选择联系人", MYWINDOW)
            return
        }
        
        dealSelectPeople(rangeManager)
    }
    
    
    /// 处理选人完成后的逻辑
    ///
    /// - Parameter rangeManager: 选择范围管理者
    func dealSelectPeople(_ rangeManager: SW_RangeManager) {
        switch type {
        case .addGroupMember:
            if let groupNum = groupNum {//有群num代表添加群成员
                guard !isRequesting else { return }
                QMUITips.showLoading("正在添加", in: self.view)
                isRequesting = true
                SW_GroupService.addGroupMember(groupNum, staffIds: rangeManager.getSelectPeopleIdStr()).response({ (json, isCache, error) in
                    if let _ = json as? JSON, error == nil {
                        showAlertMessage("添加群成员成功", self.view)
                        NotificationCenter.default.post(name: Notification.Name.Ex.GroupMembersHadChange, object: nil, userInfo: ["isAdd": true,"count": rangeManager.selectStaffs.count])
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                    }
                    QMUITips.hideAllTips(in: self.view)
                    self.isRequesting = false
                })
            }
        case .creatGroup:
            ///创建群
            self.navigationController?.pushViewController(SW_CreatGroupViewController.ctreatVc(rangeManager), animated: true)
        default:
            break
        }
    }
    
    deinit {
        PrintLog("deinit--")
    }
}

extension SW_NewSelectPeopleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rangeCellId, for: indexPath) as! SW_RangeCell
        cell.rangeModel = currentList[indexPath.row]
        cell.isSelect = rangeManager.isSelectRange(model: currentList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = currentList[indexPath.row]
        if rangeManager.isSelectRange(model: model) {
            rangeManager.removeSelectRange(model: model)
        } else {
            rangeManager.setSelectRange(model: model)
        }
        rangeChangeAction()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 79
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {/// 70   44
        return 70
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        sectionHeader.peopleCount = rangeManager.selectStaffs.count
        return sectionHeader
    }
}
