//
//  SW_WorkReportStaffListCell.swift
//  SWS
//
//  Created by jayway on 2019/1/17.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_WorkReportStaffListCell: UITableViewCell {

    @IBOutlet weak var portraitImageView: UIImageView!
    
    @IBOutlet weak var nameLb: UILabel!
    
    var staffModel: SW_WorkReportStaffListModel? {
        didSet {
           
            guard let staffModel = staffModel else { return }
            
            if let url = URL(string: staffModel.portrait.thumbnailString()) {
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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
