//
//  SW_CreateCustomerViewController.swift
//  SWS
//
//  Created by jayway on 2018/11/14.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import Eureka

//customerTempType：临时客户归类 1:集团新客户 2:为集团客户，非本单位客户 3:本单位客户，非自己的客户 4:本单位客户并且是自己的客户
/// 临时客户归类
///
/// - none: 未选择手机号
/// - new: 集团新客户
/// - oldNotUnit: 为集团客户，非本单位客户
/// - unitNotMine: 本单位客户，非自己的客户
/// - mine: 本单位客户并且是自己的客户
enum TempCustomerType: Int {
    case none          = 0
    case new
    case oldNotUnit
    case unitNotMine
    case mine
}


class SW_CreateCustomerViewController: FormViewController {
    
    /// 临时客户id    跟客户id一样使用
    private var customerId: String = ""
    /// 输入框中的手机号，需要同步
    private var phoneNum = "" {
        didSet {
            /// 只要手机号改变，客户类型就还原
            if tempCustomerType != .none {
                tempCustomerType = .none
                customer = nil
                createTableView()
            }
        }
    }
    /// 根据手机号查询出来的客户信息，手机号改变时清空
    private var customer: SW_CustomerModel?
    /// 当前手机号查询出来的客户类型，根据这个type控制显示的row内容
    private var tempCustomerType: TempCustomerType = .none
    
    private var isRequesting = false
    /// 本地城市数据源
    private var dataSource: [Any] = {
        let bundle = Bundle(for: BRAddressPickerView.classForCoder())
        let url = bundle.url(forResource: "BRPickerView", withExtension: "bundle")
        let plistBundle = Bundle(url: url!)
        if let filePath = plistBundle?.path(forResource: "BRCity", ofType: "plist") {
            return NSArray(contentsOfFile: filePath) as! [Any]
        } else {
            return []
        }
    }()
 
    init(_ customerId: String) {
        super.init(nibName: nil, bundle: nil)
        self.customerId = customerId
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    /// 查询手机号客户信息
    private func queryCustomer(_ phoneNum: String) {
        guard  isPhoneNumber(phoneNum) else {
            showAlertMessage("请输入正确的手机号", view)
            return
        }
        
        SW_AddressBookService.queryCustomer(phoneNum).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.customer = SW_CustomerModel()
                self.customer?.id = json["customerId"].stringValue
                self.customer?.realName = json["customerName"].stringValue
                self.customer?.phoneNum = json["phoneNum"].stringValue
                self.customer?.staffName = json["staffName"].stringValue
                self.customer?.staffId = json["staffId"].intValue
                self.customer?.consultantInfoId = json["consultantInfoId"].intValue
                self.customer?.lastAccessDate = json["lastAccessDate"].doubleValue
                self.tempCustomerType = TempCustomerType(rawValue: json["customerTempType"].intValue) ?? .new
                self.dealPhoneRegionData(json["regionData"].stringValue)
                self.createTableView()
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
    }
    
    /// 处理电话查询归属地得到的地区数据，根据本地plist文件数据匹配、
    ///
    /// - Parameter regionData: 电话查询归属地得到的地区数据
    private func dealPhoneRegionData(_ regionData: String) {
        let regionArr = regionData.zzComponents(separatedBy: "-")
        if regionArr.count > 1 {
            for dict in self.dataSource {
                let dict = dict as! [String:Any]
                if (dict["name"] as! String) == regionArr[0] {
                    for dict1 in (dict["citylist"] as! [Any]) {
                        let dict1 = dict1 as! [String:Any]
                        if (dict1["name"] as! String) == regionArr[1] || (dict1["name"] as! String).contains(regionArr[1]) || regionArr[1].contains((dict1["name"] as! String)) {
                            customer?.province = (dict["name"] as! String)
                            customer?.city = (dict1["name"] as! String)
                        }
                    }
                }
            }
        }
    }
    
    /// 创建新客户
    private func createCustomer() {
        guard let customer = customer else { return }
        if tempCustomerType != .mine {
            
            if tempCustomerType == .new, customer.realName.isEmpty {
                showAlertMessage("请输入姓名", MYWINDOW)
                (form.rowBy(tag: "realName1") as? SW_CommenFieldRow)?.showErrorLine()
                (form.rowBy(tag: "core problem") as? SW_CommenTextViewRow)?.showErrorLine()
                return
            }
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
        }
        
        guard !isRequesting else { return }
        isRequesting = true
        QMUITips.showLoading("正在建档", in: self.view)
        SW_AddressBookService.createCustomer(customerId, customerTempType: tempCustomerType, phoneNum: phoneNum, customer: customer).response({ (json, isCache, error) in
            self.isRequesting = false
            QMUITips.hideAllTips(in: self.view)
            if let json = json as? JSON, error == nil {
                /// 新建客户成功  列表页面需要刷新
                NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadCreateCustomer, object: nil)
                
                let vc =  SW_CustomerDetailViewController(json["customerId"].stringValue, consultantInfoId: json["consultantInfoId"].intValue)
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
        })
    }
    
    /// 协助d接待
    private func assistingReception() {
        guard let customer = customer else { return }
        guard !isRequesting else { return }
        isRequesting = true
        SW_AddressBookService.assistingReception(customerId, customerTempType: tempCustomerType, customerId: customer.id).response({ (json, isCache, error) in
            self.isRequesting = false
            if let _ = json as? JSON, error == nil {
                /// 申请协助接待成功  列表页面需要刷新
                NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadCreateCustomer, object: nil)
                if self.presentingViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                } else if let index = self.navigationController?.viewControllers.index(where: { return $0 is SW_CustomerAddressBookViewController }) {
                    self.navigationController?.popToViewController(self.navigationController!.viewControllers[index], animated: true)
                }
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
        })
    }
    
    /// 申请调档
    private func applyCustomerChangeSave() {
        guard let customer = customer else { return }
        guard !isRequesting else { return }
        isRequesting = true
        SW_AddressBookService.applyCustomerChangeSave(customerId, customerTempType: tempCustomerType, customerId: customer.id).response({ (json, isCache, error) in
            self.isRequesting = false
            if let _ = json as? JSON, error == nil {
                /// 申请调档成功  列表页面需要刷新
                NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadCreateCustomer, object: nil)
                if self.presentingViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                } else if let index = self.navigationController?.viewControllers.index(where: { return $0 is SW_CustomerAddressBookViewController }) {
                    self.navigationController?.popToViewController(self.navigationController!.viewControllers[index], animated: true)
                }
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
        })
    }
    
    //MARK: - Action
    private func formConfig() {
//        navigationOptions = RowNavigationOptions.Enabled
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
        rowKeyboardSpacing = 89
        SW_CommenLabelRow.defaultCellUpdate = { (cell,row) in
            cell.selectionStyle = .none
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
                    view.title = "客户档案"
                }
                section.header = header
        }
        
            <<< SW_FieldButtonRow("phone number") {
                $0.rawTitle = NSLocalizedString("手机号", comment: "")
                $0.buttonTitle = "查 询"
                $0.value = self.phoneNum
                $0.limitCount = 11
                $0.enabledCount = 11
                $0.keyboardType = .numberPad
                $0.placeholder = "输入手机号"
                $0.buttonActionBlock = { [weak self] in
                    self?.queryCustomer(self?.phoneNum ?? "")
                }
                if customer == nil {
                    $0.cell.valueField.becomeFirstResponder()
                } else {
                    $0.cell.valueField.resignFirstResponder()
                }
                }.onChange { [weak self] in
                    self?.phoneNum = $0.value ?? ""
        }
        ////  查询后有customer 对象
        guard let customer = customer else { return }
        
        switch tempCustomerType {
        case .none: //0
            return
        case .new,.oldNotUnit:// 1, 2
            if tempCustomerType == .new {
                form.last!
                    <<< SW_CommenFieldRow("realName1") {
                        $0.rawTitle = NSLocalizedString("姓名", comment: "")
                        $0.value = customer.realName
                        $0.cell.valueField.keyboardType = .default
                        $0.cell.valueField.placeholder = "输入姓名"
                        $0.cell.valueField.becomeFirstResponder()
                        }.onChange { [weak self] in
                            self?.customer?.realName = $0.value ?? ""
                }
            } else {
                form.last!
                <<< SW_CommenLabelRow("realName2") {
                    $0.rawTitle = NSLocalizedString("姓名", comment: "")
                    $0.value = customer.realName
                    }
            }
            form.last!
                <<< SW_CustomerLevelChoiceRow("customer leve") {
                    $0.isShowOM = false
                    $0.value = customer.level
                    }.onChange { [weak self] in
                        self?.customer?.level = $0.value ?? .none
                        $0.reload()
                }
                
                <<< SW_CustomerSourceRow("Customer source") { (row) in
                    row.value = customer.customerSource
                    row.site = customer.customerSourceSite
                    row.sourceBtnClickBlock = { [weak row, weak self] in
                        self?.view.endEditing(true)
                        BRStringPickerView.showStringPicker(withTitle: "客户来源", on: MYWINDOW, dataSource: ["网络/电话","来店","走访","外拓","车展","转介绍","其他"], defaultSelValue: row?.value?.rawString ?? "", isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { [weak self] (selectValue) in
                            let select = CustomerSource(selectValue as! String)
                            self?.customer?.customerSource = select
                            row?.site = self?.customer?.customerSourceSite ?? .none
                            row?.value = select
                            row?.cell.setupState()
                        })
                    }
                    row.siteBtnClickBlock = { [weak row, weak self] in
                        self?.view.endEditing(true)
                        BRStringPickerView.showStringPicker(withTitle: "来源网站", on: MYWINDOW, dataSource: ["懂车帝","400","好车网","易车网","汽车之家","爱卡汽车网","太平洋汽车网","其他网站"], defaultSelValue: row?.site.rawString ?? "", isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { [weak self] (selectValue) in
                            let select =  CustomerSourceSite(selectValue as! String)
                            self?.customer?.customerSourceSite = select
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
                        BRAddressPickerView.showAddressPicker(withShowType: BRAddressPickerMode.init(rawValue: 2)!, title: nil, dataSource: self.dataSource, defaultSelected: [customer.province,customer.city,""], isAutoSelect: false, themeColor: UIColor.v2Color.blue, resultBlock: { (province, city, area) in
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
                            self?.customer?.likeCarBrand = brand.name
                            self?.customer?.likeCarBrandId = brand.id
                            self?.customer?.likeCarSeries = series.name
                            self?.customer?.likeCarModel = model.name
                            row.value = self?.customer?.likeCar
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
                        self?.customer?.keyProblem = $0.value ?? ""
            }
            
            form
                +++
                Section() { [weak self] section in
                    var header = HeaderFooterView<SW_ArchiveButtonView>(.nibFile(name: "SW_ArchiveButtonView", bundle: nil))
                    header.height = {80}
                    header.onSetupView = { view, _ in
                        view.leftConstraint.constant = 15
                        view.rightConstraint.constant = 15
                        view.button.layer.borderWidth = 0
                        view.button.setTitle("建 档", for: UIControl.State())
                        
                        view.button.setBackgroundImage(UIImage(color: UIColor.v2Color.blue), for: UIControl.State())
                        view.button.setBackgroundImage(UIImage(color: UIColor(hexString: "#267cc4")), for: .highlighted)
                        view.button.setTitleColor(UIColor.white, for: UIControl.State())
                        view.button.titleLabel?.font = Font(16)
                        view.actionBlock = {
                            /// 调用归档接口
                            self?.createCustomer()
                        }
                    }
                    section.header = header
            }
            
        case .unitNotMine,.mine:// 3  4
            form.last!
                <<< SW_CommenLabelRow("realName3") {
                    $0.rawTitle = NSLocalizedString("姓名", comment: "")
                    $0.value = customer.realName
                    }
            
                <<< SW_CommenLabelRow("staffName") {
                    $0.rawTitle = NSLocalizedString("销售顾问", comment: "")
                    $0.value = customer.staffName
                    }
            
                <<< SW_CommenLabelRow("lastAccessDate") {
                    $0.rawTitle = NSLocalizedString("最近接访", comment: "")
                    $0.value = customer.lastAccessDateString
                }
            
            if tempCustomerType == .unitNotMine {// o同单位，但不是我z的客户
                
                form
                    +++
                    Section() { [weak self] section in
                        var header = HeaderFooterView<SW_TwoButtonView>(.nibFile(name: "SW_TwoButtonView", bundle: nil))
                        header.height = {100}
                        header.onSetupView = { view, _ in
                            view.setupLeft("协助接待", action: {
                                self?.assistingReception()
                            })
                            
                            view.setupRight("申请调档", action: {
                                self?.applyCustomerChangeSave()
                            })
                        }
                        section.header = header
                }
                
            } else {//// 我自己的客户，进行归档
                form
                    +++
                    Section() { [weak self] section in
                        var header = HeaderFooterView<SW_ArchiveButtonView>(.nibFile(name: "SW_ArchiveButtonView", bundle: nil))
                        header.height = {80}
                        header.onSetupView = { view, _ in
                            view.leftConstraint.constant = 15
                            view.rightConstraint.constant = 15
                            view.button.layer.borderWidth = 0
                            view.button.setTitle("归 档", for: UIControl.State())
                            view.button.setBackgroundImage(UIImage(color: UIColor.v2Color.blue), for: UIControl.State())
                            view.button.setBackgroundImage(UIImage(color: UIColor(hexString: "#267cc4")), for: .highlighted)
                            view.button.setTitleColor(UIColor.white, for: UIControl.State())
                            view.button.titleLabel?.font = Font(16)
                            view.actionBlock = {
                                /// 调用归档接口
                                self?.createCustomer()
                            }
                        }
                        section.header = header
                }
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
