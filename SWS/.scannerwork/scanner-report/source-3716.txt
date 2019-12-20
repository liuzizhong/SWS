//
//  SW_ComplaintsListCell.swift
//  SWS
//
//  Created by jayway on 2019/6/24.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_ComplaintsListCell: UITableViewCell {
    
    @IBOutlet weak var creatTimeLb: UILabel!
    @IBOutlet weak var contentImgView: UIImageView!
    
    @IBOutlet weak var contentLb: UILabel!
    
    @IBOutlet weak var replyTimeLb: UILabel!
    @IBOutlet weak var replyLb: UILabel!
    
    @IBOutlet weak var replyImgView: UIImageView!
    
    @IBOutlet weak var auditLb: UILabel!
    
    @IBOutlet weak var dealBtn: UIButton!
    
    var dealBlock: NormalBlock?
    
    @IBOutlet weak var replyTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var replyContentBottomConstraint: NSLayoutConstraint!
    
    var model: SW_ComplaintsModel? {
        didSet {
            guard let model = model else { return }
            
            creatTimeLb.text = Date.dateWith(timeInterval: model.createDate).stringWith(formatStr: "yyyy/MM/dd  HH:mm")
            contentLb.text = model.content
            
            if model.replyDate != 0 {/// 有时间说明已经处理过。
                replyTimeLb.text = Date.dateWith(timeInterval: model.replyDate).stringWith(formatStr: "yyyy/MM/dd  HH:mm")
                replyTimeLb.isHidden = false
                replyTopConstraint.constant = 28
                replyLb.isHidden = false
                replyLb.text = model.replyContent
//                replyContentBottomConstraint.constant = 18
                dealBtn.isHidden = true
                auditLb.text = "待审核"
                auditLb.isHidden = model.auditState != .waitAudit
            } else {
                replyTimeLb.text = ""
                replyTimeLb.isHidden = true
                replyTopConstraint.constant = 10
                replyLb.isHidden = true
                replyLb.text = ""
//                replyContentBottomConstraint.constant = 8
                dealBtn.isHidden = false
                auditLb.text = "待处理"
                auditLb.isHidden = false
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        contentLb.font = Font(15)
        replyLb.font = Font(15)
    }
    
    @IBAction func dealBtnClick(_ sender: UIButton) {
        dealBlock?()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
