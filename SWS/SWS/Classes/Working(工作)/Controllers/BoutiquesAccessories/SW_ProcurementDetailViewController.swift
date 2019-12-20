//
//  SW_ProcurementDetailViewController.swift
//  SWS
//
//  Created by jayway on 2019/3/21.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_ProcurementDetailViewController: FormViewController {
    
    private var purchaseOrder = SW_ProcurementListModel()
    private var isRequesting = false
    private var purchaseOrderId: String = ""
    
    private var bottomView: SW_BottomBlueButton = {
        let btn = SW_BottomBlueButton()
        btn.addShadow()
        btn.blueBtn.isEnabled = false
        btn.blueBtn.setTitle("开始录入", for: .normal)
        btn.blueBtn.addTarget(self, action: #selector(BeganEnterAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    private var type: ProcurementType = .boutiques
    
    init(_ purchaseOrderId: String, type: ProcurementType) {
        super.init(nibName: nil, bundle: nil)
        self.purchaseOrderId = purchaseOrderId
        self.type = type
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// 进入详情页如果有新建客户页面 则去除
//        navigationController?.removeViewController([SW_TemppurchaseOrderDetailViewController.self,SW_CreatepurchaseOrderViewController.self])
        formConfig()
        createTableView()
        getPurchaseOrderData()
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(TABBAR_BOTTOM_INTERVAL + 54)
        }
        bottomView.blueBtn.snp.remakeConstraints { (make) in
            make.leading.equalTo(15)
            make.top.equalTo(5)
            make.trailing.equalTo(-15)
            make.height.equalTo(44)
        }
//        setupNotification()
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
    
//    private func setupNotification() {
        /// 用户编辑了客户意向信息
//        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadEditpurchaseOrderIntention, object: nil, queue: nil) { [weak self] (notifa) in
//            let id = notifa.userInfo?["purchaseOrderId"] as! String
//            if self?.purchaseOrderId == id {
//                self?.getPurchaseOrderData()
//            }
//        }
//    }
    
    //获取客户信息刷新页面
    fileprivate func getPurchaseOrderData() {
        var request: SWSRequest
        if type == .boutiques {
            request = SW_WorkingService.getBoutiqueInOrderDetail(purchaseOrderId)
        } else {
            request = SW_WorkingService.getAccessoriesInOrderDetail(purchaseOrderId)
        }
        request.response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.purchaseOrder = SW_ProcurementListModel(json, type: self.type)
                self.bottomView.blueBtn.isEnabled = true
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
            Eureka.Section() { [weak self] section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = self?.purchaseOrder.orderNo ?? ""
                }
                section.header = header
        }

            <<< SW_StaffInfoRow("supplier") {
                $0.rowTitle = NSLocalizedString("供   应   商   ", comment: "")
                $0.isShowBottom = false
                $0.value = purchaseOrder.supplier
            }
            <<< SW_StaffInfoRow("In the area") {
                $0.rowTitle = NSLocalizedString("采 购 类 型   ", comment: "")
                $0.isShowBottom = false
                $0.value =  purchaseOrder.fromType.rawTitle
            }
            <<< SW_StaffInfoRow("payType") {
                $0.rowTitle = NSLocalizedString("支 付 类 型   ", comment: "")
                $0.isShowBottom = false
                $0.value = purchaseOrder.payType.rawTitle
            }
            <<< SW_StaffInfoRow("invoiceType") {
                $0.rowTitle = NSLocalizedString("发 票 类 型   ", comment: "")
                $0.isShowBottom = false
                $0.value = purchaseOrder.invoiceType.rawTitle
            }
            <<< SW_StaffInfoRow("rate") {
                $0.rowTitle = NSLocalizedString("税           率   ", comment: "")
                $0.isShowBottom = false
                $0.value = purchaseOrder.rate == 0 ? "" : "\(purchaseOrder.rate)%"
            }
            <<< SW_StaffInfoRow("bUnitName") {
                $0.rowTitle = NSLocalizedString("采 购 单 位   ", comment: "")
                $0.isShowBottom = false
                $0.value = purchaseOrder.bUnitName
            }
            <<< SW_StaffInfoRow("purchaser") {
                $0.rowTitle = NSLocalizedString("采购入库人   ", comment: "")
                $0.isShowBottom = false
                $0.value = purchaseOrder.purchaser
            }
            <<< SW_StaffInfoRow("buyDate") {
                $0.rowTitle = NSLocalizedString("采 购 时 间   ", comment: "")
                $0.isShowBottom = false
                $0.value = purchaseOrder.buyDateString
            }
            <<< SW_StaffInfoRow("remark") {
                $0.rowTitle = NSLocalizedString("备           注   ", comment: "")
                $0.isShowBottom = false
                $0.value = purchaseOrder.remark
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    @objc private func BeganEnterAction(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        
        let vc = SW_BarCodeScanViewViewController({ [weak self] (code) in
            guard let self = self else { return }
            guard !self.isRequesting else { return }
            self.isRequesting = true
            /// 可用的结果
            //        let code = str.addingPercentEncoding(withAllowedCharacters: customAllowedSet) ?? str
            var request: SWSRequest
            if self.type == .boutiques {
                request = SW_WorkingService.getBoutiqueDetail(code, orderId: self.purchaseOrderId)
            } else {
                request = SW_WorkingService.getAccessoriesDetail(code, orderId: self.purchaseOrderId)
            }
            request.response({ (json, isCache, error) in
                self.isRequesting = false
                var orderSupplierName = ""
                if let json = json as? JSON, error == nil {
                    if json["id"].stringValue.isEmpty {///如果是空,说明无数据，要新建
                        self.navigationController?.pushViewController(SW_AddBoutiquesAccessoriesViewController(code, type: self.type, purchaseOrderId: self.purchaseOrderId, supplier: self.purchaseOrder.supplier, supplierId: self.purchaseOrder.supplierId), animated: true)
                    } else {/// 跳转到输入数量界面
                        let model = SW_BoutiquesAccessoriesModel(json, type: self.type)
                        self.navigationController?.pushViewController(SW_BoutiquesAccessoriesDetailViewController(model, type: self.type, orderId: self.purchaseOrderId), animated: true)
                    }
                    orderSupplierName = json["orderSupplierName"].stringValue
                } else {
                    if let json = json as? JSON, json["code"].intValue == 2 {/// 
                        self.show(json["msg"].stringValue)
                        
                        orderSupplierName = json["data"]["orderSupplierName"].stringValue
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                        NotificationCenter.default.post(name: NSNotification.Name.Ex.BarCodeScanShouldReStart, object: nil)
                        return
                    }
                }
                if let supplierRow =  self.form.rowBy(tag: "supplier") as? SW_StaffInfoRow  {
                    supplierRow.value = orderSupplierName
                    supplierRow.updateCell()
                }
            })
            }, titleString: "录入" + type.rawTitle)
        //TODO:待设置框内识别
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    lazy var errorMsgLb: UILabel = {
        let lb = UILabel()
        lb.font = Font(16)
        lb.textColor = UIColor.v2Color.lightBlack
        lb.textAlignment = .center
        return lb
    }()
    
    func show(_ error: String) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 30, height: 150))
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 3.0
        view.addSubview(errorMsgLb)
        errorMsgLb.text = error
        errorMsgLb.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let dimmingView = UIView()
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        
        let vc = QMUIModalPresentationViewController()
        
        vc.dimmingView = dimmingView
        vc.animationStyle = .popup
        vc.contentView = view
        vc.supportedOrientationMask = .portrait
        vc.didHideByDimmingViewTappedBlock = {
            NotificationCenter.default.post(name: NSNotification.Name.Ex.BarCodeScanShouldReStart, object: nil)
        }
        vc.showWith(animated: true, completion: nil)
    }
}
