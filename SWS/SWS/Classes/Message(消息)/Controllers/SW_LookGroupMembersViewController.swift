//
//  SW_LookGroupMembersViewController.swift
//  SWS
//
//  Created by jayway on 2018/5/24.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_LookGroupMembersViewController: UIViewController {
    
    private let rangeCellId = "sw_rangeCellId"
    
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
        let view = BigTitleSectionHeaderView(frame: CGRect(x: 0, y: 0, width: 1, height: 70))
        view.title = "群成员"
        tableView.tableHeaderView = view
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.white
        return tableView
    }()
    
    private var groupNum = ""
    private var isGroupOwner = false

    private var currentList = [SW_RangeModel]()
    
    init(_ groupNum: String, isGroupOwner: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.groupNum = groupNum
        self.isGroupOwner = isGroupOwner
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
        if isGroupOwner {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "添加", style: .plain, target: self, action: #selector(addGroupMembersAction(_:)))
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        //群成员改变通知  添加或者删除都调用  重新获取群成员
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.GroupMembersHadChange, object: nil, queue: nil) { [weak self] (notifi) in
            self?.reGetGroupMembers()
        }
        ScrollToTopButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), scrollView: tableView)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        PrintLog("abcdfgr deinit")
    }
    
    //MARK: - 网络请求
    /// 重新获取群成员
    private func reGetGroupMembers() {
        SW_GroupService.getGroupMemberList(groupNum, max: 99999).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.currentList = SW_RangeModel.sortGroupMembers(json.arrayValue.map({ return SW_RangeModel($0, type: .staff) }))
                self.tableView.reloadData()
            }
        })
    }
    
    /// 获取当前页面的数据
    ///
    /// - Parameter
    private func getListAndReload() {
        SW_GroupService.getGroupMemberList(groupNum, max: 99999, offset: 0, type: 0).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.currentList = SW_RangeModel.sortGroupMembers(json.arrayValue.map({ return SW_RangeModel($0, type: .staff) }))
                self.tableView.reloadData()
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
    }
    
    /// 添加群成员事件
    ///
    /// - Parameter sender: 右边按钮
    @objc private func addGroupMembersAction(_ sender: UIBarButtonItem) {
        let vc = SW_NewSelectPeopleViewController(groupNum, navTitle: "添加群成员", type: .addGroupMember)
        let nav = SW_NavViewController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
}

extension SW_LookGroupMembersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rangeCellId, for: indexPath) as! SW_RangeCell
        let model = currentList[indexPath.row]
        cell.rangeModel = model
        cell.isHiddenSelect = true
        cell.isGroupOwner = model.memberType == .owner
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = currentList[indexPath.row]
        navigationController?.pushViewController(SW_StaffInfoViewController(model.id), animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 79
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
}
