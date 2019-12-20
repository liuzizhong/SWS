//
//  SW_AddressBookHomeViewController.swift
//  SWS
//
//  Created by jayway on 2018/10/31.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_AddressBookHomeViewController: SW_TableViewController {

    let AddressBookHomeCellID = "AddressBookHomeCellID"
    
    var items = [SW_NormalHomeCellModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildViewToWorkingVc()     //设置子控件
        isHideTabBar = false
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadCheckAndUpdate, object: nil, queue: nil) { [weak self] (notification) in
            self?.setupItems()
        }
        setupItems()
    }
    
    func setupItems() {
        items = [SW_NormalHomeCellModel(title: InternationStr("内部通讯录"), describe: InternationStr("快速查找公司内部人员信息，并向其发送消息"), pushVc: SW_AddressBookViewController.self)]
        if SW_UserCenter.shared.user!.auth.addressBookAuth.contains(where: { return $0.type == .customer }) {
            items.append(SW_NormalHomeCellModel(title: InternationStr("销售客户通讯录"), describe: InternationStr("高效地管理客户信息，让您的工作事半功倍"), pushVc: SW_CustomerAddressBookViewController.self))
        }
        if SW_UserCenter.shared.user!.auth.addressBookAuth.contains(where: { return $0.type == .afterSale }) {
            items.append(SW_NormalHomeCellModel(title: InternationStr("售后客户通讯录"), describe: InternationStr("高效地管理客户信息，让您的工作事半功倍"), pushVc: SW_AfterSalesCustomerAddressBookViewController.self))
        }
        
        items.append(SW_NormalHomeCellModel(title: InternationStr("工作群"), describe: InternationStr("您可以通过工作群同时与多人在线交流"), pushVc: SW_WorkGroupListViewController.self))
        
        tableView.reloadData()
    }
    
    //MARK: -设置子控件
    func setupChildViewToWorkingVc() -> Void {
        tableView.separatorStyle = .none
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 50))
        tableView.tableFooterView = UIView()
        tableView.registerNib(SW_AddressBookHomeCell.self, forCellReuseIdentifier: AddressBookHomeCellID)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL + SHOWACCESS_TABBAR_HEIGHT, right: 0)
        tableView.showsVerticalScrollIndicator = false
//        tableView.estimatedRowHeight = 216
//        tableView.rowHeight = UITableView.automaticDimension
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        PrintLog("deinit")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SW_AddressBookHomeCell = tableView.dequeueReusableCell(withIdentifier: AddressBookHomeCellID, for: indexPath) as! SW_AddressBookHomeCell
        cell.titleLb.setTitle(items[indexPath.row].title, for: UIControl.State())
        cell.describeLb.text = items[indexPath.row].describe
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if #available(iOS 10.0, *) {
            if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        }
        self.navigationController?.pushViewController(items[indexPath.row].pushVc.init(), animated: true)

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 216
    }
    
}
