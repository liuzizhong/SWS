//
//  SW_EndSalesReceptionViewController.swift
//  SWS
//
//  Created by jayway on 2018/8/17.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_EndSalesReceptionViewController: FormViewController {
    
    let record: SW_AccessCustomerRecordModel!
    
    private var isRequesting = false
    
    private var clearView = false
    
    private var customerTempNum = ""
    
    private var consultantInfoId = 0
    
    private var showTip = false
    
    private var createDate: TimeInterval = 0
    
    init(_ recordId: String, customerId: String, clearView: Bool = false, customerTempNum: String = "", consultantInfoId: Int = 0, createDate: TimeInterval = 0, showTip: Bool = false) {
        record = SW_AccessCustomerRecordModel()
        record.id = recordId
        record.customerId = customerId
        self.clearView = clearView
        self.customerTempNum = customerTempNum
        self.consultantInfoId = consultantInfoId
        self.createDate = createDate
        self.showTip = showTip
        super.init(nibName: nil, bundle: nil)
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
        NotificationCenter.default.removeObserver(self)
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
        /// 如果是true，将中间的view全部去除
        if clearView {
            navigationController?.removeViewController([SW_TempCustomerDetailViewController.self,SW_TryDriveUpImageViewController.self,SW_StartTryDriveViewController.self,SW_CustomerAccessRecordViewController.self,SW_SaleAccessRecordViewController.self,SW_TryDriveRecordViewController.self,SW_AccessRecordDetailViewController.self])
        }
        /// 需要添加变量控制
        /// 弹出提示，后台停止接待
        if showTip {        
            SW_UserCenter.shared.showAlert(message: "销售接待已在后台结束，请填写接待内容")
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "nav_back").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popSelf))
        view.backgroundColor = .white
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        rowKeyboardSpacing = 89
        navigationItem.title = NSLocalizedString("本次接待信息", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(commitAction(_:)))
        
        /// 销售接待被后台结束  跳转至结束接待页面，然后再进行提示
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.SalesReceptionHadBeenEnd, object: nil, queue: nil) { [weak self] (notifa) in
            guard let self = self else { return }
            let recordId = notifa.userInfo?["recordId"] as! String
            if recordId == self.record.id {
                /// 弹出提示，后台停止接待
                SW_UserCenter.shared.showAlert(message: "销售接待已在后台结束，请填写接待内容")
            }
        }
        
    }
    
    private func createTableView() {
        form = Form()
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = "必填信息"
                }
                section.header = header
            }
            
            <<< SW_SingleChoiceRow("come store type") {
                $0.rawTitle = NSLocalizedString("到店类型", comment: "")
                $0.value = record.comeStoreType.rawString
                $0.allOptions = ["邀约","其他"]
                }.onChange { [weak self] in
                    self?.record.comeStoreType = ComeStoreType($0.value ?? "")
            }
            
            <<< SW_ComeStorePeopleRow("number to the shop") {
                $0.limitCount = 2
                $0.value = record.customerCount == 0 ? "" : "\(record.customerCount)"
                }.onChange { [weak self] in
                    self?.record.customerCount = Int($0.value ?? "0") ?? 0
            }
            
            <<< SW_SingleChoiceRow("Commodity satisfaction") {
                $0.rawTitle = NSLocalizedString("商品满意度", comment: "")
                $0.value = record.satisfaction.rawString
                $0.allOptions = ["不满意","一般","满意"]
                }.onChange { [weak self] in
                    self?.record.satisfaction = SatisfactionType($0.value ?? "")
            }
            
            <<< SW_CommenTextViewRow("Access records")  {
                $0.placeholder = "请在此输入本次接待过程中的要点"
                $0.value = record.recordContent
                $0.maximumTextLength = 500
                $0.rawTitle = "接待记录"
                $0.textViewHeightChangeBlock = { [weak self] (textViewHeight) in
                    self?.form.rowBy(tag: "Access records")?.reload()
                }
                }.onChange { [weak self] in
                    self?.record.recordContent = $0.value ?? ""
        }
        
        tableView.reloadAndFadeAnimation()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    @objc private func commitAction(_ sender: UIButton) {
        if record.comeStoreType == .none {
            showAlertMessage("请选择到店类型", MYWINDOW)
            return
        }
        if record.customerCount == 0 {
            showAlertMessage("请输入到店人数", MYWINDOW)
            (form.rowBy(tag: "Access records") as? SW_CommenTextViewRow)?.showErrorLine()
            (form.rowBy(tag: "number to the shop") as? SW_CommenFieldRow)?.showErrorLine()
            return
        }
        if record.satisfaction == .none {
            showAlertMessage("请选择商品满意度", MYWINDOW)
            return
        }
        if record.recordContent.isEmpty {
            showAlertMessage("请输入访问记录", MYWINDOW)
            (form.rowBy(tag: "Access records") as? SW_CommenTextViewRow)?.showErrorLine()
            return
        }
        guard !isRequesting else { return }
        alertControllerShow(title: "确定保存本次访问信息吗？", message: "保存后不可再修改", rightTitle: "确 定", rightBlock: { (_, _) in
            self.isRequesting = true
            QMUITips.showLoading("正在结束", in: self.view)
            SW_AddressBookService.updateAccessCustomerRecord(self.record).response({ (json, isCache, error) in
                self.isRequesting = false
                QMUITips.hideAllTips(in: self.view)
                if let json = json as? JSON, error == nil {
                    NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadEndSalesReception, object: nil, userInfo: ["customerId": self.record.customerId, "endDate": json["endDate"].doubleValue])
                    
                    showAlertMessage("结束成功", MYWINDOW)
                    if self.clearView {
                        self.navigationController?.pushViewController(SW_TempCustomerDetailViewController(self.record.customerId, customerTempNum: self.customerTempNum, consultantInfoId: self.consultantInfoId, createDate: self.createDate, clearView: true), animated: true)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                }
            })
        }, leftTitle: "取 消", leftBlock: nil)
    }
    
    @objc func popSelf() {
        /// 个数为1时说明是present才会出现。
        if self.navigationController?.viewControllers.count == 1 {
            dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension SW_EndSalesReceptionViewController {
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
