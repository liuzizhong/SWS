//
//  SW_EditCustomerInfoViewController.swift
//  SWS
//
//  Created by jayway on 2018/8/16.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_EditCustomerInfoViewController: FormViewController {
    
    private var customer: SW_CustomerModel!
    
    private var isRequesting = false
    
    var progressView: SW_ProgressView = {
        let view = Bundle.main.loadNibNamed("SW_ProgressView", owner: nil, options: nil)?.first as! SW_ProgressView
        return view
    }()
    
    /// 汽车颜色列表
    private var carProValueList = [NormalModel]()
    /// 汽车内饰颜色列表
    private var carUpholsteryValueList = [NormalModel]()
    
    init(_ customer: SW_CustomerModel) {
        super.init(nibName: nil, bundle: nil)
        self.customer = customer.copy() as? SW_CustomerModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formConfig()
        createTableView()
        tableView.reloadAndFadeAnimation()
    }
    
    deinit {
        removeObserve(customer)
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

        view.backgroundColor = .white
        tableView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 30, right: 0)
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        tableView.separatorColor = UIColor.mainColor.separator
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        rowKeyboardSpacing = 89
        view.addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
//        progressView.setProgress(Float(customer.dataPercentage) / 100.0, animated: true)
        observe(customer, keyPath: #keyPath(SW_CustomerModel.dataPercentage)) { [weak self] (observer, old, new) in
            self?.progressView.setProgress(Float(new as! Int) / 100.0, animated: true)
        }
        
        navigationItem.title = NSLocalizedString("客户意向信息", comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(backAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(commitAction(_:)))
        
        SW_CommenLabelRow.defaultCellUpdate = { (cell, row) in
            cell.selectionStyle = .default
        }
    }
    
    
    private func createTableView() {
        
        form = Form()
            +++
            Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = "必填信息"
                }
                section.header = header
            }
            
            <<< SW_CustomerLevelChoiceRow("customer leve") {
                $0.isShowOM = true
                $0.value = customer.level
                }.onChange { [weak self] in
                    self?.customer.level = $0.value ?? .none
                    $0.reload()
            }
        
            <<< SW_CustomerSourceRow("Customer source") { (row) in
                row.value = customer.customerSource
                row.site = customer.customerSourceSite
                row.sourceBtnClickBlock = { [weak row, weak self] in
                    self?.view.endEditing(true)
                    BRStringPickerView.showStringPicker(withTitle: "客户来源", on: MYWINDOW, dataSource: ["网络/电话","来店","走访","外拓","车展","转介绍","其他"], defaultSelValue: row?.value?.rawString ?? "", isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { [weak self] (selectValue) in
                        let select = CustomerSource(selectValue as! String)
                        self?.customer.customerSource = select
                        row?.site = self?.customer?.customerSourceSite ?? .none
                        row?.value = select
                        row?.cell.setupState()
                    })
                }
                row.siteBtnClickBlock = { [weak row, weak self] in
                    self?.view.endEditing(true)
                    BRStringPickerView.showStringPicker(withTitle: "来源网站", on: MYWINDOW, dataSource: ["懂车帝","400","好车网","易车网","汽车之家","爱卡汽车网","太平洋汽车网","其他网站"], defaultSelValue: row?.site.rawString ?? "", isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { [weak self] (selectValue) in
                        let select =  CustomerSourceSite(selectValue as! String)
                        self?.customer.customerSourceSite = select
                        row?.site = select
                        row?.cell.setupState()
                    })
                }
                }.onCellSelection({ (cell, row) in
                    row.deselect()
                }).onChange({ (row) in
                    if row.value == .networkPhone {
                        row.siteBtnClickBlock?()
                    }
                })
            
            
            <<< SW_CommenLabelRow("In the area") {
                $0.rawTitle = NSLocalizedString("所在地区", comment: "")
                $0.value = customer.city.isEmpty ? customer.province : "\(customer.province)-\(customer.city)"
                $0.cell.placeholder = "选择客户所在地区"
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    guard let self = self else { return }
                    self.view.endEditing(true)
                    BRAddressPickerView.showAddressPicker(withShowType: BRAddressPickerMode.init(rawValue: 2)!, title: nil, dataSource: [], defaultSelected: [self.customer.province,self.customer.city,""], isAutoSelect: false, themeColor: UIColor.v2Color.blue, resultBlock: { (province, city, area) in
                        self.customer?.province = province?.name ?? ""
                        self.customer?.city = city?.name ?? ""
                        row.value = self.customer!.city.isEmpty ? "" : "\(self.customer!.province)-\(self.customer!.city)"
                        row.updateCell()
                    }, cancel: nil)
                })

            <<< SW_CommenLabelRow("Interested models") {
                $0.rawTitle = NSLocalizedString("意向车型", comment: "")
                $0.value = customer.likeCar == "  " ? "" : customer.likeCar
                $0.cell.placeholder = "点击选择意向车型"
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    self?.navigationController?.pushViewController(SW_SelectCarModelViewController(.unit, successBlock: { (brand, series, model) in
                        /// 更换了厂牌 清空喜欢颜色和内饰颜色
                        if self?.customer?.likeCarBrandId != brand.id {
                            self?.customer?.likeCarBrandId = brand.id
                            self?.carProValueList.removeAll()
                            self?.carUpholsteryValueList.removeAll()
                            if let likeCarColor = self?.form.rowBy(tag: "likeCarColor") as? SW_CommenLabelRow  {
                                self?.customer.likeCarColor = ""
                                likeCarColor.value = ""
                                likeCarColor.updateCell()
                            }
                            if let interiorColor = self?.form.rowBy(tag: "Interior trim tastes") as? SW_CommenLabelRow  {
                                self?.customer.interiorColor = ""
                                interiorColor.value = ""
                                interiorColor.updateCell()
                            }
                        }
                        self?.customer.likeCarBrand = brand.name
                        self?.customer.likeCarSeries = series.name
                        self?.customer.likeCarModel = model.name
                        row.value = self?.customer.likeCar
                        row.updateCell()
                    }, saleState: true), animated: true)
                })

            <<< SW_CommenTextViewRow("core problem")  {
                $0.placeholder = "请填写客户特征或核心问题等信息"
                $0.maximumTextLength = 200
                $0.value = customer.keyProblem
                $0.rawTitle = "核心问题"
                $0.textViewHeightChangeBlock = { [weak self] (textViewHeight) in
                    self?.form.rowBy(tag: "core problem")?.reload()
                }
                }.onChange { [weak self] in
                    self?.customer.keyProblem = $0.value ?? ""
        }

            form
            +++
                Section() { section in
                    var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                    header.height = {70}
                    header.onSetupView = { view, _ in
                        view.title = "选填信息"
                    }
                    section.header = header
                }

                <<< SW_CommenLabelRow("Compare the models") {
                    $0.rawTitle = NSLocalizedString("对比车型", comment: "")
                    $0.value = customer.contrastCar == " " ? "" : customer.contrastCar
                    $0.cell.placeholder = "点击选择对比车型"
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        self?.navigationController?.pushViewController(SW_SelectCarModelViewController(.all, successBlock: { (brand, series, model) in
                            self?.customer.contrastCarBrand = brand.name
                            self?.customer.contrastCarSeries = series.name
//                            self?.customer.contrastCarModel = model.name
                            row.value = self?.customer.contrastCar
                            row.updateCell()
                        }, isFinishBySeries: true), animated: true)
                    })

                <<< SW_CommenLabelRow("Shopping time") {
                    $0.rawTitle = NSLocalizedString("购车时间", comment: "")
                    $0.value = customer.buyDate == 0 ? "" : Date.dateWith(timeInterval: customer.buyDate).simpleTimeString(formatter: .year)
                    $0.cell.placeholder = "点击选择购车时间"
                    }.onCellSelection({ (cell, row) in
                        row.deselect()
                        let currentDate = Date()
                        var selectValue = Date.dateWith(formatStr: "yyyy-MM-dd", dateString: row.value ?? "") ?? currentDate
                        if selectValue < currentDate {
                            selectValue = currentDate
                        }
                        BRDatePickerView.showDatePicker(withTitle: "购车时间", on: MYWINDOW, dateType: BRDatePickerMode.init(rawValue: 6)!, defaultSelValue: selectValue, minDate: currentDate, maxDate: nil, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (key) in
                            row.value = key
                            row.updateCell()
                        }, cancel: nil)
                    }).onChange { [weak self] in
                        self?.customer.buyDate = $0.value?.toTimeInterval(formatStr: "yyyy-MM-dd") ?? 0
                }
                
                <<< SW_CarBudgetRow("Car budget") { (row) in
                    row.value = customer.buyBudget == 0 ? "" : "\(customer.buyBudget)"
                    row.buyWay = customer.buyWay
                    row.count = customer.buyCount
                    row.buyWayChangeBlock = { [weak self] (buyway) in
                        self?.customer.buyWay = buyway
                    }
                    row.buyCountChangeBlock = { [weak self] (buycount) in
                        self?.customer.buyCount = buycount
                    }
                    }.onChange { [weak self] in
                        self?.customer.buyBudget = Int($0.value ?? "0") ?? 0
                }

                ////TODO: 新增属性
                <<< SW_CommenLabelRow("likeCarColor") {
                    $0.rawTitle = NSLocalizedString("外色喜好", comment: "")
                    $0.value = customer.likeCarColor
                    $0.cell.placeholder = "点击选择外色喜好"
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        ///必须先选择意向车型
                        if self?.customer.likeCarBrandId.isEmpty == true {
                            showAlertMessage("请选择意向车型", MYWINDOW)
                            return
                        }
                        if self!.carProValueList.count > 0 {
                            self?.showCarProValueListPicker()
                        } else {
                            SW_WorkingService.getCarProValue(self?.customer.likeCarBrandId ?? "").response({ (json, isCache, error) in
                                if let json = json as? JSON, error == nil {
                                    self?.carProValueList = json["list"].arrayValue.map({ return NormalModel($0) })
                                    self?.showCarProValueListPicker()
                                } else {
                                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                                }
                            })
                        }
                    })
                
                <<< SW_CommenLabelRow("Interior trim tastes") {
                    $0.rawTitle = NSLocalizedString("内饰喜好", comment: "")
                    $0.value = customer.interiorColor
                    $0.cell.placeholder = "点击选择内饰喜好"
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        ///必须先选择意向车型
                        if self?.customer.likeCarBrandId.isEmpty == true {
                            showAlertMessage("请选择意向车型", MYWINDOW)
                            return
                        }
                        if self!.carUpholsteryValueList.count > 0 {
                            self?.showCarUpholsteryValueListPicker()
                        } else {
                            SW_WorkingService.getCarUpholsteryValue(self?.customer.likeCarBrandId ?? "").response({ (json, isCache, error) in
                                if let json = json as? JSON, error == nil {
                                    self?.carUpholsteryValueList = json["list"].arrayValue.map({ return NormalModel($0) })
                                    self?.showCarUpholsteryValueListPicker()
                                } else {
                                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                                }
                            })
                        }
                    })

                <<< SW_CommenLabelRow("main purpose") {
                    $0.rawTitle = NSLocalizedString("主要用途", comment: "")
                    $0.value = customer.useFor.rawString
                    $0.cell.placeholder = "点击选择主要用途"
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        BRStringPickerView.showStringPicker(withTitle: "主要用途", on: MYWINDOW, dataSource: ["商务接待","办公","代步","旅行","普通家用"], defaultSelValue: row.value, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (selectValue) in
                            let select = selectValue as? String ?? ""
                            self?.customer.useFor = UseforType(select)
                            row.value = select
                            row.updateCell()
                        })
                    })

                <<< SW_CarUserRow("The user") {
                    $0.value = customer.carUser
                    $0.sex = customer.userSex
                    $0.sexChangeBlock = { [weak self] (sex) in
                        self?.customer.userSex = sex
                    }
                    }.onChange { [weak self] in
                        self?.customer.carUser = $0.value ?? ""
                }

                <<< SW_CommenLabelRow("Existing models") {
                    $0.rawTitle = NSLocalizedString("现有车型", comment: "")
                    $0.value = customer.havedCar == " " ? "" : customer.havedCar
                    $0.cell.placeholder = "点击选择现有车型"
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        self?.navigationController?.pushViewController(SW_SelectCarModelViewController(.all, successBlock: { (brand, series, model) in
                            self?.customer.havedCarBrand = brand.name
                            self?.customer.havedCarSeries = series.name
//                            self?.customer.havedCarModel = model.name
                            row.value = self?.customer.havedCar
                            row.updateCell()
                        }, isFinishBySeries: true), animated: true)
                    })

                <<< SW_SingleChoiceRow("Car type") {
                    $0.rawTitle = NSLocalizedString("购车类型", comment: "")
                    $0.value = customer.buyType.rawString
                    $0.allOptions = ["初购","增购","换购"]
                    }.onChange { [weak self] in
                        self?.customer.buyType = BuyType($0.value ?? "")
                        let row = self?.form.rowBy(tag: "Replacement model")
                        row?.baseCell.isHidden = self?.customer.buyType != .replace
                        row?.updateCell()
                }
                
                <<< SW_CommenLabelRow("Replacement model") {
                    $0.rawTitle = NSLocalizedString("置换车型", comment: "")
                    $0.cell.placeholder = "点击选择置换车型"
                    $0.value = customer.replaceCar == " " ? "" : customer.replaceCar
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        self?.navigationController?.pushViewController(SW_SelectCarModelViewController(.all, successBlock: { (brand, series, model) in
                            self?.customer.replaceCarBrand = brand.name
                            self?.customer.replaceCarSeries = series.name
//                            self?.customer.replaceCarModel = model.name
                            row.value = self?.customer.replaceCar
                            row.updateCell()
                        }, isFinishBySeries: true), animated: true)
                    }).cellUpdate({ [weak self] (cell, row) in
                        row.value = self?.customer.replaceCar == " " ? "" : self?.customer.replaceCar
                    })
        
        if customer.buyType != .replace {
            form.rowBy(tag: "Replacement model")?.baseCell.isHidden = true
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    /// 显示车身颜色列表pickerview
    private func showCarProValueListPicker() {
        guard carProValueList.count > 0 else { return }
        guard let row = form.rowBy(tag: "likeCarColor") as? SW_CommenLabelRow else { return }
        BRStringPickerView.showStringPicker(withTitle: "外色喜好", on: MYWINDOW, dataSource: carProValueList.map({ return $0.name }), defaultSelValue: row.value, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (selectValue) in
            let select = selectValue as? String ?? ""
            
            if self.customer.likeCarColor != select {
                self.customer.likeCarColor = select
                row.value = self.customer.likeCarColor
                row.updateCell()
            }
        })
    }
    
    /// 显示车身内饰颜色列表pickerview
    private func showCarUpholsteryValueListPicker() {
        guard carUpholsteryValueList.count > 0 else { return }
        guard let row = form.rowBy(tag: "Interior trim tastes") as? SW_CommenLabelRow else { return }
        BRStringPickerView.showStringPicker(withTitle: "内饰喜好", on: MYWINDOW, dataSource: carUpholsteryValueList.map({ return $0.name }), defaultSelValue: row.value, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (selectValue) in
            let select = selectValue as? String ?? ""
            
            if self.customer.interiorColor != select {
                self.customer.interiorColor = select
                row.value = self.customer.interiorColor
                row.updateCell()
            }
        })
    }
    
    @objc private func commitAction(_ sender: UIButton) {
        if customer.level == .none {
            showAlertMessage("请选择客户级别", MYWINDOW)
            return
        }
        if customer.customerSource == .none {
            showAlertMessage("请选择客户来源", MYWINDOW)
            return
        }
        if customer.customerSource == .networkPhone,customer.customerSourceSite == .none  {
            showAlertMessage("请选择来源网站", MYWINDOW)
            return
        }
        if customer.likeCar == "  " {
            showAlertMessage("请选择意向车型", MYWINDOW)
            return
        }
        if customer.keyProblem.isEmpty {
            showAlertMessage("请输入核心问题", MYWINDOW)
            (form.rowBy(tag: "core problem") as? SW_CommenTextViewRow)?.showErrorLine()
            return
        }
        
        guard !isRequesting else { return }
        isRequesting = true
        QMUITips.showLoading("正在保存", in: self.view)
        /// 如果到这里说明该填的都填了。  --提交修改客户意向 ----
        SW_AddressBookService.saveCustomerIntention(customer).response({ (json, isCache, error) in
            self.isRequesting = false
            QMUITips.hideAllTips(in: self.view)
            if let _ = json as? JSON, error == nil {
                NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadEditCustomerIntention, object: nil, userInfo: ["customerId": self.customer.id, "level": self.customer.level, "dataPercentage": self.customer.dataPercentage])
                    showAlertMessage("保存成功", MYWINDOW)
                    self.navigationController?.popViewController(animated: true)
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
        })
    }
    
    @objc private func backAction() {
        alertControllerShow(title: "您确定取消编辑此意向信息吗？", message: nil, rightTitle: "确 定", rightBlock: { (controller, action) in
            self.navigationController?.popViewController(animated: true)
        }, leftTitle: "取 消", leftBlock: nil)
    }
}

extension SW_EditCustomerInfoViewController {
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
