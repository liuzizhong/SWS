//
//  SW_SalesContractManagerViewController.swift
//  SWS
//
//  Created by jayway on 2019/5/22.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

/// 合同业务类型
enum ContractBusinessType: Int {
    case insurance   //  = 0
    case mortgageLoans
    case registration
    case purchaseTax
    case assgnationCar
    
    var rawTitle: String {
        switch self {
        case .insurance:
            return "保险"
        case .mortgageLoans:
            return "按揭贷款"
        case .registration:
            return "上牌"
        case .purchaseTax:
            return "购置税"
        case .assgnationCar:
            return "合同车辆分配"
        }
    }
    
    var rowHeight: CGFloat {
        switch self {
        case .assgnationCar:
            return 155
        case .insurance,.registration:
            return 140
        default:
            return 125
        }
    }
}

class SW_SalesContractManagerViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formConfig()
        createTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
//        updateBadge()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Action
    private func formConfig() {
        
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        tableView.separatorColor = UIColor.mainColor.separator
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        LabelRow.defaultCellUpdate = { (cell, row) in
            cell.selectionStyle = .default
            cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "Main_NextPage"))
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
                    view.title = "销售合同管理"
                }
                section.header = header
        }
        let authDetails = SW_UserCenter.shared.user!.auth.contractAuth
        
        if authDetails.contains(where: { return $0.type == 14 }) {
            form.last!
                <<< LabelRow("insuranceList") {
                    $0.title = NSLocalizedString("保险办理", comment: "")
                    $0.cell.selectionStyle = .default
                    $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        self?.navigationController?.pushViewController(SW_SalesContractListViewController(.insurance), animated: true)
                    })
        }
        if authDetails.contains(where: { return $0.type == 13 }) {
            form.last!
                <<< LabelRow("mortgageLoansList") {
                    $0.title = NSLocalizedString("按揭贷款办理", comment: "")
                    $0.cell.selectionStyle = .default
                    $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        self?.navigationController?.pushViewController(SW_SalesContractListViewController(.mortgageLoans), animated: true)
                    })
        }
        if authDetails.contains(where: { return $0.type == 15 }) {
            form.last!
                <<< LabelRow("registrationList") {
                    $0.title = NSLocalizedString("上牌办理", comment: "")
                    $0.cell.selectionStyle = .default
                    $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        self?.navigationController?.pushViewController(SW_SalesContractListViewController(.registration), animated: true)
                    })
        }
        if authDetails.contains(where: { return $0.type == 16 }) {
            form.last!
                <<< LabelRow("purchaseTaxList") {
                    $0.title = NSLocalizedString("购置税办理", comment: "")
                    $0.cell.selectionStyle = .default
                    $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        self?.navigationController?.pushViewController(SW_SalesContractListViewController(.purchaseTax), animated: true)
                    })
        }
        if authDetails.contains(where: { return $0.type == 26 }) {
        form.last!
            <<< LabelRow("boutique install") {
                $0.title = NSLocalizedString("合同精品安装", comment: "")
                $0.cell.selectionStyle = .default
                $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    self?.navigationController?.pushViewController(SW_SalesContractInstallListViewController(), animated: true)
                })
        }
        if authDetails.contains(where: { return $0.type == 27 }) {
        form.last!
            <<< LabelRow("Assgnation Car") {
                $0.title = NSLocalizedString("合同车辆分配", comment: "")
                $0.cell.selectionStyle = .default
                $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    self?.navigationController?.pushViewController(SW_SalesContractListViewController(.assgnationCar), animated: true)
                })
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        PrintLog("deinit")
    }
}

// MARK: - TableViewDelegate
extension SW_SalesContractManagerViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}


