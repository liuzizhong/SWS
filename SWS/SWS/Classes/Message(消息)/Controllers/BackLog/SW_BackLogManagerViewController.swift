//
//  SW_BackLogManagerViewController.swift
//  SWS
//
//  Created by jayway on 2019/8/20.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_BackLogManagerViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formConfig()
        createTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        NotificationCenter.default.post(name: NSNotification.Name.Ex.BackLogCountUpdate, object: nil)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.SetupUnreadMessageCount, object: nil, queue: nil) { [weak self] (notifi) in
            self?.updateBadge()
        }
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateBadge()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Action
    private func formConfig() {
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        LabelRow.defaultCellUpdate = { (cell, row) in
            cell.selectionStyle = .default
            cell.textLabel?.textColor = UIColor.v2Color.lightBlack
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
            cell.detailTextLabel?.textColor = UIColor.mainColor.gray
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 16.0)
        }
        
    }
    
    
    fileprivate func createTableView() {
        form = Form()
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = "待办事项"
                }
                section.header = header
        }
//        23 "待办事项-销售合同  24 待办事项-维修单"  26待办事项-续保单"
        let authDetails = SW_UserCenter.shared.user!.auth.backLogAuth.map({ return $0.type })
        
        if authDetails.contains(23) {
            form.last!
                <<< LabelRow("saleContractList") {
                    $0.title = NSLocalizedString("销售合同审核", comment: "")
                    $0.cell.selectionStyle = .default
                    $0.cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "Main_NextPage"))
                    $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        self?.navigationController?.pushViewController(SW_BackLogListViewController(.saleContract), animated: true)
                    })
        }
        if authDetails.contains(24) {
            form.last!
                <<< LabelRow("repairOrderList") {
                    $0.title = NSLocalizedString("维修单审核", comment: "")
                    $0.cell.selectionStyle = .default
                    $0.cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "Main_NextPage"))
                    $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        self?.navigationController?.pushViewController(SW_BackLogListViewController(.repairOrder), animated: true)
                    })
        }
        
        tableView.reloadData()
    }
    
    private func updateBadge() {
        setBadge("saleContractList", count: SW_BadgeManager.shared.backLogModel.saleOrderCount)
        setBadge("repairOrderList", count: SW_BadgeManager.shared.backLogModel.repairOrderCount)
    }
    
    private func setBadge(_ rowTag: String, count: Int) {
        if let row = form.rowBy(tag: rowTag) as? LabelRow {
            row.cell.contentView.badgeOffset = CGPoint(x: -13, y: 32)
            row.cell.contentView.badgeValue(number: count)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        PrintLog("deinit")
    }
}

// MARK: - TableViewDelegate
extension SW_BackLogManagerViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
