//
//  SW_AccessRecordDetailViewController.swift
//  SWS
//
//  Created by jayway on 2018/8/23.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

enum AccessRecordDetailType: Int {
    case sale  =  1
    case afterSale
}

class SW_AccessRecordDetailViewController: FormViewController {

    private var type: AccessRecordDetailType = .sale
    
    private var recordId = ""
    
    private var recordData: SW_AccessCustomerRecordModel? {
        didSet {
            createTableView()
        }
    }
    
    private var afterSaleRecordData: SW_AfterSaleAccessRecordListModel? {
        didSet {
            createTableView()
        }
    }
    
    class func creatVc(_ recordId: String, type: AccessRecordDetailType = .sale) -> SW_AccessRecordDetailViewController {
        let vc = SW_AccessRecordDetailViewController()
        vc.recordId = recordId
        vc.type = type
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
        
        SW_CommenLabelRow.defaultCellUpdate = { (cell, row) in
            cell.selectionStyle = .none
        }
    }
    
    private func requestRecordDatas() {
        if type == .sale {
            SW_AddressBookService.getAccessCustomerRecord(recordId).response({ (json, isCache, error) in
                if let json = json as? JSON, error == nil {
                    self.recordData = SW_AccessCustomerRecordModel(json)
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                }
            })
        } else {
            SW_AfterSaleService.getAfterSaleVisitRecordData(recordId).response({ (json, isCache, error) in
                if let json = json as? JSON, error == nil {
                    self.afterSaleRecordData = SW_AfterSaleAccessRecordListModel(json)
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                }
            })
        }
    }

    private func createTableView() {
        if type == .sale {
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
                <<< SW_CommenLabelRow("duration") {
                    $0.rawTitle = NSLocalizedString("访问时长", comment: "")
                    $0.value = recordData.duration
                }
                <<< SW_CommenLabelRow("recordContent") {
                    $0.rawTitle = NSLocalizedString("访问记录", comment: "")
                    $0.allowsMultipleLine = true
                    $0.value = recordData.recordContent
            }
        } else {
            guard let recordData = afterSaleRecordData else { return }
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
                <<< SW_CommenLabelRow("duration") {
                    $0.rawTitle = NSLocalizedString("访问时长", comment: "")
                    $0.value = recordData.duration
                }
                <<< SW_CommenLabelRow("recordContent") {
                    $0.rawTitle = NSLocalizedString("访问记录", comment: "")
                    $0.allowsMultipleLine = true
                    $0.value = recordData.recordContent
            }
        }
        
        
    }
    
    deinit {
        PrintLog("deinit")
    }
}
