//
//  SW_InventoryDetailViewController.swift
//  SWS
//
//  Created by jayway on 2019/4/8.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_InventoryDetailViewController: FormViewController {
    
    private var order = SW_InventoryListModel()
    private var isRequesting = false
    private var orderId: String = ""
    
    private var bottomView: SW_BottomBlueButton = {
        let btn = SW_BottomBlueButton()
        btn.addShadow()
        btn.blueBtn.isEnabled = false
        btn.blueBtn.setTitle("开始盘点", for: .normal)
        btn.blueBtn.addTarget(self, action: #selector(BeganEnterAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    private var type: ProcurementType = .boutiques
    
    init(_ orderId: String, type: ProcurementType) {
        super.init(nibName: nil, bundle: nil)
        self.orderId = orderId
        self.type = type
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// 进入详情页如果有新建客户页面 则去除
        //        navigationController?.removeViewController([SW_TemporderDetailViewController.self,SW_CreateorderViewController.self])
        formConfig()
        createTableView()
        getOrderData()
        
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
//            NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadEditorderIntention, object: nil, queue: nil) { [weak self] (notifa) in
//                let id = notifa.userInfo?["orderId"] as! String
//                if self?.orderId == id {
//                    self?.getorderData()
//                }
//            }
    //    }
    
    //获取客户信息刷新页面
    fileprivate func getOrderData() {
        SW_WorkingService.getInventoryOrderDetail(type, id: orderId).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.order = SW_InventoryListModel(json, type: self.type)
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
                    view.title = self?.order.orderNo ?? ""
                }
                section.header = header
            }
            <<< SW_StaffInfoRow("warehouseName") {
                $0.rowTitle = NSLocalizedString("盘 点 仓 库   ", comment: "")
                $0.isShowBottom = false
                $0.value =  order.warehouseName
            }
            <<< SW_StaffInfoRow("areaNums") {
                $0.rowTitle = NSLocalizedString("盘 点 区 域   ", comment: "")
                $0.isShowBottom = false
                $0.value = order.areaNums
            }
            <<< SW_StaffInfoRow("bUnitName") {
                $0.rowTitle = NSLocalizedString("盘 点 单 位   ", comment: "")
                $0.isShowBottom = false
                $0.value = order.bUnitName
            }
            <<< SW_StaffInfoRow("staffName") {
                $0.rowTitle = NSLocalizedString("盘   点   人   ", comment: "")
                $0.isShowBottom = false
                $0.value = order.staffName
            }
            <<< SW_StaffInfoRow("createDateString") {
                $0.rowTitle = NSLocalizedString("盘 点 时 间   ", comment: "")
                $0.isShowBottom = false
                $0.value = order.createDateString
            }
            <<< SW_StaffInfoRow("remark") {
                $0.rowTitle = NSLocalizedString("备           注   ", comment: "")
                $0.isShowBottom = false
                $0.value = order.remark
        }
        
        tableView.reloadData()
    }
    
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

            SW_WorkingService.getScanDetail(self.type, code: code, id: self.orderId).response({ (json, isCache, error) in
                if let json = json as? JSON, error == nil {
                    if json["data"]["id"].stringValue.isEmpty {///如果是空,说明该物品不在指定区域或不存在物品信息，显示弹窗提示
                        self.show(json["msg"].stringValue)
                    } else {/// 跳转到输入数量界面
                        let model = SW_BoutiquesAccessoriesModel(json["data"], type: self.type)
                        self.navigationController?.pushViewController(SW_BoutiquesAccessoriesDetailViewController(model, type: self.type, orderId: self.orderId, requestType: 2), animated: true)
                    }
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                    NotificationCenter.default.post(name: NSNotification.Name.Ex.BarCodeScanShouldReStart, object: nil)
                }
                self.isRequesting = false
            })
            }, titleString: type.rawTitle + "盘点")
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
