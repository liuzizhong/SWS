//
//  SW_RepairOrderManagerViewController.swift
//  SWS
//
//  Created by jayway on 2019/5/21.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_RepairOrderManagerViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formConfig()
        createTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
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
            cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "Main_NextPage"))
            cell.textLabel?.textColor = UIColor.v2Color.lightBlack
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
            cell.detailTextLabel?.textColor = UIColor.mainColor.gray
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 16.0)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.RedDotNotice, object: nil, queue: nil) {  [weak self]  (notifi) in
            self?.updateBadge()
        }
    }
    
    
    fileprivate func createTableView() {
        form = Form()
            
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = "维修接待管理"
                }
                section.header = header
        }
        let authDetails = SW_UserCenter.shared.user!.auth.repairAuth.map({ return $0.type })
        
        if authDetails.contains(.order) {
            form.last!
                <<< LabelRow("orderList") {
                    $0.title = NSLocalizedString("维修单管理", comment: "")
                    $0.cell.selectionStyle = .default
                    $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        self?.navigationController?.pushViewController(SW_OrderListViewController(.order), animated: true)
                    })
        }
        if authDetails.contains(.construction) {
            form.last!
                <<< LabelRow("constructionList") {
                    $0.title = NSLocalizedString("维修施工", comment: "")
                    $0.cell.selectionStyle = .default
                    $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        self?.navigationController?.pushViewController(SW_OrderListViewController(.construction), animated: true)
                    })
        }
        if authDetails.contains(.quality) {
            form.last!
                <<< LabelRow("qualityList") {
                    $0.title = NSLocalizedString("维修质检", comment: "")
                    $0.cell.selectionStyle = .default
                    $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                         self?.navigationController?.pushViewController(SW_OrderListViewController(.quality), animated: true)
                    })
        }
        
        if authDetails.contains(.kanban) {
            form.last!
                <<< LabelRow("Maintenance of kanban") {
                    $0.title = NSLocalizedString("维修看板", comment: "")
                    $0.cell.selectionStyle = .default
                    $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        self?.navigationController?.pushViewController(SW_RepairOrderKanbanViewController(), animated: true)
                    })
        }
        
        tableView.reloadData()
    }
    
    private func updateBadge() {
        setBadge("orderList", state: SW_BadgeManager.shared.repairOrderNotice.repairNotice)
        setBadge("constructionList", state: SW_BadgeManager.shared.repairOrderNotice.constructionNotice)
        setBadge("qualityList", state: SW_BadgeManager.shared.repairOrderNotice.qualityNotice)
    }
    
    private func setBadge(_ rowTag: String, state: Bool) {
        if let row = form.rowBy(tag: rowTag) as? LabelRow {
            row.cell.textLabel?.badgeOffset = CGPoint(x: 4, y: 9)
            row.cell.textLabel?.badgeView(state: state)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        PrintLog("deinit")
    }
}

// MARK: - TableViewDelegate
extension SW_RepairOrderManagerViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}

