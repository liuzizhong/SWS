//
//  SW_EditDayOrderViewController.swift
//  SWS
//
//  Created by jayway on 2018/6/22.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

/// 创建或者编辑每日订单报表
class SW_EditDayOrderViewController: FormViewController {
    
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
    /// 订单类型列表
    private var orderTypeList = [OrderTypeModel]()
    /// 订单归属列表
    private var depList = [SW_AddressBookModel]()
    /// 订单业务人员列表
    private var staffList = [SW_AddressBookModel]()
    /// 汽车品牌列表
    private var carBrandList = [NormalModel]()
    /// 汽车系列列表
    private var carSeriesList = [NormalModel]()
    /// 汽车型号列表
    private var carModelList = [NormalModel]()
    /// 汽车颜色列表
    private var carProValueList = [NormalModel]()
    /// 保险种类列表
    private var insuranceTypeList = [NormalModel]()
    /// 成本类型列表
    private var costTypeList = [NormalModel]()
    /// 收入类型列表
    private var incomeTypeList = [NormalModel]()
    
    //MARK: - 初始化部分
    /// 初始化方法 如果参数未空则代表创建报表
    ///
    /// - Parameter reportModel: 需要编辑的订单报表
    init(_ reportModel: SW_RevenueDetailModel? = nil) {
        super.init(nibName: nil, bundle: nil)
        if let report = reportModel {
            self.reportModel = report.copy() as? SW_RevenueDetailModel
        } else {
            self.reportModel = SW_RevenueDetailModel(.dayOrder)
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

        navigationItem.title = NSLocalizedString("每日订单报表", comment: "")
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
                $0.rawTitle = NSLocalizedString("订单编号", comment: "")
                $0.limitCount = 40
                $0.value = reportModel.orderNo
                $0.cell.isMustChoose = true
                $0.cell.valueField.keyboardType = .asciiCapable
                $0.cell.valueField.placeholder = "输入订单编号"
                }.onChange { [weak self] in
                    self?.reportModel.orderNo = $0.value ?? ""
                }
        
            <<< SW_RedStarLabelRow("order Date") {
                $0.rawTitle = NSLocalizedString("营收署期", comment: "")
                $0.value = reportModel.orderDate == 0 ? "" : Date.dateWith(timeInterval: reportModel.orderDate).simpleTimeString(formatter: .year)
                $0.cell.isMustChoose = true
                $0.cell.placeholder = "选择订单归属日期"
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
        
            <<< SW_RedStarFieldRow("customer Name") {
                $0.rawTitle = NSLocalizedString("客户姓名", comment: "")
                $0.value = reportModel.customerName
                $0.cell.isMustChoose = true
                $0.cell.valueField.keyboardType = .default
                $0.cell.valueField.placeholder = "输入客户姓名"
                }.onChange { [weak self] in
                    self?.reportModel.customerName = $0.value ?? ""
            }
        
            +++
            Eureka.Section()
        
            <<< SW_RedStarLabelRow("order Type") {
                $0.rawTitle = NSLocalizedString("订单类型", comment: "")
                $0.value = reportModel.orderType.name
                $0.cell.isMustChoose = true
                $0.cell.placeholder = "选择订单类型"
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    if self!.orderTypeList.count > 0 {
                        self?.showOrderTypePicker()
                    } else {
                        SW_WorkingService.getOrderType().response({ (json, isCache, error) in
                            if let json = json as? JSON, error == nil {
                                self?.orderTypeList = json["orderType"].arrayValue.map({ return OrderTypeModel($0) })
                                self?.showOrderTypePicker()
                            } else {
                                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                            }
                        })
                    }
                   
                })
        
            <<< SW_RedStarLabelRow("fromDeptName") {
                $0.rawTitle = NSLocalizedString("订单归属", comment: "")
                $0.value = reportModel.fromDeptName
                $0.cell.isMustChoose = true
                $0.cell.placeholder = "选择业务部门"
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    if self!.depList.count > 0 {
                        self?.showDepListPicker()
                    } else {
                        SW_AddressBookService.getDepartmentList(SW_UserCenter.shared.user!.id, bUnitId: SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId).response({ (json, isCache, error) in
                            if let json = json as? JSON, error == nil {
                                self?.depList = SW_AddressBookData.getDataList(json["list"].arrayValue, type: .department)
                                self?.showDepListPicker()
                            } else {
                                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                            }
                        })
                    }
                })
        
            <<< SW_RedStarLabelRow("salesman") {
                $0.rawTitle = NSLocalizedString("业务人员", comment: "")
                $0.value = reportModel.salesman
                $0.cell.isMustChoose = true
                $0.cell.placeholder = "选择业务人员"
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    ///必须先选择订单归属
                    if self?.reportModel.fromDeptName.isEmpty == true {
                        showAlertMessage("请选择订单归属", MYWINDOW)
                        return
                    }
                    if self!.staffList.count > 0 {
                        self?.showStaffListPicker()
                    } else {
                        SW_AddressBookService.getDepartmentStaffList(SW_UserCenter.shared.user!.id, departmentId: self?.reportModel.fromDeptId ?? 0, businessUnitId: SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId).response({ (json, isCache, error) in
                            if let json = json as? JSON, error == nil {
                                self?.staffList = SW_AddressBookData.getDataList(json.arrayValue, type: .contact)
                                self?.showStaffListPicker()
                            } else {
                                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                            }
                        })
                    }
                })
        
            <<< SW_RedStarLabelRow("carBrand") {
                $0.rawTitle = NSLocalizedString("厂商品牌", comment: "")
                $0.value = reportModel.carBrand.name
                $0.cell.isMustChoose = true
                $0.cell.placeholder = "选择厂商品牌"
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    if self!.carBrandList.count > 0 {
                        self?.showCarBrandListPicker()
                    } else {
                        SW_WorkingService.getCarBrand().response({ (json, isCache, error) in
                            if let json = json as? JSON, error == nil {
                                self?.carBrandList = json["list"].arrayValue.map({ return NormalModel($0) })
                                self?.showCarBrandListPicker()
                            } else {
                                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                            }
                        })
                    }
                })
            
            <<< SW_RedStarLabelRow("carSerie") {
                $0.rawTitle = NSLocalizedString("车辆名称", comment: "")
                $0.value = reportModel.carSerie.name
                $0.cell.isMustChoose = true
                $0.cell.placeholder = "选择车辆名称"
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    ///必须先选择订单归属
                    if self?.reportModel.carBrand.name.isEmpty == true {
                        showAlertMessage("请选择厂商品牌", MYWINDOW)
                        return
                    }
                    if self!.carSeriesList.count > 0 {
                        self?.showCarSeriesListPicker()
                    } else {
                        SW_WorkingService.getCarSeries(self?.reportModel.carBrand.id ?? "").response({ (json, isCache, error) in
                            if let json = json as? JSON, error == nil {
                                self?.carSeriesList = json["list"].arrayValue.map({ return NormalModel($0) })
                                self?.showCarSeriesListPicker()
                            } else {
                                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                            }
                        })
                    }
                })
        
            <<< SW_RedStarLabelRow("carModel") {
                $0.rawTitle = NSLocalizedString("车辆型号", comment: "")
                $0.value = reportModel.carModel.name
                $0.cell.isMustChoose = true
                $0.cell.placeholder = "选择车辆型号"
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    ///必须先选择订单归属
                    if self?.reportModel.carSerie.name.isEmpty == true {
                        showAlertMessage("请选择车辆名称", MYWINDOW)
                        return
                    }
                    if self!.carModelList.count > 0 {
                        self?.showCarModelListPicker()
                    } else {
                        SW_WorkingService.getCarModel(self?.reportModel.carSerie.id ?? "").response({ (json, isCache, error) in
                            if let json = json as? JSON, error == nil {
                                self?.carModelList = json["list"].arrayValue.map({ return NormalModel($0) })
                                self?.showCarModelListPicker()
                            } else {
                                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                            }
                        })
                    }
                })
            
            <<< SW_RedStarLabelRow("carColor") {
                $0.rawTitle = NSLocalizedString("车身颜色", comment: "")
                $0.value = reportModel.carColor.name
                $0.cell.isMustChoose = true
                $0.cell.placeholder = "选择车身颜色"
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    ///必须先选择订单归属
                    if self?.reportModel.carBrand.name.isEmpty == true {
                        showAlertMessage("请选择厂商品牌", MYWINDOW)
                        return
                    }
                    if self!.carProValueList.count > 0 {
                        self?.showCarProValueListPicker()
                    } else {
                        SW_WorkingService.getCarProValue(self?.reportModel.carBrand.id ?? "").response({ (json, isCache, error) in
                            if let json = json as? JSON, error == nil {
                                self?.carProValueList = json["list"].arrayValue.map({ return NormalModel($0) })
                                self?.showCarProValueListPicker()
                            } else {
                                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                            }
                        })
                    }
                })
        
            +++
            Section()
            
            <<< SW_RedStarLabelRow("insuranceCompany") {
                $0.rawTitle = NSLocalizedString("保险公司", comment: "")
                $0.value = reportModel.insuranceCompanyName
                $0.cell.isMustChoose = false
                $0.cell.placeholder = "选择保险公司"
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    let vc = SW_InsuranceCompanyViewController(nil)
                    vc.selectBlock = { (select) -> Void in
                        if self?.reportModel.insuranceCompanyKey != select.id {
                            self?.reportModel.insuranceCompanyName = select.name
                            self?.reportModel.insuranceCompanyKey = select.id
                            self?.insuranceTypeList.removeAll()
                            //重新初始化数据
                            self?.createTableView()
                            self?.tableView.reloadAndFadeAnimation()
                        }
                    }
                    self?.navigationController?.pushViewController(vc, animated: true)
            })
        
        addInsuranceTypesSection()
        addRevenueListSection()
        addCostListSection()
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    //MARK: - 添加可变分组
    /// 添加保险分区
    private func addInsuranceTypesSection() {
        guard !reportModel.insuranceCompanyKey.isEmpty else { return }
        if reportModel.insuranceTypes.count > 0 {
            
            for index in 0..<reportModel.insuranceTypes.count {
                form
                +++
                    Section() { [weak self] section in
                        var header = HeaderFooterView<SW_DeleteSectionHeader>(.class)
                        header.height = {32}
                        header.onSetupView = { view, _ in
                            view.backgroundColor = UIColor.mainColor.background
                            view.title = "保险种类(\(index+1))"
                            view.sectionIndex = index
                            view.deleteBtn.isHidden = self?.reportModel.insuranceTypes.count == 1
                            view.deleteActionBlock = { (deleteIndex) -> Void in
                                self?.reportModel.insuranceTypes.remove(at: deleteIndex)
                                self?.tableView.reloadDataAndScrollOriginal({ [weak self] in
                                    self?.createTableView()
                                    self?.tableView.reloadData()
                                })
                            }
                        }
                        section.header = header
                }
                
                    <<< SW_RedStarLabelRow("insuranceTypeName \(index)") {
                        $0.rawTitle = NSLocalizedString("保险种类", comment: "")
                        $0.value = reportModel.insuranceTypes[index].insuranceTypeName
                        $0.cell.isMustChoose = true
                        $0.cell.placeholder = "选择保险种类"
                        }.onCellSelection({ [weak self] (cell, row) in
                            row.deselect()
                            if self!.insuranceTypeList.count > 0 {
                                self?.showInsuranceTypeListPicker(index)
                            } else {
                                SW_WorkingService.getInsuranceTypes(self?.reportModel.insuranceCompanyKey ?? "").response({ (json, isCache, error) in
                                    if let json = json as? JSON, error == nil {
                                        self?.insuranceTypeList = json.arrayValue.map({ return NormalModel($0) })
                                        self?.showInsuranceTypeListPicker(index)
                                    } else {
                                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                                    }
                                })
                            }
                        })
                    
                    
                    <<< SW_RedStarLabelRow("insuranceLimitDate \(index)") {
                        $0.rawTitle = NSLocalizedString("到期日期", comment: "")
                        $0.value = reportModel.insuranceTypes[index].limitDate == 0 ? "" : Date.dateWith(timeInterval: reportModel.insuranceTypes[index].limitDate).simpleTimeString(formatter: .year)
                        $0.cell.isMustChoose = true
                        $0.cell.placeholder = "选择日期"
                        }.onCellSelection({ (cell, row) in
                            row.deselect()
                            let selectValue = Date.dateWith(formatStr: "yyyy-MM-dd", dateString: row.value ?? "")
                            BRDatePickerView.showDatePicker(withTitle: "到期日期", on: MYWINDOW, dateType: BRDatePickerMode.init(rawValue: 6)!, defaultSelValue: selectValue, minDate: Date(timeIntervalSince1970: 0), maxDate: nil, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (key) in
                                row.value = key
                                row.updateCell()
                            }, cancel: nil)
                        }).onChange { [weak self] in
                            self?.reportModel.insuranceTypes[index].limitDate = $0.value?.toTimeInterval(formatStr: "yyyy-MM-dd") ?? 0
                }
            }
            ///在最后一行添加一个添加的row
            form.last!
            <<< SW_AddRow("insuranceAddRow").onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    self?.reportModel.insuranceTypes.append(InsuranceModel())
                    self?.tableView.reloadDataAndScrollOriginal({ [weak self] in
                    self?.createTableView()
                    self?.tableView.reloadData()
                    })
                })
        }
    }
    
    /// 添加成本分区
    private func addCostListSection() {
        if reportModel.costList.count == 0 {
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
                        if self?.reportModel.fromDeptName.isEmpty == true {
                            showAlertMessage("请选择订单归属", MYWINDOW)
                            return
                        }
                        if self!.costTypeList.count > 0 {
                            self?.showCostTypeListPicker(index)
                        } else {
                            SW_WorkingService.getDepCostTypes(self?.reportModel.fromDeptId ?? 0).response({ (json, isCache, error) in
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
                        if self?.reportModel.fromDeptName.isEmpty == true {
                            showAlertMessage("请选择订单归属", MYWINDOW)
                            return
                        }
                        if self!.incomeTypeList.count > 0 {
                            self?.showIncomeTypeListPicker(index)
                        } else {
                            SW_WorkingService.getDepIncomeType(self?.reportModel.fromDeptId ?? 0).response({ (json, isCache, error) in
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
            showAlertMessage("请输入订单编号", MYWINDOW)
            return
        }
        if reportModel.orderDate == 0 {
            showAlertMessage("请选择订单署期", MYWINDOW)
            return
        }
        if reportModel.customerName.isEmpty {
            showAlertMessage("请输入客户姓名", MYWINDOW)
            return
        }
        if reportModel.orderType.name.isEmpty {
            showAlertMessage("请选择订单类型", MYWINDOW)
            return
        }
        if reportModel.fromDeptName.isEmpty {
            showAlertMessage("请选择订单归属", MYWINDOW)
            return
        }
        if reportModel.salesman.isEmpty {
            showAlertMessage("请选择业务人员", MYWINDOW)
            return
        }
        if reportModel.carBrand.name.isEmpty {
            showAlertMessage("请选择厂商品牌", MYWINDOW)
            return
        }
        if reportModel.carSerie.name.isEmpty {
            showAlertMessage("请选择车辆名称", MYWINDOW)
            return
        }
        if reportModel.carModel.name.isEmpty {
            showAlertMessage("请选择车辆型号", MYWINDOW)
            return
        }
        if reportModel.carColor.name.isEmpty {
            showAlertMessage("请选择车身颜色", MYWINDOW)
            return
        }
        
        //选择了保险公司，则必须填写保险种类
        if !reportModel.insuranceCompanyKey.isEmpty {
            for insuran in reportModel.insuranceTypes {
                if insuran.insuranceTypeName.isEmpty {
                    showAlertMessage("请选择保险种类", MYWINDOW)
                    return
                }
                if insuran.limitDate == 0 {
                    showAlertMessage("请选择保险到期日期", MYWINDOW)
                    return
                }
            }
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
        SW_WorkingService.saveDayOrder(reportModel).response({ (json, isCache, error) in
            self.isRequesting = false
            QMUITips.hideAllTips(in: self.view)
            if let _ = json as? JSON, error == nil {
                if self.reportModel.id.isEmpty {//新建
                    if let index = self.navigationController?.viewControllers.index(where: { return $0 is SW_RevenueManageViewController }) {
                        //                    通知每日订单报表刷新数据
                        NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadCreatRevenueReport, object: nil, userInfo: ["revenueReportType": RevenueReportType.dayOrder])
                        showAlertMessage("保存成功", MYWINDOW)
                        self.navigationController?.popToViewController(self.navigationController!.viewControllers[index], animated: true)
                    }
                } else {//编辑 返回详情页
                    NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadEditRevenueReport, object: nil, userInfo: ["revenueReportType": RevenueReportType.dayOrder, "fromDeptName": self.reportModel.fromDeptName, "reportNo":self.reportModel.orderNo, "reportDate":self.reportModel.orderDate])
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
        SW_WorkingService.checkSaleOrder(reportModel.id).response({  (json, isCache, error) in
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    //MARK: - private 方法  显示pickerview
    /// 显示订单类型pickerview
    private func showOrderTypePicker() {
        guard orderTypeList.count > 0 else { return }
        guard let row = form.rowBy(tag: "order Type") as? SW_RedStarLabelRow else { return }
        BRStringPickerView.showStringPicker(withTitle: "订单类型", on: MYWINDOW, dataSource: orderTypeList.map({ return $0.name }), defaultSelValue: row.value, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (selectValue) in
            PrintLog(selectValue)
            if let index = self.orderTypeList.index(where: { return $0.name == selectValue  as? String ?? ""}) {
                self.reportModel.orderType = self.orderTypeList[index]
                row.value = self.reportModel.orderType.name
                row.updateCell()
            }
        })
    }
    
    /// 显示订单归属pickerview
    private func showDepListPicker() {
        guard depList.count > 0 else { return }
        guard let row = form.rowBy(tag: "fromDeptName") as? SW_RedStarLabelRow else { return }
        BRStringPickerView.showStringPicker(withTitle: "订单归属", on: MYWINDOW, dataSource: depList.map({ return $0.departmentName }), defaultSelValue: row.value, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (selectValue) in
            let select = selectValue as? String ?? ""
            
            ///更换了部门 才刷新页面 并且清除业务人员数据
            if self.reportModel.fromDeptName != select {
                if let index = self.depList.index(where: { return $0.departmentName == select}) {
                    self.reportModel.fromDeptName = self.depList[index].departmentName
                    self.reportModel.fromDeptId = self.depList[index].id
                    row.value = self.reportModel.fromDeptName
                    row.updateCell()
                    //业务人员列表清空
                    self.staffList.removeAll()
                    //收入成本类型清空
                    self.costTypeList.removeAll()
                    self.incomeTypeList.removeAll()
                    guard let salesman = self.form.rowBy(tag: "salesman") as? SW_RedStarLabelRow else { return }
                    salesman.value = ""
                    self.reportModel.salesman = ""
                    self.reportModel.salesmanId = 0
                    salesman.updateCell()
                    //将成本类型的row类型清空
                    for index in 0..<self.reportModel.costList.count {
                        guard let costRow = self.form.rowBy(tag: "costRow \(index)") as? SW_RedStarLabelRow else { return }
                        costRow.value = ""
                        self.reportModel.costList[index].typeName = ""
                        self.reportModel.costList[index].typeId = ""
                        costRow.updateCell()
                    }
                    //将收入类型的row类型清空
                    for index in 0..<self.reportModel.revenueList.count {
                        guard let incomeRow = self.form.rowBy(tag: "incomeRow \(index)") as? SW_RedStarLabelRow else { return }
                        incomeRow.value = ""
                        self.reportModel.revenueList[index].typeName = ""
                        self.reportModel.revenueList[index].typeId = ""
                        incomeRow.updateCell()
                    }
                }
            }
        })
    }
    
    /// 显示业务人员pickerview
    private func showStaffListPicker() {
        guard staffList.count > 0 else {
            showAlertMessage("该部门没有成员", MYWINDOW)
            return
        }
        guard let row = form.rowBy(tag: "salesman") as? SW_RedStarLabelRow else { return }
        BRStringPickerView.showStringPicker(withTitle: "业务人员", on: MYWINDOW, dataSource: staffList.map({ return $0.realName }), defaultSelValue: row.value, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (selectValue) in
            let select = selectValue as? String ?? ""
            
            if self.reportModel.salesman != select {
                if let index = self.staffList.index(where: { return $0.realName == select}) {
                    self.reportModel.salesman = self.staffList[index].realName
                    self.reportModel.salesmanId = self.staffList[index].id
                    row.value = self.reportModel.salesman
                    row.updateCell()
                }
            }
        })
    }
    
    /// 显示汽车品牌列表pickerview
    private func showCarBrandListPicker() {
        guard carBrandList.count > 0 else { return }
        guard let row = form.rowBy(tag: "carBrand") as? SW_RedStarLabelRow else { return }
        BRStringPickerView.showStringPicker(withTitle: "厂商品牌", on: MYWINDOW, dataSource: carBrandList.map({ return $0.name }), defaultSelValue: row.value, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (selectValue) in
            let select = selectValue as? String ?? ""
            
            if self.reportModel.carBrand.name != select {
                if let index = self.carBrandList.index(where: { return $0.name == select}) {
                    self.reportModel.carBrand = self.carBrandList[index]
                    row.value = self.reportModel.carBrand.name
                    row.updateCell()
                    //业务人员列表清空
                    self.carSeriesList.removeAll()
                    self.carModelList.removeAll()
                    self.carProValueList.removeAll()
                    guard let carSerie = self.form.rowBy(tag: "carSerie") as? SW_RedStarLabelRow else { return }
                    guard let carModel = self.form.rowBy(tag: "carModel") as? SW_RedStarLabelRow else { return }
                    guard let carColor = self.form.rowBy(tag: "carColor") as? SW_RedStarLabelRow else { return }
                    carSerie.value = ""
                    carModel.value = ""
                    carColor.value = ""
                    self.reportModel.carSerie = NormalModel()
                    self.reportModel.carModel = NormalModel()
                    self.reportModel.carColor = NormalModel()
                    carSerie.updateCell()
                    carModel.updateCell()
                    carColor.updateCell()
                }
            }
        })
    }
    
    /// 显示汽车名称列表pickerview
    private func showCarSeriesListPicker() {
        guard carSeriesList.count > 0 else { return }
        guard let row = form.rowBy(tag: "carSerie") as? SW_RedStarLabelRow else { return }
        BRStringPickerView.showStringPicker(withTitle: "车辆名称", on: MYWINDOW, dataSource: carSeriesList.map({ return $0.name }), defaultSelValue: row.value, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (selectValue) in
            let select = selectValue as? String ?? ""

            if self.reportModel.carSerie.name != select {
                if let index = self.carSeriesList.index(where: { return $0.name == select}) {
                    self.reportModel.carSerie = self.carSeriesList[index]
                    row.value = self.reportModel.carSerie.name
                    row.updateCell()
                    //业务人员列表清空
                    self.carModelList.removeAll()
                    self.carProValueList.removeAll()
                    guard let carModel = self.form.rowBy(tag: "carModel") as? SW_RedStarLabelRow else { return }
                    guard let carColor = self.form.rowBy(tag: "carColor") as? SW_RedStarLabelRow else { return }
                    carModel.value = ""
                    carColor.value = ""
                    self.reportModel.carModel = NormalModel()
                    self.reportModel.carColor = NormalModel()
                    carModel.updateCell()
                    carColor.updateCell()
                }
            }
        })
    }
    
    /// 显示汽车型号列表pickerview
    private func showCarModelListPicker() {
        guard carModelList.count > 0 else { return }
        guard let row = form.rowBy(tag: "carModel") as? SW_RedStarLabelRow else { return }
        BRStringPickerView.showStringPicker(withTitle: "车辆型号", on: MYWINDOW, dataSource: carModelList.map({ return $0.name }), defaultSelValue: row.value, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (selectValue) in
            let select = selectValue as? String ?? ""
            
            if self.reportModel.carModel.name != select {
                if let index = self.carModelList.index(where: { return $0.name == select}) {
                    self.reportModel.carModel = self.carModelList[index]
                    row.value = self.reportModel.carModel.name
                    row.updateCell()
                    //业务人员列表清空
                    self.carProValueList.removeAll()
                    guard let carColor = self.form.rowBy(tag: "carColor") as? SW_RedStarLabelRow else { return }
                    carColor.value = ""
                    self.reportModel.carColor = NormalModel()
                    carColor.updateCell()
                }
            }
        })
    }
    
    /// 显示车身颜色列表pickerview
    private func showCarProValueListPicker() {
        guard carProValueList.count > 0 else { return }
        guard let row = form.rowBy(tag: "carColor") as? SW_RedStarLabelRow else { return }
        BRStringPickerView.showStringPicker(withTitle: "车身颜色", on: MYWINDOW, dataSource: carProValueList.map({ return $0.name }), defaultSelValue: row.value, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (selectValue) in
            let select = selectValue as? String ?? ""
            
            if self.reportModel.carColor.name != select {
                if let index = self.carProValueList.index(where: { return $0.name == select}) {
                    self.reportModel.carColor = self.carProValueList[index]
                    row.value = self.reportModel.carColor.name
                    row.updateCell()
                }
            }
        })
    }
    
    /// 显示保险种类列表pickerview
    private func showInsuranceTypeListPicker(_ index: Int) {
        guard insuranceTypeList.count > 0 else { return }
        guard let row = form.rowBy(tag: "insuranceTypeName \(index)") as? SW_RedStarLabelRow else { return }
        BRStringPickerView.showStringPicker(withTitle: "保险种类", on: MYWINDOW, dataSource: insuranceTypeList.map({ return $0.name }), defaultSelValue: row.value, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (selectValue) in
            let select = selectValue as? String ?? ""
            
            if self.reportModel.insuranceTypes[index].insuranceTypeName != select {
                if let findIndex = self.insuranceTypeList.index(where: { return $0.name == select}) {
                    self.reportModel.insuranceTypes[index].insuranceTypeName = self.insuranceTypeList[findIndex].name
                    self.reportModel.insuranceTypes[index].insuranceTypeId = self.insuranceTypeList[findIndex].id
                    row.value = self.reportModel.insuranceTypes[index].insuranceTypeName
                    row.updateCell()
                }
            }
        })
    }
    
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
extension SW_EditDayOrderViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 49
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section > 2 ? 32 : 14
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
