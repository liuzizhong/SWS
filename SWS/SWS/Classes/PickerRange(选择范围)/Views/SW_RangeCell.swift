//
//  SW_RangeCell.swift
//  SWS
//
//  Created by jayway on 2018/5/7.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_RangeCell: UITableViewCell {

    @IBOutlet weak var selectImageView: UIImageView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var centerLb: UILabel!
    
    @IBOutlet weak var centerCountLb: UILabel!
    
    @IBOutlet weak var topLb: UILabel!
    
    @IBOutlet weak var topPositionLb: UILabel!
    
    @IBOutlet weak var topCountLb: UILabel!
    
    @IBOutlet weak var bottomLb: UILabel!
    
    @IBOutlet weak var groupOwnerImage: UILabel!
    
    @IBOutlet weak var labelLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var selectImageLeft: NSLayoutConstraint!
    @IBOutlet weak var selectImageWidth: NSLayoutConstraint!
    var rangeModel: SW_RangeModel? {
        didSet {
            updateCell()
        }
    }
    
    var isSelect = false {
        didSet {
            selectImageView.image = isSelect ? #imageLiteral(resourceName: "Main_select") : #imageLiteral(resourceName: "Main_unselect")
        }
    }
    
    var isGroupOwner = false {
        didSet {
            groupOwnerImage.isHidden = !isGroupOwner
        }
    }
    
    var isHiddenSelect: Bool = false {
        didSet {
            if isHiddenSelect {
                selectImageLeft.constant = 6
                selectImageWidth.constant = 0
            } else {
                selectImageLeft.constant = 16
                selectImageWidth.constant = 15
            }
        }
    }
    
    fileprivate func updateCell() {
        guard let model = rangeModel else { return }
        
        switch model.type {
        case .region:
            labelLeftConstraint.constant = 10//73
            iconImageView.isHidden = true
            centerLb.isHidden = false
            centerCountLb.isHidden = false
            topLb.isHidden = true
            topPositionLb.isHidden = true
            topCountLb.isHidden = true
            bottomLb.isHidden = true
            
            centerLb.text = model.regStr
            centerCountLb.text = "(\(model.staffCount)人)"
            
        case .business:
            labelLeftConstraint.constant = 10//73
            iconImageView.isHidden = true
            centerLb.isHidden = false
            centerCountLb.isHidden = false
            topLb.isHidden = true
            topPositionLb.isHidden = true
            topCountLb.isHidden = true
            bottomLb.isHidden = true
            
            centerLb.text = model.businessName
            centerCountLb.text = "(\(model.staffCount)人)"
            
        case .department:
            labelLeftConstraint.constant = 10//73
            iconImageView.isHidden = true
            centerLb.isHidden = true
            centerCountLb.isHidden = true
            topLb.isHidden = false
            topPositionLb.isHidden = true
            topCountLb.isHidden = false
            bottomLb.isHidden = false
            topLb.font = Font(16)
            topLb.text = model.departmentName
            topCountLb.text = "(\(model.staffCount)人)"
            bottomLb.text = model.regStr + "-" + model.businessName
            
        case .staff:
            labelLeftConstraint.constant = 79
            iconImageView.isHidden = false
            centerLb.isHidden = true
            centerCountLb.isHidden = true
            topLb.font = MediumFont(16)
            topLb.isHidden = false
            topPositionLb.isHidden = false
            topCountLb.isHidden = true
            bottomLb.isHidden = false
            
            
            if let url = URL(string: model.portrait.thumbnailString()) {
                iconImageView.setImageWith(url, placeholder: UIImage(named: "icon_personalavatar"))
            } else {
                iconImageView.image = UIImage(named: "icon_personalavatar")
            }
            topLb.text = model.realName
            topPositionLb.text = "(\(model.positionName))"
            bottomLb.text = model.regStr
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       groupOwnerImage.layer.cornerRadius = 3
        iconImageView.layer.cornerRadius = iconImageView.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
