//
//  SW_PurchaseCarRecordViewController.swift
//  SWS
//
//  Created by jayway on 2019/6/3.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_PurchaseCarRecordViewController: FormViewController {
    
    private lazy var emptyView: LYEmptyView = {
        return SW_NoDataEmptyView.creat()
    }()
    
    private var buyCarDatas = [SW_PurchaseCarRecordListModel]()
    
    var customerId = ""
    var phone = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        requsertbuyCarDatas()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MAKR: 初始化设置
    private func setup() {
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        //        navigationItem.title = InternationStr("接访记录")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_HEIGHT, right: 0)
        automaticallyAdjustsScrollViewInsets = false
        tableView.ly_emptyView = SW_LoadingEmptyView.creat()
        tableView.ly_emptyView.contentViewOffset = -(SCREEN_HEIGHT - 250) * 0.1
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadHandleComplaints, object: nil, queue: nil) { [weak self] (notifa) in
            let type = notifa.userInfo?["complaintType"] as! HandleComplaintType
            let orderId = notifa.userInfo?["orderId"] as! String
            if type == .purchaseCar, let index = self?.buyCarDatas.firstIndex(where: { return $0.contractId == orderId }) {
                guard let row = self?.form.rowBy(tag: "purchaseCar Record \(index)") as? SW_AccessRecordListRow else {
                    return
                }
                self?.buyCarDatas[index].complaintState = .waitAudit
                row.cell.complaintState = .waitAudit
                row.updateCell()
            }
        }
    }
    
    
    //MARK: 请求收藏列表数据
    private func requsertbuyCarDatas() {
        SW_AddressBookService.getCarSalesContractRecordList(customerId).response({ (json, isCache, error) in
            self.emptyView.contentViewOffset = -(self.tableView.height - 250) * 0.1
            self.tableView.ly_emptyView = self.emptyView
            if let json = json as? JSON, error == nil {
                self.buyCarDatas = json["list"].arrayValue.map({ (value) -> SW_PurchaseCarRecordListModel in
                    return SW_PurchaseCarRecordListModel(value)
                })
                self.createTableView()
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
    }
    
    private func createTableView() {
        form = Form()
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = "购车记录"
                }
                section.header = header
        }
        
        for index in 0..<buyCarDatas.count {
            form.last!
                <<< SW_AccessRecordListRow("purchaseCar Record \(index)") {
                    $0.purchaseCarRecord = buyCarDatas[index]
                    $0.cell.indexLabel.text = "\(buyCarDatas.count - index)"
                    $0.cell.bottomLine.isHidden = index == buyCarDatas.count - 1
                    $0.cell.topLine.isHidden = index == 0
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        guard let self = self else { return }
                        let model = self.buyCarDatas[index]
                        self.navigationController?.pushViewController(SW_PurchaseCarRecordDetailViewController(model.contractId,phone: self.phone), animated: true)
                    })
            
        }
        
        tableView.reloadAndFadeAnimation()
    }
    
    //MARK: private method
    deinit {
        NotificationCenter.default.removeObserver(self)
        PrintLog("deinit")
    }
    
    //MARK: - tableviewdelegate
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
}
