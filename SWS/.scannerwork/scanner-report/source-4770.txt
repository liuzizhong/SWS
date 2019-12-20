//
//  SW_AccessingCollectionViewCell.swift
//  SWS
//
//  Created by jayway on 2018/11/21.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_AccessingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var contentBgView: UIView!
    
    @IBOutlet weak var imageBgView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLb: UILabel!
    
    @IBOutlet weak var endButton: UIButton!
    
    @IBOutlet weak var timeLb: UILabel!
    
    var model: SW_AccessingListModel? {
        didSet {
            guard let model = model else { return }
            if model.customerType == .real {
                imageView.image = UIImage(named: "personalcenter_icon_personalavatar")
                if let url = URL(string: model.portrait) {
                    imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "personalcenter_icon_personalavatar"))
                }
                nameLb.text = model.realName
            } else {
                imageView.image = UIImage(named: "correspondent_addressbook_icon_personalavatar_normal")
                nameLb.text = model.customerTempNum
            }
            let results = SW_CustomerAccessingManager.calculateTimeLabel(accessStartTime: model.accessStartDate, tryDriveStartTime: model.tryDriveStartDate, tryDriveEndTime: model.tryDriveEndDate)
            timeLb.text = results.0
            endButton.isEnabled = model.tryDriveStartDate == 0 || (model.tryDriveStartDate != 0 && model.tryDriveEndDate != 0)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentBgView.addShadow()
        imageView.layer.cornerRadius = 22
        imageView.layer.masksToBounds = true
        
        imageBgView.layer.cornerRadius = 22
        imageBgView.addShadow()
        imageBgView.layer.shadowOffset = CGSize.init(width: 0, height: -1)
        timeLb.textColor = UIColor.v2Color.blue
    }
    
    @IBAction func endBtnDidClick(_ sender: UIButton) {
        guard let model = model else { return }
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        getTopVC().navigationController?.pushViewController(SW_EndSalesReceptionViewController(model.accessCustomerRecordId, customerId: model.customerId), animated: true)
    }
    
    
}
