//
//  SW_SalesContractDetailViewController.swift
//  SWS
//
//  Created by jayway on 2019/5/22.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_SalesContractDetailViewController: FormViewController {
    private var type: ContractBusinessType = .insurance
    private var salesContract: SW_SalesContractDetailModel!
    private var contractId: String = ""
    
    private lazy var detailBtn: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 0, y: 0, width: 60, height: 44)
        switch type {
        case .insurance:
            btn.setTitle("保单详情", for: UIControl.State())
        case .mortgageLoans:
            btn.setTitle("贷款详情", for: UIControl.State())
        case .registration:
            btn.setTitle("上牌详情", for: UIControl.State())
        case .purchaseTax:
            btn.frame = CGRect(x: 0, y: 0, width: 80, height: 44)
            btn.setTitle("购置税详情", for: UIControl.State())
        case .assgnationCar:
            break
        }
        btn.setTitleColor(UIColor.v2Color.blue, for: UIControl.State())
        btn.titleLabel?.font = Font(14)
        btn.addTarget(self, action: #selector(detailBtnClick(_:)), for: .touchUpInside)
        return btn
    }()
    
    init(_ contractId: String, type: ContractBusinessType) {
        super.init(nibName: nil, bundle: nil)
        self.contractId = contractId
        self.type = type
        self.salesContract = SW_SalesContractDetailModel(type: type)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formConfig()
        createTableView()
        getsalesContractData()
    }
    
    deinit {
//        NotificationCenter.default.removeObserver(self)
        PrintLog("deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //获取客户信息刷新页面
    fileprivate func getsalesContractData() {
        SW_SalesContractService.getContractDetail(contractId, type: type).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.salesContract = SW_SalesContractDetailModel(json, type: self.type)
                //        需要判断，只有办理了才显示
                if self.salesContract.auditState == .pass {
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.detailBtn)
                }
                self.createTableView()
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                //                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    //MARK: - Action
    private func formConfig() {
        navigationOptions = RowNavigationOptions.Enabled
        view.backgroundColor = .white
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL + 54, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = false
        }
        
        SW_StaffInfoRow.defaultCellSetup = { (cell, row) in
            cell.selectionStyle = .none
            cell.titleLb.textColor = UIColor.v2Color.darkGray
            cell.valueLb.textColor = UIColor.v2Color.darkBlack
        }
        /// 列表更新
//        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.SalesContractBusinessDandling, object: nil, queue: nil) { [weak self] (notifa) in
//            self?.getsalesContractData()
//        }
    }
    
    private func createTableView() {
        form = Form()
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = "合同详情"
                }
                section.header = header
            }
            <<< SW_StaffInfoRow("Contract no") {
                $0.rowTitle = NSLocalizedString("合   同  编   号   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.contractNum
            }
            <<< SW_StaffInfoRow("Contract state") {
                $0.rowTitle = NSLocalizedString("合   同  状   态   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.payState.rawTitle
            }

        switch type {
        case .insurance:
            form.last!
            <<< SW_StaffInfoRow("Insurance status") {
                $0.rowTitle = NSLocalizedString("保   险  状   态   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.auditState.rawTitle
            }
        case .mortgageLoans:
            form.last!
                <<< SW_StaffInfoRow("loans status") {
                    $0.rowTitle = NSLocalizedString("贷   款  状   态   ", comment: "")
                    $0.isShowBottom = false
                    $0.value =  salesContract.auditState == .pass ? "已办理" : "未办理"
            }
        case .registration:
            form.last!
                <<< SW_StaffInfoRow("registration status") {
                    $0.rowTitle = NSLocalizedString("上   牌  状   态   ", comment: "")
                    $0.isShowBottom = false
                    $0.value =  salesContract.auditState == .pass ? "已办理" : "未办理"
            }
                <<< SW_StaffInfoRow("purchaseTax status") {
                    $0.rowTitle = NSLocalizedString("购 置 税 状 态   ", comment: "")
                    $0.isShowBottom = false
                    $0.value =  salesContract.carPurchaseState == .pass ? "已办理" : "未办理"
            }
        case .purchaseTax:
            form.last!
                <<< SW_StaffInfoRow("purchaseTax status") {
                    $0.rowTitle = NSLocalizedString("购 置 税 状 态   ", comment: "")
                    $0.isShowBottom = false
                    $0.value =  salesContract.auditState == .pass ? "已办理" : "未办理"
            }
        case .assgnationCar:
            break
        }
        
            form.last!
            <<< SW_StaffInfoRow("Expected delivery date") {
                $0.rowTitle = NSLocalizedString("预计交车日期   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.deliveryDate == 0 ? "" : Date.dateWith(timeInterval: salesContract.deliveryDate).stringWith(formatStr: "yyyy.MM.dd")
            }
            
            <<< SW_StaffInfoRow("Subordinate units") {
                $0.rowTitle = NSLocalizedString("所   属  单   位   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.bUnitName
            }
            
            <<< SW_StaffInfoRow("Sales consultant") {
                $0.rowTitle = NSLocalizedString("销   售  顾   问   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.saleName
            }
            <<< SW_StaffInfoRow("The customer name") {
                $0.rowTitle = NSLocalizedString("客   户  名   称   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.customerName
            }
            
            <<< SW_StaffInfoRow("certificate id") {
                $0.rowTitle = NSLocalizedString("证   件  号   码   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.idCard.isEmpty ? "无" : salesContract.idCard
            }
            <<< SW_StaffInfoRow("phone number") {
                $0.rowTitle = NSLocalizedString("联   系  方   式   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.phoneNum
            }
            <<< SW_StaffInfoRow("Customer address") {
                $0.rowTitle = NSLocalizedString("客   户  地   址   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.customerAddress
            }
        if type != .mortgageLoans {
            form.last!
            <<< SW_StaffInfoRow("License plate number") {
                $0.rowTitle = NSLocalizedString("车      牌      号   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.numberPlate.isEmpty ? "无" : salesContract.numberPlate
            }
        }
        
             form.last!
            <<< SW_StaffInfoRow("vin") {
                $0.rowTitle = NSLocalizedString("车      架      号   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.vin.isEmpty ? "未分配" : salesContract.vin
            }
            <<< SW_StaffInfoRow("Vehicle information") {
                $0.rowTitle = NSLocalizedString("车   型  信   息   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.carBrand.isEmpty ? "" : salesContract.carBrand + "  " + salesContract.carSeries + "  " + salesContract.carModel + "  " + salesContract.carColor
            }
        
        if type == .mortgageLoans {
            form.last!
                <<< SW_StaffInfoRow("loan amount") {
                    $0.rowTitle = NSLocalizedString("按   揭  金   额   ", comment: "")
                    $0.isShowBottom = false
                    $0.value = salesContract.mortgageAmount.toAmoutString()
            }
        }
        
        /// 未通过办理
        if salesContract.auditState != .pass && salesContract.invalidAuditState != 3 {
            form
                +++
                Section() { [weak self] section in
                    var header = HeaderFooterView<SW_ArchiveButtonView>(.nibFile(name: "SW_ArchiveButtonView", bundle: nil))
                    header.height = {80}
                    header.onSetupView = { view, _ in
                        view.leftConstraint.constant = 15
                        view.rightConstraint.constant = 15
                        view.button.layer.borderWidth = 0
                        view.button.setTitle("办理", for: UIControl.State())
                        if self?.type == .registration || self?.type == .purchaseTax {
//                            view.button.isEnabled = self?.salesContract.vin.isEmpty == false
                        } else {
                            view.button.isEnabled = self?.salesContract.auditState != .wait
                            view.button.setTitle("办理中", for: .disabled)
                        }
                        view.button.setBackgroundImage(UIImage(color: UIColor.v2Color.blue), for: UIControl.State())
                        view.button.setBackgroundImage(UIImage(color: UIColor(hexString: "#267cc4")), for: .highlighted)
                        view.button.setTitleColor(UIColor.white, for: UIControl.State())
                        view.button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .disabled)
                        view.button.titleLabel?.font = Font(16)
                        view.actionBlock = {
                            /// 点击办理按钮
                            self?.handleBtnAction()
                        }
                    }
                    section.header = header
            }
        }
        
        tableView.reloadData()
    }
    
    //MARK: -private func
    private func handleBtnAction() {
//        根据type跳转到对应编辑页面
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        switch type {
        case .insurance:
            navigationController?.pushViewController(SW_ContractInsuranceEditViewController(salesContract, contractId: contractId), animated: true)
            
        case .mortgageLoans:
            navigationController?.pushViewController(SW_ContractLoansEditViewController(salesContract, contractId: contractId), animated: true)
        case .registration:
//            if salesContract.carPurchaseState != .pass {
//                showAlertMessage("购置税未办理", MYWINDOW)
//                return
//            }
            navigationController?.pushViewController(SW_ContractRegistrationEditViewController(salesContract, contractId: contractId), animated: true)
        case .purchaseTax:
            navigationController?.pushViewController(SW_ContractPurchaseTaxEditViewController(salesContract, contractId: contractId), animated: true)
        case .assgnationCar:
            break
        }
    }
    
    /// 跳转到对应详情界面
    @objc private func detailBtnClick(_ sender: UIBarButtonItem) {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        switch type {
        case .insurance:
            navigationController?.pushViewController(SW_ContractInsuranceDetailViewController(salesContract), animated: true)
        case .mortgageLoans:
            navigationController?.pushViewController(SW_ContractLoansDetailViewController(salesContract), animated: true)
        case .registration:
            navigationController?.pushViewController(SW_ContractRegistrationDetailViewController(salesContract), animated: true)
        case .purchaseTax:
            navigationController?.pushViewController(SW_ContractPurchaseTaxDetailViewController(salesContract), animated: true)
        case .assgnationCar:
            break
        }
    }
    
    //MARK: - FormViewControllerProtocol   重写一下方法是因为需要去除该库添加时的动画
    override func sectionsHaveBeenAdded(_ sections: [Section], at indexes: IndexSet) {
        
    }
    
    override func rowsHaveBeenAdded(_ rows: [BaseRow], at indexes: [IndexPath]) {
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
}

