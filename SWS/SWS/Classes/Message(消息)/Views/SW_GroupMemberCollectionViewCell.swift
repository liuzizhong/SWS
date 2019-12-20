//
//  SW_GroupMemberCollectionViewCell.swift
//  SWS
//
//  Created by jayway on 2018/5/23.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_GroupMemberCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var shouDownBtn: UIButton!
    
    var shouDownBlock: NormalBlock?
    
    var canShouDown = false {
        didSet {
            shouDownBtn.isHidden = !canShouDown
        }
    }
    
    var model: SW_RangeModel? {
        didSet {
            guard let model = model else { return }
            if let url = URL(string: model.portrait.thumbnailString()) {
//                iconImageView.sd_setImage(with: url)
                iconImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "icon_personalavatar"))
            } else {
                iconImageView.image = UIImage(named: "icon_personalavatar")
            }
            nameLabel.text = model.realName
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        iconImageView.layer.cornerRadius = iconImageView.height/2
    }

    @IBAction func shouDownBtnClick(_ sender: UIButton) {
        shouDownBlock?()
    }
    
    
}
