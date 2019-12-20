//
//  SW_EditYearNonOrderViewController.swift
//  SWS
//
//  Created by jayway on 2018/6/27.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_EditYearNonOrderViewController: FormViewController {
    private var type = RevenueReportType.monthNonOrder
    /// 将要编辑或者新建的报表model--存放数据
    private var reportModel: SW_RevenueDetailModel!
    
    private var commitBtn: SW_BottomBlueButton = {
        let btn = SW_BottomBlueButton()
        btn.blueBtn.setTitle("提交", for: UIControl.State())
        btn.blueBtn.addTarget(self, action: #selector(commitAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    private var isRequesting = false
    
    //MARK: - 内存中存一些接口数据，第一次时请求，后则使用内存数据
    /// 成本类型列表
    private var costTypeList = [NormalModel]()
    /// 收入类型列表
    private var incomeTypeList = [NormalModel]()
    
    //MARK: - 初始化部分
    /// 初始化方法 如果参数未空则代表创建报表
    ///
    /// - Parameter reportModel: 需要编辑的订单报表
    init(_ reportModel: SW_RevenueDetailModel? = nil, type: RevenueReportType) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
        if let report = reportModel {
            self.reportModel = report.copy() as! SW_RevenueDetailModel
        } else {
            self.reportModel = SW_RevenueDetailModel(type)
        }
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
    
    
    //MARK: - 设置tableview数据源
    private func formConfig() {

        navigationItem.title = NSLocalizedString(type.rawTitle, comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(backAction))
        
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = UIColor.mainColor.background
        tableView.separatorColor = UIColor.mainColor.separator
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL + 73, right: 0)
        rowKeyboardSpacing = 89
        view.addSubview(commitBtn)
        commitBtn.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(TABBAR_HEIGHT + TABBAR_BOTTOM_INTERVAL + 35)
        }
    }
    
    fileprivate func createTableView() {
        form = Form()
            +++
            Eureka.Section()
            
            <<< SW_RedStarFieldRow("order Number") {
                $0.rawTitle = NSLocalizedString("营收编号", comment: "")
                $0.limitCount = 40
                $0.value = reportModel.orderNo
                $0.cell.isMustChoose = true
                $0.cell.valueField.keyboardType = .asciiCapable
                $0.cell.valueField.placeholder = "输入营收编号"
                }.onChange { [weak self] in
                    self?.reportModel.orderNo = $0.value ?? ""
            }
            
            <<< SW_RedStarLabelRow("order Date") {
                $0.rawTitle = NSLocalizedString("营收署期", comment: "")
                $0.value = reportModel.orderDate == 0 ? "" : Date.dateWith(timeInterval: reportModel.orderDate).simpleTimeString(formatter: .year)
                $0.cell.isMustChoose = true
                $0.cell.placeholder = "选择营收归属日期"
                }.onCellSelection({ (cell, row) in
                    row.deselect()
                    let selectValue = Date.dateWith(formatStr: "yyyy-MM-dd", dateString: row.value ?? "")
                    BRDatePickerView.showDatePicker(withTitle: "营收署期", on: MYWINDOW, dateType: BRDatePickerMode.init(rawValue: 6)!, defaultSelValue: selectValue, minDate: Date(timeIntervalSince1970: 0), maxDate: nil, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (key) in
                        row.value = key
                        row.updateCell()
                    }, cancel: nil)
                }).onChange { [weak self] in
                    self?.reportModel.orderDate = $0.value?.toTimeInterval(formatStr: "yyyy-MM-dd") ?? 0
            }
        
        addRevenueListSection()
        addCostListSection()
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    //MARK: - 添加可变分组
    /// 添加成本分区
    private func addCostListSection() {
        if reportModel.costList.count == 0 {//编辑时可能出现没有收入的情况，添加一个默认的
            reportModel.costList.append(CostIncomeModel())
        }
        
        for index in 0..<reportModel.costList.count {
            form
                +++
                Section() { [weak self] section in
                    var header = HeaderFooterView<SW_DeleteSectionHeader>(.class)
                    header.height = {32}
                    header.onSetupView = { view, _ in
                        view.backgroundColor = UIColor.mainColor.background
                        view.title = "成本(\(index+1))"
                        view.sectionIndex = index
                        view.deleteBtn.isHidden = self?.reportModel.costList.count == 1
                        view.deleteActionBlock = { (deleteIndex) -> Void in
                            self?.reportModel.costList.remove(at: deleteIndex)
                            self?.tableView.reloadDataAndScrollOriginal({ [weak self] in
                                self?.createTableView()
                                self?.tableView.reloadData()
                            })
                        }
                    }
                    section.header = header
                }
                
                <<< SW_RedStarLabelRow("costRow \(index)") {
                    $0.rawTitle = NSLocalizedString("成本", comment: "")
                    $0.value = reportModel.costList[index].typeName
                    $0.cell.isMustChoose = false
                    $0.cell.placeholder = "选择类型"
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        if self!.costTypeList.count > 0 {
                            self?.showCostTypeListPicker(index)
                        } else {
                            SW_WorkingService.getBusUnitCostType().response({ (json, isCache, error) in
                                if let json = json as? JSON, error == nil {
                                    self?.costTypeList = json["list"].arrayValue.map({ return NormalModel($0) })
                                    self?.showCostTypeListPicker(index)
                                } else {
                                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                                }
                            })
                        }
                    })
                
                ///输入框类型field
                <<< SW_RedStarFieldRow("costNumber \(index)") {
                    $0.rawTitle = NSLocalizedString("金额", comment: "")
                    $0.isAmount = true
                    $0.value = reportModel.costList[index].amount
                    $0.cell.isMustChoose = false
                    $0.cell.valueField.keyboardType = .decimalPad
                    $0.cell.valueField.placeholder = "输入金额"
                    }.onChange { [weak self] in
                        self?.reportModel.costList[index].amount = $0.value ?? ""
            }
        }
        ///在最后一行添加一个添加的row
        form.last!
            <<< SW_AddRow("costAddRow").onCellSelection({ [weak self] (cell, row) in
                row.deselect()
                self?.reportModel.costList.append(CostIncomeModel())
                self?.tableView.reloadDataAndScrollOriginal({ [weak self] in
                    self?.createTableView()
                    self?.tableView.reloadData()
                })
            })
    }
    
    /// 添加收入分区
    private func addRevenueListSection() {
        if reportModel.revenueList.count == 0 {//编辑时可能出现没有收入的情况，添加一个默认的
            reportModel.revenueList.append(CostIncomeModel())
        }
        
        for index in 0..<reportModel.revenueList.count {
            form
                +++
                Section() { [weak self] section in
                    var header = HeaderFooterView<SW_DeleteSectionHeader>(.class)
                    header.height = {32}
                    header.onSetupView = { view, _ in
                        view.backgroundColor = UIColor.mainColor.background
                        view.title = "收入(\(index+1))"
                        view.sectionIndex = index
                        view.deleteBtn.isHidden = self?.reportModel.revenueList.count == 1
                        view.deleteActionBlock = { (deleteIndex) -> Void in
                            self?.reportModel.revenueList.remove(at: deleteIndex)
                            self?.tableView.reloadDataAndScrollOriginal({ [weak self] in
                                self?.createTableView()
                                self?.tableView.reloadData()
                            })
                        }
                    }
                    section.header = header
                }
                
                <<< SW_RedStarLabelRow("incomeRow \(index)") {
                    $0.rawTitle = NSLocalizedString("收入", comment: "")
                    $0.value = reportModel.revenueList[index].typeName
                    $0.cell.isMustChoose = false
                    $0.cell.placeholder = "选择类型"
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        if self!.incomeTypeList.count > 0 {
                            self?.showIncomeTypeListPicker(index)
                        } else {
                            SW_WorkingService.getBusUnitIncomeType().response({ (json, isCache, error) in
                                if let json = json as? JSON, error == nil {
                                    self?.incomeTypeList = json["list"].arrayValue.map({ return NormalModel($0) })
                                    self?.showIncomeTypeListPicker(index)
                                } else {
                                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                                }
                            })
                        }
                    })
                
                ///输入框类型field
                <<< SW_RedStarFieldRow("incomeNumber \(index)") {
                    $0.rawTitle = NSLocalizedString("金额", comment: "")
                    $0.isAmount = true
                    $0.value = reportModel.revenueList[index].amount
                    $0.cell.isMustChoose = false
                    $0.cell.valueField.keyboardType = .decimalPad
                    $0.cell.valueField.placeholder = "输入金额"
                    }.onChange { [weak self] in
                        self?.reportModel.revenueList[index].amount = $0.value ?? ""
            }
        }
        ///在最后一行添加一个添加的row
        form.last!
            <<< SW_AddRow("incomeAddRow").onCellSelection({ [weak self] (cell, row) in
                row.deselect()
                self?.reportModel.revenueList.append(CostIncomeModel())
                self?.tableView.reloadDataAndScrollOriginal({ [weak self] in
                    self?.createTableView()
                    self?.tableView.reloadData()
                })
            })
    }
    
    
    //MARK: - 提交按钮点击
    @objc private func commitAction(_ sender: UIButton) {
        if reportModel.orderNo.isEmpty {
            showAlertMessage("请输入营收编号", MYWINDOW)
            return
        }
        if reportModel.orderDate == 0 {
            showAlertMessage("请选择营收署期", MYWINDOW)
            return
        }
        
        //判断是否有输入收入或者成本
        let postState = reportModel.isCanPost
        if !postState.0 {
            showAlertMessage(postState.1, MYWINDOW)
            return
        }
        
        if !reportModel.id.isEmpty {
            ///编辑前先调用接口
            checkReportEditState()
        } else {
            ///直接新建
            alertControllerShow(title: "您确定保存此报表信息吗？", message: "您可以在15天内再修改本信息2次", rightTitle: "确 定", rightBlock: { (_, _) in
                self.postRequest()
            }, leftTitle: "取 消", leftBlock: nil)
        }
        
    }
    
    private func postRequest() {
        guard !isRequesting else { return }
        isRequesting = true
        QMUITips.showLoading("正在保存", in: self.view)
        /// 如果到这里说明该填的都填了。  --提交新建订单报表 ----
        SW_WorkingService.saveDayNonOrder(reportModel).response({ (json, isCache, error) in
            self.isRequesting = false
            QMUITips.hideAllTips(in: self.view)
            if let _ = json as? JSON, error == nil {
                if self.reportModel.id.isEmpty {//新建
                    if let index = self.navigationController?.viewControllers.index(where: { return $0 is SW_RevenueManageViewController }) {
                        //                    通知每日订单报表刷新数据
                        NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadCreatRevenueReport, object: nil, userInfo: ["revenueReportType": self.type])
                        showAlertMessage("保存成功", MYWINDOW)
                        self.navigationController?.popToViewController(self.navigationController!.viewControllers[index], animated: true)
                    }
                } else {//编辑 返回详情页
                    NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadEditRevenueReport, object: nil, userInfo: ["revenueReportType": self.type, "fromDeptName": self.reportModel.fromDeptName, "reportNo":self.reportModel.orderNo, "reportDate":self.reportModel.orderDate])
                    showAlertMessage("保存成功", MYWINDOW)
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
        })
        
    }
    
    
    /// 检查是否能够进行编辑并提示 时间与修改次数
    private func checkReportEditState() {
        guard !isRequesting else { return }
        isRequesting = true
        SW_WorkingService.checkFlowSheet(reportModel.id).response({  (json, isCache, error) in
            self.isRequesting = false
            if let json = json as? JSON, error == nil {
                if json["modifyType"].intValue == 2 {//2代表可以修改
                    let msg = json["modifyCount"].intValue == 2 ? "您可以在\("\(max(1, json["modifyDate"].intValue/1000/60/60/24))天")内再修改本信息1次" : "您将不能再修改本信息"
                    alertControllerShow(title: "您确定保存此报表信息吗？", message: msg, rightTitle: "确 定", rightBlock: { (_, _) in
                        self.postRequest()
                    }, leftTitle: "取 消", leftBlock: nil)
                } else {//不可以修改了，说明是进入该页面后过期的
                    //                    此订单已超出修改时限
                    SW_UserCenter.shared.showAlert(message: "此报表已超出修改时限", str: "我知道了", action: nil)
                }
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
        })
        
    }
    
    private func getModifyDate(_ timeInterval: Int) -> String {
        return "\(max(1, timeInterval/1000/60/60/24))天"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    //MARK: - private 方法  显示pickerview
    /// 显示成本类型列表pickerview
    private func showCostTypeListPicker(_ index: Int) {
        guard costTypeList.count > 0 else { return }
        guard let row = form.rowBy(tag: "costRow \(index)") as? SW_RedStarLabelRow else { return }
        BRStringPickerView.showStringPicker(withTitle: "成本类型", on: MYWINDOW, dataSource: costTypeList.map({ return $0.name }), defaultSelValue: row.value, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (selectValue) in
            let select = selectValue as? String ?? ""
            
            if self.reportModel.costList[index].typeName != select {
                if let findIndex = self.costTypeList.index(where: { return $0.name == select}) {
                    self.reportModel.costList[index].typeName = self.costTypeList[findIndex].name
                    self.reportModel.costList[index].typeId = self.costTypeList[findIndex].id
                    row.value = self.reportModel.costList[index].typeName
                    row.updateCell()
                }
            }
        })
    }
    
    /// 显示收入类型列表pickerview
    private func showIncomeTypeListPicker(_ index: Int) {
        guard incomeTypeList.count > 0 else { return }
        guard let row = form.rowBy(tag: "incomeRow \(index)") as? SW_RedStarLabelRow else { return }
        BRStringPickerView.showStringPicker(withTitle: "收入类型", on: MYWINDOW, dataSource: incomeTypeList.map({ return $0.name }), defaultSelValue: row.value, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (selectValue) in
            let select = selectValue as? String ?? ""
            
            if self.reportModel.revenueList[index].typeName != select {
                if let findIndex = self.incomeTypeList.index(where: { return $0.name == select}) {
                    self.reportModel.revenueList[index].typeName = self.incomeTypeList[findIndex].name
                    self.reportModel.revenueList[index].typeId = self.incomeTypeList[findIndex].id
                    row.value = self.reportModel.revenueList[index].typeName
                    row.updateCell()
                }
            }
        })
    }
    
    @objc private func backAction() {
        alertControllerShow(title: "您确定取消编辑此报表信息吗？", message: nil, rightTitle: "确 定", rightBlock: { (controller, action) in
            self.navigationController?.popViewController(animated: true)
        }, leftTitle: "取 消", leftBlock: nil)
    }
    
    
    //MARK: - FormViewControllerProtocol   重写一下方法是因为需要去除该库添加时的动画
    override func sectionsHaveBeenAdded(_ sections: [Section], at indexes: IndexSet) {
    }
    
    override func rowsHaveBeenAdded(_ rows: [BaseRow], at indexes: [IndexPath]) {
    }
}

// MARK: - TableViewDelegate
extension SW_EditYearNonOrderViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 49
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section > 0 ? 32 : 14
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
