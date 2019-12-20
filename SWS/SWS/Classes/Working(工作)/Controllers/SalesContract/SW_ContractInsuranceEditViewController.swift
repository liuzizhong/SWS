//
//  SW_ContractInsuranceEditViewController.swift
//  SWS
//
//  Created by jayway on 2019/5/28.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_ContractInsuranceEditViewController: FormViewController {
    
    private var isRequesting = false
    
    private var salesContract: SW_SalesContractDetailModel!
    
    private var contractId = ""
    
    /// 用于存放这次新上传到七牛的keys  deinit时需要删除，删除前要判断是否有进行保存，保存了就不删除
    private var addKeys = [String]()
    
    /// 用于销毁时判断是否有进行保存操作没有要删除key
    private var hadSave = false
    
    ///控制添加的图片与接收人的最大数量
    private var maxPictureCount = 4
    private let imageColumn = 4
    
    lazy var insuranceItemsTotalAmountRow: SW_StaffInfoRow = {
        return SW_StaffInfoRow("Total commercial insurance") {
            $0.rowTitle = NSLocalizedString("商业险合计   ", comment: "")
            $0.isShowBottom = false
            $0.value = salesContract.insuranceItemsTotalAmount.toAmoutString()
        }
    }()
    
    lazy var insuranceTotalAmountRow: SW_StaffInfoRow = {
        return SW_StaffInfoRow("The policy combined") {
            $0.rowTitle = NSLocalizedString("保 单  合 计   ", comment: "")
            $0.isShowBottom = false
            $0.value = salesContract.insuranceTotalAmount.toAmoutString()
        }
    }()
    
    init(_ salesContract: SW_SalesContractDetailModel, contractId: String) {
        super.init(nibName: nil, bundle: nil)
        self.salesContract = salesContract
        self.salesContract.delegate = self
        self.contractId = contractId
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
        ///删除未保存工作报告的keys，防止空间浪费 --- 需要判断是否保存了，没保存
        if !hadSave {
            SWSQiniuService.imgBatchDelete(addKeys.joined(separator: ",")).response({ (json, isCache, error) in
            })
        }
//        removeObserve(salesContract)
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
        navigationOptions = RowNavigationOptions.Enabled
        view.backgroundColor = .white
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL + 54, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = false
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(backAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提交审核", style: .plain, target: self, action: #selector(handleAction(_:)))
        
        SW_StaffInfoRow.defaultCellSetup = { (cell, row) in
            cell.selectionStyle = .none
            cell.titleLb.textColor = UIColor.v2Color.darkGray
            cell.valueLb.textColor = UIColor.v2Color.darkBlack
        }
        rowKeyboardSpacing = 89
        
    }
    
    private func createTableView() {
        form = Form()
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = "保单办理"
                }
                section.header = header
            }
            <<< SW_StaffInfoRow("Contract no") {
                $0.rowTitle = NSLocalizedString("合 同 编 号   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.contractNum
            }
            <<< SW_StaffInfoRow("Vin") {
                $0.rowTitle = NSLocalizedString("车   架   号   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.vin.isEmpty ? "未分配" : salesContract.vin
            }
            
            <<< SW_CommenLabelRow("insuranceCompany") {
                $0.rawTitle = NSLocalizedString("保险公司", comment: "")
                $0.value = salesContract.insuranceCompany
                $0.cell.placeholder = "点击选择保险公司"
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    let vc = SW_InsuranceCompanyViewController(self?.salesContract.bUnitId)
                    vc.selectBlock = { (select) -> Void in
                        if self?.salesContract.insuranceCompanyId != select.id {
                            self?.salesContract.insuranceCompany = select.name
                            self?.salesContract.insuranceCompanyId = select.id
                            //重新初始化数据
                            row.value = select.name
                            row.updateCell()
                        }
                    }
                    self?.navigationController?.pushViewController(vc, animated: true)
                })
            <<< SW_CommenFieldRow("insuranceNum") {
                $0.rawTitle = NSLocalizedString("保单号", comment: "")
                $0.value = salesContract.insuranceNum
                $0.limitCount = 40
                $0.cell.valueField.keyboardType = .asciiCapable
                $0.cell.valueField.placeholder = "请输入保单号"
                //                $0.cell.valueField.becomeFirstResponder()
                }.onChange { [weak self] in
                    self?.salesContract.insuranceNum = $0.value ?? ""
            }
            <<< SW_CommenFieldRow("commercialInsuranceNum") {
                $0.rawTitle = NSLocalizedString("商业险单号", comment: "")
                $0.value = salesContract.commercialInsuranceNum
                $0.limitCount = 40
                $0.cell.valueField.keyboardType = .asciiCapable
                $0.cell.valueField.placeholder = "请输入商业险单号"
                //                $0.cell.valueField.becomeFirstResponder()
                }.onChange { [weak self] in
                    self?.salesContract.commercialInsuranceNum = $0.value ?? ""
            }
            <<< SW_StartEndTimeRow("insuranceStartDate") { (row) in
                row.rawTitle = NSLocalizedString("保险期间", comment: "")
                row.value = salesContract.insuranceStartDate == 0 ? "" : Date.dateWith(timeInterval: salesContract.insuranceStartDate).stringWith(formatStr: "yyyy-MM-dd")
                row.endTime = salesContract.insuranceEndDate == 0 ? "" : Date.dateWith(timeInterval: salesContract.insuranceEndDate).stringWith(formatStr: "yyyy-MM-dd ")
                
                row.startBtnClickBlock = {  [weak self, weak row] in
                    guard let self = self else { return }
                    guard let row = row else { return }
                    self.view.endEditing(true)
                    
                    let currentDate = Date()
                    let selectValue = Date.dateWith(formatStr: "yyyy-MM-dd", dateString: row.value ?? "") ?? currentDate
                    BRDatePickerView.showDatePicker(withTitle: "批复日期", on: MYWINDOW, dateType: BRDatePickerMode.init(rawValue: 6)!, defaultSelValue: selectValue, minDate: Date(timeIntervalSince1970: 0), maxDate: nil, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (dateStr) in
                        guard let dateStr = dateStr else { return }
                        /// 更换了日期才进行下面的操作
                        guard row.value != dateStr else { return }
                        if let date = Date.dateWith(formatStr: "yyyy-MM-dd", dateString: dateStr) {
                            row.value = dateStr
                            row.cell.setupState()
                            self.salesContract.insuranceStartDate = date.getCurrentTimeInterval()
                            /**
                             *  选择开始时间后，要判断结束时间是否有值， 没值的时候直接用开始时间+1年即可
                             *  有值时：  开始时间与之前的结束时间 比较大小
                             *   如果开始时间大于结束时间，则直接使用开始时间+1年
                             *   如果开始时间小于结束时间，要判断是否是同一天，
                             **/
                            if self.salesContract.insuranceEndDate != 0, self.salesContract.insuranceEndDate >= self.salesContract.insuranceStartDate {
                                PrintLog("这种情况不用处理")
                            } else {
                                PrintLog("这种情况结束时间等于开始时间+1年")
                                var endDate = (date as NSDate).addingYears(1) ?? Date()
                                endDate = (endDate as NSDate).addingDays(-1) ?? Date()
                                self.salesContract.insuranceEndDate = endDate.getCurrentTimeInterval()
                                row.endTime = endDate.stringWith(formatStr: "yyyy-MM-dd")
                                row.cell.setupState()
                            }
                        }
                    }, cancel: nil)
                }
                
                ///------start  end 分割
                row.endBtnClickBlock = { [weak self, weak row] in
                    guard let row = row else { return }
                    guard let self = self else { return }
                    self.view.endEditing(true)
                    if self.salesContract.insuranceStartDate == 0 {
                        showAlertMessage("请选择开始时间", MYWINDOW)
                        return
                    }
                    /// 选中的开始时间
                    let startDate = Date.dateWith(timeInterval: self.salesContract.insuranceStartDate)
                    let defaultValue = self.salesContract.insuranceEndDate == 0 ? startDate : Date.dateWith(timeInterval: self.salesContract.insuranceEndDate)

                    BRDatePickerView.showDatePicker(withTitle: "选择时间", on: MYWINDOW, dateType: BRDatePickerMode.init(rawValue: 6)!, defaultSelValue: defaultValue, minDate: startDate, maxDate: nil, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (dateStr) in
                        guard let dateStr = dateStr else { return }
                        /// 更换了日期才进行下面的操作
                        guard row.endTime.contains(dateStr) == false else { return }
                        if let selectDate = Date.dateWith(formatStr: "yyyy-MM-dd", dateString: dateStr) {
                            row.endTime = dateStr
                            row.cell.setupState()
                            self.salesContract.insuranceEndDate = selectDate.getCurrentTimeInterval()
                        }
                    }, cancel: nil)
                }
                
            }
            
            +++
            Section() { section in
                var header = HeaderFooterView<UIView>(.class)
                header.height = {10}
                section.header = header
            }
            <<< insuranceTotalAmountRow
            <<< insuranceItemsTotalAmountRow
            
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<SW_InsuranceSectionHeaderView>(.nibFile(name: "SW_InsuranceSectionHeaderView", bundle: nil))
                header.onSetupView = { view, _ in
                    view.isShowBxzl = false
                }
                header.height = {20}
                section.header = header
            }
        
//        if salesContract.carShipTaxTag == 1 {
//            form.last!
//                <<< SW_CommenFieldRow("carShipTaxAmount") {
//                    $0.rawTitle = NSLocalizedString("车船税", comment: "")
//                    $0.decimalCount = 4
//                    $0.amountMax = 9999999999.9999
//                    $0.isAmount = true
//                    $0.value = salesContract.carShipTaxAmount == 0 ? "" :  "\(salesContract.carShipTaxAmount)"
//                    $0.cell.valueField.keyboardType = .decimalPad
//                    $0.cell.valueField.placeholder = "请输入车船税"
//                    $0.cell.rightLbWidth.constant = 170
//                    $0.cell.rightLb.text = ""
//                    }.onChange { [weak self] in
//                        self?.salesContract.carShipTaxAmount = Double($0.value ?? "") ?? 0
//            }
//        }
        
//        if salesContract.compulsoryInsuranceTag == 1 {
//            form.last!
//                <<< SW_CommenFieldRow("compulsoryInsuranceAmount") {
//                    $0.rawTitle = NSLocalizedString("交强险", comment: "")
//                    $0.decimalCount = 4
//                    $0.amountMax = 9999999999.9999
//                    $0.isAmount = true
//                    $0.value = salesContract.compulsoryInsuranceAmount == 0 ? "" :  "\(salesContract.compulsoryInsuranceAmount)"
//                    $0.cell.valueField.keyboardType = .decimalPad
//                    $0.cell.valueField.placeholder = "请输入交强险"
//                    $0.cell.rightLbWidth.constant = 170
//                    $0.cell.rightLb.text = ""
//                    }.onChange { [weak self] in
//                        self?.salesContract.compulsoryInsuranceAmount = Double($0.value ?? "") ?? 0
//            }
//        }
        
        for i in 0..<salesContract.insuranceItems.count {
            let insurance = salesContract.insuranceItems[i]
            form.last!
                <<< SW_CommenFieldRow("\(insurance.id + insurance.name)") {
                    $0.rawTitle = NSLocalizedString(insurance.name, comment: "")
                    $0.decimalCount = 4
                    $0.amountMax = 9999999999.9999
                    $0.isAmount = true
                    $0.value = insurance.insuredAmount == 0 ? "" :  "\(insurance.insuredAmount)"
                    $0.cell.valueField.keyboardType = .decimalPad
                    $0.cell.valueField.placeholder = "请输入\(insurance.name)"
                    $0.cell.rightLbWidth.constant = 170
                    $0.cell.rightLb.text = insurance.insuredRemark
                    }.onChange { [weak self] in
                        self?.salesContract.insuranceItems[i].insuredAmount = Double($0.value ?? "") ?? 0
                        if i == 0 {
                            self?.salesContract.carShipTaxAmount = Double($0.value ?? "") ?? 0
                        } else if i == 1 {
                            self?.salesContract.compulsoryInsuranceAmount = Double($0.value ?? "") ?? 0
                        }
                        self?.salesContract.calculateInsuranceAmount()
            }
        }
        
            form.last!
            <<< SW_SelectAttachmentRow("attachmentList") {
                $0.images = salesContract.attachmentList
                $0.column = CGFloat(imageColumn)
                $0.maxCount = maxPictureCount
                $0.didShouDownRow = { [weak self] (indexPath) in//删除图片  indexpath
                    //删除图片
                    self?.deleteImage(indexPath)
                }
                $0.didSelectAdd = { [weak self] in//点击添加图片。弹出图片选择器
                    SW_ImagePickerHelper.shared.showPicturePicker({ (img) in
                        dispatch_async_main_safe {
                            self?.handleImage(img)
                        }
                    }, cropMode: .none)
                }
        }
        
        tableView.reloadData()
    }
    
    
    //MARK: - FormViewControllerProtocol   重写一下方法是因为需要去除该库添加时的动画
    override func sectionsHaveBeenAdded(_ sections: [Section], at indexes: IndexSet) {
        
    }
    
    override func rowsHaveBeenAdded(_ rows: [BaseRow], at indexes: [IndexPath]) {
        
    }
    
    //MARK: - 图片选择相关逻辑
    // 最后的处理  上传图片  上传服务器
    // 上传至七牛后，将七牛返回的key上传至服务端。
    private func handleImage(_ selectImage: UIImage) {
        guard let row = self.form.rowBy(tag: "attachmentList") as? SW_SelectAttachmentRow else { return }
        if row.images.count + row.upImages.count >= maxPictureCount {
            return
        }
        row.upImages.append(selectImage)
        row.updateCell()
        
        SWSUploadManager.share.upLoadAttachmentContractImage(selectImage, block: { (success, key, prefix) in
            if let key = key, let prefix = prefix, success {
                //                上传成功
                self.addKeys.append(key)
                self.salesContract.imagePrefix = prefix
                self.salesContract.attachmentList.append(prefix+key)
                /// 找到对应的上传的image删除
                if let index = row.upImages.firstIndex(of: selectImage) {
                    row.upImages.remove(at: index)
                }
                row.successImage[prefix+key] = selectImage
                row.images = self.salesContract.attachmentList
                row.updateCell()
                self.tableView.scrollToBottom(animated: true)
            } else {/// 上传失败
                showAlertMessage("上传失败,请重新选择", MYWINDOW)
                if let index = row.upImages.firstIndex(of: selectImage) {
                    row.upImages.remove(at: index)
                }
                row.updateCell()
            }
        }) { (key, progress) in
            /// 更新这个image对应cell的进度，根据图片找到对应的indexpath
            dispatch_async_main_safe {
                row.updateUpImagesProgress(image: selectImage, progress: progress)
            }
        }
    }
    
    private func deleteImage(_ indexPaht: IndexPath) {
        if self.salesContract.attachmentList.count > indexPaht.row {//删除的在正确范围内
            let key = self.salesContract.attachmentList[indexPaht.row].replacingOccurrences(of: self.salesContract.imagePrefix, with: "")
            self.salesContract.attachmentList.remove(at: indexPaht.row)
            //这次上传的删除
            if let index = addKeys.firstIndex(of: key) {
                addKeys.remove(at: index)
                //删除七牛空间中的图片---不是本次上传的不删除
                SWSQiniuService.imgBatchDelete(key).response({ (json, isCache, error) in
                })
            }
            //刷新页面
            if let row = self.form.rowBy(tag: "attachmentList") as? SW_SelectAttachmentRow {
                row.images = self.salesContract.attachmentList
                row.updateCell()
            }
            
        }
    }
    
    @objc private func backAction() {
        alertControllerShow(title: "您确定取消编辑吗？", message: nil, rightTitle: "确 定", rightBlock: { (controller, action) in
            self.navigationController?.popViewController(animated: true)
        }, leftTitle: "取 消", leftBlock: nil)
    }
    
    //MARK: - 提交按钮点击
    @objc private func handleAction(_ sender: UIBarButtonItem) {
        if salesContract.insuranceCompanyId.isEmpty {
            showAlertMessage("请选择保险公司", MYWINDOW)
            return
        }
        if salesContract.insuranceNum.isEmpty {
            showAlertMessage("请输入保单号", MYWINDOW)
            (form.rowBy(tag: "insuranceNum") as? SW_CommenFieldRow)?.showErrorLine()
            for insurance in salesContract.insuranceItems {
                (form.rowBy(tag: "\(insurance.id + insurance.name)") as? SW_CommenFieldRow)?.showErrorLine()
            }
            return
        }
        if salesContract.insuranceStartDate == 0 {
            showAlertMessage("请选择保险期间", MYWINDOW)
            return
        }
        for insurance in salesContract.insuranceItems {
            if insurance.insuredAmount == 0 {
                showAlertMessage("请输入\(insurance.name)", MYWINDOW)
                for insurance2 in salesContract.insuranceItems {
                    (form.rowBy(tag: "\(insurance2.id + insurance2.name)") as? SW_CommenFieldRow)?.showErrorLine()
                }
                return
            }
        }
        
        /// 添加一个判断是否有正在上传中的图片的逻辑，等全部上传完成后才可以提交
        guard let row = self.form.rowBy(tag: "attachmentList") as? SW_SelectAttachmentRow else { return }
        if row.upImages.count != 0 {
            showAlertMessage("附件上传中,请稍后", MYWINDOW)
            return
        }
        alertControllerShow(title: "您确定提交吗？", message: nil, rightTitle: "确 定", rightBlock: { (_, _) in
            self.postRequest()
        }, leftTitle: "取 消", leftBlock: nil)
    }
    
    
    ///保存成功后的逻辑课优化
    private func postRequest() {
        guard !isRequesting else { return }
        isRequesting = true
        QMUITips.showLoading("正在提交", in: self.view)
        SW_SalesContractService.submitInsuranceContractAudit(contractId: contractId, contract: salesContract).response({ (json, isCache, error) in
            self.isRequesting = false
            QMUITips.hideAllTips(in: self.view)
            if let _ = json as? JSON, error == nil {
                self.hadSave = true///该变量为true时不会删除上传的图片
                NotificationCenter.default.post(name: Notification.Name.Ex.SalesContractBusinessDandling, object: nil)
                showAlertMessage("提交成功", MYWINDOW)
//                self.navigationController?.popViewController(animated: true)
                if let index = self.navigationController?.viewControllers.lastIndex(where: { (vc) -> Bool in
                    return vc is SW_SalesContractListViewController
                }) {
                    self.navigationController?.popToViewController(self.navigationController!.viewControllers[index], animated: true)
                }
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                if let json = json as? JSON, json["code"].intValue == 2 {
                    if let index = self.navigationController?.viewControllers.lastIndex(where: { (vc) -> Bool in
                        return vc is SW_SalesContractListViewController
                    }) {
                        self.navigationController?.popToViewController(self.navigationController!.viewControllers[index], animated: true)
                    }
                }
            }
        })
        
    }
    
}

extension SW_ContractInsuranceEditViewController: SW_SalesContractDetailModelDelegate {
    func insuranceAmountDidChange(itemAmout: Double, allAmout: Double) {
        insuranceItemsTotalAmountRow.value = itemAmout.toAmoutString()
        insuranceItemsTotalAmountRow.updateCell()
        
        insuranceTotalAmountRow.value =  allAmout.toAmoutString()
        insuranceTotalAmountRow.updateCell()
    }
}
