//
//  SW_BoutiqueInstallDetailViewController.swift
//  SWS
//
//  Created by jayway on 2019/11/14.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_BoutiqueInstallDetailViewController: FormViewController {
    
    private var salesContract: SW_BoutiqueInstallDetailModel!
    private var contractId: String = ""
    /// 合同作废状态，3表示作废成功
    private var canInstall = true
    private var reloadBlock: NormalBlock
    
    /// 已作废||已安装状态-》隐藏完成安装按钮，隐藏输入框，
    ///  其余情况都显示输入框，完成安装按钮，限制（输入框输入范围 = 实际出库数量-已安装数量）
    init(_ contractId: String, canInstall: Bool, reloadBlock: @escaping NormalBlock) {
        self.reloadBlock = reloadBlock
        super.init(nibName: nil, bundle: nil)
        self.contractId = contractId
        self.canInstall = canInstall
        self.salesContract = SW_BoutiqueInstallDetailModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formConfig()
        createTableView()
        getsalesContractData()
    }
    
    deinit {
//        NotificationCenter.default.removeObserver(self)
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
    
    //获取客户信息刷新页面
    fileprivate func getsalesContractData() {
        SW_WorkingService.getBoutiqueContractDetailShow(contractId).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.salesContract = SW_BoutiqueInstallDetailModel(json)
                if self.salesContract.concreteOutStockNum != 0 && self.salesContract.concreteOutStockNum == self.salesContract.boutiqueInstallCount {
                    self.canInstall = false
                }
                self.createTableView()
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                //                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    //MARK: - Action
    private func formConfig() {
        navigationOptions = RowNavigationOptions.Enabled
        view.backgroundColor = .white
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL + 54, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        rowKeyboardSpacing = 50
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = false
        }
        
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
                    view.title = "合同详情"
                }
                section.header = header
            }
            <<< SW_StaffInfoRow("Contract no") {
                $0.rowTitle = NSLocalizedString("合同编号   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.contractNum
            }
            <<< SW_StaffInfoRow("Sales consultant") {
                $0.rowTitle = NSLocalizedString("销售顾问   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.saleName
            }
            <<< SW_StaffInfoRow("vin") {
                $0.rowTitle = NSLocalizedString("车  架  号   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.vin.isEmpty ? "未分配" : salesContract.vin
            }
            <<< SW_StaffInfoRow("Vehicle information") {
                $0.rowTitle = NSLocalizedString("车型信息   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.carBrand.isEmpty ? "" : salesContract.carBrand + "  " + salesContract.carSeries + "  " + salesContract.carModel + "  " + salesContract.carColor
            }
        +++
        Eureka.Section() { section in
            var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
            header.height = {70}
            header.onSetupView = { view, _ in
                view.title = "精品信息"
            }
            section.header = header
        }
        
        for index in 0..<salesContract.boutiqueContractList.count {
            let model = salesContract.boutiqueContractList[index]
            form.last!
            <<< SW_ContractBoutiqueInstallRow("SW_ContractBoutiqueInstallRow \(index)") {
                $0.model = model
                $0.canInstall = canInstall
                $0.maxCount = max(0, model.concreteOutStockNum - model.installCount)
                $0.value = model.nowInstallCount == nil ? "" : model.nowInstallCount!.toAmoutString()
            }.onChange {
                if $0.value?.isEmpty == true {
                    model.nowInstallCount = nil
                } else {
                    model.nowInstallCount = Double($0.value ?? "0")
                }
            }
        }
        
        /// 可以进行安装才显示按钮
        if canInstall {
            form
                +++
                Section() { [weak self] section in
                    var header = HeaderFooterView<SW_ArchiveButtonView>(.nibFile(name: "SW_ArchiveButtonView", bundle: nil))
                    header.height = {80}
                    header.onSetupView = { view, _ in
                        view.leftConstraint.constant = 15
                        view.rightConstraint.constant = 15
                        view.button.layer.borderWidth = 0
                        view.button.setTitle("完成安装", for: UIControl.State())
                        view.button.isEnabled = true
                        view.button.setBackgroundImage(UIImage(color: UIColor.v2Color.blue), for: UIControl.State())
                        view.button.setBackgroundImage(UIImage(color: UIColor(hexString: "#267cc4")), for: .highlighted)
                        view.button.setTitleColor(UIColor.white, for: UIControl.State())
//                        view.button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .disabled)
                        view.button.titleLabel?.font = Font(16)
                        view.actionBlock = {
                            /// 点击办理按钮
                            self?.handleBtnAction()
                        }
                    }
                    section.header = header
            }
        }
        
        tableView.reloadData()
    }
    
    
    private var isRequesting = false
    //MARK: -private func
    private func handleBtnAction() {
        guard !isRequesting else { return }
        
        let filterList = salesContract.boutiqueContractList.filter { (model) -> Bool in
            if let count = model.nowInstallCount, count > 0 {
                return true
            }
            return false
        }
        if filterList.count == 0 {
            showAlertMessage("该合同单无符合安装条件的精品", nil)
            return
        }
        
        isRequesting = true
        QMUITips.showLoading("正在安装", in: self.view)
        /// 本次安装数量+已安装数量==出库数量  -》状态变化为已安装 更新列表
        SW_WorkingService.installBoutique(contractId, installList: filterList).response({ (json, isCache, error) in
            if let _ = json as? JSON, error == nil {
                showAlertMessage("安装成功", nil)
                let nowAllCount = filterList.reduce(0) { (result, model) -> Double in
                    return result + model.nowInstallCount!
                }
                if nowAllCount + self.salesContract.boutiqueInstallCount == self.salesContract.concreteOutStockNum {
                    self.reloadBlock()
                }
                self.navigationController?.popViewController(animated: true)
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
            QMUITips.hideAllTips(in: self.view)
            self.isRequesting = false
        })
        
    }
    
    //MARK: - FormViewControllerProtocol   重写一下方法是因为需要去除该库添加时的动画
    override func sectionsHaveBeenAdded(_ sections: [Section], at indexes: IndexSet) {
        
    }
    
    override func rowsHaveBeenAdded(_ rows: [BaseRow], at indexes: [IndexPath]) {
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
}
