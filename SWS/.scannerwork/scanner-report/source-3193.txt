//
//  SW_AuditRepairOrderViewController.swift
//  SWS
//
//  Created by jayway on 2019/8/23.
//  Copyright © 2019 yuanrui. All rights reserved.
//

/// 当前页面显示表格类型
///
/// - item: 维修项目
/// - accessories: 配件
/// - boutique: 精品
/// - other: 其他费用
/// - repairPackage: 活动套餐
/// - coupons: 优惠券
/// - suggest: 建议项目
enum AuditRepairOrderPageType: Int {
    case item           = 0
    case accessories
    case boutique
    case other
    case repairPackage
    case coupons
    case suggest
}

import Eureka

class SW_AuditRepairOrderViewController: FormViewController {
    
    private var pageType = AuditRepairOrderPageType.item {
        didSet {
            if pageType != oldValue {
                createTableView()
            }
        }
    }
    
    private lazy var typeHeaderRow: SW_AuditRepairOrderTypeHeaderRow = { [weak self] in
        let row = SW_AuditRepairOrderTypeHeaderRow("SW_AuditRepairOrderTypeHeaderRow") {
            $0.typeChangeBlock = { (infoType) in
                self?.pageType = infoType
            }
            $0.value = self?.pageType
        }
        return row
    }()

    private lazy var itemRow: SW_AuditRepairOrderItemFormRow = { [weak self] in
        let row = SW_AuditRepairOrderItemFormRow("SW_AuditRepairOrderItemFormRow") {
            guard let self = self else { return }
            $0.value = self.repairOrder.repairOrderItemList
        }
        return row
        }()

    private lazy var accessoriesRow: SW_AuditRepairOrderAccessoriesFormRow = { [weak self] in
        let row = SW_AuditRepairOrderAccessoriesFormRow("SW_AuditRepairOrderAccessoriesFormRow") {
            guard let self = self else { return }
            $0.value = self.repairOrder.repairOrderAccessoriesList
        }
        return row
        }()
    
    private lazy var boutiqueRow: SW_AuditRepairOrderBoutiquesFormRow = { [weak self] in
        let row = SW_AuditRepairOrderBoutiquesFormRow("SW_AuditRepairOrderBoutiquesFormRow") {
            guard let self = self else { return }
            $0.value = self.repairOrder.repairOrderBoutiquesList
        }
        return row
        }()

    private lazy var otherRow: SW_AuditRepairOrderOtherFormRow = { [weak self] in
        let row = SW_AuditRepairOrderOtherFormRow("SW_AuditRepairOrderOtherFormRow") {
            guard let self = self else { return }
            $0.value = self.repairOrder.repairOrderOtherInfoList
        }
        return row
        }()
    
    private lazy var repairPackageRow: SW_AuditRepairOrderPackageFormRow = { [weak self] in
        let row = SW_AuditRepairOrderPackageFormRow("SW_AuditRepairOrderPackageFormRow") {
            guard let self = self else { return }
            $0.value = self.repairOrder.repairPackageItemList
        }
        return row
        }()
    
    private lazy var couponsRow: SW_AuditRepairOrderCouponsFormRow = { [weak self] in
        let row = SW_AuditRepairOrderCouponsFormRow("SW_AuditRepairOrderCouponsFormRow") {
            guard let self = self else { return }
            $0.value = self.repairOrder.repairOrderCouponsList
        }
        return row
        }()
    
    private var repairOrder: SW_AuditRepairOrderDetailModel!
    private var orderId: String = ""
    private var isRequesting = false
    
    lazy var navTitleView: SW_NavTitleView = {
        let view = Bundle.main.loadNibNamed("SW_NavTitleView", owner: nil, options: nil)?.first as! SW_NavTitleView
        view.backBlock = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        return view
    }()
    
    lazy var topView: SW_AuditRepairOrderTopView = {
        let view = Bundle.main.loadNibNamed("SW_AuditRepairOrderTopView", owner: nil, options: nil)?.first as! SW_AuditRepairOrderTopView
        return view
    }()
    
    private lazy var bottomView: SW_BottomBlueButton = {
        let btn = SW_BottomBlueButton()
        btn.addShadow()
        btn.blueBtn.setTitle("审核", for: .normal)
        btn.blueBtn.addTarget(self, action: #selector(auditAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    init(_ orderId: String) {
        super.init(nibName: nil, bundle: nil)
        self.orderId = orderId
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formConfig()
        getrepairOrderData()
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
    fileprivate func getrepairOrderData() {
        SW_AfterSaleService.showRepairOrder(orderId).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.repairOrder = SW_AuditRepairOrderDetailModel(json)
                self.setupView()
                self.createTableView()
            } else {
                self.navigationController?.popViewController(animated: true)
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
    }
    private func setupView() {
        if repairOrder.auditState == .wait {
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
        
        view.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.equalTo(navTitleView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        topView.receivableAmountLb.text = repairOrder.receivableAmount.toAmoutString()
        topView.paidenAmountLb.text = repairOrder.paidedAmount.toAmoutString()
        topView.packageAmountLb.text = repairOrder.packageAmount.toAmoutString()
        topView.deductibleAmountLb.text = repairOrder.deductibleTotalAmount.toAmoutString()
        topView.uncollectedAmount.text = repairOrder.uncollectedAmount.toAmoutString()
        navTitleView.title = repairOrder.repairOrderNum
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
                $0.rowTitle = NSLocalizedString("客 户 名 称   ", comment: "")
                $0.isShowBottom = false
                $0.value =  repairOrder.realName
            }
            
            <<< SW_StaffInfoRow("phoneNum1") {
                $0.rowTitle = NSLocalizedString("联 系 方 式   ", comment: "")
                $0.isShowBottom = false
                $0.value =  repairOrder.phoneNum1
            }
            <<< SW_StaffInfoRow("numberPlate") {
                $0.rowTitle = NSLocalizedString("车   牌   号   ", comment: "")
                $0.isShowBottom = false
                $0.value = repairOrder.numberPlate
            }
            <<< SW_StaffInfoRow("Vehicle information") {
                $0.rowTitle = NSLocalizedString("车 型 信 息   ", comment: "")
                $0.isShowBottom = false
                $0.value = repairOrder.carBrand.isEmpty ? "" : repairOrder.carBrand + "  " + repairOrder.carSeries + "  " + repairOrder.carModel + "  " + repairOrder.carColor
            }
            <<< SW_StaffInfoRow("customerInfoType") {
                $0.rowTitle = NSLocalizedString("维修单类型   ", comment: "")
                $0.isShowBottom = false
                switch repairOrder.customerInfoType {// 0 个人  1 公户  2 新车
                case 1:
                    $0.value = "公户"
                case 2:
                    $0.value = "新车"
                default:
                    $0.value = "个人"
                }
            }
        
            <<< SW_StaffInfoRow("payState") {
                $0.rowTitle = NSLocalizedString("维修单状态   ", comment: "")
                $0.isShowBottom = false
                $0.value =  repairOrder.payState.rawTitle
            }
            
            <<< SW_StaffInfoRow("repairBusinessTypeStr") {
                $0.rowTitle = NSLocalizedString("业 务 类 型   ", comment: "")
                $0.isShowBottom = false
                $0.value =  repairOrder.repairBusinessTypeStr
            }
            
            <<< SW_StaffInfoRow("payType") {
                $0.rowTitle = NSLocalizedString("结 账 类 型   ", comment: "")
                $0.isShowBottom = false
                $0.value =  repairOrder.payType == 1 ? "即结" : "挂账"
            }
            <<< SW_StaffInfoRow("bUnitName") {
                $0.rowTitle = NSLocalizedString("所 属 单 位   ", comment: "")
                $0.isShowBottom = false
                $0.value = repairOrder.bUnitName
            }
            <<< SW_StaffInfoRow("saleName") {
                $0.rowTitle = NSLocalizedString("销 售 顾 问   ", comment: "")
                $0.isShowBottom = false
                $0.value = repairOrder.staffName
            }
            <<< SW_StaffInfoRow("inStockDateString") {
                $0.rowTitle = NSLocalizedString("入 厂 时 间   ", comment: "")
                $0.isShowBottom = false
                $0.value = repairOrder.inStockDate == 0 ? "" : repairOrder.inStockDateString
            }
            <<< SW_StaffInfoRow("completeDateString") {
                $0.rowTitle = NSLocalizedString("出 厂 时 间   ", comment: "")
                $0.isShowBottom = false
                $0.value = repairOrder.completeDate == 0 ? "未出厂" : repairOrder.completeDateString
            }
            
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = "维修单详情"
                }
                section.header = header
            }
        
        <<< typeHeaderRow
        
        switch pageType {
        case .item:
            form.last! <<< itemRow
        case .accessories:
            form.last! <<< accessoriesRow
        case .boutique:
            form.last! <<< boutiqueRow
        case .other:
            form.last! <<< otherRow
        case .repairPackage:
            form.last! <<< repairPackageRow
        case .coupons:
            form.last! <<< couponsRow
        case .suggest:
            break
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
            self.postRequest(text, isReject:0)
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
        SW_AfterSaleService.orderAudit(orderId, remark: text, isReject: isReject).response({ (json, isCache, error) in
            if let _ = json as? JSON, error == nil {
                //                审核成功，列表移除该item，退出页面
                showAlertMessage("审核成功", MYWINDOW)
                NotificationCenter.default.post(name: NSNotification.Name.Ex.SalesContractHadAudit, object: nil, userInfo: ["orderId": self.orderId])
                self.navigationController?.popViewController(animated: true)
            } else {
                if let json = json as? JSON, json["code"].intValue == 2 {
                    showAlertMessage(json["msg"].stringValue, MYWINDOW)
                    NotificationCenter.default.post(name: NSNotification.Name.Ex.SalesContractHadAudit, object: nil, userInfo: ["orderId": self.orderId])
                    self.navigationController?.popViewController(animated: true)
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                }
            }
            self.isRequesting = false
        })
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
