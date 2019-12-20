//
//  SW_AfterSaleCustomerAddressBookListCell.swift
//  SWS
//
//  Created by jayway on 2019/2/23.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_AfterSaleCustomerAddressBookListCell: UITableViewCell {
    
    @IBOutlet weak var portraitImageView: UIImageView!
    
    @IBOutlet weak var fixCarLb: UILabel!
    
    @IBOutlet weak var levelBgImgView: UIImageView!
    
    @IBOutlet weak var vipLevelLb: UILabel!
    
    @IBOutlet weak var sexImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var carNumberLabel: UILabel!
    
    @IBOutlet weak var lastAccessDateLabel: UILabel!
    
    @IBOutlet weak var accessStateLb: UILabel!
    
    @IBOutlet weak var nameLeftConstraint: NSLayoutConstraint!
    
    
    var customerModel: SW_AfterSaleCustomerListModel? {
        didSet {
            guard let customerModel = customerModel else { return }
            if let url = URL(string: customerModel.portrait.thumbnailString()) {
                portraitImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "icon_personalavatar"))
            } else {
                portraitImageView.image = UIImage(named: "icon_personalavatar")
            }
            
            fixCarLb.text = customerModel.carBrand + " " + customerModel.carSeries + " " + customerModel.carModel
            accessStateLb.isHidden = !customerModel.isHandle
            if customerModel.customerLevel > 0 {
                vipLevelLb.text = "\(customerModel.customerLevel)"
                levelBgImgView.isHidden = false
                vipLevelLb.isHidden = false
                nameLeftConstraint.constant = 35
            } else {
                vipLevelLb.text = ""
                levelBgImgView.isHidden = true
                vipLevelLb.isHidden = true
                nameLeftConstraint.constant = 14
            }
            sexImageView.image = customerModel.sex.littleImage
            nameLabel.text = customerModel.realName
            if !customerModel.numberPlate.isEmpty {
                carNumberLabel.text = "(" + customerModel.numberPlate + ")"
            } else {
                carNumberLabel.text = ""
            }
            lastAccessDateLabel.text = customerModel.lastVisitDateString
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        portraitImageView.layer.cornerRadius = 27
       
    }
    
}
