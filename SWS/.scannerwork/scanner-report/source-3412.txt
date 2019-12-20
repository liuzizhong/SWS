//
//  SW_OrderDetailBaseInfoHeader.swift
//  SWS
//
//  Created by jayway on 2019/3/4.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_OrderDetailBaseInfoHeader: UIView {

    var isHideSenderLb = true
    
    @IBOutlet weak var portraitImageView: UIImageView!
    
    @IBOutlet weak var vinLb: UILabel!
    
    @IBOutlet weak var levelBgImgView: UIImageView!
    
    @IBOutlet weak var vipLevelLb: UILabel!
    
    @IBOutlet weak var sexImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var carNumberLabel: UILabel!
    
    @IBOutlet weak var senderLb: UILabel!
    
    @IBOutlet weak var repairRecordBtn: UIButton!
    
    @IBOutlet weak var vinTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var predictDateLabel: UILabel!
    @IBOutlet weak var creatDateLb: UILabel!
    @IBOutlet weak var mileageLb: UILabel!
    @IBOutlet weak var staffNameLb: UILabel!
    
    @IBOutlet weak var restTimeLb: UILabel!
    
    var repairRecordBlock: NormalBlock?
    
    var orderModel: SW_RepairOrderRecordDetailModel? {
        didSet {
            guard let orderModel = orderModel else { return }
            if let url = URL(string: orderModel.customerPortrait) {
                portraitImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "icon_personalavatar"))
            } else {
                portraitImageView.image = UIImage(named: "icon_personalavatar")
            }
            staffNameLb.text = "SA:\(orderModel.staffName)"
            
            vinLb.text = "车架号:\(orderModel.vin)"
            let isHideSender = orderModel.sender.isEmpty || isHideSenderLb
            vinTopConstraint.constant = isHideSender ? 5 : 25
            senderLb.isHidden = isHideSender
            senderLb.text = "送修人:\(orderModel.sender)"
            
            if orderModel.customerLevel > 0 {
                vipLevelLb.text = "\(orderModel.customerLevel)"
                levelBgImgView.isHidden = false
                vipLevelLb.isHidden = false
            } else {
                vipLevelLb.text = ""
                levelBgImgView.isHidden = true
                vipLevelLb.isHidden = true
            }
            sexImageView.image = orderModel.customerSex.littleImage
            nameLabel.text = orderModel.customerName
            carNumberLabel.text = orderModel.numberPlate
            predictDateLabel.text = orderModel.predictDateString
            creatDateLb.text = Date.dateWith(timeInterval: orderModel.createDate).stringWith(formatStr: "yyyy/MM/dd HH:mm")
            mileageLb.text = "\(orderModel.mileage)km"
            let date1 = Date()
            let date2 = Date.dateWith(timeInterval: orderModel.predictDate)
            
            let components = NSCalendar.current.dateComponents([.hour,.minute], from: date1, to: date2)
            
            if components.hour! < 0 || components.minute! < 0 {//超出预计出厂时间
                restTimeLb.text = "-\(abs(components.hour!)):\(abs(components.minute!))'"
                restTimeLb.textColor = UIColor.v2Color.red
            } else {
                restTimeLb.text = "\(components.hour!):\(components.minute!)'"
                restTimeLb.textColor = UIColor.v2Color.lightGray
            }
            
            //            PrintLog("order: \(orderModel.customerName) -- \(components.hour):\(components.minute)' ")
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        portraitImageView.layer.cornerRadius = 40
        repairRecordBtn.layer.cornerRadius = 3
        repairRecordBtn.layer.borderWidth = 1
        repairRecordBtn.layer.borderColor = UIColor.v2Color.blue.cgColor
        repairRecordBtn.setTitleColor(UIColor.v2Color.blue, for: UIControl.State())
        portraitImageView.addGestureRecognizer(UITapGestureRecognizer { [weak self] (gesture) in
            guard let self = self else { return }
            if let image = self.portraitImageView.image {//点击头像查看大图
                let vc = SW_ImagePreviewViewController([image])
                vc.sourceImageView = {
                    return self.portraitImageView
                }
                self.getTopVC().present(vc, animated: true, completion: nil)
//                vc.customGestureExitBlock = { (aImagePreviewViewController, currentZoomImageView) in
//                    aImagePreviewViewController?.exitPreviewToRect(inScreenCoordinate: self.convert(self.portraitImageView.frame, to: nil))
//                }
//                vc.startPreviewFromRect(inScreenCoordinate: self.convert(self.portraitImageView.frame, to: nil), cornerRadius: self.portraitImageView.layer.cornerRadius)
            }
        })
    }
    
    @IBAction func repairRecordBtnClick(_ sender: UIButton) {
        repairRecordBlock?()
    }
    
}
