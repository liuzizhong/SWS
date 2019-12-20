//
//  SW_ContractRegistrationDetailViewController.swift
//  SWS
//
//  Created by jayway on 2019/5/23.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_ContractRegistrationDetailViewController: FormViewController {
    
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
                    view.title = "上牌详情"
                }
                section.header = header
            }
            <<< SW_StaffInfoRow("Contract no") {
                $0.rowTitle = NSLocalizedString("合同编号   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.contractNum
            }
            <<< SW_StaffInfoRow("vin") {
                $0.rowTitle = NSLocalizedString("车  架  号   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.vin.isEmpty ? "未分配" : salesContract.vin
            }
            <<< SW_StaffInfoRow("plate number") {
                $0.rowTitle = NSLocalizedString("车  牌  号   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.numberPlate.isEmpty ? "无" : salesContract.numberPlate
            }
            <<< SW_StaffInfoRow("registration date") {
                $0.rowTitle = NSLocalizedString("上牌日期   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.handleDate == 0 ? "" : Date.dateWith(timeInterval: salesContract.handleDate).stringWith(formatStr: "yyyy.MM.dd")
            }
//            <<< SW_StaffInfoRow("registration cost") {
//                $0.rowTitle = NSLocalizedString("上牌成本   ", comment: "")
//                $0.isShowBottom = false
//                $0.value =  salesContract.carNumCostAmount.toAmoutString()
//            }
        
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
