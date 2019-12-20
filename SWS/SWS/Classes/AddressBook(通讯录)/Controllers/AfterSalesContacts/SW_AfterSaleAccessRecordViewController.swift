//
//  SW_AfterSaleAccessRecordViewController.swift
//  SWS
//
//  Created by jayway on 2019/2/26.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_AfterSaleAccessRecordViewController: FormViewController {
    
    private var type: AfterSaleCustomerRecordType = .access
    
    private var vin = ""
    private var repairOrderId = ""
    private var customerId = ""
    /// 是否从施工单进入，施工单进入时不显示投诉、评分内容。
    private var isConstruction = false
    
    private lazy var emptyView: LYEmptyView = {
        return SW_NoDataEmptyView.creat()
    }()
    ///  售后接访记录列表
    private var recordDatas = [SW_AfterSaleAccessRecordListModel]()
    /// 维修记录列表
    var repairOrderRecordDatas = [SW_RepairOrderRecordListModel]()
    
    init(type: AfterSaleCustomerRecordType, vin: String, repairOrderId: String, customerId: String, isConstruction: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
        self.vin = vin
        self.customerId = customerId
        self.repairOrderId = repairOrderId
        self.isConstruction = isConstruction
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        requsertrecordDatas()
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
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_HEIGHT, right: 0)
        automaticallyAdjustsScrollViewInsets = false
        tableView.ly_emptyView = SW_LoadingEmptyView.creat()
        tableView.ly_emptyView.contentViewOffset = -(SCREEN_HEIGHT - 250) * 0.1
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadHandleComplaints, object: nil, queue: nil) { [weak self] (notifa) in
            guard self?.isConstruction == false else { return }
            let type = notifa.userInfo?["complaintType"] as! HandleComplaintType
            let orderId = notifa.userInfo?["orderId"] as! String
            
            if type == .repairOrder, let index = self?.repairOrderRecordDatas.firstIndex(where: { return $0.repairOrderId == orderId }), index < 2 {
                guard let row = self?.form.rowBy(tag: "repairOrder Record \(index)") as? SW_AccessRecordListRow else {
                    return
                }
                
                self?.repairOrderRecordDatas[index].complaintState = .waitAudit
                row.cell.complaintState = .waitAudit
                row.updateCell()
            }
        }
    }
    
    //MARK: 请求收藏列表数据
    private func requsertrecordDatas() {
        if type == .access {
            SW_AfterSaleService.getAfterSaleVisitRecordList(repairOrderId, customerId: customerId).response({ (json, isCache, error) in
                if let json = json as? JSON, error == nil {
                    self.emptyView.contentViewOffset = -(self.tableView.height - 250) * 0.1
                    self.tableView.ly_emptyView = self.emptyView
                    self.recordDatas = json["list"].arrayValue.map({ (value) -> SW_AfterSaleAccessRecordListModel in
                        return SW_AfterSaleAccessRecordListModel(value)
                    })
                    self.createTableView()
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                }
            })
        } else {
            SW_AfterSaleService.getRepairOrderList(vin).response({ (json, isCache, error) in
                if let json = json as? JSON, error == nil {
                    self.emptyView.contentViewOffset = -(self.tableView.height - 250) * 0.1
                    self.tableView.ly_emptyView = self.emptyView
                    self.repairOrderRecordDatas = json["list"].arrayValue.map({ (value) -> SW_RepairOrderRecordListModel in
                        return SW_RepairOrderRecordListModel(value)
                    })
                    if self.isConstruction {
                        self.repairOrderRecordDatas.forEach({ $0.complaintState = .pass })
                    }
                    self.createTableView()
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                }
            })
        }
    }
    
    private func createTableView() {
        let title = type == .access ? "接访记录" : "维修记录"
        form = Form()
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = title
                }
                section.header = header
        }
        
        if type == .access {
            for index in 0..<recordDatas.count {
                form.last!
                    <<< SW_AccessRecordListRow("Access Record \(index)") {
                        $0.afterSaleRecord = recordDatas[index]
                        $0.cell.indexLabel.text = "\(recordDatas.count - index)"
                        $0.cell.bottomLine.isHidden = index == recordDatas.count - 1
                        $0.cell.topLine.isHidden = index == 0
                        }.onCellSelection({ [weak self] (cell, row) in
                            row.deselect()
                            guard let self = self else { return }
                            let model = self.recordDatas[index]
                            self.navigationController?.pushViewController(SW_AccessRecordDetailViewController.creatVc(model.id, type: .afterSale), animated: true)
                        })
            }
        } else {
            for index in 0..<repairOrderRecordDatas.count {
                form.last!
                    <<< SW_AccessRecordListRow("repairOrder Record \(index)") {
                        $0.repairOrderRecord = repairOrderRecordDatas[index]
                        $0.cell.indexLabel.text = "\(repairOrderRecordDatas.count - index)"
                        $0.cell.bottomLine.isHidden = index == repairOrderRecordDatas.count - 1
                        $0.cell.topLine.isHidden = index == 0
                        }.onCellSelection({ [weak self] (cell, row) in
                            row.deselect()
                            guard let self = self else { return }
                            let model = self.repairOrderRecordDatas[index]
                            self.navigationController?.pushViewController(SW_RepairOrderRecordDetailViewController.creatVc(model.repairOrderId,  isConstruction: self.isConstruction), animated: true)
                        })
            }
            
        }
        
        tableView.reloadData()
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
