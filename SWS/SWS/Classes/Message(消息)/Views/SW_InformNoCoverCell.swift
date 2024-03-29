//
//  SW_InformNoCoverCell.swift
//  SWS
//
//  Created by jayway on 2018/5/21.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_InformNoCoverCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var detailBgView: UIView!
    
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var summaryLabel: UILabel!
    
    @IBOutlet weak var timeLbWidth: NSLayoutConstraint!
    
    var type = InformType.group {
        didSet {
            typeLabel.text = type.rawTitle
        }
    }
    
    var model: SW_InformModel? {
        didSet {
            guard let model = model else { return }
            let time = Date.dateWith(timeInterval: TimeInterval(model.timestamp)).messageContentTimeString()
            timeLbWidth.constant = time.size(Font(12), width: 0).width + 20
            timeLabel.text = time
            titleLabel.text = model.title
            summaryLabel.text = model.content
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        timeLabel.layer.cornerRadius = 10
        detailBgView.layer.cornerRadius = 3
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        detailBgView.backgroundColor = isHighlighted ? #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        // Configure the view for the selected state
    }

}
