//
//  SW_AssgnationCarDetailViewController.swift
//  SWS
//
//  Created by jayway on 2019/11/14.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_AssgnationCarDetailViewController: FormViewController {
    
    private var salesContract: SW_SalesContractDetailModel!
    private var contractId: String = ""
    /// 是否分配了车辆
    private var hasAssgnation = false
    private var reloadBlock: ((String,Int)->Void)?
    
    init(_ contractId: String, reloadBlock: @escaping (String,Int)->Void) {
        super.init(nibName: nil, bundle: nil)
        self.contractId = contractId
        self.reloadBlock = reloadBlock
        self.salesContract = SW_SalesContractDetailModel(type: .assgnationCar)
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
        SW_SalesContractService.getContractDetail(contractId, type: .assgnationCar).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.salesContract = SW_SalesContractDetailModel(json, type: .assgnationCar)
                self.hasAssgnation = self.salesContract.carList.contains(where: { $0.assignationState == 2 })
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
            Eureka.Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = "合同详情"
                }
                section.header = header
            }
            <<< SW_StaffInfoRow("Contract no") {
                $0.rowTitle = NSLocalizedString("合   同  编   号   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.contractNum
            }
            
            <<< SW_StaffInfoRow("Sales consultant") {
                $0.rowTitle = NSLocalizedString("销   售  顾   问   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.saleName
            }

          <<< SW_StaffInfoRow("Expected delivery date") {
              $0.rowTitle = NSLocalizedString("预计交车日期   ", comment: "")
              $0.isShowBottom = false
              $0.value = salesContract.deliveryDate == 0 ? "" : Date.dateWith(timeInterval: salesContract.deliveryDate).stringWith(formatStr: "yyyy.MM.dd")
          }
            
            <<< SW_StaffInfoRow("Vehicle information") {
                $0.rowTitle = NSLocalizedString("车   型  信   息   ", comment: "")
                $0.isShowBottom = false
                $0.value =  salesContract.carBrand.isEmpty ? "" : salesContract.carBrand + "  " + salesContract.carSeries + "  " + salesContract.carModel + "  " + salesContract.carColor
            }
        +++
        Eureka.Section() { section in
            var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
            header.height = {70}
            header.onSetupView = { view, _ in
                view.title = "车辆信息"
            }
            section.header = header
        }
        
        for index in 0..<salesContract.carList.count {
            let model = salesContract.carList[index]
            form.last!
            <<< SW_AssgnationCarRow("SW_AssgnationCarRow \(index)") {
                $0.hasAssgnation = hasAssgnation
                $0.assgnationBlock = { [weak self] in
                    self?.contractAssgnationCarOrReleaseCar(carInfo: model)
                }
                $0.value = model
            }
        }
        
        tableView.reloadData()
    }
    
    private var isRequesting = false
    
    //MARK: -private func
    /// 分配车辆接口   1分配车辆 2解除车辆
    private func contractAssgnationCarOrReleaseCar(carInfo: SW_CarInfoModel) {
        
        guard !isRequesting else { return }
        
        let title = hasAssgnation ? "是否取消分配此车辆？" : "是否分配此车辆？"
        
        alertControllerShow(title: title, message: nil, rightTitle: "确定", rightBlock: { (_, _) in
            self.isRequesting = true
            QMUITips.showLoading("正在\(self.hasAssgnation ? "取消分配" : "分配")", in: self.view)
            SW_SalesContractService.contractAssgnationCarOrReleaseCar(contractId: self.contractId, carInfoId: carInfo.carInfoId, type: self.hasAssgnation ? 2 : 1).response({ (json, isCache, error) in
                if let _ = json as? JSON, error == nil {
                    self.hasAssgnation = !self.hasAssgnation
                    carInfo.assignationState = self.hasAssgnation ? 2 : 1
                    self.reloadBlock?(self.contractId,carInfo.assignationState)
                    /// TODO: 通知列表刷新cell
                    self.createTableView()
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                }
                QMUITips.hideAllTips(in: self.view)
                self.isRequesting = false
            })
        }, leftTitle: "取消", leftBlock: nil)
        
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
