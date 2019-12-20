//
//  SW_TryDriveRecordViewController.swift
//  SWS
//
//  Created by jayway on 2018/8/29.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

/// 试乘试驾记录详情控制器
class SW_TryDriveRecordViewController: FormViewController {

    var recordId = ""
    
    var record: SW_AccessCustomerRecordModel!
    
    init(_ recordId: String) {
        super.init(nibName: nil, bundle: nil)
        self.recordId = recordId
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formConfig()
        requestrecords()
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
    
    deinit {
        PrintLog("deinit")
    }
    
    private func requestrecords() {
        SW_AddressBookService.getAccessCustomerRecord(recordId).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.record = SW_AccessCustomerRecordModel(json)
                self.createTableView()
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    //MARK: - Action
    private func formConfig() {

        view.backgroundColor = .white
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_HEIGHT, right: 0)
//        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .white//UIColor.mainColor.background
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        automaticallyAdjustsScrollViewInsets = false
//        navigationItem.title = NSLocalizedString("接访记录", comment: "")
        tableView.ly_emptyView = SW_LoadingEmptyView.creat()
        tableView.ly_emptyView.contentViewOffset = -(SCREEN_HEIGHT - 250) * 0.1
        SW_CommenLabelRow.defaultCellUpdate = { (cell, row) in
            cell.selectionStyle = .none
        }
    }
    
    
    private func createTableView() {
        
        form = Form()
            +++
            Eureka.Section() { [weak self] section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = self?.record.accessType.rawString ?? ""
                }
                section.header = header
            }

            <<< SW_StartEndTimeRow("Test drive time") { (row) in
                row.rawTitle = NSLocalizedString("试驾时间", comment: "")
                row.value = Date.dateWith(timeInterval: record.startDate).stringWith(formatStr: "yyyy.MM.dd HH:mm")
                row.endTime = Date.dateWith(timeInterval: record.endDate).stringWith(formatStr: "yyyy.MM.dd HH:mm")
            }
            
            <<< SW_CommenLabelRow("duration") {
                $0.rawTitle = NSLocalizedString("访问时长", comment: "")
                $0.value = record.duration
            }
            
            <<< SW_CommenLabelRow("car model") {
                $0.rawTitle = NSLocalizedString("车辆型号", comment: "")
                $0.value = record.testCar
            }
            
            <<< SW_CommenLabelRow("testCarVIN") {
                $0.rawTitle = NSLocalizedString("车架号", comment: "")
                $0.value = record.testCarVIN
                $0.cell.placeholder = "无"
            }
        
            
            
        <<< SW_CommenLabelRow("testDriveContent") {
            $0.rawTitle = NSLocalizedString("试驾反馈", comment: "")
            $0.value = record.testDriveContent
            $0.allowsMultipleLine = true
        }
        
        tableView.reloadAndFadeAnimation()
    }
    

    
    //MARK: - FormViewControllerProtocol   重写一下方法是因为需要去除该库添加时的动画
    override func sectionsHaveBeenAdded(_ sections: [Section], at indexes: IndexSet) {
        
    }
    
    override func rowsHaveBeenAdded(_ rows: [BaseRow], at indexes: [IndexPath]) {
        
    }
}

extension SW_TryDriveRecordViewController {

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 6
    }
}
