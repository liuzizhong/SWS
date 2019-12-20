//
//  SW_ContractInsuranceDetailViewController.swift
//  SWS
//
//  Created by jayway on 2019/5/23.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_ContractInsuranceDetailViewController: FormViewController {
    
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
                    view.title = "保单详情"
                }
                section.header = header
            }
            <<< SW_StaffInfoRow("Contract no") {
                $0.rowTitle = NSLocalizedString("合 同 编 号   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.contractNum
            }
            <<< SW_StaffInfoRow("vin") {
                $0.rowTitle = NSLocalizedString("车   架   号   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.vin.isEmpty ? "未分配" : salesContract.vin
            }
            <<< SW_StaffInfoRow("insurance company") {
                $0.rowTitle = NSLocalizedString("保 险 公 司   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.insuranceCompany
            }
            <<< SW_StaffInfoRow("Insurance policy no") {
                $0.rowTitle = NSLocalizedString("保   单   号   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.insuranceNum
            }
            <<< SW_StaffInfoRow("commercialInsuranceNum") {
                $0.rowTitle = NSLocalizedString("商业险单号   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.commercialInsuranceNum
            }
            <<< SW_StaffInfoRow("insurance During") {
                $0.rowTitle = NSLocalizedString("保 险 期 间   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.insuranceStartDate == 0 ? "" : Date.dateWith(timeInterval: salesContract.insuranceStartDate).stringWith(formatStr: "yyyy.MM.dd") + "-" + Date.dateWith(timeInterval: salesContract.insuranceEndDate).stringWith(formatStr: "yyyy.MM.dd")
            }
            <<< SW_StaffInfoRow("The policy combined") {
                $0.rowTitle = NSLocalizedString("保 单 合 计   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.insuranceTotalAmount.toAmoutString()
            }
            <<< SW_StaffInfoRow("Total commercial insurance") {
                $0.rowTitle = NSLocalizedString("商业险合计   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.insuranceItemsTotalAmount.toAmoutString()
            }
        /// ---------------------------保险项目------------------------
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<SW_InsuranceSectionHeaderView>(.nibFile(name: "SW_InsuranceSectionHeaderView", bundle: nil))
                header.onSetupView = { view, _ in
                    view.isShowBxzl = true
                }
                header.height = {40}
                section.header = header
        }
        
//        if salesContract.carShipTaxTag == 1 {
//            form.last!
//                <<< SW_InsuranceInfoRow("vehicle tax") {
//                    $0.rowTitle = NSLocalizedString("车船税", comment: "")
//                    $0.value = salesContract.carShipTaxAmount.toAmoutString()
//                    $0.rightValue = ""
//            }
//        }
        
//        if salesContract.compulsoryInsuranceTag == 1 {
//            form.last!
//                <<< SW_InsuranceInfoRow("Insurance compulsory") {
//                    $0.rowTitle = NSLocalizedString("交强险", comment: "")
//                    $0.value = salesContract.compulsoryInsuranceAmount.toAmoutString()
//                    $0.rightValue = ""
//            }
//        }
        
        for insurance in salesContract.insuranceItems {
//            switch insurance.name {
//            case "车辆损失险":
//                form.last!
//                    <<< SW_StaffInfoRow("Insurance damage") {
//                        $0.rowTitle = NSLocalizedString("车 辆 损 失 险   ", comment: "")
//                        $0.isShowBottom = false
//                        $0.value = insurance.insuredAmount == 0 ? "" :  "\(insurance.insuredAmount)"
//                        $0.rightValue = insurance.insuredRemark
//
//                }
//            case "全车盗抢险":
//                form.last!
//                    <<< SW_StaffInfoRow("Insurance theft protection") {
//                        $0.rowTitle = NSLocalizedString("全 车 盗 抢 险   ", comment: "")
//                        $0.isShowBottom = false
//                        $0.value = insurance.insuredAmount == 0 ? "" :  "\(insurance.insuredAmount)"
//                        $0.rightValue = insurance.insuredRemark
//                }
//            case "车上人员险":
//                form.last!
//                    <<< SW_StaffInfoRow("Insurance person") {
//                        $0.rowTitle = NSLocalizedString("车 上 人 员 险   ", comment: "")
//                        $0.isShowBottom = false
//                        $0.value = insurance.insuredAmount == 0 ? "" :  "\(insurance.insuredAmount)"
//                        $0.rightValue = insurance.insuredRemark
//                }
//            case "玻璃破损险":
//                form.last!
//                    <<< SW_StaffInfoRow("Insurance glass") {
//                        $0.rowTitle = NSLocalizedString("玻 璃 破 损 险   ", comment: "")
//                        $0.isShowBottom = false
//                        $0.value = insurance.insuredAmount == 0 ? "" :  "\(insurance.insuredAmount)"
//                        $0.rightValue = insurance.insuredRemark
//                }
//            case "车辆划痕险":
//                form.last!
//                    <<< SW_StaffInfoRow("Insurance scratch") {
//                        $0.rowTitle = NSLocalizedString("车 辆 划 痕 险   ", comment: "")
//                        $0.isShowBottom = false
//                        $0.value = insurance.insuredAmount == 0 ? "" :  "\(insurance.insuredAmount)"
//                        $0.rightValue = insurance.insuredRemark
//                }
//            case "不计免赔险":
//                form.last!
//                    <<< SW_StaffInfoRow("Insurance AER") {
//                        $0.rowTitle = NSLocalizedString("不 计 免 赔 险   ", comment: "")
//                        $0.isShowBottom = false
//                        $0.value = insurance.insuredAmount == 0 ? "" :  "\(insurance.insuredAmount)"
//                        $0.rightValue = insurance.insuredRemark
//                }
//            case "第三者责任险":
//                form.last!
//                    <<< SW_StaffInfoRow("Insurance third party") {
//                        $0.rowTitle = NSLocalizedString("第三者责任险   ", comment: "")
//                        $0.isShowBottom = false
//                        $0.value = insurance.insuredAmount == 0 ? "" :  "\(insurance.insuredAmount)"
//                        $0.rightValue = insurance.insuredRemark
//                }
//            default:/// 找不到对应的，可能是新增的，
//                form.last!
//                    <<< SW_StaffInfoRow(insurance.id) {
//                        $0.rowTitle = NSLocalizedString("\(insurance.name)   ", comment: "")
//                        $0.isShowBottom = false
//                        $0.value = insurance.insuredAmount == 0 ? "" :  "\(insurance.insuredAmount)"
//                        $0.rightValue = insurance.insuredRemark
//                }
//            }
            form.last!
                <<< SW_InsuranceInfoRow(insurance.id+insurance.name) {
                    $0.rowTitle = NSLocalizedString("\(insurance.name)", comment: "")
                    $0.value = insurance.insuredAmount.toAmoutString()
                    $0.rightValue = insurance.insuredRemark
            }
        }
        
        
        /// ---------------------------保险项目------------------------
        
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
    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 70
//    }
    
    
}
