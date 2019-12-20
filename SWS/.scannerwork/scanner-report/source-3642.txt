//
//  SW_CustomerDetailViewController.swift
//  SWS
//
//  Created by jayway on 2018/8/14.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

/// 当前显示界面数据
///
/// - access: 接访记录
/// - contract: 合同购车记录
enum SaleCustomerRecordType {
    case access
    case contract
}

class SW_CustomerDetailViewController: FormViewController {
    
    private var type: SaleCustomerRecordType = .access {
        didSet {
            if type != oldValue {
                createTableView()
                tableView.scroll(toRow: 1, inSection: 0, at: .top, animated: false)
            }
        }
    }
    
    var headerRow: SW_CustomerInfoHeaderCellRow? {
        return form.rowBy(tag: "SW_CustomerInfoHeaderCellRow") as? SW_CustomerInfoHeaderCellRow
    }
    
    private var staffList = [SW_AddressBookModel]()
    
    /// 接待记录列表
    private var recordDatas = [SW_AccessRecordListModel]()
    /// 购车记录列表
    private var buyCarDatas = [SW_PurchaseCarRecordListModel]()
    /// 合同总数
    private var contractTotalCount = 0
    
    private var customer = SW_CustomerModel()
    
    private var customerId: String = ""
    
    private var consultantInfoId = 0
    
    lazy var rightBtn: UIBarButtonItem = {
        let btn = QMUIButton(type: .custom)
        btn.setImage(UIImage(named: "personalcenter_icon_more"), for: UIControl.State())
        btn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        btn.addTarget(self, action: #selector(moreAction(_:)), for: .touchUpInside)
        let barbtn = UIBarButtonItem(customView: btn)
        return barbtn
    }()
    
    init(_ customerId: String, consultantInfoId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.customerId = customerId
        self.consultantInfoId = consultantInfoId
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       /// 进入详情页如果有新建客户页面 则去除
        navigationController?.removeViewController([SW_TempCustomerDetailViewController.self,SW_CreateCustomerViewController.self])
        
        formConfig()
        getStaffInfo()
        setupNotification()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        PrintLog("deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        navigationController?.navigationBar.setBackgroundImage(UIImage.image(solidColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), size: CGSize(width: 5, height: 64)), for: .default)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupNotification() {
        /// 用户编辑了客户意向信息
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadEditCustomerIntention, object: nil, queue: nil) { [weak self] (notifa) in
            let id = notifa.userInfo?["customerId"] as! String
            if self?.customerId == id {
                self?.getStaffInfo()
            }
        }
        /// 结束了销售接待 刷新页面
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadEndSalesReception, object: nil, queue: nil) { [weak self] (notifa) in
            let id = notifa.userInfo?["customerId"] as! String
            if id == self?.customerId {
                self?.getAccessCustomerRecordList()
            }
        }
        /// 结束了试乘试驾 刷新页面
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadEndTryDriving, object: nil, queue: nil) { [weak self] (notifa) in
            let id = notifa.userInfo?["customerId"] as! String
            if id == self?.customerId {
                self?.getAccessCustomerRecordList()
            }
        }
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
            
            if type == .access, let index = self?.recordDatas.firstIndex(where: { return $0.id == orderId }), index < 2 {
                guard let row = self?.form.rowBy(tag: "Access Record \(index)") as? SW_AccessRecordListRow else {
                    return
                }
                self?.recordDatas[index].complaintState = .waitAudit
                row.cell.complaintState = .waitAudit
                row.updateCell()
            } else if type == .purchaseCar, let index = self?.buyCarDatas.firstIndex(where: { return $0.contractId == orderId }), index < 2 {
                guard let row = self?.form.rowBy(tag: "purchaseCar Record \(index)") as? SW_AccessRecordListRow else {
                    return
                }
                self?.buyCarDatas[index].complaintState = .waitAudit
                row.cell.complaintState = .waitAudit
                row.updateCell()
            }
        }
    }
    
    //获取客户信息刷新页面
    fileprivate func getStaffInfo() {
        var isError = false
        
        let group = DispatchGroup()
        group.enter()
        SW_AddressBookService.getCustomerDetail(customerId).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.customer = SW_CustomerModel(json)
            } else {
                if let json = json as? JSON, json["code"].intValue == 2 {
                    NotificationCenter.default.post(name: NSNotification.Name.Ex.CustomerHadBeenChange, object: nil, userInfo: ["customerId": self.customerId])
                    SW_UserCenter.shared.showAlert(message: json["msg"].stringValue, str: "确定", action: { (action) in
                        self.navigationController?.popViewController(animated: true)
                    })
                    
                } else {
                    isError = true
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                }
            }
            group.leave()
        })
       
        group.enter()
        SW_AddressBookService.getAccessCustomerRecordList(consultantInfoId).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.recordDatas = json.arrayValue.map({ (value) -> SW_AccessRecordListModel in
                    return SW_AccessRecordListModel(value)
                })
            } else {
                isError = true
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
            group.leave()
        })
        
        group.enter()
        SW_AddressBookService.getCarSalesContractRecordList(customerId, max: 2).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.buyCarDatas = json["list"].arrayValue.map({ (value) -> SW_PurchaseCarRecordListModel in
                    return SW_PurchaseCarRecordListModel(value)
                })
                self.contractTotalCount = json["count"].intValue
            } else {
                isError = true
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
            group.leave()
        })
        
        var beingAccessJson = JSON.null
        group.enter()
        SW_AddressBookService.getCustomerBeingAccess(customerId).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                beingAccessJson = json["list"]
            } else {
                isError = true
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
            group.leave()
        })
        
        group.notify(queue: .main) {
            if isError {
                self.navigationController?.popViewController(animated: true)
            } else {
                ///设置用户正在接待状态
                self.customer.setBeingAccessJson(beingAccessJson)
                self.navigationItem.rightBarButtonItem = self.rightBtn
                self.createTableView()
            }
        }
    }
    
    private func getAccessCustomerRecordList() {
        SW_AddressBookService.getAccessCustomerRecordList(consultantInfoId).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.recordDatas = json.arrayValue.map({ (value) -> SW_AccessRecordListModel in
                    return SW_AccessRecordListModel(value)
                })
                self.tableView.reloadDataAndScrollOriginal({ [weak self] in
                    self?.createTableView()
                })
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
            <<< SW_CustomerInfoHeaderCellRow("SW_CustomerInfoHeaderCellRow") {
                $0.value = customer
                $0.cell.delegate = self
                $0.cell.controller = self
            }
        
        
            <<< SW_SaleCustomerRecordHeaderRow("SW_SaleCustomerRecordHeaderRow") { [weak self] in
                $0.typeChangeBlock = { (infoType) in
                    self?.type = infoType
                }
                $0.moreBlock = { [weak self] in
                    guard let self = self else { return }
                    PrintLog("more")
                    if self.type == .access {
                        let vc = SW_CustomerAccessRecordViewController()
                        vc.consultantInfoId = self.consultantInfoId
                        vc.phone = self.customer.phoneNum
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        ////  购车记录
                        let vc = SW_PurchaseCarRecordViewController()
                        vc.customerId = self.customerId
                        vc.phone = self.customer.phoneNum
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                $0.value = self?.type
        }
        
        if type == .access {
            if recordDatas.count > 0 {
                // 显示的条数，大于2显示2条 ，小于2 显示1条
                let count = min(2, recordDatas.count)
                for index in 0..<count {
                    form.last!
                        <<< SW_AccessRecordListRow("Access Record \(index)") {
                            $0.value = recordDatas[index]
                            $0.cell.indexLabel.text = "\(recordDatas.count - index)"
                            $0.cell.bottomLine.isHidden = index == recordDatas.count - 1
                            $0.cell.topLine.isHidden = index == 0
                            $0.cell.moreImageView.isHidden = !(index == 1 && recordDatas.count > 2)
                            }.onCellSelection({ [weak self] (cell, row) in
                                row.deselect()
                                guard let self = self else { return }
                                let model = self.recordDatas[index]
                                switch model.accessType {
                                case .tryDrive:
                                    self.navigationController?.pushViewController(SW_TryDriveRecordViewController(model.id), animated: true)
                                case .salesReception:
                                    self.navigationController?.pushViewController(SW_SaleAccessRecordViewController.creatVc(model.id, phone: self.customer.phoneNum), animated: true)
                                default:
                                    self.navigationController?.pushViewController(SW_AccessRecordDetailViewController.creatVc(model.id), animated: true)
                                }
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
            if buyCarDatas.count > 0 {
                let showCount = min(buyCarDatas.count, 2)
                for index in 0..<showCount {
                    form.last!
                        <<< SW_AccessRecordListRow("purchaseCar Record \(index)") {
                            $0.purchaseCarRecord = buyCarDatas[index]
                            $0.cell.indexLabel.text = "\(contractTotalCount - index)"
                            $0.cell.bottomLine.isHidden = index == contractTotalCount - 1
                            $0.cell.topLine.isHidden = index == 0
                            $0.cell.moreImageView.isHidden = !(index == 1 && contractTotalCount > 2)
                            }.onCellSelection({ [weak self] (cell, row) in
                                row.deselect()
                                guard let self = self else { return }
                                let model = self.buyCarDatas[index]
                                self.navigationController?.pushViewController(SW_PurchaseCarRecordDetailViewController(model.contractId, phone:self.customer.phoneNum), animated: true)
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
            Eureka.Section() { [weak self] section in
                var header = HeaderFooterView<SW_CustomerSectionHeaderView>(.nibFile(name: "SW_CustomerSectionHeaderView", bundle: nil))
                header.onSetupView = { view, _ in
                    /// 点击编辑按钮
                    view.setup("客户意向信息", btnName: "编辑")
                    view.editBlock = {
                        guard let `self` = self else { return }
                        self.navigationController?.pushViewController(SW_EditCustomerInfoViewController(self.customer), animated: true)
                    }
                }
                section.header = header
            }
            
            <<< SW_StaffInfoRow("Customer source") {
                $0.rowTitle = NSLocalizedString("客户来源   ", comment: "")
                $0.isShowBottom = false
                if customer.customerSource == .networkPhone {
                    $0.value = customer.customerSource.rawString + "-" + customer.customerSourceSite.rawString
                } else {
                    $0.value = customer.customerSource.rawString
                }
            }
            <<< SW_StaffInfoRow("In the area") {
                $0.rowTitle = NSLocalizedString("所在地区   ", comment: "")
                $0.isShowBottom = false
                $0.value =  customer.city.isEmpty ? customer.province : "\(customer.province)-\(customer.city)"
            }
            <<< SW_StaffInfoRow("Interested models") {
                $0.rowTitle = NSLocalizedString("意向车型   ", comment: "")
                $0.isShowBottom = false
                $0.value = customer.likeCarBrand + "   " + customer.likeCarSeries + "   " + customer.likeCarModel//customer.likeCar
            }
            <<< SW_StaffInfoRow("Compare the models") {
                $0.rowTitle = NSLocalizedString("对比车型   ", comment: "")
                $0.isShowBottom = false
                $0.value = customer.contrastCarBrand + "   " + customer.contrastCarSeries// + "   " + customer.contrastCarModel//customer.contrastCar
            }
            
            <<< SW_StaffInfoRow("likeCarColor") {
                $0.rowTitle = NSLocalizedString("外色喜好   ", comment: "")
                $0.isShowBottom = false
                $0.value = customer.likeCarColor
            }
            
            <<< SW_StaffInfoRow("Interior trim tastes") {
                $0.rowTitle = NSLocalizedString("内饰喜好   ", comment: "")
                $0.isShowBottom = false
                $0.value = customer.interiorColor
            }
            <<< SW_StaffInfoRow("main purpose") {
                $0.rowTitle = NSLocalizedString("主要用途   ", comment: "")
                $0.isShowBottom = false
                $0.value = customer.useFor.rawString
            }
            <<< SW_StaffInfoRow("Car type") {
                $0.rowTitle = NSLocalizedString("购车类型   ", comment: "")
                $0.isShowBottom = false
                $0.value = customer.buyType.rawString
            }
            <<< SW_StaffInfoRow("Existing models") {
                $0.rowTitle = NSLocalizedString("现有车型   ", comment: "")
                $0.isShowBottom = false
                $0.value = customer.havedCarBrand + "   " + customer.havedCarSeries// + "   " + customer.havedCarModel
            }
            <<< SW_StaffInfoRow("Replacement model") {
                $0.rowTitle = NSLocalizedString("置换车型   ", comment: "")
                $0.isShowBottom = false
                $0.value = customer.replaceCarBrand + "   " + customer.replaceCarSeries// + "   " + customer.replaceCarModel
            }
            <<< SW_StaffInfoRow("Car budget") {
                $0.rowTitle = NSLocalizedString("购车预算   ", comment: "")
                $0.isShowBottom = false
                var str = customer.buyBudget == 0 ? "" : "\(customer.buyBudget)万    "
                str += customer.buyCount == 0 ? "1台    " : "\(customer.buyCount)台    "
                str += customer.buyWay.rawString
                $0.value = str
            }
            
            <<< SW_StaffInfoRow("The user") {
                $0.rowTitle = NSLocalizedString("使  用  者   ", comment: "")
                $0.isShowBottom = false
                $0.value = customer.carUser + "    " + (customer.carUser.isEmpty ? "" : customer.userSex.rawTitle)
            }
            <<< SW_StaffInfoRow("Shopping time") {
                $0.rowTitle = NSLocalizedString("购车时间   ", comment: "")
                $0.isShowBottom = false
                $0.value = customer.buyDateString
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
        
        
        let followAction = QMUIAlertAction(title: customer.isFollow ? "取消关注" : "关注", style: .default) { (alertController, action) in
            SW_AddressBookService.followCustomer(self.customer.id, isFollow: !self.customer.isFollow).response({ (json, isCache, error) in
                if error == nil {
                    self.customer.isFollow = !self.customer.isFollow
                    NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadFollowCustomer, object: nil, userInfo: ["customerId": self.customerId, "isFollow": self.customer.isFollow])
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                }
            })
        }
        let followImg = customer.isFollow ? UIImage(named: "personalcenter_icon_unfollow") : UIImage(named: "personalcenter_icon_follow")
        followAction.button.setImage(followImg, for: UIControl.State())
        followAction.button.spacingBetweenImageAndTitle = customer.isFollow ? sheetW - 133 : sheetW - 100
        followAction.button.imagePosition = .right
        actionSheet.addAction(followAction)
        
        let addRecordAction = QMUIAlertAction(title: "添加接访记录", style: .default) { (alertController, action) in
            self.navigationController?.pushViewController(SW_AddAccessRecordViewController(self.customerId), animated: true)
        }
        addRecordAction.button.setImage(UIImage(named: "personalcenter_icon_record"), for: UIControl.State())
        addRecordAction.button.spacingBetweenImageAndTitle = sheetW - 166
        addRecordAction.button.imagePosition = .right
        addRecordAction.isEnabled = customer.accessStartDate == 0
        actionSheet.addAction(addRecordAction)
        
        let changeAction = QMUIAlertAction(title: "更换销售顾问", style: .default) { [weak self] (alertController, action) in
            if self!.staffList.count > 0 {
                self?.showStaffListPicker()
            } else {
                SW_AddressBookService.getSellerList().response({ (json, isCache, error) in
                    if let json = json as? JSON, error == nil {
                        self?.staffList = json.arrayValue.map({ (jsonValue) -> SW_AddressBookModel in
                            let model = SW_AddressBookModel()
                            model.realName = jsonValue["realName"].stringValue
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
        changeAction.isEnabled = customer.accessStartDate == 0
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
        followAction.buttonAttributes = buttonAttributes
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
    
    /// 显示销售人员pickerview
    private func showStaffListPicker() {
        guard staffList.count > 0 else {
            showAlertMessage("没有其他销售顾问", MYWINDOW)
            return
        }
        BRStringPickerView.showStringPicker(withTitle: "选择销售顾问", on: MYWINDOW, dataSource: staffList.map({ return $0.realName }), defaultSelValue: "", isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (selectValue) in
            
            alertControllerShow(title: "你确定将此客户转移给\(selectValue!)吗？", message: "确定后此客户将从你的通讯录中移除！", rightTitle: "确 定", rightBlock: { (controller, action) in
                let select = selectValue as? String ?? ""
                if let index = self.staffList.firstIndex(where: { return $0.realName == select}) {
                    SW_AddressBookService.changeStaff(self.customer.id, staffId: self.staffList[index].id, consultantInfoId: self.customer.consultantInfoId).response({ (json, isCache, error) in
                        if let _ = json as? JSON, error == nil {
                            showAlertMessage("更换销售顾问成功", MYWINDOW)
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


// MARK: - TableViewDelegate
extension SW_CustomerDetailViewController: SW_CustomerInfoHeaderCellDelegate {
    /// 点击试乘试驾按钮
    func SW_CustomerInfoHeaderCellDidClickTryDriving() {
        if let vc = UIStoryboard(name: "AddressBook", bundle: nil).instantiateViewController(withIdentifier: String(describing: SW_TryDriveUpImageViewController.self)) as? SW_TryDriveUpImageViewController {
            vc.customerId = customerId
            vc.testDriveRecordId = customer.accessRecordId
            /// 试乘试驾上传图片界面
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    ///  view 的布局发生改变，高度重新计算
    func SW_CustomerInfoHeaderCellDidChangeframe() {
        form.rowBy(tag: "SW_CustomerInfoHeaderCellRow")?.reload()
        tableView.scroll(toRow: 0, inSection: 0, at: .top, animated: false)
    }
    
    /// 点击结束销售接待
    func SW_CustomerInfoHeaderCellDidClickEndAccess() {
        self.navigationController?.pushViewController(SW_EndSalesReceptionViewController(customer.accessRecordId, customerId: customerId), animated: true)
    }
    
    /// 点击结束试乘试驾
    func SW_CustomerInfoHeaderCellDidClickEndTryDriving() {
        self.navigationController?.pushViewController(SW_TestDriveEvaluationOneViewController(customer.tryDriveRecordId, customerId: customerId), animated: true)
    }
}


