//
//  SW_AddressBookMainCell.swift
//  SWS
//
//  Created by jayway on 2018/4/19.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_AddressBookMainCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var staffName: UILabel!//联系人才用这个
    //    var iconImageView
    @IBOutlet weak var staffDeatil: UILabel!
    
    @IBOutlet weak var normalLb: UILabel!//单行都用这个显示内容
    
    @IBOutlet weak var positionLb: UILabel!
    
    @IBOutlet weak var separaterLine: UIView!
    
    @IBOutlet weak var forbindenImgV: UIImageView!
    
    var isForbinden = false {
        didSet {
            forbindenImgV.isHidden = !isForbinden
            iconImageView.alpha = isForbinden ? 0.4 : 1
            normalLb.alpha = isForbinden ? 0.4 : 1
        }
    }
    
    var model: SW_AddressBookModel? {
        didSet {
            updateCell()
        }
    }
    
    var groupModel: SW_GroupModel? {
        didSet {
            guard let groupModel = groupModel else {
                return
            }
            iconImageView.sd_cancelCurrentImageLoad()
            
            if let url = URL(string: groupModel.imageUrl) {
                iconImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "icon_groupavatar"))
            } else {
                iconImageView.image = UIImage(named: "icon_groupavatar")
            }
            positionLb.isHidden = true
            staffName.isHidden = true
            staffDeatil.isHidden = true
            normalLb.isHidden = false
            normalLb.text = groupModel.groupName
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        iconImageView.layer.cornerRadius = 27
    }

    func updateCell() {
        guard let model = model else {
            return
        }
        iconImageView.sd_cancelCurrentImageLoad()
        if let url = URL(string: model.portrait.thumbnailString()) {
            iconImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "icon_personalavatar"))
        } else {
            iconImageView.image = UIImage(named: "icon_personalavatar")
        }
        staffName.isHidden = false
        staffDeatil.isHidden = false
        positionLb.isHidden = false
        normalLb.isHidden = true
        staffName.text = model.realName
        positionLb.text = "(\(model.positionName))"
        staffDeatil.text = model.regionName
    }
    
}
