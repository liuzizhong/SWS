//
//  SW_AfterSaleCustomerDetailViewController.swift
//  SWS
//
//  Created by jayway on 2019/2/25.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

/// 当前显示界面数据
///
/// - access: 接访记录
/// - repairOrder: 维修记录
enum AfterSaleCustomerRecordType {
    case access
    case repairOrder
}

class SW_AfterSaleCustomerDetailViewController: FormViewController {
    
    private var type: AfterSaleCustomerRecordType = .access {
        didSet {
            if type != oldValue {
                createTableView()
            }
        }
    }
    
    private var staffList = [SW_AddressBookModel]()

    private var customer = SW_AfterSaleCustomerModel()
    
    private var customerId: String = ""
    private var repairOrderId: String = ""
    private var vin: String = ""
    private var bUnitId: Int = 0
    
    lazy var rightBtn: UIBarButtonItem = {
        let btn = QMUIButton(type: .custom)
        btn.setImage(UIImage(named: "personalcenter_icon_more"), for: UIControl.State())
        btn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btn.addTarget(self, action: #selector(moreAction(_:)), for: .touchUpInside)
        let barbtn = UIBarButtonItem(customView: btn)
        return barbtn
    }()

    
    init(_ customerId: String, repairOrderId: String, vin: String, bUnitId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.customerId = customerId
        self.repairOrderId = repairOrderId
        self.vin = vin
        self.bUnitId = bUnitId
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// 进入详情页如果有新建客户页面 则去除
//        navigationController?.removeViewController([SW_TempCustomerDetailViewController.self,SW_CreateCustomerViewController.self])
        formConfig()
        getCustomerInfo()
        setupNotification()
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
    
    private func setupNotification() {
        /// 添加了访问记录 刷新页面
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadAddAccessRecord, object: nil, queue: nil) { [weak self] (notifa) in
            let id = notifa.userInfo?["customerId"] as! String
            if id == self?.customerId {
                self?.getAccessCustomerRecordList()
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadHandleComplaints, object: nil, queue: nil) { [weak self] (notifa) in
            let type = notifa.userInfo?["complaintType"] as! HandleComplaintType
            let orderId = notifa.userInfo?["orderId"] as! String
            
            if type == .repairOrder, let index = self?.customer.repairOrderRecordDatas.firstIndex(where: { return $0.repairOrderId == orderId }), index < 2 {
                guard let row = self?.form.rowBy(tag: "repairOrder Record \(index)") as? SW_AccessRecordListRow else {
                    return
                }
                self?.customer.repairOrderRecordDatas[index].complaintState = .waitAudit
                row.cell.complaintState = .waitAudit
                row.updateCell()
            }
        }
    }
    
    //获取客户信息刷新页面
    fileprivate func getCustomerInfo() {
        SW_AfterSaleService.getCustomerDetail(repairOrderId, customerId: customerId, vin: vin, bUnitId: bUnitId).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.customer = SW_AfterSaleCustomerModel(json)
                self.navigationItem.rightBarButtonItem = self.rightBtn
                self.createTableView()
            } else {
                if let json = json as? JSON, json["code"].intValue == 2 {
                    NotificationCenter.default.post(name: NSNotification.Name.Ex.CustomerHadBeenChange, object: nil, userInfo: ["customerId": self.customerId])
                    
                    SW_UserCenter.shared.showAlert(message: json["msg"].stringValue, str: "确定", action: { (_) in
                        self.navigationController?.popViewController(animated: true)
                    })
                    
                } else {
                    self.navigationController?.popViewController(animated: true)
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                }
            }
        })
        
    }
    
    private func getAccessCustomerRecordList() {
        SW_AfterSaleService.getAfterSaleVisitRecordList(repairOrderId, customerId: customerId, max: 2).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.customer.recordDatas = json["list"].arrayValue.map({ (value) -> SW_AfterSaleAccessRecordListModel in
                    return SW_AfterSaleAccessRecordListModel(value)
                })
                self.customer.recordTotalCount = json["count"].intValue
                self.createTableView()
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
    }
    
    //MARK: - Action
    private func formConfig() {
        navigationOptions = RowNavigationOptions.Enabled
        view.backgroundColor = .white
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_HEIGHT, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = false
        }
        tableView.ly_emptyView = SW_LoadingEmptyView.creat()
        tableView.ly_emptyView.contentViewOffset = -(SCREEN_HEIGHT - 250) * 0.1
        SW_StaffInfoRow.defaultCellSetup = { (cell, row) in
            cell.selectionStyle = .none
            cell.titleLb.textColor = UIColor.v2Color.darkGray
            cell.valueLb.textColor = UIColor.v2Color.darkBlack
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_back").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popSelf))
    }
    
    private func createTableView() {
        
        form = Form()
            +++
            Eureka.Section()
            <<< SW_AfterSaleCustomerInfoRow("SW_AfterSaleCustomerInfoRow") {
                $0.value = customer
        }

            <<< SW_AfterSaleCustomerRecordHeaderRow("SW_AfterSaleCustomerRecordHeaderRow") { [weak self] in
                $0.typeChangeBlock = { (infoType) in
                    self?.type = infoType
                }
                $0.moreBlock = { [weak self] in
                    guard let self = self else { return }
                        PrintLog("more")
                    let vc = SW_AfterSaleAccessRecordViewController(type: self.type, vin: self.customer.vin, repairOrderId: self.repairOrderId, customerId: self.customerId, isConstruction: false)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                $0.value = self?.type
        }
        if type == .access {
            if customer.recordDatas.count > 0 {
                let showCount = min(customer.recordDatas.count, 2)
                for index in 0..<showCount {
                    form.last!
                        <<< SW_AccessRecordListRow("AfterAccess Record \(index)") {
                            $0.afterSaleRecord = customer.recordDatas[index]
                            $0.cell.indexLabel.text = "\(customer.recordTotalCount - index)"
                            $0.cell.bottomLine.isHidden = index == customer.recordTotalCount - 1
                            $0.cell.topLine.isHidden = index == 0
                            $0.cell.moreImageView.isHidden = !(index == 1 && customer.recordTotalCount > 2)
                            }.onCellSelection({ [weak self] (cell, row) in
                                row.deselect()
                                guard let self = self else { return }
                                let model = self.customer.recordDatas[index]
                                self.navigationController?.pushViewController(SW_AccessRecordDetailViewController.creatVc(model.id, type: .afterSale), animated: true)
                            })
                }
            } else {
                form.last!
                    <<< SW_NoCommenRow("No AfterAccess Record") {
                        $0.cell.tipLabel.text = "暂无数据"
                        $0.cell.heightConstraint.constant = 80
                }
            }
        
        } else {
            if customer.repairOrderRecordDatas.count > 0 {
                let showCount = min(customer.repairOrderRecordDatas.count, 2)
                for index in 0..<showCount {
                    form.last!
                        <<< SW_AccessRecordListRow("repairOrder Record \(index)") {
                            $0.repairOrderRecord = customer.repairOrderRecordDatas[index]
                            $0.cell.indexLabel.text = "\(customer.repairOrderRecordTotalCount - index)"
                            $0.cell.bottomLine.isHidden = index == customer.repairOrderRecordTotalCount - 1
                            $0.cell.topLine.isHidden = index == 0
                            $0.cell.moreImageView.isHidden = !(index == 1 && customer.repairOrderRecordTotalCount > 2)
                            }.onCellSelection({ [weak self] (cell, row) in
                                row.deselect()
                                guard let self = self else { return }
                                let model = self.customer.repairOrderRecordDatas[index]
                                self.navigationController?.pushViewController(SW_RepairOrderRecordDetailViewController.creatVc(model.repairOrderId, isConstruction: false), animated: true)
                            })
                }
            } else {
                form.last!
                    <<< SW_NoCommenRow("No repairOrder Record") {
                        $0.cell.tipLabel.text = "暂无数据"
                        $0.cell.heightConstraint.constant = 80
                }
            }
            
        }
        
        form
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<SW_CustomerSectionHeaderView>(.nibFile(name: "SW_CustomerSectionHeaderView", bundle: nil))
                header.onSetupView = { view, _ in
                    /// 点击编辑按钮
                    view.setup("客户信息", btnName: "")
                    view.editBtn.isHidden = true
                }
                section.header = header
            }

            <<< SW_StaffInfoRow("vin") {
                $0.rowTitle = NSLocalizedString("车  架  号   ", comment: "")
                $0.isShowBottom = false
                $0.value = customer.vin
            }
            <<< SW_StaffInfoRow("carModel") {
                $0.rowTitle = NSLocalizedString("车       型   ", comment: "")
                $0.isShowBottom = false
                $0.value = customer.carBrand + "   " + customer.carSeries + "   " + customer.carModel
            }
            <<< SW_StaffInfoRow("carColor") {
                $0.rowTitle = NSLocalizedString("车身颜色   ", comment: "")
                $0.isShowBottom = false
                $0.value = customer.carColor
            }
            <<< SW_StaffInfoRow("upholsteryColor") {
                $0.rowTitle = NSLocalizedString("内饰颜色   ", comment: "")
                $0.isShowBottom = false
                $0.value = customer.upholsteryColor
            }
            <<< SW_StaffInfoRow("mileage") {
                $0.rowTitle = NSLocalizedString("里  程  数   ", comment: "")
                $0.isShowBottom = false
                $0.value = "\(customer.mileage)km"
            }
            <<< SW_StaffInfoRow("buyCarDate") {
                $0.rowTitle = NSLocalizedString("购车时间   ", comment: "")
                $0.isShowBottom = false
                $0.value = customer.buyCarDate == 0 ? "" : Date.dateWith(timeInterval: customer.buyCarDate).simpleTimeString(formatter: .year)
        }
        
        tableView.reloadData()
    }
    
    //MARK: - FormViewControllerProtocol   重写一下方法是因为需要去除该库添加时的动画
    override func sectionsHaveBeenAdded(_ sections: [Section], at indexes: IndexSet) {
        
    }
    
    override func rowsHaveBeenAdded(_ rows: [BaseRow], at indexes: [IndexPath]) {
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? CGFloat.leastNormalMagnitude : 70
    }
    
    
    @objc private func moreAction(_ sender: UIBarButtonItem) {
        let sheetW = isIPad ? 270 : SCREEN_WIDTH
        
        let actionSheet = QMUIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        /// 添加action
        let phoneAction = QMUIAlertAction(title: "电话", style: .default) { (alertController, action) in
            if !self.customer.phoneNum.isEmpty {
                UIApplication.shared.open(scheme: "tel://\(self.customer.phoneNum)")//
            }
        }
        phoneAction.button.setImage(UIImage(named: "personalcenter_icon_phone"), for: UIControl.State())
        
        phoneAction.button.spacingBetweenImageAndTitle = sheetW - 100
        phoneAction.button.imagePosition = .right
        actionSheet.addAction(phoneAction)
        
        let msgAction = QMUIAlertAction(title: "消息", style: .default) { (alertController, action) in
            if !self.customer.phoneNum.isEmpty {
                UIApplication.shared.open(scheme: "sms://\(self.customer.phoneNum)")//
            }
        }
        msgAction.button.setImage(UIImage(named: "personalcenter_icon_messages"), for: UIControl.State())
        msgAction.button.spacingBetweenImageAndTitle = sheetW - 100
        msgAction.button.imagePosition = .right
        actionSheet.addAction(msgAction)
        
        let addRecordAction = QMUIAlertAction(title: "添加接访记录", style: .default) { (alertController, action) in
            self.navigationController?.pushViewController(SW_AfterSaleAddAccessRecordViewController(self.customerId, repairOrderId: self.repairOrderId), animated: true)
        }
        addRecordAction.button.setImage(UIImage(named: "personalcenter_icon_record"), for: UIControl.State())
        addRecordAction.button.spacingBetweenImageAndTitle = sheetW - 166
        addRecordAction.button.imagePosition = .right
        actionSheet.addAction(addRecordAction)
        
        let changeAction = QMUIAlertAction(title: "更换售后顾问", style: .default) { [weak self] (alertController, action) in
            if self!.staffList.count > 0 {
                self?.showStaffListPicker()
            } else {
                SW_AfterSaleService.getAfterSaleList().response({ (json, isCache, error) in
                    if let json = json as? JSON, error == nil {
                        self?.staffList = json["list"].arrayValue.map({ (jsonValue) -> SW_AddressBookModel in
                            let model = SW_AddressBookModel()
                            model.realName = jsonValue["name"].stringValue
                            model.id = jsonValue["id"].intValue
                            return model
                        })
                        self?.showStaffListPicker()
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                    }
                })
            }
        }
        changeAction.button.setImage(UIImage(named: "personalcenter_icon_change"), for: UIControl.State())
        changeAction.button.spacingBetweenImageAndTitle = sheetW - 166
        changeAction.button.imagePosition = .right
//        changeAction.isEnabled = customer.accessStartDate == 0
        actionSheet.addAction(changeAction)
        
        if !isIPad {
            actionSheet.addCancelAction()
        }
        // 样式设置
        var buttonAttributes = actionSheet.sheetButtonAttributes
        buttonAttributes?[NSAttributedString.Key.foregroundColor] = UIColor.v2Color.blue
        buttonAttributes?[NSAttributedString.Key.font] = Font(16)
        actionSheet.sheetButtonAttributes = buttonAttributes
        changeAction.buttonAttributes = buttonAttributes
        addRecordAction.buttonAttributes = buttonAttributes
        
        msgAction.buttonAttributes = buttonAttributes
        phoneAction.buttonAttributes = buttonAttributes
        
        var buttonDisabledAttributes = actionSheet.sheetButtonDisabledAttributes
        buttonDisabledAttributes?[NSAttributedString.Key.foregroundColor] = UIColor.v2Color.disable
        buttonDisabledAttributes?[NSAttributedString.Key.font] = Font(16)
        actionSheet.sheetButtonDisabledAttributes = buttonDisabledAttributes
        
        var cancelAttributs = actionSheet.sheetCancelButtonAttributes
        cancelAttributs?[NSAttributedString.Key.foregroundColor] = UIColor.v2Color.blue
        cancelAttributs?[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 16)
        actionSheet.sheetCancelButtonAttributes = cancelAttributs
        
        actionSheet.showWith(animated: true)
    }
    
    @objc func popSelf() {
        if self.presentingViewController != nil {
            dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    /// 显示售后人员pickerview
    private func showStaffListPicker() {
        guard staffList.count > 0 else {
            showAlertMessage("没有其他售后顾问", MYWINDOW)
            return
        }
        BRStringPickerView.showStringPicker(withTitle: "选择售后顾问", on: MYWINDOW, dataSource: staffList.map({ return $0.realName }), defaultSelValue: "", isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (selectValue) in
            
            
            alertControllerShow(title: "你确定将此客户转移给\(selectValue!)吗？", message: "确定后此客户将从你的通讯录中移除！", rightTitle: "确 定", rightBlock: { (controller, action) in
                let select = selectValue as? String ?? ""
                if let index = self.staffList.firstIndex(where: { return $0.realName == select}) {
                    SW_AfterSaleService.changeAfterSale(self.customer.id, toStaffId: self.staffList[index].id).response({ (json, isCache, error) in
                        if let _ = json as? JSON, error == nil {
                            showAlertMessage("更换售后顾问成功", MYWINDOW)
                            NotificationCenter.default.post(name: NSNotification.Name.Ex.CustomerHadBeenChange, object: nil, userInfo: ["customerId": self.customerId])
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                        }
                    })
                }
            }, leftTitle: "取 消", leftBlock: nil)
        })
    }
}
