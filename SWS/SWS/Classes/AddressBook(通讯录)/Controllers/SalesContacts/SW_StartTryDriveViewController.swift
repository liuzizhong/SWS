//
//  SW_StartTryDriveViewController.swift
//  SWS
//
//  Created by jayway on 2018/8/18.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_StartTryDriveViewController: FormViewController {
    
    private var record: SW_AccessCustomerRecordModel!
    
    private var isRequesting = false
    
    /// 试驾车列表
    private var testCarList = [SW_TestCarListModel]()
    
    private var commitBtn: SW_BlueButton = {
        let btn = SW_BlueButton()
        btn.setTitle("开始试驾", for: UIControl.State())
        btn.addTarget(self, action: #selector(commitAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    init(_ record: SW_AccessCustomerRecordModel) {
        super.init(nibName: nil, bundle: nil)
        self.record = record
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formConfig()
        createTableView()
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Action
    private func formConfig() {

        view.backgroundColor = .white
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_HEIGHT, right: 0)
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        SW_CommenLabelRow.defaultCellUpdate = { (cell, row) in
            cell.selectionStyle = .none
        }
        tableView.addSubview(commitBtn)
        commitBtn.snp.makeConstraints { (make) in
            make.top.equalTo(360)
            make.leading.equalTo(22)
//            make.trailing.equalTo(-22)
            make.width.equalTo(SCREEN_WIDTH-44)
            make.height.equalTo(46)
        }
    }
    
    private func createTableView() {
        form = Form()
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = "试乘/试驾"
                }
                section.header = header
            }
            <<< SW_CommenLabelRow("car model") {
                $0.rawTitle = NSLocalizedString("车辆型号", comment: "")
                $0.value = record.testCar == "  " ? "" : record.testCar
                $0.cell.placeholder = "点击选择车型"
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    guard let self = self else { return }
                    if self.testCarList.count > 0 {
                        self.showTestCarListPicker()
                    } else {
                        SW_WorkingService.getTestCar().response({ (json, isCache, error) in
                            if let json = json as? JSON, error == nil {
                                self.testCarList = json["list"].arrayValue.map({ return SW_TestCarListModel($0) })
                                self.showTestCarListPicker()
                            } else {
                                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                            }
                        })
                    }
                })
        /// 选择了试驾车才可以下去
        guard record.testCar != "  " else { return }
        
        form.last!
            <<< SW_CommenLabelRow("testCarKeyNum") {
                $0.rawTitle = NSLocalizedString("钥匙号", comment: "")
                $0.value = record.testCarKeyNum.isEmpty ? "无" : record.testCarKeyNum
        }
        
        if !record.testCarNumberPlate.isEmpty {
            form.last!
                <<< SW_CommenLabelRow("testCarNumberPlate") {
                    $0.rawTitle = NSLocalizedString("车牌号", comment: "")
                    $0.value = record.testCarNumberPlate
            }
        }
        tableView.reloadData()
    }
    
    /// 显示汽车品牌列表pickerview
    private func showTestCarListPicker() {
        guard testCarList.count > 0 else { return }
        guard let row = form.rowBy(tag: "car model") as? SW_CommenLabelRow else { return }
        var title = "钥匙号:无"
        if row.value == "" {/// 未选择车辆
            title = "钥匙号:\(testCarList[0].keyNum)"
        } else if let model = findModel(row.value ?? "") {
            /// 找到对应的钥匙号
            title = "钥匙号:\(model.keyNum)"
        }
        BRStringPickerView.showStringPicker(withTitle: title, on: MYWINDOW, dataSource: testCarList.map({ return $0.testCar }), defaultSelValue: row.value, isAutoSelect: false, themeColor: UIColor.v2Color.blue, resultBlock: { (selectValue) in
            let select = selectValue as? String ?? ""
            if self.record.testCar != select {
                if let model = self.findModel(select) {
                    self.record.testCarBrand = model.carBrandName
                    self.record.testCarSeries = model.carSeriesName
                    self.record.testCarModel = model.carModelName
                    self.record.testCarKeyNum = model.keyNum
                    self.record.testCarNumberPlate = model.numberPlate
                    self.createTableView()
                }
            }
        }) { (picker, selectValue) in
            let select = selectValue as? String ?? ""
            if let model = self.findModel(select) {
                picker?.titleLabel.text = "钥匙号:\(model.keyNum)"
            }
        }
        
    }
    
    /// 根据select值，找到对应的model
    private func findModel(_ select: String) -> SW_TestCarListModel? {
        guard testCarList.count > 0 else { return nil }
        if let index = testCarList.index(where: { return $0.testCar == select}) {
            return testCarList[index]
        }
        return nil
    }
    
    //MARK: - FormViewControllerProtocol   重写一下方法是因为需要去除该库添加时的动画
    override func sectionsHaveBeenAdded(_ sections: [Section], at indexes: IndexSet) {
        
    }
    
    override func rowsHaveBeenAdded(_ rows: [BaseRow], at indexes: [IndexPath]) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    @objc private func commitAction(_ sender: UIButton) {
        if record.testCar == "  " {
            showAlertMessage("请选择车辆型号", MYWINDOW)
            return
        }
        guard !isRequesting else { return }
        isRequesting = true
        QMUITips.showLoading("正在开始", in: self.view)
        record.startDate = Date().getCurrentTimeInterval()
        SW_AddressBookService.saveAccessCustomerRecord(record).response({ (json, isCache, error) in
            self.isRequesting = false
            QMUITips.hideAllTips(in: self.view)
            if let json = json as? JSON, error == nil {
                PrintLog(json)
                NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadStartTryDriving, object: nil, userInfo: ["customerId": self.record.customerId, "recordId": json["accessCustomerRecordId"].stringValue, "startDate": self.record.startDate, "testCar": self.record.testCar])
                if let index = self.navigationController?.viewControllers.index(where: { return $0 is SW_CustomerDetailViewController || $0 is SW_TempCustomerDetailViewController }) {
                    self.navigationController?.popToViewController(self.navigationController!.viewControllers[index], animated: true)
                }
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
        })
        
    }
   
}

extension SW_StartTryDriveViewController {
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
