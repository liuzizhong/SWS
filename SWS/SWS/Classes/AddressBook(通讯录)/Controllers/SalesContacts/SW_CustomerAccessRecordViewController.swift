//
//  SW_CustomerAccessRecordViewController.swift
//  SWS
//
//  Created by jayway on 2018/8/16.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_CustomerAccessRecordViewController: FormViewController {
    
    private lazy var emptyView: LYEmptyView = {
        return SW_NoDataEmptyView.creat()
    }()
    
    private var recordDatas = [SW_AccessRecordListModel]()
    
    var phone: String = ""
    
    var consultantInfoId = 0
    
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
//        navigationItem.title = InternationStr("接访记录")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_HEIGHT, right: 0)
        automaticallyAdjustsScrollViewInsets = false
        tableView.ly_emptyView = SW_LoadingEmptyView.creat()
        tableView.ly_emptyView.contentViewOffset = -(SCREEN_HEIGHT - 250) * 0.1
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadHandleComplaints, object: nil, queue: nil) { [weak self] (notifa) in
            let type = notifa.userInfo?["complaintType"] as! HandleComplaintType
            let orderId = notifa.userInfo?["orderId"] as! String
            
            if type == .access, let index = self?.recordDatas.firstIndex(where: { return $0.id == orderId }) {
                guard let row = self?.form.rowBy(tag: "Access Record \(index)") as? SW_AccessRecordListRow else {
                    return
                }
                self?.recordDatas[index].complaintState = .waitAudit
                row.cell.complaintState = .waitAudit
                row.updateCell()
            }
        }
    }
    
    private func setupNavtitle() {
        if let firstAccess = recordDatas.last {//计算距离首次接访时间
            /// 这里计算时间间隔的标准是，过了第二天0点就加1天，因此计算时将第一次接访时间改为当天0点，方便计算
            let dateStr = Date.dateWith(timeInterval: firstAccess.endDate).simpleTimeString(formatter: .year)
            let firstDate = Date.dateWith(formatStr: "yyyy-MM-dd", dateString: dateStr)!.getCurrentTimeInterval()
            let day = Int((Date().getCurrentTimeInterval() - firstDate)/1000/60/60/24)
            if day > 0 {            
                navigationItem.titleView = SW_TwoRowNavTitleView(title: "接访记录", detailTitle: "距离首次接访\(day)天")
            }
        }
    }
    
    //MARK: 请求收藏列表数据
    private func requsertrecordDatas() {
        SW_AddressBookService.getAccessCustomerRecordList(consultantInfoId).response({ (json, isCache, error) in
            self.emptyView.contentViewOffset = -(self.tableView.height - 250) * 0.1
            self.tableView.ly_emptyView = self.emptyView
            if let json = json as? JSON, error == nil {
                self.recordDatas = json.arrayValue.map({ (value) -> SW_AccessRecordListModel in
                    return SW_AccessRecordListModel(value)
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
                    view.title = "接待记录"
                }
                section.header = header
            }
            
        for index in 0..<recordDatas.count {
            form.last!
                <<< SW_AccessRecordListRow("Access Record \(index)") {
                    $0.value = recordDatas[index]
                    $0.cell.indexLabel.text = "\(recordDatas.count - index)"
                    $0.cell.bottomLine.isHidden = index == recordDatas.count - 1
                    $0.cell.topLine.isHidden = index == 0
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        guard let self = self else { return }
                        let model = self.recordDatas[index]
                        switch model.accessType {
                        case .tryDrive:
                            self.navigationController?.pushViewController(SW_TryDriveRecordViewController(model.id), animated: true)
                        case .salesReception:
                            self.navigationController?.pushViewController(SW_SaleAccessRecordViewController.creatVc(model.id, phone: self.phone), animated: true)
                        default:
                            self.navigationController?.pushViewController(SW_AccessRecordDetailViewController.creatVc(model.id), animated: true)
                        }
                        
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


