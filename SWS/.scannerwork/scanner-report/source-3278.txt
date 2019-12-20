//
//  SW_RevenueDetailViewController.swift
//  SWS
//
//  Created by jayway on 2018/6/27.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_RevenueDetailViewController: FormViewController {
    private var type = RevenueReportType.dayOrder
    /// 将要显示的model--存放数据
    private var reportModel: SW_RevenueDetailModel!
    
    ///这3个indexpath用于计算row高度
    private var insuranceIndexPath = IndexPath(row: 99, section: 99)
    private var revenueIndexPath = IndexPath(row: 99, section: 99)
    private var costIndexPath = IndexPath(row: 99, section: 99)
    
    private var reportId = ""
    
    //MARK: - 初始化部分
    /// 初始化方法
    ///
    /// - Parameter reportId: 需要显示的报表ID
    init(_ reportId: String, type: RevenueReportType) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
        self.reportId = reportId
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formConfig()
        requestReportDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: - 请求数据
    private func requestReportDetail() {
        var request: SWSRequest!
        switch type {
        case .dayOrder:
            request = SW_WorkingService.getSaleOrderDetail(reportId)
        default:
            request = SW_WorkingService.getFlowSheetDetail(reportId)
        }
        
        request.response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.reportModel = SW_RevenueDetailModel(self.type, json: json)
                self.addEditButton()
                self.createTableView()
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                self.navigationController?.popViewController(animated: true)
            }
        })
        
    }
    
    //MARK: - 设置tableview数据源
    private func formConfig() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadEditRevenueReport, object: nil, queue: nil) { [weak self] (notifa) in
            self?.requestReportDetail()
        }
        view.backgroundColor = UIColor.mainColor.background

        navigationItem.title = NSLocalizedString(type.rawTitle, comment: "")
        tableView.backgroundColor = UIColor.mainColor.background
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL + 30, right: 0)
    }
    
    fileprivate func createTableView() {
        var section = 0
        form = Form()
        switch type {
        case .dayOrder:
            form
                +++
                Eureka.Section()
                
                <<< SW_RevenueDetailNormalRow("order Number") {
                    $0.rawTitle = NSLocalizedString("订单编号:", comment: "")
                    $0.value = reportModel.orderNo
                    $0.cell.dottedLine.isHidden = true
                }
                
                <<< SW_RevenueDetailNormalRow("order Date") {
                    $0.rawTitle = NSLocalizedString("营收署期:", comment: "")
                    $0.value = reportModel.orderDate == 0 ? "" : Date.dateWith(timeInterval: reportModel.orderDate).stringWith(formatStr: "yyyy.MM.dd")
                }
            
                <<< SW_RevenueDetailNormalRow("customer Name") {
                    $0.rawTitle = NSLocalizedString("客户姓名:", comment: "")
                    $0.value = reportModel.customerName
                }
            
                <<< SW_RevenueDetailNormalRow("order Type") {
                    $0.rawTitle = NSLocalizedString("订单类型:", comment: "")
                    $0.value = reportModel.orderType.name
                }
            
                <<< SW_RevenueDetailNormalRow("fromDeptName") {
                    $0.rawTitle = NSLocalizedString("订单归属:", comment: "")
                    $0.value = reportModel.fromDeptName
                }
            
                <<< SW_RevenueDetailNormalRow("salesman") {
                    $0.rawTitle = NSLocalizedString("业务人员:", comment: "")
                    $0.value = reportModel.salesman
                }
            
                <<< SW_RevenueDetailNormalRow("carBrand") {
                    $0.rawTitle = NSLocalizedString("厂商品牌:", comment: "")
                    $0.value = reportModel.carBrand.name
                }
            
                <<< SW_RevenueDetailNormalRow("carSerie") {
                    $0.rawTitle = NSLocalizedString("车辆名称:", comment: "")
                    $0.value = reportModel.carSerie.name
                }
            
                <<< SW_RevenueDetailNormalRow("carModel") {
                    $0.rawTitle = NSLocalizedString("车辆型号:", comment: "")
                    $0.value = reportModel.carModel.name
                }
            
                <<< SW_RevenueDetailNormalRow("carColor") {
                    $0.rawTitle = NSLocalizedString("车身颜色:", comment: "")
                    $0.value = reportModel.carColor.name
                }
            
            ////下面的开始需要判断添加  保险
            if !reportModel.insuranceCompanyName.isEmpty {
                section += 1
                form
                    +++
                    Eureka.Section()
                    
                    <<< SW_RevenueDetailNormalRow("use insurance") {
                        $0.rawTitle = NSLocalizedString("保险使用:", comment: "")
                        $0.value = "有"
                        $0.cell.dottedLine.isHidden = true
                    }
                
                    <<< SW_RevenueDetailNormalRow("insuranceCompanyName") {
                        $0.rawTitle = NSLocalizedString("保险公司:", comment: "")
                        $0.value = reportModel.insuranceCompanyName
                    }
                
                
                    <<< SW_InsuranceDetailRow("insuranceTypes") {
                        $0.rawTitle = NSLocalizedString("保险种类:", comment: "")
                        $0.value = reportModel.insuranceTypes
                    }
                
                    insuranceIndexPath = IndexPath(row: 2, section: 1)
            }
            
            
        case .dayNonOrder:
            form
                +++
                Eureka.Section()
                
                <<< SW_RevenueDetailNormalRow("order Number") {
                    $0.rawTitle = NSLocalizedString("营收编号:", comment: "")
                    $0.value = reportModel.orderNo
                    $0.cell.dottedLine.isHidden = true
                }
                
                <<< SW_RevenueDetailNormalRow("order Date") {
                    $0.rawTitle = NSLocalizedString("营收署期:", comment: "")
                    $0.value = reportModel.orderDate == 0 ? "" : Date.dateWith(timeInterval: reportModel.orderDate).stringWith(formatStr: "yyyy.MM.dd")
                }
                
                <<< SW_RevenueDetailNormalRow("customer Name") {
                    $0.rawTitle = NSLocalizedString("客户姓名:", comment: "")
                    $0.value = reportModel.customerName
                }
                
                <<< SW_RevenueDetailNormalRow("fromDeptName") {
                    $0.rawTitle = NSLocalizedString("营收归属:", comment: "")
                    $0.value = reportModel.fromDeptName
                }
                
                <<< SW_RevenueDetailNormalRow("salesman") {
                    $0.rawTitle = NSLocalizedString("业务人员:", comment: "")
                    $0.value = reportModel.salesman
                }
            
        default:
            form
                +++
                Eureka.Section()
                
                <<< SW_RevenueDetailNormalRow("order Number") {
                    $0.rawTitle = NSLocalizedString("营收编号:", comment: "")
                    $0.value = reportModel.orderNo
                    $0.cell.dottedLine.isHidden = true
                }
                
                <<< SW_RevenueDetailNormalRow("order Date") {
                    $0.rawTitle = NSLocalizedString("营收署期:", comment: "")
                    $0.value = reportModel.orderDate == 0 ? "" : Date.dateWith(timeInterval: reportModel.orderDate).stringWith(formatStr: "yyyy.MM.dd")
            }
        }
        // mark: - 下面部分是 成本 和 收入  --所有报表都有的类型， 公用
        if reportModel.revenueList.filter({ return !$0.typeName.isEmpty }).count > 0 {
            section += 1
            form
                +++
                Eureka.Section()
                
                <<< SW_CostIncomeDetailRow("revenueList") {
                    $0.rawTitle = NSLocalizedString("收入:", comment: "")
                    $0.totalAmount = reportModel.revenueAmount
                    $0.value = reportModel.revenueList
                }
            revenueIndexPath = IndexPath(row: 0, section: section)
        }
        
        if reportModel.costList.filter({ return !$0.typeName.isEmpty }).count > 0 {
            section += 1
            form
                +++
                Eureka.Section()
                
            <<< SW_CostIncomeDetailRow("costList") {
                $0.rawTitle = NSLocalizedString("成本:", comment: "")
                $0.totalAmount = reportModel.costAmount
                $0.value = reportModel.costList
            }
            costIndexPath = IndexPath(row: 0, section: section)
        }
        
        tableView.reloadAndFadeAnimation()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        PrintLog("deinit")
    }
    
    //MARK: - 编辑按钮点击
    private func addEditButton() {
        if reportModel.isModify {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "编辑", style: .plain, target: self, action: #selector(editAction(_:)))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc private func editAction(_ sender: UIButton) {
        switch type {
        case .dayOrder:
            self.navigationController?.pushViewController(SW_EditDayOrderViewController(reportModel), animated: true)
        case .dayNonOrder:
            self.navigationController?.pushViewController(SW_EditDayNonOrderViewController(reportModel), animated: true)
        default:
            self.navigationController?.pushViewController(SW_EditYearNonOrderViewController(reportModel, type: type), animated: true)
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
}

// MARK: - TableViewDelegate
extension SW_RevenueDetailViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 14
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
