//
//  SW_AddAccessRecordViewController.swift
//  SWS
//
//  Created by jayway on 2018/8/17.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_AddAccessRecordViewController: FormViewController {
    
    private var record = SW_AccessCustomerRecordModel()
    
    private var isRequesting = false
    
    init(_ customerId: String) {
        super.init(nibName: nil, bundle: nil)
        self.record.customerId = customerId
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
        tableView.keyboardDismissMode = .onDrag
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        rowKeyboardSpacing = 89
        navigationItem.title = NSLocalizedString("本次访问记录", comment: "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(commitAction(_:)))
    }
    
    
    private func createTableView() {
        
        form = Form()
         
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = "必填信息"
                }
                section.header = header
            }
            
            <<< SW_SingleChoiceRow("Access type") {
                $0.rawTitle = NSLocalizedString("访问方式", comment: "")
                $0.value = record.accessType.rawString
                $0.allOptions = ["电话","上门","车展"]
                }.onChange { [weak self] in
                    self?.record.accessType = AccessType($0.value ?? "")
            }
            
            
            <<< SW_StartEndTimeRow("Access time") { (row) in
                row.rawTitle = NSLocalizedString("访问时间", comment: "")
                row.value = record.startDate == 0 ? "" : Date.dateWith(timeInterval: record.startDate).stringWith(formatStr: "yyyy.MM.dd HH:mm")
                row.endTime = record.endDate == 0 ? "" : Date.dateWith(timeInterval: record.endDate).stringWith(formatStr: "yyyy.MM.dd HH:mm")
                    
                row.startBtnClickBlock = {  [weak self, weak row] in
                    guard let self = self else { return }
                    guard let row = row else { return }
                    self.view.endEditing(true)
                    let maxDate = Date().addingTimeInterval(-60)
                    let minDate = (maxDate as NSDate).addingDays(-15)!
                    
                    let defaultValue = self.record.startDate == 0 ? maxDate : Date.dateWith(timeInterval: self.record.startDate)
                    
                    BRDatePickerView.showDatePicker(withTitle: "选择时间", on: MYWINDOW, dateType: BRDatePickerMode.init(rawValue: 2)!, defaultSelValue: defaultValue, minDate: minDate, maxDate: maxDate, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (dateStr) in
                        guard let dateStr = dateStr else { return }
                        /// 更换了日期才进行下面的操作
                        guard row.value != dateStr else { return }
                        //                        let year = maxDate.year()
                        //                        var tempString = "\(year)-\(dateStr)"
                        if let date = Date.dateWith(formatStr: "yyyy-MM-dd HH:mm", dateString: dateStr) {
                            //                            if tempDate > maxDate {//需要减少1年
                            //                                tempString = "\(year-1)-\(dateStr)"
                            //                                tempDate = Date.dateWith(formatStr: "yyyy-MM-dd HH:mm", dateString: tempString)!
                            //                            }
                            row.value = dateStr
                            row.cell.setupState()
                            self.record.startDate = date.getCurrentTimeInterval()
                            /**
                             *  选择开始时间后，要判断结束时间是否有值， 没值的时候直接用开始时间+1分钟即可
                             *  有值时：  开始时间与之前的结束时间 比较大小
                             *   如果开始时间大于结束时间，则直接使用开始时间+1分钟
                             *   如果开始时间小于结束时间，要判断是否是同一天，
                             **/
                            if self.record.endDate != 0, date.isSameDay(Date.dateWith(timeInterval: self.record.endDate)), self.record.endDate >= self.record.startDate + 60*1000 {
                                print("这种情况不用处理")
                            } else {
                                print("这种情况结束时间等于开始时间+1分钟")
                                self.record.endDate = self.record.startDate + 60*1000
                                row.endTime = Date.dateWith(timeInterval: self.record.endDate).stringWith(formatStr: "yyyy.MM.dd HH:mm")
                                row.cell.setupState()
                            }
                        }
                    }, cancel: nil)
                }
                ///------start  end 分割
                row.endBtnClickBlock = { [weak self, weak row] in
                    guard let row = row else { return }
                    guard let self = self else { return }
                    self.view.endEditing(true)
                    if self.record.startDate == 0 {
                        showAlertMessage("请选择开始时间", MYWINDOW)
                        return
                    }
                    /// 选中的开始时间
                    let startDate = Date.dateWith(timeInterval: self.record.startDate)
                    /// 选择开始时间的日期字符串
                    let startString = startDate.stringWith(formatStr: "yyyy.MM.dd")
                    
                    var minDate: Date? = nil
                    var maxDate: Date? = nil
                    minDate = startDate.addingTimeInterval(60)
                    if startDate.isTodayDate() {// 是当天
                        maxDate = Date()
                    } else {//不是当天
                        maxDate = Date.dateWith(formatStr: "yyyy.MM.dd HH:mm", dateString: "\(startString) 23:59")
                        if maxDate! < minDate! {
                            maxDate = minDate
                        }
                    }
                    
                    let defaultValue = self.record.endDate == 0 ? minDate : Date.dateWith(timeInterval: self.record.endDate)
                    
                    BRDatePickerView.showDatePicker(withTitle: "选择时间", on: MYWINDOW, dateType: BRDatePickerMode.init(rawValue: 0)!, defaultSelValue: defaultValue, minDate: minDate, maxDate: maxDate, isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { (dateStr) in
                        guard let dateStr = dateStr else { return }
                        /// 更换了日期才进行下面的操作
                        guard row.endTime.contains(dateStr) == false else { return }
                        let selectDateStr = "\(startString) \(dateStr)"
                        if let selectDate = Date.dateWith(formatStr: "yyyy-MM-dd HH:mm", dateString: selectDateStr) {
                            row.endTime = selectDateStr
                            row.cell.setupState()
                            self.record.endDate = selectDate.getCurrentTimeInterval()
                        }
                    }, cancel: nil)
                }
                
            }
            
            
            <<< SW_CommenTextViewRow("Access records")  {
                $0.placeholder = "请在此输入本次访问过程中的要点 "
                $0.maximumTextLength = 500
                $0.value = record.recordContent
                $0.rawTitle = "访问记录"
                $0.textViewHeightChangeBlock = { [weak self] (textViewHeight) in
                    self?.form.rowBy(tag: "Access records")?.reload()
                }
                }.onChange { [weak self] in
                    self?.record.recordContent = $0.value ?? ""
            }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    @objc private func commitAction(_ sender: UIButton) {
        if record.accessType == .none {
            showAlertMessage("请选择访问方式", MYWINDOW)
            return
        }
        if record.startDate == 0 {
            showAlertMessage("请选择开始时间", MYWINDOW)
            return
        }
        if record.endDate == 0 {
            showAlertMessage("请选择结束时间", MYWINDOW)
            return
        }
        if record.recordContent.isEmpty {
            showAlertMessage("请输入访问记录", MYWINDOW)
            (form.rowBy(tag: "Access records") as? SW_CommenTextViewRow)?.showErrorLine()
            return
        }
        guard !isRequesting else { return }
        alertControllerShow(title: "确定保存本次访问信息吗？", message: "保存后不可再修改", rightTitle: "确 定", rightBlock: { (_, _) in
            self.postRequest()
        }, leftTitle: "取 消", leftBlock: nil)
    }
    
    ///保存成功后的逻辑课优化
    private func postRequest() {
        isRequesting = true
        QMUITips.showLoading("正在保存", in: self.view)
//        record.startDate = 1534302420000
//        record.endDate = 1534306320000
        /// 如果到这里说明该填的都填了。  --提交新建订单报表 ----
        SW_AddressBookService.saveAccessCustomerRecord(record).response({ (json, isCache, error) in
            self.isRequesting = false
            QMUITips.hideAllTips(in: self.view)
            if let _ = json as? JSON, error == nil {
                showAlertMessage("保存成功", MYWINDOW)//或者编辑
                NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadAddAccessRecord, object: nil, userInfo: ["customerId": self.record.customerId, "endDate": self.record.endDate])
                   self.navigationController?.popViewController(animated: true)

            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
        
    }
    
}

extension SW_AddAccessRecordViewController {
    
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
