//
//  SW_AfterSaleCustomerInfoCell.swift
//  SWS
//
//  Created by jayway on 2019/2/23.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_AfterSaleCustomerInfoCell: Cell<SW_AfterSaleCustomerModel>, CellType {
    
//    weak var controller: UIViewController?
    
    @IBOutlet weak var portraitImageView: UIImageView!
    
    @IBOutlet weak var vipBgView: UIImageView!
    
    @IBOutlet weak var vipLevelLb: UILabel!
    
    @IBOutlet weak var sexImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var carNumberLb: UILabel!
    
    public override func setup() {
        super.setup()
        selectionStyle = .none

        portraitImageView.layer.cornerRadius = 95
        /// uitapge 点击选择头像
        portraitImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewDidTap(_:))))
        
        /// 初始化数据源
        setupData()
    }
    
    deinit {
        PrintLog("deinit")
//        NotificationCenter.default.removeObserver(self)
    }
    
    public override func update() {
        super.update()
        setupData()
    }
    
    //MARK: - setup  设置头部数据
    func setupData() {
        guard let model = row.value else { return }
        
        if let url = URL(string: model.portrait) {
            portraitImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "personalcenter_icon_personalavatar"))
        }
        vipLevelLb.text = "\(model.customerLevel)"
        if model.customerLevel > 0 {
            vipLevelLb.text = "\(model.customerLevel)"
            vipBgView.isHidden = false
            vipLevelLb.isHidden = false
        } else {
            vipLevelLb.text = ""
            vipBgView.isHidden = true
            vipLevelLb.isHidden = true
        }
        sexImageView.image = model.sex.bigImage
        nameLabel.text = model.customerName
        carNumberLb.text = model.numberPlate
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
    
}

final class SW_AfterSaleCustomerInfoRow: Row<SW_AfterSaleCustomerInfoCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_AfterSaleCustomerInfoCell>(nibName: "SW_AfterSaleCustomerInfoCell")
    }
    
}
