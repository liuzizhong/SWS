//
//  SW_BoutiquesAccessoriesDetailViewController.swift
//  SWS
//
//  Created by jayway on 2019/3/25.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_BoutiquesAccessoriesDetailViewController: FormViewController {
    private var requestType = 1/// 1 采购入库   2 盘点数量
    private var boutiquesAccessories: SW_BoutiquesAccessoriesModel!
    private var orderId = ""
    private var type: ProcurementType = .boutiques
    
    private var isRequesting = false
    
    init(_ boutiquesAccessories: SW_BoutiquesAccessoriesModel, type: ProcurementType, orderId: String, requestType: Int = 1) {
        super.init(nibName: nil, bundle: nil)
        self.boutiquesAccessories = boutiquesAccessories
        self.orderId = orderId
        self.type = type
        self.requestType = requestType
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// 进入详情页如果有新增精品配件页面 则去除
        navigationController?.removeViewController([SW_AddBoutiquesAccessoriesViewController.self])
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
        navigationItem.title = "填写数量"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(doneAction(_:)))
        
        SW_StaffInfoRow.defaultCellSetup = { (cell, row) in
            cell.selectionStyle = .none
            cell.titleLb.textColor = UIColor.v2Color.darkGray
            cell.valueLb.textColor = UIColor.v2Color.darkBlack
        }
    }
    
    private func createTableView() {
        form = Form()
            +++
            Eureka.Section()
            
            <<< SW_CommenFieldRow("addCount") {
                $0.rawTitle = NSLocalizedString("数量", comment: "")
                $0.decimalCount = 4
                $0.amountMax = 99999.9999
                $0.isAmount = true
                $0.value = boutiquesAccessories.addCount == 0 ? "" :  "\(boutiquesAccessories.addCount)"
                $0.cell.valueField.keyboardType = .decimalPad
                $0.cell.valueField.placeholder = "请输入\(requestType == 1 ? "采购" : "盘点")数量"
                $0.cell.valueField.becomeFirstResponder()
                }.onChange { [weak self] in
                   self?.boutiquesAccessories.addCount = Double($0.value ?? "") ?? 0
            }
            
            <<< SW_StaffInfoRow("name") {
                $0.rowTitle = NSLocalizedString("\(type.rawTitle)名称   ", comment: "")
                $0.isShowBottom = false
                $0.value =  boutiquesAccessories.name
            }
            <<< SW_StaffInfoRow("code") {
                $0.rowTitle = NSLocalizedString("\(type.rawTitle)条码   ", comment: "")
                $0.isShowBottom = false
                $0.value = boutiquesAccessories.code
            }
            <<< SW_StaffInfoRow("num") {
                $0.rowTitle = NSLocalizedString("\(type.rawTitle)编号   ", comment: "")
                $0.isShowBottom = false
                $0.value = boutiquesAccessories.num
            }
            <<< SW_StaffInfoRow("warehouseName") {
                $0.rowTitle = NSLocalizedString("所在仓库   ", comment: "")
                $0.isShowBottom = false
                $0.value = boutiquesAccessories.warehouseName
            }
            <<< SW_StaffInfoRow("Position no") {
                $0.rowTitle = NSLocalizedString("仓  位  号   ", comment: "")
                $0.isShowBottom = false
                $0.value = boutiquesAccessories.warehousePositionNum.isEmpty ? "" : boutiquesAccessories.warehousePositionNum
            }
        if type == .accessories {
            form.last!
                <<< SW_StaffInfoRow("accessoriesTypeName") {
                    $0.rowTitle = NSLocalizedString("配件种类   ", comment: "")
                    $0.isShowBottom = false
                    $0.value = boutiquesAccessories.accessoriesTypeName
            }
        } else {
            form.last!
                <<< SW_StaffInfoRow("boutiqueTypeName") {
                    $0.rowTitle = NSLocalizedString("精品种类   ", comment: "")
                    $0.isShowBottom = false
                    $0.value = boutiquesAccessories.boutiqueTypeName
            }
        }
            form.last!
            <<< SW_StaffInfoRow("forCarModelType") {
                $0.rowTitle = NSLocalizedString("适用车型   ", comment: "")
                $0.isShowBottom = false
                if boutiquesAccessories.forCarModelType == 1 {
                    $0.value = "通用"
                } else {
                    $0.value = boutiquesAccessories.carBrand + "  " + boutiquesAccessories.carSeries
                }
            }
                
            <<< SW_StaffInfoRow("unit") {
                $0.rowTitle = NSLocalizedString("单       位   ", comment: "")
                $0.isShowBottom = false
                $0.value = boutiquesAccessories.unit
            }
            <<< SW_StaffInfoRow("specification") {
                $0.rowTitle = NSLocalizedString("规       格   ", comment: "")
                $0.isShowBottom = false
                $0.value = boutiquesAccessories.specification
        }
        
        //        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    @objc private func doneAction(_ sender: UIBarButtonItem) {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        if boutiquesAccessories.addCount == 0 {
            showAlertMessage("请输入数量", MYWINDOW)
            (form.rowBy(tag: "addCount") as? SW_CommenFieldRow)?.showErrorLine()
            return
        }
        guard !isRequesting else {
            showAlertMessage("保存中，请勿重复操作", MYWINDOW)
            return
        }
        isRequesting = true
        var request: SWSRequest
        switch requestType {
        case 1:
            request = SW_WorkingService.saveBoutiqueAccessoriesInOrder(type, id: orderId, boutiqueAccessoriesId: boutiquesAccessories.id, count: boutiquesAccessories.addCount)
        case 2:
            request = SW_WorkingService.saveInventoryOrder(type, id: orderId, boutiqueAccessoriesId: boutiquesAccessories.id, count: boutiquesAccessories.addCount, stockId: boutiquesAccessories.stockId)
        default:
            request = SW_WorkingService.saveBoutiqueAccessoriesInOrder(type, id: orderId, boutiqueAccessoriesId: boutiquesAccessories.id, count: boutiquesAccessories.addCount)
        }
        request.response({ (json, isCache, error) in
            if let _ = json as? JSON, error == nil {
                showAlertMessage("保存成功", MYWINDOW)
                self.navigationController?.popViewController(animated: true)
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                if let json = json as? JSON, json["code"].intValue == 2 {///
                    if let index = self.navigationController?.viewControllers.lastIndex(where: { (vc) -> Bool in
                        return vc is SW_ProcurementListViewController || vc is SW_InventoryListViewController
                    }) {
                        self.navigationController?.popToViewController(self.navigationController!.viewControllers[index], animated: true)
                    }
                }
            }
            self.isRequesting = false
        })
    }
    
    
}
