//
//  SW_ContractLoansDetailViewController.swift
//  SWS
//
//  Created by jayway on 2019/5/23.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_ContractLoansDetailViewController: FormViewController {
    
    private var salesContract: SW_SalesContractDetailModel!
    
    init(_ salesContract: SW_SalesContractDetailModel) {
        super.init(nibName: nil, bundle: nil)
        self.salesContract = salesContract
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formConfig()
        createTableView()
    }
    
    deinit {
        PrintLog("deinit")
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
    }
    
    private func createTableView() {
        form = Form()
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = "贷款详情"
                }
                section.header = header
            }
            <<< SW_StaffInfoRow("Contract no") {
                $0.rowTitle = NSLocalizedString("合同编号   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.contractNum
                }
            <<< SW_StaffInfoRow("mortgage amount") {
                    $0.rowTitle = NSLocalizedString("按揭金额   ", comment: "")
                    $0.isShowBottom = false
                $0.value = salesContract.mortgageAmount.toAmoutString()
        }
            <<< SW_StaffInfoRow("Financial institutions") {
                $0.rowTitle = NSLocalizedString("金融机构   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.financialOrgName
        }
            <<< SW_StaffInfoRow("Approval date") {
                $0.rowTitle = NSLocalizedString("批复日期   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.handleDate == 0 ? "" : Date.dateWith(timeInterval: salesContract.handleDate).stringWith(formatStr: "yyyy.MM.dd")
        }
            <<< SW_StaffInfoRow("Approval amount") {
                $0.rowTitle = NSLocalizedString("批复金额   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.approvalAmount.toAmoutString()
        }
            <<< SW_StaffInfoRow("Mortgage period according") {
                $0.rowTitle = NSLocalizedString("按揭期数   ", comment: "")
                $0.isShowBottom = false
                $0.value = "\(salesContract.mortgagePeriod)"
        }
//            <<< SW_StaffInfoRow("cost of a mortgage") {
//                $0.rowTitle = NSLocalizedString("按揭成本   ", comment: "")
//                $0.isShowBottom = false
//                $0.value = salesContract.mortgageCostAmount.toAmoutString()
//        }
        if salesContract.attachmentList.count > 0 {
            form.last!
            <<< SW_SalesContractAttachmentRow("attachmentList") {
                $0.value = salesContract.attachmentList
            }
        }
        
        tableView.reloadData()
    }
    
    
    //MARK: - FormViewControllerProtocol   重写一下方法是因为需要去除该库添加时的动画
    //    override func sectionsHaveBeenAdded(_ sections: [Section], at indexes: IndexSet) {
    //
    //    }
    //
    //    override func rowsHaveBeenAdded(_ rows: [BaseRow], at indexes: [IndexPath]) {
    //
    //    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    
}
