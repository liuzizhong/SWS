//
//  SW_SuggestionListCell.swift
//  SWS
//
//  Created by jayway on 2018/12/11.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_SuggestionListCell: UITableViewCell {

    @IBOutlet weak var timeLb: UILabel!
    
    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var contentImgView: UIImageView!
    @IBOutlet weak var contentLb: UILabel!
    
    @IBOutlet weak var repleyLb: UILabel!
    
    @IBOutlet weak var repleyImgView: UIImageView!
    
    @IBOutlet weak var contentTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var replyContentBottomConstraint: NSLayoutConstraint!
    
    var model: SW_SuggestionModel? {
        didSet {
            guard let model = model else { return }
            
            timeLb.text = Date.dateWith(timeInterval: model.createDate).stringWith(formatStr: "yyyy/MM/dd  HH:mm")
            contentLb.text = model.content
            
            if model.tittle.isEmpty {
                titleLb.text = ""
                titleLb.isHidden = true
                contentTopConstraint.constant = 10
            } else {
                titleLb.text = model.tittle
                titleLb.isHidden = false
                contentTopConstraint.constant = 32
            }
            
            if model.replyContent.isEmpty {
                repleyImgView.isHidden = true
                repleyLb.isHidden = true
                repleyLb.text = ""
                replyContentBottomConstraint.constant = 8
            } else {
                repleyImgView.isHidden = false
                repleyLb.isHidden = false
                repleyLb.text = model.replyContent
                replyContentBottomConstraint.constant = 18
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        contentLb.font = Font(15)
        repleyLb.font = Font(15)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
