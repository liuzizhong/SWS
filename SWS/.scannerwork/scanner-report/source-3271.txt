//
//  SW_VehicleInfoQueryViewController.swift
//  SWS
//
//  Created by jayway on 2019/5/22.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

struct NumberPlateCustomerInfo {
    var customerName = ""
    var phoneNum = ""
    var repairDate: TimeInterval = 0
    var insuranceCompany = ""
    var bUnitName = ""
    
    init(_ json: JSON) {
        customerName = json["customerName"].stringValue
        phoneNum = json["phoneNum"].stringValue
        repairDate = json["repairDate"].doubleValue
        insuranceCompany = json["insuranceCompany"].stringValue
        bUnitName = json["bUnitName"].stringValue
    }
}

class SW_VehicleInfoQueryViewController: FormViewController {
    
    private var isRequesting = false
    private var plate = "" {
        didSet {
            /// 只要车牌号改变，客户就还原
            if customer != nil {
                customer = nil
                createTableView()
            }
        }
    }
    
    private var customer: NumberPlateCustomerInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formConfig()
        createTableView()
        // Do any additional setup after loading the view.
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    /// 查询条形码相关信息
    private func queryPlate(_ plate: String) {
        SW_AddressBookService.getCustomerInfoByNumberPlate(plate).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.customer = NumberPlateCustomerInfo(json)
                self.createTableView()
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
        })
    }
    
    //MARK: - Action
    private func formConfig() {
        navigationOptions = RowNavigationOptions.Enabled
        view.backgroundColor = .white
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 200, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets.zero
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = false
        }
        
        SW_StaffInfoRow.defaultCellSetup = { (cell, row) in
            cell.selectionStyle = .none
            cell.titleLb.textColor = UIColor.v2Color.darkGray
            cell.titleLb.font = Font(16)
            cell.valueLb.textColor = UIColor.v2Color.darkBlack
            cell.valueLb.font = Font(16)
            cell.rightLb.font = Font(16)
            cell.rightLb.textColor = UIColor.v2Color.blue
        }
    }
    
    private func createTableView() {
        /// 主要return  都刷新tableview
        defer {
            tableView.reloadData()
        }
        
        form = Form()
            +++
            Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = "车辆查询"
                }
                section.header = header
            }
            
            <<< SW_FieldButtonRow("plate") {
                $0.rawTitle = NSLocalizedString("车牌号", comment: "")
                $0.buttonTitle = "查 询"
                $0.value = self.plate
                $0.limitCount = 8
//                $0.keyboardType = .default
                $0.isPlateKeyBoard = true
                $0.placeholder = "输入车牌号(例如:粤AXXXXX)"
                $0.buttonActionBlock = { [weak self] in
                    if #available(iOS 10.0, *) {
                        feedbackGenerator()
                    }
                    self?.queryPlate(self?.plate ?? "")
                }
                $0.cell.valueField.font  = Font(15)
//                $0.cell.valueField.clearButtonMode = .never
                if customer == nil {
                    $0.cell.valueField.becomeFirstResponder()
                } else {
                    $0.cell.valueField.resignFirstResponder()
                }
                }.onChange { [weak self] in
                    self?.plate = $0.value ?? ""
        }
        
        guard let customer = customer else { return }
        
        if customer.phoneNum.isEmpty {/// 无手机号说明无客户信息
            /// 查询无结果
            form
            +++
                Section() { section in
                    var header = HeaderFooterView<UIView>(.class)
                    header.height = {270}
                    header.onSetupView = { view, _ in
                        let lb = UILabel()
                        lb.textAlignment = .center
                        lb.textColor = UIColor.v2Color.darkGray
                        lb.font = Font(16)
                        lb.text = "查询无结果"
                        view.addSubview(lb)
                        lb.snp.makeConstraints({ (make) in
                            make.edges.equalToSuperview()
                        })
                    }
                    section.header = header
            }
            
        } else {
            form
                +++
                Section() { section in
                    var header = HeaderFooterView<UIView>(.class)
                    header.height = {15}
//                    header.onSetupView = { view, _ in
//                    }
                    section.header = header
                }
                
                <<< SW_StaffInfoRow("customerName") {
                    $0.rowTitle = NSLocalizedString("客户姓名   ", comment: "")
                    $0.isShowBottom = false
                    $0.value = customer.customerName
                    $0.rightValue = "拨号"
                    }.onCellSelection({  (cell, row) in
                        row.deselect()
                        UIApplication.shared.open(scheme: "tel://\(customer.phoneNum)")//
                    })
                
                <<< SW_StaffInfoRow("insuranceCompany") {
                    $0.rowTitle = NSLocalizedString("保险公司   ", comment: "")
                    $0.isShowBottom = false
                    $0.value = customer.insuranceCompany
                }
                <<< SW_StaffInfoRow("repairDate") {
                    $0.rowTitle = NSLocalizedString("最近维修   ", comment: "")
                    $0.isShowBottom = false
                    $0.value = customer.repairDate == 0 ? "" : Date.dateWith(timeInterval: customer.repairDate).stringWith(formatStr: "yyyy.MM.dd")
                }
                <<< SW_StaffInfoRow("bUnitName") {
                    $0.rowTitle = NSLocalizedString("维修单位   ", comment: "")
                    $0.isShowBottom = false
                    $0.value = customer.bUnitName
                }
            
        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    //MARK: - FormViewControllerProtocol   重写一下方法是因为需要去除该库添加时的动画
    override func sectionsHaveBeenAdded(_ sections: [Section], at indexes: IndexSet) {
        
    }
    
    override func rowsHaveBeenAdded(_ rows: [BaseRow], at indexes: [IndexPath]) {
        
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
}
