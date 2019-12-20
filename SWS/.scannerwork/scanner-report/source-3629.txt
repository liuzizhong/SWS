//
//  SW_SaleAccessRecordViewController.swift
//  SWS
//
//  Created by jayway on 2018/8/23.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_SaleAccessRecordViewController: FormViewController {
    
    private var phone: String = ""
    private var recordId = ""
    
    private var recordData: SW_AccessCustomerRecordModel? {
        didSet {
            createTableView()
        }
    }
    
    class func creatVc(_ recordId: String, phone: String) -> SW_SaleAccessRecordViewController {
        let vc = SW_SaleAccessRecordViewController()
        vc.recordId = recordId
        vc.phone = phone
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        requestRecordDatas()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup() {

        view.backgroundColor = .white
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        //        navigationItem.title = InternationStr("接访记录")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_HEIGHT, right: 0)
        automaticallyAdjustsScrollViewInsets = false
        
//      cell的默认设置
        SW_CommenLabelRow.defaultCellUpdate = { (cell, row) in
            cell.selectionStyle = .none
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadHandleComplaints, object: nil, queue: nil) { [weak self] (notifa) in
            let type = notifa.userInfo?["complaintType"] as! HandleComplaintType
            let orderId = notifa.userInfo?["orderId"] as! String
            if type == .access, orderId == self?.recordId {
                guard let row = self?.form.rowBy(tag: "Customer complaints") as? SW_CommenLabelRow else {
                    return
                }
                row.value = "待审核"
                row.cell.rightActionLb.text = "详情"
                row.updateCell()
            }
        }
    }
    
    private func requestRecordDatas() {
        SW_AddressBookService.getAccessCustomerRecord(recordId).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.recordData = SW_AccessCustomerRecordModel(json)
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
    }
    
    private func createTableView() {
        guard let recordData = recordData else { return }
        
        form = Form()
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = recordData.accessType.rawString
                }
                section.header = header
            }
            
            <<< SW_StartEndTimeRow("Access time") { (row) in
                row.rawTitle = NSLocalizedString("访问时间", comment: "")
                row.value = Date.dateWith(timeInterval: recordData.startDate).stringWith(formatStr: "yyyy.MM.dd HH:mm")
                row.endTime = Date.dateWith(timeInterval: recordData.endDate).stringWith(formatStr: "yyyy.MM.dd HH:mm")
            }
        if recordData.complaintRecords.count > 0 {
            form.last!
                
                <<< SW_CommenLabelRow("Customer complaints") {
                    $0.rawTitle = NSLocalizedString("客户投诉", comment: "")
                    $0.value =  recordData.complaintState.rawTitle
                    $0.cell.rightActionLb.isHidden = false
                    $0.cell.rightActionLb.text =  recordData.complaintState == .waitHandle  ? "处理" : "详情"
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        PrintLog("goto ")
                        let vc = SW_ComplaintsListViewController.creatVc(recordData.complaintRecords, phone: self?.phone ?? "")
                        self?.navigationController?.pushViewController(vc, animated: true)
                    })
        }
        if recordData.customerServingItemScores.count > 0   || recordData.nonGrandedItems.count > 0 {
            form.last!
                
                <<< SW_CommenLabelRow("Customer rating") {
                    $0.rawTitle = NSLocalizedString("回访记录", comment: "")
                    $0.value = recordData.customerServingItemScores.count > 0 ? "\(recordData.getScore.toAmoutString())分" : "已回访"
                    $0.cell.rightActionLb.isHidden = false
                    $0.cell.rightActionLb.text = "详情"
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        PrintLog("goto ")
                        self?.navigationController?.pushViewController(SW_CustomerScoreManagerViewController(recordData.customerServingItemScores, nonScoreItems: recordData.nonGrandedItems), animated: true)
                    })
        }
        
        form.last!
            <<< SW_CommenLabelRow("duration") {
                $0.rawTitle = NSLocalizedString("访问时长", comment: "")
                $0.value = recordData.duration
            }
            
            <<< SW_CommenLabelRow("comeStoreType") {
                $0.rawTitle = NSLocalizedString("到店类型", comment: "")
                $0.value = recordData.comeStoreType.rawString
            }
            
            <<< SW_CommenLabelRow("customerCount") {
                $0.rawTitle = NSLocalizedString("到店人数", comment: "")
                $0.value = "\(recordData.customerCount)人"
            }
            
            <<< SW_CommenLabelRow("isTestDrive") {
                $0.rawTitle = NSLocalizedString("是否试驾", comment: "")
                $0.value = recordData.isTestDrive
            }
            
            <<< SW_CommenLabelRow("satisfaction") {
                $0.rawTitle = NSLocalizedString("商品满意度 ", comment: "")
                $0.value = recordData.satisfaction.rawString
            }
            
            <<< SW_CommenLabelRow("recordContent") {
                $0.rawTitle = NSLocalizedString("接待记录", comment: "")
                $0.allowsMultipleLine = true
                $0.value = recordData.recordContent
        }
        
        tableView.reloadAndFadeAnimation()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        PrintLog("deinit")
    }
}
