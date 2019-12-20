//
//  SW_AuditSaleContractViewController.swift
//  SWS
//
//  Created by jayway on 2019/8/21.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

/// 当前页面显示表格类型
///
/// - boutique: 合同精品
/// - other: 其他费用
/// - insurance: 保险信息
enum AuditSaleContractPageType {
    case boutique
    case other
    case insurance
}

class SW_AuditSaleContractViewController: FormViewController {
    
    private var pageType = AuditSaleContractPageType.boutique {
        didSet {
            if pageType != oldValue {
                createTableView()
            }
        }
    }
    
    private lazy var boutiqueRow: SW_AuditSaleContravtBoutiqueFormRow = { [weak self] in
        let row = SW_AuditSaleContravtBoutiqueFormRow("SW_AuditSaleContravtBoutiqueFormRow") {
            guard let self = self else { return }
            $0.value = self.salesContract.boutiqueContractList
        }
        return row
    }()
    
    private lazy var otherRow: SW_AuditSaleContravtOtherFormRow = { [weak self] in
        let row = SW_AuditSaleContravtOtherFormRow("SW_AuditSaleContravtOtherFormRow") {
            guard let self = self else { return }
            $0.value = self.salesContract.otherInfoContractList
        }
        return row
        }()
    
    private lazy var insuranceRow: SW_AuditSaleContravtInsuranceFormRow = { [weak self] in
        let row = SW_AuditSaleContravtInsuranceFormRow("SW_AuditSaleContravtInsuranceFormRow") {
            guard let self = self else { return }
            $0.value = self.salesContract.insuranceList
        }
        return row
        }()
    
    private var modifyAuditState: AuditState = .noCommit
    private var salesContract: SW_PurchaseCarRecordDetailModel!
    private var contractId: String = ""
    private var isRequesting = false
    
    lazy var navTitleView: SW_NavTitleView = {
        let view = Bundle.main.loadNibNamed("SW_NavTitleView", owner: nil, options: nil)?.first as! SW_NavTitleView
        view.backBlock = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        return view
    }()
    
    lazy var topView: SW_AuditSaleContractTopView = {
        let view = Bundle.main.loadNibNamed("SW_AuditSaleContractTopView", owner: nil, options: nil)?.first as! SW_AuditSaleContractTopView
        return view
    }()
    
    private lazy var bottomView: SW_BottomBlueButton = {
        let btn = SW_BottomBlueButton()
        btn.addShadow()
        btn.blueBtn.setTitle("审核", for: .normal)
        btn.blueBtn.addTarget(self, action: #selector(auditAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    init(_ contractId: String, modifyAuditState: AuditState) {
        super.init(nibName: nil, bundle: nil)
        self.contractId = contractId
        self.modifyAuditState = modifyAuditState
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formConfig()
        getsalesContractData()
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //获取客户信息刷新页面
    fileprivate func getsalesContractData() {
        SW_AddressBookService.getCarSalesContractDetail(contractId, modifyAuditState: modifyAuditState).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.salesContract = SW_PurchaseCarRecordDetailModel(json)
                self.setupView()
                self.createTableView()
            } else {
                self.navigationController?.popViewController(animated: true)
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
    }
    private func setupView() {
        if salesContract.auditState == .wait || salesContract.invalidAuditState == .wait || modifyAuditState == .wait {
            view.addSubview(bottomView)
            bottomView.snp.makeConstraints { (make) in
                make.leading.trailing.bottom.equalToSuperview()
                make.height.equalTo(TABBAR_BOTTOM_INTERVAL + 64)
            }
            bottomView.blueBtn.snp.remakeConstraints { (make) in
                make.leading.equalTo(15)
                make.top.equalTo(10)
                make.trailing.equalTo(-15)
                make.height.equalTo(44)
            }
        }
        if salesContract.invalidAuditState == .wait {
//            invalidRemark  弹窗提示作废原因
            navTitleView.rightBlock = { [weak self] in
                self?.showInvalidRemark()
            }
            navTitleView.riightBtn.setTitle("作废原因", for: UIControl.State())
            bottomView.blueBtn.setTitle("审核（作废）", for: UIControl.State())
            showInvalidRemark()
        } else if modifyAuditState == .wait {
            navTitleView.rightBlock = { [weak self] in
                self?.showModifyRemark()
            }
            navTitleView.riightBtn.setTitle("修改原因", for: UIControl.State())
            bottomView.blueBtn.setTitle("审核（修改）", for: UIControl.State())
            showModifyRemark()
        }
        
        view.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.equalTo(navTitleView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        topView.receivableAmountLb.text = salesContract.receivableAmount.toAmoutString()
        topView.contractAmountLb.text = salesContract.contractAmount.toAmoutString()
        topView.paidAmountLb.text = salesContract.paidAmount.toAmoutString()
        topView.uncollectedAmountLb.text = salesContract.uncollectedAmount.toAmoutString()
        navTitleView.title = salesContract.contractNum
    }
    
    //MARK: - Action
    private func formConfig() {
        navigationOptions = RowNavigationOptions.Enabled
        view.backgroundColor = .white
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        tableView.bounces = false
        tableView.contentInset = UIEdgeInsets(top: 88 + NAV_HEAD_INTERVAL, left: 0, bottom: TABBAR_BOTTOM_INTERVAL + 64, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 44 + NAV_HEAD_INTERVAL, left: 0, bottom: TABBAR_BOTTOM_INTERVAL, right: 0)
        
        tableView.ly_emptyView = SW_LoadingEmptyView.creat()
        tableView.ly_emptyView.contentViewOffset = -(SCREEN_HEIGHT - 100) * 0.15
        tableView.rowHeight = UITableView.automaticDimension
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
            cell.rightLb.font = Font(14)
            cell.rightLb.textColor = UIColor.v2Color.blue
        }
        
        view.addSubview(navTitleView)
        navTitleView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(NAV_HEAD_INTERVAL + 44)
        }
    }
    
    private func createTableView() {
        form = Form()
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = "基本信息"
                }
                section.header = header
            }
            <<< SW_StaffInfoRow("realName") {
                $0.rowTitle = NSLocalizedString("客   户  名   称   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.realName
        }

            <<< SW_StaffInfoRow("phoneNum") {
                $0.rowTitle = NSLocalizedString("联   系  方   式   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.phoneNum
            }
            
            <<< SW_StaffInfoRow("Vehicle information") {
                $0.rowTitle = NSLocalizedString("车   型  信   息   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.carBrand.isEmpty ? "" : salesContract.carBrand + "  " + salesContract.carSeries + "  " + salesContract.carModel + "  " + salesContract.carColor
            }
            <<< SW_StaffInfoRow("Contract state") {
                $0.rowTitle = NSLocalizedString("合   同  状   态   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.payState.rawTitle
            }
            
            <<< SW_StaffInfoRow("Terms of payment") {
                $0.rowTitle = NSLocalizedString("付   款  方   式   ", comment: "")
                $0.isShowBottom = false
                if salesContract.paymentWay == 1 {
                    $0.value = "按揭   \(salesContract.mortgageAmount.toAmoutString())   \(salesContract.mortgagePeriod)期"
                } else {
                    $0.value = "全款"
                }
            }
            
            <<< SW_StaffInfoRow("Expected delivery date") {
                $0.rowTitle = NSLocalizedString("预计交车日期   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.deliveryDate == 0 ? "" : Date.dateWith(timeInterval: salesContract.deliveryDate).stringWith(formatStr: "yyyy.MM.dd")
            }
            <<< SW_StaffInfoRow("bUnitName") {
                $0.rowTitle = NSLocalizedString("所   属  单   位   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.bUnitName
            }
            <<< SW_StaffInfoRow("saleName") {
                $0.rowTitle = NSLocalizedString("销   售  顾   问   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.saleName
            }
            <<< SW_StaffInfoRow("car retailPrice") {
                $0.rowTitle = NSLocalizedString("车 辆 零 售 价   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.retailPrice.toAmoutString()
            }
            <<< SW_StaffInfoRow("vin") {
                $0.rowTitle = NSLocalizedString("车      架      号   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.vin.isEmpty ? "未分配" : salesContract.vin
            }
            
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = "合同信息"
                }
                section.header = header
            }
//             表格 位置
            <<< SW_AuditSaleContractTypeHeaderRow("SW_AuditSaleContractTypeHeaderRow") { [weak self] in
                $0.typeChangeBlock = { (infoType) in
                    self?.pageType = infoType
                }
                $0.value = self?.pageType
            }
            
        switch pageType {
        case .boutique:
            form.last!
                <<<
                boutiqueRow
        case .other:
            form.last!
                <<<
                otherRow
        case .insurance:
            form.last!
                <<<
                insuranceRow
        }
        
            form.last!
            <<< SW_StaffInfoRow("carAmount") {
                $0.rowTitle = NSLocalizedString("    车 辆 金 额   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.carAmount.toAmoutString()
            }
            <<< SW_StaffInfoRow("boutiqueAmount") {
                $0.rowTitle = NSLocalizedString("    合 同 精 品   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.boutiqueAmount.toAmoutString()
            }
            <<< SW_StaffInfoRow("carShipTaxAmount") {
                $0.rowTitle = NSLocalizedString("    车    船   税   ", comment: "")
                $0.isShowBottom = false
                $0.leftValue = salesContract.carShipTaxType
                $0.value = salesContract.carShipTaxAmount.toAmoutString()
        }
            <<< SW_StaffInfoRow("compulsoryInsuranceAmount") {
                $0.rowTitle = NSLocalizedString("    交    强   险   ", comment: "")
                $0.isShowBottom = false
                $0.leftValue = salesContract.compulsoryInsuranceType
                $0.value = salesContract.compulsoryInsuranceAmount.toAmoutString()
            }
            <<< SW_StaffInfoRow("commercialInsuranceAmount") {
                $0.rowTitle = NSLocalizedString("    商    业   险   ", comment: "")
                $0.isShowBottom = false
                $0.leftValue = salesContract.commercialInsuranceType
                $0.value = salesContract.commercialInsuranceAmount.toAmoutString()
            }
            <<< SW_StaffInfoRow("carNumAmount") {
                $0.rowTitle = NSLocalizedString("    上           牌   ", comment: "")
                $0.isShowBottom = false
                $0.leftValue = salesContract.carNumType
                $0.value = salesContract.carNumAmount.toAmoutString()
        }
            <<< SW_StaffInfoRow("carPurchaseTaxAmount") {
                $0.rowTitle = NSLocalizedString("    购    置   税   ", comment: "")
                $0.isShowBottom = false
                $0.leftValue = salesContract.carPurchaseTaxType
                $0.value = salesContract.carPurchaseTaxAmount.toAmoutString()
        }
            <<< SW_StaffInfoRow("mortgageHandlingAmount") {
                $0.rowTitle = NSLocalizedString("    按 揭 费 用   ", comment: "")
                $0.isShowBottom = false
                $0.leftValue = salesContract.mortgageCostType
                $0.value = salesContract.mortgageHandlingAmount.toAmoutString()
        }
            <<< SW_StaffInfoRow("otherAmount") {
                $0.rowTitle = NSLocalizedString("    其 他 费 用   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.otherAmount.toAmoutString()
        }
            <<< SW_StaffInfoRow("codicil1") {
                $0.rowTitle = NSLocalizedString("    附加条款 1   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.codicil1
        }
            <<< SW_StaffInfoRow("codicil2") {
                $0.rowTitle = NSLocalizedString("    附加条款 2   ", comment: "")
                $0.isShowBottom = false
                $0.value = salesContract.codicil2
        }
        
        tableView.reloadData()
    }
    
    //MARK: - private func
    @objc private func auditAction(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        guard !isRequesting else {
            showAlertMessage("审核中，请勿重复操作", MYWINDOW)
            return
        }
        SW_AuditTextModalView.show(placeholder: "请填写审核信息（特别是在驳回时）", limitCount: 100, sureBlock: { (text) in
            self.postRequest(text, isReject:2)
        }, rejectBlock: { (text) in
            self.postRequest(text, isReject:1)
        }, isShouldHadTextToDismiss: false)
        
    }
    
    private func postRequest(_ text: String, isReject: Int) {
        guard !isRequesting else {
            showAlertMessage("审核中，请勿重复操作", MYWINDOW)
            return
        }
        isRequesting = true
        var request: SWSRequest
        /// 作废审核
        if salesContract.invalidAuditState == .wait {
            request = SW_AddressBookService.carSalesContractInvalidAudit(contractId, remark: text, isReject: isReject)
        } else if modifyAuditState == .wait {// 修改审核
            request = SW_AddressBookService.carSalesContractModifyAudit(contractId, remark: text, isReject: isReject)
        } else {
            request = SW_AddressBookService.carSalesContractAudit(contractId, remark: text, isReject: isReject)
        }
        
        request.response({ (json, isCache, error) in
            if let _ = json as? JSON, error == nil {
//                审核成功，列表移除该item，退出页面
                showAlertMessage("审核成功", MYWINDOW)
                NotificationCenter.default.post(name: NSNotification.Name.Ex.SalesContractHadAudit, object: nil, userInfo: ["orderId": self.contractId])
                self.navigationController?.popViewController(animated: true)
            } else {
                if let json = json as? JSON, json["code"].intValue == 2 {
                    showAlertMessage(json["msg"].stringValue, MYWINDOW)
                    NotificationCenter.default.post(name: NSNotification.Name.Ex.SalesContractHadAudit, object: nil, userInfo: ["orderId": self.contractId])
                    self.navigationController?.popViewController(animated: true)
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                }
            }
            self.isRequesting = false
        })
    }
    
    /// 显示作废原因
    private func showInvalidRemark() {
        SW_InvalidRemarkModalView.show(salesContract.invalidRemark, title: "作废原因")
    }
    
    /// 显示修改原因
    private func showModifyRemark() {
        SW_InvalidRemarkModalView.show(salesContract.modifyRemark, title: "修改原因")
    }
    
    /// 用于计算上下滑动方向
    private var lastOffset: CGFloat = 0
    
    /// 当前是否显示搜索框，默认显示
    private var currentShowState = true
    
    private func showOrHideNavTitle(show: Bool) {
        /// 状态相同return
        guard currentShowState != show else { return }
        guard isCurrentViewControllerVisible() else { return }
        
        currentShowState = show
        
        navTitleView.showOrHideSubView(show: show, duration: 0.1)
        navTitleView.snp.updateConstraints { (update) in
            update.height.equalTo(show ? NAV_HEAD_INTERVAL + 44 : NAV_HEAD_INTERVAL)
        }
        UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSet = scrollView.contentOffset.y
        if scrollView.isDragging {/// 拖动才进行显隐
            showOrHideNavTitle(show: offSet - lastOffset < 0)
        }
        lastOffset = offSet
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
