//
//  SW_CustomerInfoHeaderCell.swift
//  SWS
//
//  Created by jayway on 2018/8/15.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

@objc protocol SW_CustomerInfoHeaderCellDelegate: NSObjectProtocol {
    /// view的frame发生改变
    @objc optional func SW_CustomerInfoHeaderCellDidChangeframe()
    /// 点击添加访问记录按钮
    @objc optional func SW_CustomerInfoHeaderCellDidClickAddRecord()
    /// 点击结束销售接待按钮
    func SW_CustomerInfoHeaderCellDidClickEndAccess()
    /// 点击开始试乘试驾按钮
    func SW_CustomerInfoHeaderCellDidClickTryDriving()
    /// 点击结束试乘试驾按钮
    func SW_CustomerInfoHeaderCellDidClickEndTryDriving()
}


class SW_CustomerInfoHeaderCell: Cell<SW_CustomerModel>, CellType, SW_CustomerAccessingManagerDelegate {
    
    weak var delegate: SW_CustomerInfoHeaderCellDelegate?
    
    weak var controller: UIViewController?
    
    @IBOutlet weak var progressView: CircleProgressView!
    
    @IBOutlet weak var portraitImageView: UIImageView!
    
    @IBOutlet weak var levelLb: UILabel!
    
    @IBOutlet weak var percentLb: UILabel!
    
    @IBOutlet weak var sexImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
 
    @IBOutlet weak var phoneLb: UILabel!
    
    @IBOutlet weak var keyProblemLb: UILabel!
    
    @IBOutlet var buttons: [QMUIButton]!
    
    @IBOutlet weak var accessButton: QMUIButton!
    
    @IBOutlet weak var tryDriveButton: QMUIButton!
    
    @IBOutlet weak var accessDateLabel: UILabel!

    @IBOutlet weak var tyrDriveDateLabel: UILabel!
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        accessDateLabel.textColor = UIColor.v2Color.blue
        keyProblemLb.textColor = UIColor.v2Color.blue
        tyrDriveDateLabel.textColor = UIColor.v2Color.blue
        levelLb.layer.cornerRadius = 15
        portraitImageView.layer.cornerRadius = 95
        /// uitapge 点击选择头像
        portraitImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewDidTap(_:))))
        /// 点击显示核心问题
        keyProblemLb.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(keyProblemLbDidTap(_:))))
        
        progressView.centerLabel.isHidden = true
        progressView.progressBackgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        progressView.clockwise = true
        progressView.progressWidth = 4
        
        buttons.forEach({
            $0.imagePosition = .top
            $0.spacingBetweenImageAndTitle = 6
        })
        
        /// 初始化数据源
        setupData()
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
        setupData()
    }
    
    //MARK: - setup
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
    
    /// 设置头部数据
    func setupData() {
        guard let model = row.value else { return }
        
        if let url = URL(string: model.portrait) {
            portraitImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "personalcenter_icon_personalavatar"))
        }
        if model.dataPercentage >= 80 {
            progressView.progressColor = #colorLiteral(red: 0, green: 0.6352941176, blue: 0.03137254902, alpha: 1)
            percentLb.textColor = #colorLiteral(red: 0, green: 0.6352941176, blue: 0.03137254902, alpha: 1)
        } else if model.dataPercentage >= 60 {
            progressView.progressColor = #colorLiteral(red: 0.8941176471, green: 0.7607843137, blue: 0, alpha: 1)
            percentLb.textColor = #colorLiteral(red: 0.8941176471, green: 0.7607843137, blue: 0, alpha: 1)
        } else {
            progressView.progressColor = #colorLiteral(red: 0.9019607843, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
            percentLb.textColor = #colorLiteral(red: 0.9019607843, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
        }
        percentLb.text = "\(model.dataPercentage)%"
        progressView.percent = Float(model.dataPercentage)/100.0
        
        levelLb.backgroundColor = model.level.rawColor
        levelLb.text = model.level.rawString
        
        sexImageView.image = model.sex.bigImage
        nameLabel.text = model.realName
        phoneLb.text = model.phoneNum
//        keyProblemLb.textAlignment = model.keyProblem.count < 15 ? .center : .left
        keyProblemLb.textAlignment = model.keyProblem.size(Font(16), width: SCREEN_WIDTH - 70).height > 20 ? .left : .center
        keyProblemLb.text = model.keyProblem
    }
    
    /// 初始化时的状态   如果开启销售接待则要开启定时器
    func setupButtonState(_ animated: Bool = true) {
        guard let model = row.value else { return }
        if model.accessStartDate == 0 {// 没开启销售接待- 试乘试驾没开启
            accessButton.setImage(UIImage(named: "reception_drive_icon_start"), for: UIControl.State())
            accessButton.isEnabled = true
            tryDriveButton.isEnabled = false
            accessDateLabel.text = "00:00:00"
            showOrHideTyrDriveDateLabel(show: false, animated: animated)
        } else {//开启了销售接待
            accessButton.setImage(UIImage(named: "reception_icon_end"), for: UIControl.State())
            
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
    
    /// 开启、结束、销售接待
    @IBAction func accessAction(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        if row.value?.accessStartDate == 0 {
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
                        self.startSalesAccess()
                        NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadStartSalesReception, object: nil, userInfo: ["customerId": self.row.value?.id ?? ""])
                        //// 需要手动添加一个记录到接待列表中，并刷新tabbar页面
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                    }
                })
            }, leftTitle: "取 消", leftBlock: nil)
            
        } else {
            /// 结束销售接待-通知进行评价，评价成功后再刷新页面
            delegate?.SW_CustomerInfoHeaderCellDidClickEndAccess()
        }
    }
    
    /// 开启、结束、试乘试驾
    @IBAction func tryDrivingActoin(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        
        if isNotStartTryDrive() {//开启
            delegate?.SW_CustomerInfoHeaderCellDidClickTryDriving()
        } else {
            /// 结束试乘试驾-通知进行评价，评价成功后再刷新页面
            delegate?.SW_CustomerInfoHeaderCellDidClickEndTryDriving()
        }
    }
    
    /// 点击头像
    @objc func imageViewDidTap(_ gesture: UITapGestureRecognizer) {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        guard let model = row.value else { return }
        SW_ImagePickerHelper.shared.showPicturePicker( { (image) in
            MBProgressHUD.hide()
            let hud = MBProgressHUD.showAdded(to: MYWINDOW, animated: true)
            hud?.mode = MBProgressHUDModeAnnularDeterminate
            hud?.animationType = MBProgressHUDAnimationFade
            hud?.labelText = "正在上传"
            SWSUploadManager.share.upLoadCustomerPortraitImage(model.id, image: image, block: { (success, key, prefix) in
                hud?.hide(true)
                if let key = key, success {
                    //上传成功
                    SW_AddressBookService.savePortrait(self.row.value?.id ?? "", portrait: key).response({ (json, isCache, error) in
                        if let json = json as? JSON, error == nil {
                            if let url = URL(string: json["portrait"].stringValue) {
                                self.portraitImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "personalcenter_icon_personalavatar"))
                            }
                            model.portrait = json["portrait"].stringValue
                            NotificationCenter.default.post(name: NSNotification.Name.Ex.UserHadSaveCustomerPortrait, object: nil, userInfo: ["customerId": model.id, "portrait": model.portrait])
                        } else {
                            showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                        }
                    })
                }
            }, progressBlock: { (key, progress) in
                hud?.progress = progress
            })
        })
    }
    
    /// 点击核心问题
    @objc func keyProblemLbDidTap(_ gesture: UITapGestureRecognizer) {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        let contentView = UIScrollView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH - 30, height: 180))
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 3
        contentView.layer.masksToBounds = true
        contentView.alwaysBounceHorizontal = false
        
        let label = UILabel()
        label.numberOfLines = 0
        label.text = row.value?.keyProblem ?? ""
        label.textColor = UIColor.v2Color.blue
        label.font = Font(16)
        contentView.addSubview(label)
        
        let contentViewPadding = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        label.frame = CGRect(x: contentViewPadding.left, y: contentViewPadding.top, width: contentView.width - contentViewPadding.left - contentViewPadding.right, height: CGFloat.infinity)
        
        contentView.contentSize = CGSize(width: 0, height: label.frame.maxY + contentViewPadding.bottom)
        
        let modelVc = QMUIModalPresentationViewController()
        modelVc.animationStyle = .popup
        modelVc.contentView = contentView
        modelVc.supportedOrientationMask = .portrait
        /// 动画
        modelVc.layoutBlock = { (containerBounds,keyboardHeight,contentViewDefaultFrame) in
            contentView.frame = CGRectSetXY(contentView.frame, CGFloatGetCenter(containerBounds.width, contentView.width), containerBounds.height - 120 - contentView.height)
        }
        
        modelVc.showWith(animated: true, completion: nil)
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
        tryDriveButton.isEnabled = SW_CustomerAccessingManager.shared.isContainsDelegate(self)//delegate中包含自己则可开启试乘试驾
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
            tyrDriveDateLabel.alpha = 1
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
            tyrDriveDateLabel.alpha = 0
            UIView.animate(withDuration: animated ? 0.5 : 0, delay: 0, options: [.curveEaseInOut,.allowUserInteraction],  animations: {
                self.accessDateLabel.font = MediumFont(68)
                self.layoutIfNeeded()
            }, completion: nil)
        }
        delegate?.SW_CustomerInfoHeaderCellDidChangeframe?()
    }
    
    
}

final class SW_CustomerInfoHeaderCellRow: Row<SW_CustomerInfoHeaderCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_CustomerInfoHeaderCell>(nibName: "SW_CustomerInfoHeaderCell")
    }
    
    deinit {
        PrintLog("deinit")
        SW_CustomerAccessingManager.shared.removeDelegate(cell)
    }
}
