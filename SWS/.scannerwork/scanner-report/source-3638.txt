//
//  SW_TempCustomerDetailViewController.swift
//  SWS
//
//  Created by jayway on 2018/11/13.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import Eureka

class SW_TempCustomerDetailViewController: FormViewController {
    /// 接待记录列表
    private var recordDatas = [SW_AccessRecordListModel]()
    /// 临时客户id    跟客户id一样使用
    private var customerId: String = ""
    
    private var customer = SW_CustomerModel()
    
    private var consultantInfoId = 0
    
    private var clearView = false
    
    init(_ customerId: String, customerTempNum: String, consultantInfoId: Int, createDate: TimeInterval, clearView: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.customerId = customerId
        self.customer.id = customerId//这里的id 是临时客户id    传参都使用这个临时客户id
        self.customer.customerTempNum = customerTempNum
        self.customer.createDate = createDate
        self.consultantInfoId = consultantInfoId
        self.clearView = clearView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formConfig()
//        createTableView()
        getStaffInfo()
        setupNotification()
        // Do any additional setup after loading the view.
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
    
    private func setupNotification() {
        
        /// 销售接待被后台结束  跳转至结束接待页面，然后再进行提示
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.SalesReceptionHadBeenEnd, object: nil, queue: nil) { [weak self] (notifa) in
            guard let self = self else { return  }
            let id = notifa.userInfo?["customerId"] as! String
            let recordId = notifa.userInfo?["recordId"] as! String
            if id == self.customerId {
                if let topVc = self.navigationController?.topViewController {
                    /// 移除qmui弹窗
                    self.removeAllQMUIAlertController()
                    /// 移除presentviewcontroller
                    if topVc.presentedViewController != nil {
                        topVc.dismiss(animated: false, completion: nil)
                    }
                }
                if self.navigationController?.topViewController is SW_EndSalesReceptionViewController {
                    /// 如果销售接待进去结束页面则不做处理。
                } else {
                    self.navigationController?.pushViewController(SW_EndSalesReceptionViewController(recordId, customerId: self.customerId, clearView: true, customerTempNum: self.customer.customerTempNum, consultantInfoId: self.consultantInfoId, createDate: self.customer.createDate, showTip: true), animated: true)
                }
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
    }
    
    
    //获取客户信息刷新页面
    fileprivate func getStaffInfo() {
        var isError = false
        let group = DispatchGroup()
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
                self.popSelf()//navigationController?.popViewController(animated: true)
            } else {
                ///设置用户正在接待状态
                self.customer.setBeingAccessJson(beingAccessJson)
                self.createTableView()
            }
        }
    }
    
    /// 更新接待记录列表
    private func getAccessCustomerRecordList() {
        SW_AddressBookService.getAccessCustomerRecordList(consultantInfoId).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.recordDatas = json.arrayValue.map({ (value) -> SW_AccessRecordListModel in
                    return SW_AccessRecordListModel(value)
                })
                self.createTableView()
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
    }
    
    
    //MARK: - Action
    private func formConfig() {
        if clearView {
            navigationController?.removeViewController([SW_EndSalesReceptionViewController.self])
        }
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_back").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popSelf))
    }
    
    private func createTableView() {
        form = Form()
            +++
            Eureka.Section()
            <<< SW_TempCustomerInfoHeaderRow("SW_TempCustomerInfoHeaderRow") {
                $0.value = customer
                $0.cell.delegate = self
                $0.cell.controller = self
        }
        
        if recordDatas.count > 0 {
            form
                +++
                Eureka.Section() { [weak self] section in
                    var header = HeaderFooterView<SW_CustomerSectionHeaderView>(.nibFile(name: "SW_CustomerSectionHeaderView", bundle: nil))
                    header.onSetupView = { view, _ in
                        /// 点击编辑按钮
                        view.setup("接访记录", btnName: "更多")
                        view.editBlock = {
                            guard let `self` = self else { return }
                            let vc = SW_CustomerAccessRecordViewController()
                            vc.consultantInfoId = self.consultantInfoId
                            vc.phone = self.customer.phoneNum
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                    section.header = header
            }
            
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
                                self.navigationController?.pushViewController(SW_SaleAccessRecordViewController.creatVc(model.id, phone: ""), animated: true)
                            default:
                                self.navigationController?.pushViewController(SW_AccessRecordDetailViewController.creatVc(model.id), animated: true)
                            }
                            
                        })
                
            }
        }
        
        form
            +++
            Eureka.Section() { [weak self] section in
                    var header = HeaderFooterView<SW_TwoButtonView>(.nibFile(name: "SW_TwoButtonView", bundle: nil))
                    header.height = {100}
                    header.onSetupView = { view, _ in
                        view.setupLeft("快速建档", action: {
                            guard let self = self else { return }
                            if self.customer.accessStartDate != 0 {
                                showAlertMessage("请先结束接待", MYWINDOW)
                                return
                            }
                            if self.recordDatas.count > 0 {
                                let vc = SW_CreateCustomerViewController(self.customerId)
                                self.navigationController?.pushViewController(vc, animated: true)
                            } else {
                                showAlertMessage("请先添加接访记录", MYWINDOW)
                            }
                        })
                        view.leftBtn.setTitleColor(UIColor.v2Color.blue, for: UIControl.State())
                        view.leftBtn.setBackgroundImage(nil, for: UIControl.State())
                        view.leftBtn.setBackgroundImage(nil, for: .highlighted)
                        view.leftBtn.backgroundColor = .white
                        view.leftBtn.layer.borderColor = UIColor.v2Color.blue.cgColor
                        view.leftBtn.layer.borderWidth = 1
                        view.setupRight("移除客户", action: {
                            guard let self = self else { return }
                            if self.customer.accessStartDate != 0 {
                                showAlertMessage("请先结束接待", MYWINDOW)
                                return
                            }
                            alertControllerShow(title: "你确定移除此客户吗？", message: "移除后此客户将不再显示在你的通讯录中", rightTitle: "确 定", rightBlock: { (controller, action) in
                                SW_AddressBookService.clear(self.customerId).response({ (json, isCache, error) in
                                    if let _ = json as? JSON, error == nil {
                                        NotificationCenter.default.post(name: NSNotification.Name.Ex.CustomerHadBeenChange, object: nil, userInfo: ["customerId": self.customerId])
                                        showAlertMessage("移除客户成功", MYWINDOW)
                                        self.popSelf()//navigationController?.popViewController(animated: true)
                                    } else {
                                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                                    }
                                })
                            }, leftTitle: "取 消", leftBlock: nil)
                        })
                        view.rightBtn.setTitleColor(UIColor.v2Color.red, for: UIControl.State())
                        view.rightBtn.setBackgroundImage(nil, for: UIControl.State())
                        view.rightBtn.setBackgroundImage(nil, for: .highlighted)
                        view.rightBtn.backgroundColor = .white
                        view.rightBtn.layer.borderColor = UIColor.v2Color.red.cgColor
                        view.rightBtn.layer.borderWidth = 1
                    }
                    section.header = header
        }
        
        tableView.reloadData()
    }
    
    @objc func popSelf() {
        if self.presentingViewController != nil {
            dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: - FormViewControllerProtocol   重写一下方法是因为需要去除该库添加时的动画
    override func sectionsHaveBeenAdded(_ sections: [Section], at indexes: IndexSet) {
        
    }
    
    override func rowsHaveBeenAdded(_ rows: [BaseRow], at indexes: [IndexPath]) {
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? CGFloat.leastNormalMagnitude : 70
    }
    
}

// MARK: - TableViewDelegate
extension SW_TempCustomerDetailViewController: SW_CustomerInfoHeaderCellDelegate {
    /// 点击试乘试驾按钮
    func SW_CustomerInfoHeaderCellDidClickTryDriving() {
        if let vc = UIStoryboard(name: "AddressBook", bundle: nil).instantiateViewController(withIdentifier: String(describing: SW_TryDriveUpImageViewController.self)) as? SW_TryDriveUpImageViewController {
            vc.customerId = customerId
            vc.testDriveRecordId = customer.accessRecordId
            /// 试乘试驾上传图片界面
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /// 添加访问记录按钮点击
    func SW_CustomerInfoHeaderCellDidClickAddRecord() {
        self.navigationController?.pushViewController(SW_AddAccessRecordViewController(self.customerId), animated: true)
    }
    
    ///  view 的布局发生改变，高度重新计算
    func SW_CustomerInfoHeaderCellDidChangeframe() {
        form.rowBy(tag: "SW_TempCustomerInfoHeaderRow")?.reload()
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
