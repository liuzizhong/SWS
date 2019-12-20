//
//  SW_RepairOrderListCell.swift
//  SWS
//
//  Created by jayway on 2019/2/28.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_RepairOrderListCell: UITableViewCell {
    
    @IBOutlet weak var portraitImageView: UIImageView!
    
    @IBOutlet weak var repairOrderNumLb: UILabel!
    
    @IBOutlet weak var levelBgImgView: UIImageView!
    
    @IBOutlet weak var vipLevelLb: UILabel!
    
    @IBOutlet weak var isInvalidLb: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var carNumberLabel: UILabel!
    
    @IBOutlet weak var predictDateLabel: UILabel!
    
    @IBOutlet weak var nameLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var qualityStateLb: UILabel!
    
    @IBOutlet weak var ConstructionStateLb: UILabel!
    
    @IBOutlet weak var restTimeLb: UILabel!
    
    @IBOutlet weak var staffNameLb: UILabel!
    
    var orderModel: SW_RepairOrderListModel? {
        didSet {
            guard let orderModel = orderModel else { return }
            if let url = URL(string: orderModel.customerPortrait.thumbnailString()) {
                portraitImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "icon_personalavatar"))
            } else {
                portraitImageView.image = UIImage(named: "icon_personalavatar")
            }
            staffNameLb.text = "SA:\(orderModel.staffName)"
            repairOrderNumLb.text = "维修单号:\(orderModel.repairOrderNum)"
            isInvalidLb.isHidden = !orderModel.isInvalid
            if orderModel.customerLevel > 0 {
                vipLevelLb.text = "\(orderModel.customerLevel)"
                levelBgImgView.isHidden = false
                vipLevelLb.isHidden = false
                nameLeftConstraint.constant = 35
            } else {
                vipLevelLb.text = ""
                levelBgImgView.isHidden = true
                vipLevelLb.isHidden = true
                nameLeftConstraint.constant = 14
            }
//            sexImageView.image = orderModel.customerSex.littleImage
            nameLabel.text = orderModel.customerName
            if !orderModel.numberPlate.isEmpty {
                carNumberLabel.text = "(" + orderModel.numberPlate + ")"
            } else {
                carNumberLabel.text = ""
            }
            predictDateLabel.text = orderModel.predictDateString
            
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
            qualityStateLb.text = orderModel.qualityStateStr
            
            if orderModel.type == .quality {
                ConstructionStateLb.isHidden = true
            } else {
                ConstructionStateLb.text = "\(orderModel.orderType != 2 ? "未确认" : orderModel.repairStateStr)/"
                ConstructionStateLb.isHidden = false
            }
            
            if orderModel.repairStateStr == "已完工" {
                ConstructionStateLb.textColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
            } else {
                ConstructionStateLb.textColor = UIColor.v2Color.darkGray
            }
            if orderModel.qualityStateStr == "已通过" {
                qualityStateLb.textColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
            } else {
                qualityStateLb.textColor = UIColor.v2Color.darkGray
            }
            
            portraitImageView.badgeOffset = CGPoint(x: -6, y: 10)
            portraitImageView.badgeWidth = 12
            portraitImageView.badgeView(state: (orderModel.type == .order && orderModel.newItem == 2) || (orderModel.type == .construction && orderModel.newItem == 3))
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        portraitImageView.layer.cornerRadius = 27
        isInvalidLb.layer.cornerRadius = 8
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        isInvalidLb.backgroundColor = UIColor.v2Color.red
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        isInvalidLb.backgroundColor = UIColor.v2Color.red
    }
}
