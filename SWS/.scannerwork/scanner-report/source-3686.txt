//
//  SW_TempCustomerInfoHeaderCell.swift
//  SWS
//
//  Created by jayway on 2018/11/14.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import Eureka


class SW_TempCustomerInfoHeaderCell: Cell<SW_CustomerModel>, CellType, SW_CustomerAccessingManagerDelegate {
    
    weak var delegate: SW_CustomerInfoHeaderCellDelegate?
    
    weak var controller: UIViewController?
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var createDateLb: UILabel!
    
    @IBOutlet weak var startSaleAccessBtn: SW_BlueButton!
    @IBOutlet weak var addRecordBtn: SW_BlueButton!
    @IBOutlet weak var addRecordTitleLb: UILabel!
    @IBOutlet weak var addRecordTipLb: UILabel!
    
    @IBOutlet var buttons: [QMUIButton]!
    @IBOutlet weak var accessButton: QMUIButton!
    @IBOutlet weak var tryDriveButton: QMUIButton!
    @IBOutlet weak var accessDateLabel: UILabel!
    @IBOutlet weak var tyrDriveDateLabel: UILabel!
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        accessDateLabel.textColor = UIColor.v2Color.blue
        tyrDriveDateLabel.textColor = UIColor.v2Color.blue
        buttons.forEach({
            $0.imagePosition = .top
            $0.spacingBetweenImageAndTitle = 6
        })
        
        /// 初始化数据源
        setupDatas()
        /// 初始化按钮状态
        setupButtonState(false)
        /// 初始化通知
        setupNotification()
    }
    
    deinit {
        PrintLog("deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func update() {
        super.update()
        setupDatas()
    }
    
    //MARK: - setup
    private func setupDatas() {
        guard let model = row.value else { return }
        nameLabel.text = model.customerTempNum
        createDateLb.text = Date.dateWith(timeInterval: model.createDate).stringWith(formatStr: "yyyy-MM-dd HH:mm")
    }
    
    func setupNotification() {
        /// 结束了销售接待 刷新页面
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadEndSalesReception, object: nil, queue: nil) { [weak self] (notifa) in
            let id = notifa.userInfo?["customerId"] as! String
            if id == self?.row.value?.id {
                self?.row.value?.accessRecordId = ""
                self?.row.value?.accessStartDate = 0
                self?.endAccessSuccess()
            }
        }
        /// 结束了试乘试驾 刷新页面
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadEndTryDriving, object: nil, queue: nil) { [weak self] (notifa) in
            let id = notifa.userInfo?["customerId"] as! String
            if id == self?.row.value?.id {
                self?.row.value?.tryDriveRecordId = ""
                self?.row.value?.tryDriveEndDate = notifa.userInfo?["endDate"] as! Double
                self?.endTryDrivingSuccess()
            }
        }
        /// 开启试乘试驾 刷新页面
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadStartTryDriving, object: nil, queue: nil) { [weak self] (notifa) in
            let id = notifa.userInfo?["customerId"] as! String
            if id == self?.row.value?.id {
                self?.row.value?.tryDriveRecordId = notifa.userInfo?["recordId"] as! String
                self?.row.value?.tryDriveStartDate = notifa.userInfo?["startDate"] as! Double
                self?.row.value?.tryDriveEndDate = 0
                self?.row.value?.testCar =  notifa.userInfo?["testCar"] as! String
                self?.startTryDriving()
            }
        }
    }
    
    /// 初始化时的状态   如果开启销售接待则要开启定时器
    func setupButtonState(_ animated: Bool = true) {
        guard let model = row.value else { return }
        if model.accessStartDate == 0 {// 没开启销售接待- 试乘试驾没开启
            showOrHideAddRecordView(show: true, animated: animated)
            showOrHideTyrDriveDateLabel(show: false, animated: animated)
        } else {//开启了销售接待
            showOrHideAddRecordView(show: false, animated: animated)
            accessDateLabel.alpha = 1
            if isNotStartTryDrive() { // 没开启试乘试驾
                /// 要判断s销售接待时间是否超出限制，
                tryDriveButton.setImage(UIImage(named: "reception_drive_icon_start"), for: UIControl.State())
                accessButton.isEnabled = true
                tryDriveButton.isEnabled = true
                showOrHideTyrDriveDateLabel(show: false, animated: animated)
            } else {//开启了试乘试驾
                tryDriveButton.setImage(UIImage(named: "reception_icon_end"), for: UIControl.State())
                accessButton.isEnabled = false
                tryDriveButton.isEnabled = true
                showOrHideTyrDriveDateLabel(show: true, animated: animated)
            }
            SW_CustomerAccessingManager.shared.addDelegate(self)
        }
    }
    
    private func isNotStartTryDrive() -> Bool {
        return row.value?.tryDriveStartDate == 0 || (row.value?.tryDriveStartDate != 0 && row.value?.tryDriveEndDate != 0)
    }
    
    /// 结束、销售接待
    @IBAction func accessAction(_ sender: UIButton) {
        /// 结束销售接待-通知进行评价，评价成功后再刷新页面
        delegate?.SW_CustomerInfoHeaderCellDidClickEndAccess()
    }
    
    /// 开启、结束、试乘试驾
    @IBAction func tryDrivingActoin(_ sender: UIButton) {
        if isNotStartTryDrive() {//开启
            delegate?.SW_CustomerInfoHeaderCellDidClickTryDriving()
        } else {
            /// 结束试乘试驾-通知进行评价，评价成功后再刷新页面
            delegate?.SW_CustomerInfoHeaderCellDidClickEndTryDriving()
        }
    }
    
    @IBAction func startSaleAccessDidClick(_ sender: SW_BlueButton) {
        if SW_CustomerAccessingManager.shared.accessingList.count == 5 {
            showAlertMessage("保存失败，接待人数不能超过5个，请先结束相关接待。", MYWINDOW)
            return
        }
        alertControllerShow(title: "现在开始记录本次销售接待吗？", message: nil, rightTitle: "确 定", rightBlock: { (_, _) in
            let record = SW_AccessCustomerRecordModel()
            record.accessType = .salesReception
            record.customerId = self.row.value?.id ?? ""
            record.startDate = Date().getCurrentTimeInterval()
            SW_AddressBookService.saveAccessCustomerRecord(record).response({ (json, isCache, error) in
                if let json = json as? JSON, error == nil {
                    /// 需要开启定时器
                    self.row.value?.accessRecordId = json["accessCustomerRecordId"].stringValue
                    self.row.value?.accessStartDate = record.startDate
                    NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadStartSalesReception, object: nil, userInfo: ["customerId": self.row.value?.id ?? ""])
                    self.startSalesAccess()
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                }
            })
        }, leftTitle: "取 消", leftBlock: nil)
        
    }
    
    /// 点击添加访问记录按钮
    @IBAction func addRecordDidClick(_ sender: SW_BlueButton) {
        delegate?.SW_CustomerInfoHeaderCellDidClickAddRecord?()
    }
    
    // 开启销售接待页面刷新方法---开启定时器
    func startSalesAccess() {
        setupButtonState()
        accessDateLabel.text = "00:00:00"
    }
    
    // 开启试乘试驾页面刷新方法-开启试乘试驾必须开启销售接待，所以已经有定时器了，不用再次开启
    func startTryDriving() {
        setupButtonState()
        tyrDriveDateLabel.text = "00:00:00"
    }
    
    /// 评价销售接待成功，刷新页面
    func endAccessSuccess() {
        setupButtonState()
        accessDateLabel.text = "00:00:00"
    }
    
    /// 评价试乘试驾成功，刷新页面
    func endTryDrivingSuccess() {
        setupButtonState()
        //要判断销售接待有没超过5小时超过则不可以点击
        tryDriveButton.isEnabled = SW_CustomerAccessingManager.shared.isContainsDelegate(self)
    }
    
    /// 相当于定时器  进入这里则刷新time
    ///
    /// - Parameter manager: manager对象
    func SW_CustomerAccessingManagerNotificationReloadTime(manager: SW_CustomerAccessingManager) {
        guard let model = row.value else { return }
        
        let results = SW_CustomerAccessingManager.calculateTimeLabel(accessStartTime: model.accessStartDate, tryDriveStartTime: model.tryDriveStartDate, tryDriveEndTime: model.tryDriveEndDate)
        
        accessDateLabel.text = results.0
        tyrDriveDateLabel.text = results.1
        if let enable = results.2 {
            tryDriveButton.isEnabled = enable
        }
        if results.3 {/// 结束计时
            SW_CustomerAccessingManager.shared.removeDelegate(self)
        }
    }
    
    private func showOrHideAddRecordView(show: Bool, animated: Bool = true) {
        let alpha: CGFloat = show ? 1 : 0
        UIView.animate(withDuration: animated ? 0.3 : 0 , delay: 0, options: .allowUserInteraction, animations: {
            self.accessButton.alpha = 1-alpha
            self.tryDriveButton.alpha = 1-alpha
            self.accessDateLabel.alpha = 1-alpha
            self.tyrDriveDateLabel.alpha = 1-alpha
            self.addRecordBtn.alpha = alpha
            self.addRecordTipLb.alpha = alpha
            self.addRecordTitleLb.alpha = alpha
            self.startSaleAccessBtn.isEnabled = show
        }, completion: nil)
    }
    
    /// 时间lb显示状态
    private func showOrHideTyrDriveDateLabel(show: Bool, animated: Bool = true) {
        accessDateLabel.snp.removeConstraints()
        tyrDriveDateLabel.snp.removeConstraints()
        if show {
            accessDateLabel.snp.makeConstraints { (make) in
                make.leading.equalTo(accessButton.snp.leading).offset(5)
                make.top.equalTo(accessButton.snp.bottom).offset(15)
            }
            tyrDriveDateLabel.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(accessDateLabel.snp.bottom).offset(5)
                make.bottom.equalToSuperview().offset(-10)
            }
            self.tyrDriveDateLabel.alpha = 1
            UIView.animate(withDuration: animated ? 0.5 : 0, delay: 0, options: [.curveEaseInOut,.allowUserInteraction],  animations: {
                self.accessDateLabel.font = MediumFont(24)
                self.layoutIfNeeded()
            }, completion: nil)
        } else {
            accessDateLabel.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(accessButton.snp.bottom).offset(5)
                make.bottom.equalToSuperview().offset(-10)
            }
            tyrDriveDateLabel.snp.makeConstraints { (make) in
                make.edges.equalTo(accessDateLabel)
            }
            self.tyrDriveDateLabel.alpha = 0
            UIView.animate(withDuration: animated ? 0.5 : 0, delay: 0, options: [.curveEaseInOut,.allowUserInteraction],  animations: {
                self.accessDateLabel.font = MediumFont(68)
                self.layoutIfNeeded()
            }, completion: nil)
        }
        delegate?.SW_CustomerInfoHeaderCellDidChangeframe?()
    }
    
}

final class SW_TempCustomerInfoHeaderRow: Row<SW_TempCustomerInfoHeaderCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_TempCustomerInfoHeaderCell>(nibName: "SW_TempCustomerInfoHeaderCell")
    }
    
    deinit {
        PrintLog("deinit")
        SW_CustomerAccessingManager.shared.removeDelegate(cell)
    }
}
