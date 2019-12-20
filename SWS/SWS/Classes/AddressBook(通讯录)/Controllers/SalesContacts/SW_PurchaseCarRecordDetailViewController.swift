//
//  SW_PurchaseCarRecordDetailViewController.swift
//  SWS
//
//  Created by jayway on 2019/6/3.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_PurchaseCarRecordDetailViewController: FormViewController {
    private var phone: String = ""
    private var salesContract: SW_PurchaseCarRecordDetailModel!
    private var contractId: String = ""
    
    init(_ contractId: String, phone: String) {
        super.init(nibName: nil, bundle: nil)
        self.phone = phone
        self.contractId = contractId
        self.salesContract = SW_PurchaseCarRecordDetailModel(JSON.null)
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
        NotificationCenter.default.removeObserver(self)
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
        SW_AddressBookService.getCarSalesContractDetail(contractId, modifyAuditState: .noCommit).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.salesContract = SW_PurchaseCarRecordDetailModel(json)
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
            cell.rightLb.font = Font(14)
            cell.rightLb.textColor = UIColor.v2Color.blue
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadHandleComplaints, object: nil, queue: nil) { [weak self] (notifa) in
            let type = notifa.userInfo?["complaintType"] as! HandleComplaintType
            let orderId = notifa.userInfo?["orderId"] as! String
            if type == .purchaseCar, orderId == self?.contractId {
                guard let row = self?.form.rowBy(tag: "Customer complaints") as? SW_StaffInfoRow else {
                    return
                }
                row.value = "待审核"
                row.rightValue = "详情"
                row.updateCell()
            }
        }
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
        if salesContract.complaintRecords.count > 0 {
            form.last!
            
                <<< SW_StaffInfoRow("Customer complaints") {
                    $0.rowTitle = NSLocalizedString("客   户  投   诉   ", comment: "")
                    $0.isShowBottom = false
                    $0.value = salesContract.complaintState.rawTitle
                    $0.rightValue = salesContract.complaintState == .waitHandle ? "处理" : "详情"
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        PrintLog("goto ")
                        let vc = SW_ComplaintsListViewController.creatVc(self?.salesContract.complaintRecords ?? [], phone: self?.phone ?? "")
                        
                        self?.navigationController?.pushViewController(vc, animated: true)
                    })
        }
        if salesContract.customerServingItemScores.count > 0  || salesContract.nonGrandedItems.count > 0 {
            form.last!
            
                <<< SW_StaffInfoRow("Customer rating") {
                    $0.rowTitle = NSLocalizedString("回   访  记   录   ", comment: "")
                    $0.isShowBottom = false
                    $0.value =  salesContract.customerServingItemScores.count > 0 ? "\(salesContract.getScore)分" : "已回访"
                    $0.rightValue = "详情"
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        PrintLog("goto ")
                        guard let self = self else { return }
                        self.navigationController?.pushViewController(SW_CustomerScoreManagerViewController(self.salesContract.customerServingItemScores, nonScoreItems: self.salesContract.nonGrandedItems), animated: true)
                    })
        }
        
            form.last!
            <<< SW_StaffInfoRow("Contract type") {
                $0.rowTitle = NSLocalizedString("合   同  类   型   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.contractType == 2 ? "组织" : "个人"
            }
            
            <<< SW_StaffInfoRow("Terms of payment") {
                $0.rowTitle = NSLocalizedString("付   款  方   式   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.paymentWay == 2 ? "全款" : "按揭"
            }
            
            <<< SW_StaffInfoRow("Expected delivery date") {
                $0.rowTitle = NSLocalizedString("预计交车日期   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.deliveryDate == 0 ? "" : Date.dateWith(timeInterval: salesContract.deliveryDate).stringWith(formatStr: "yyyy.MM.dd")
            }
            
            <<< SW_StaffInfoRow("Vehicle information") {
                $0.rowTitle = NSLocalizedString("车   型  信   息   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.carBrand.isEmpty ? "" : salesContract.carBrand + "  " + salesContract.carSeries + "  " + salesContract.carModel + "  " + salesContract.carColor
            }
            <<< SW_StaffInfoRow("vin") {
                $0.rowTitle = NSLocalizedString("车      架      号   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.vin.isEmpty ? "未分配" : salesContract.vin
            }
            <<< SW_StaffInfoRow("License plate number") {
                $0.rowTitle = NSLocalizedString("车      牌      号   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.numberPlate.isEmpty ? "无" : salesContract.numberPlate
            }
            <<< SW_StaffInfoRow("Contract state") {
                $0.rowTitle = NSLocalizedString("合   同  状   态   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.payState.rawTitle
            }
            <<< SW_StaffInfoRow("invoiceState") {
                $0.rowTitle = NSLocalizedString("开   票  状   态   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.invoiceState == 2 ? "已开票" : "未开票"
            }
            <<< SW_StaffInfoRow("loans mortgageState") {
                $0.rowTitle = NSLocalizedString("贷   款  状   态   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.mortgageState == 2 ? "已办理" : "未办理"
            }
            <<< SW_StaffInfoRow("Insurance status") {
                $0.rowTitle = NSLocalizedString("保   险  状   态   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.insuranceState.rawTitle
            }
            <<< SW_StaffInfoRow("purchaseTax status") {
                $0.rowTitle = NSLocalizedString("购 置 税 状 态   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.carPurchaseState == 2 ? "已办理" : "未办理"
            }
            <<< SW_StaffInfoRow("registration status") {
                $0.rowTitle = NSLocalizedString("上   牌  状   态   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.carNumState == 2 ? "已办理" : "未办理"
            }
            form
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = "精品信息"
                }
                section.header = header
        }
            
            <<< SW_BoutiqueContractRow("SW_BoutiqueContractRow Header") {
                $0.isHeader = true
        }
        if salesContract.boutiqueContractList.count > 0 {
            
            for index in 0..<salesContract.boutiqueContractList.count {
                form.last!
                    <<< SW_BoutiqueContractRow("SW_BoutiqueContractRow \(index)") {
                        $0.value = salesContract.boutiqueContractList[index]
                }
            }
        } else {
            form.last!
                <<< SW_NoCommenRow("No boutiqueContractList") {
                    $0.cell.tipLabel.text = "暂无数据"
                    $0.cell.heightConstraint.constant = 80
            }
        }
        
        tableView.reloadData()
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
