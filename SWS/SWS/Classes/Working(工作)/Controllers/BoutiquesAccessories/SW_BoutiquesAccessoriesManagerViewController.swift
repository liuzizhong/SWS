//
//  SW_BoutiquesAccessoriesManagerViewController.swift
//  SWS
//
//  Created by jayway on 2019/3/21.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

/// 采购类型
enum ProcurementType: Int {
    case boutiques     = 0
    case accessories
    
    var rawTitle: String {
        switch self {
        case .boutiques:
            return "精品"
        case .accessories:
            return "配件"
        }
    }
}

class SW_BoutiquesAccessoriesManagerViewController: FormViewController {
    
    private var type: ProcurementType = .boutiques
    
    init(_ type: ProcurementType) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formConfig()
        createTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Action
    private func formConfig() {
        
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
//        tableView.separatorColor = UIColor.mainColor.separator
//        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
//        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        
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
            Eureka.Section() { [weak self] section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = (self?.type.rawTitle ?? "") + "管理"
                }
                section.header = header
            }
        var authDetails = [Int]()
        if type == .accessories, let accessoriesAuth = SW_UserCenter.shared.user?.auth.accessoriesAuth.first {
            authDetails = accessoriesAuth.authDetails
        }
        if  type == .boutiques, let boutiqueAuth = SW_UserCenter.shared.user?.auth.boutiqueAuth.first {
            authDetails = boutiqueAuth.authDetails
        }
        if authDetails.contains(1) {
            form.last!
            <<< LabelRow("ProcurementList") {
                $0.title = NSLocalizedString("采购入库", comment: "")
                $0.cell.selectionStyle = .default
                $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    self?.gotoProcurementList()
                })
        }
        if authDetails.contains(2) {
            form.last!
                <<< LabelRow("inventoryList") {
                    $0.title = NSLocalizedString("\(self.type.rawTitle)盘点", comment: "")
                    $0.cell.selectionStyle = .default
                    $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        self?.gotoInventoryList()
                })
        }
        if authDetails.contains(3) {
            form.last!
                <<< LabelRow("StockList") {
                    $0.title = NSLocalizedString("\(self.type.rawTitle)库存查询", comment: "")
                    $0.cell.selectionStyle = .default
                    $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    self?.gotoStockList()
                })
        }
    }
    
    fileprivate func gotoProcurementList() {
        navigationController?.pushViewController(SW_ProcurementListViewController(type), animated: true)
    }
    
    
    fileprivate func gotoInventoryList() {
        navigationController?.pushViewController(SW_InventoryListViewController(type), animated: true)
    }
    
    fileprivate func gotoStockList() {
        navigationController?.pushViewController(SW_StockListQueryViewController(type), animated: true)
    }
    
    deinit {
        PrintLog("deinit")
    }
}

// MARK: - TableViewDelegate
extension SW_BoutiquesAccessoriesManagerViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}









