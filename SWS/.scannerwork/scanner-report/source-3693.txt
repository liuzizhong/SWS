//
//  SW_CustomerAddressBookListCell.swift
//  SWS
//
//  Created by jayway on 2018/8/14.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_CustomerAddressBookListCell: UITableViewCell {
    @IBOutlet weak var progressView: CircleProgressView!
    
    @IBOutlet weak var portraitImageView: UIImageView!
    
    @IBOutlet weak var fllowLb: UILabel!
    
    @IBOutlet weak var likeCarLb: UILabel!
    
    @IBOutlet weak var levelBgView: UIView!
    
    @IBOutlet weak var levelLabel: UILabel!
    
    @IBOutlet weak var sexImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var positionLabel: UILabel!
    
    @IBOutlet weak var accessStateLabel: UILabel!
    
    @IBOutlet weak var lastAccessDateLabel: UILabel!
    
    var customerModel: SW_CustomerListModel? {
        didSet {
            guard let customerModel = customerModel else { return }
            if let url = URL(string: customerModel.portrait.thumbnailString()) {
                portraitImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "icon_personalavatar"))
            } else {
                portraitImageView.image = UIImage(named: "icon_personalavatar")
            }
           
            if customerModel.dataPercentage >= 80 {
                progressView.progressColor = #colorLiteral(red: 0, green: 0.6352941176, blue: 0.03137254902, alpha: 1)
            } else if customerModel.dataPercentage >= 60 {
                progressView.progressColor = #colorLiteral(red: 0.8941176471, green: 0.7607843137, blue: 0, alpha: 1)
            } else {
                progressView.progressColor = #colorLiteral(red: 0.9019607843, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
            }
            progressView.percent = Float(customerModel.dataPercentage)/100.0
            fllowLb.isHidden = !customerModel.isFollow

            likeCarLb.text = customerModel.likeCarBrand + " " + customerModel.likeCarSeries + " " + customerModel.likeCarModel
            levelBgView.backgroundColor = customerModel.level.rawColor
            levelLabel.text = customerModel.level.rawString
            sexImageView.image = customerModel.sex.littleImage
            nameLabel.text = customerModel.realName
            if !customerModel.occupation.isEmpty {
                positionLabel.text = "(" + customerModel.occupation + ")"
            } else {
                positionLabel.text = ""
            }
            lastAccessDateLabel.text = customerModel.lastAccessDateString
            accessStateLabel.isHidden = !(customerModel.accessState == 1 || customerModel.isHandle)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        levelBgView.layer.cornerRadius = 7
        portraitImageView.layer.cornerRadius = 27
        fllowLb.layer.cornerRadius = 8
        
        progressView.centerLabel.isHidden = true
        progressView.progressBackgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        progressView.clockwise = true
        progressView.progressWidth = 2
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        levelBgView.backgroundColor = customerModel?.level.rawColor ?? #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        fllowLb.backgroundColor = #colorLiteral(red: 0.6274509804, green: 0.6745098039, blue: 0.7529411765, alpha: 1)
        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        levelBgView.backgroundColor = customerModel?.level.rawColor ?? #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        fllowLb.backgroundColor = #colorLiteral(red: 0.6274509804, green: 0.6745098039, blue: 0.7529411765, alpha: 1)
    }
}
