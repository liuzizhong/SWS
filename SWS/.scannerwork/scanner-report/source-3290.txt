//
//  SW_ContractRegistrationEditViewController.swift
//  SWS
//
//  Created by jayway on 2019/5/28.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_ContractRegistrationEditViewController: FormViewController {
    
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
    
    init(_ salesContract: SW_SalesContractDetailModel, contractId: String) {
        super.init(nibName: nil, bundle: nil)
        self.salesContract = salesContract
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(handleAction(_:)))
        rowKeyboardSpacing = 89
        SW_StaffInfoRow.defaultCellSetup = { (cell, row) in
            cell.selectionStyle = .none
            cell.titleLb.textColor = UIColor.v2Color.darkGray
            cell.valueLb.textColor = UIColor.v2Color.darkBlack
        }
    }
    
    private func createTableView() {
        form = Form()
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = "上牌办理"
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
            
            <<< SW_CommenFieldRow("numberPlate") {
                $0.rawTitle = NSLocalizedString("车牌号", comment: "")
                $0.value = salesContract.numberPlate
                $0.limitCount = 8
                $0.isPlateKeyBoard = true
//                $0.cell.valueField.clearButtonMode = .never
                $0.cell.valueField.placeholder = "请输入车牌号(例如:粤AXXXXX)"
                }.onChange { [weak self] in
                    self?.salesContract.numberPlate = $0.value ?? ""
            }
            
            <<< SW_CommenLabelRow("handleDate") {
                $0.rawTitle = NSLocalizedString("上牌日期", comment: "")
                $0.value = salesContract.handleDate == 0 ? "" : Date.dateWith(timeInterval: salesContract.handleDate).simpleTimeString(formatter: .year)
                $0.cell.placeholder = "点击选择上牌日期"
                }.onCellSelection({ (cell, row) in
                    row.deselect()
                    let currentDate = Date()
                    let selectValue = Date.dateWith(formatStr: "yyyy-MM-dd", dateString: row.value ?? "") ?? currentDate
                    
                    BRDatePickerView.showDatePicker(withTitle: "上牌日期", on: MYWINDOW, dateType: BRDatePickerMode.init(rawValue: 6)!, defaultSelValue: selectValue, minDate: Date(timeIntervalSince1970: 0), maxDate: nil, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (key) in
                        row.value = key
                        row.updateCell()
                    }, cancel: nil)
                }).onChange { [weak self] in
                    self?.salesContract.handleDate = $0.value?.toTimeInterval(formatStr: "yyyy-MM-dd") ?? 0
            }
            
//            <<< SW_CommenFieldRow("carNumCostAmount") {
//                $0.rawTitle = NSLocalizedString("上牌成本", comment: "")
//                $0.decimalCount = 4
//                $0.amountMax = 9999999999.9999
//                $0.isAmount = true
//                $0.value = salesContract.carNumCostAmount == 0 ? "" : "\(salesContract.carNumCostAmount)"
//                $0.cell.valueField.keyboardType = .decimalPad
//                $0.cell.valueField.placeholder = "请输入上牌成本"
//                }.onChange { [weak self] in
//                    self?.salesContract.carNumCostAmount = Double($0.value ?? "") ?? 0
//            }
            
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
    //    override func sectionsHaveBeenAdded(_ sections: [Section], at indexes: IndexSet) {
    //
    //    }
    //
    //    override func rowsHaveBeenAdded(_ rows: [BaseRow], at indexes: [IndexPath]) {
    //
    //    }
    //
    
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
            if let index = addKeys.index(of: key) {
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
        if salesContract.numberPlate.isEmpty {
            (form.rowBy(tag: "numberPlate") as? SW_CommenFieldRow)?.showErrorLine()
//            (form.rowBy(tag: "carNumCostAmount") as? SW_CommenFieldRow)?.showErrorLine()
            showAlertMessage("请输入车牌号", MYWINDOW)
            return
        }
        if salesContract.handleDate == 0 {
            showAlertMessage("请选择上牌日期", MYWINDOW)
            return
        }
//        if salesContract.carNumCostAmount == 0 {
//            (form.rowBy(tag: "carNumCostAmount") as? SW_CommenFieldRow)?.showErrorLine()
//            showAlertMessage("请输入上牌成本", MYWINDOW)
//            return
//        }
        
        
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
        QMUITips.showLoading("正在办理", in: self.view)
        SW_SalesContractService.saveCarNumContractFinish(contractId: contractId, contract: salesContract).response({ (json, isCache, error) in
            self.isRequesting = false
            QMUITips.hideAllTips(in: self.view)
            if let _ = json as? JSON, error == nil {
                self.hadSave = true///该变量为true时不会删除上传的图片
                NotificationCenter.default.post(name: Notification.Name.Ex.SalesContractBusinessDandling, object: nil)
                showAlertMessage("办理成功", MYWINDOW)
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



