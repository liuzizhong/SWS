//
//  SW_ReadRecordListCell.swift
//  SWS
//
//  Created by jayway on 2019/7/24.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_ReadRecordListCell: UITableViewCell {
    
    @IBOutlet weak var portraitImageView: UIImageView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var isReadLb: UILabel!
    @IBOutlet weak var positionLb: UILabel!
    
    var model: SW_ReadRecordStaffModel? {
        didSet {
            guard let model = model else { return }
            nameLb.text = model.staffName
            isReadLb.isHidden = !model.isRead
            positionLb.text = model.positionName.isEmpty ? "" : "(\(model.positionName))"
            if let url = URL(string: model.portrait.thumbnailString()) {
                portraitImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "icon_personalavatar"))
            } else {
                portraitImageView.image = UIImage(named: "icon_personalavatar")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        portraitImageView.layer.cornerRadius = portraitImageView.height/2
        isReadLb.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        isReadLb.backgroundColor = #colorLiteral(red: 0.6274509804, green: 0.6745098039, blue: 0.7529411765, alpha: 1)
        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        isReadLb.backgroundColor = #colorLiteral(red: 0.6274509804, green: 0.6745098039, blue: 0.7529411765, alpha: 1)
    }
}
