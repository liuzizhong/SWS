//
//  SW_WorkReportListCell.swift
//  SWS
//
//  Created by jayway on 2018/7/5.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_WorkReportListCell: UITableViewCell {
    
    @IBOutlet weak var portraitImageView: UIImageView!
    
    @IBOutlet weak var checkDoneInameView: UIImageView!
    
    @IBOutlet weak var typeTitleLb: UILabel!
    
    @IBOutlet weak var timeLb: UILabel!
    
    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var contentLb: UILabel!
    
    @IBOutlet weak var checkCountLb: UILabel!
    
    ///动态修改的约束
    @IBOutlet weak var checkCountLbHeightConstraint: NSLayoutConstraint!///normal   14.5
    
    @IBOutlet weak var checkCountLbTopConstraint: NSLayoutConstraint!
    
    var reportModel: SW_WorkReportListModel? {
        didSet {
            guard let reportModel = reportModel else { return }
             
            portraitImageView.badgeWidth = 10
            portraitImageView.badgeOffset = CGPoint(x: -3, y: 4)
            switch reportModel.ownerType {
            case .mine:
                checkCountLb.isHidden = false
                checkCountLb.text = "审阅情况(\(reportModel.checkCount)/\(reportModel.receiverTotal))"
                checkCountLbHeightConstraint.constant = 14.5
                checkCountLbTopConstraint.constant = 5
                
                if let url = URL(string: SW_UserCenter.shared.user?.portrait ?? "") {
                    portraitImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "icon_personalavatar"))
                } else {
                    portraitImageView.image = UIImage(named: "icon_personalavatar")
                }
                checkDoneInameView.isHidden = true
                typeTitleLb.text = "我的" + reportModel.type.rawTitle
                portraitImageView.badgeView(state: reportModel.isNewCheck)
            case .received:
                checkCountLb.isHidden = true
                checkCountLb.text = ""
                checkCountLbHeightConstraint.constant = 0
                checkCountLbTopConstraint.constant = 0
                
                if let url = URL(string: reportModel.portrait.thumbnailString()) {
                    portraitImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "icon_personalavatar"))
                } else {
                    portraitImageView.image = UIImage(named: "icon_personalavatar")
                }
                checkDoneInameView.isHidden = !reportModel.isCheck
                typeTitleLb.text = reportModel.reporterName + "的" + reportModel.type.rawTitle
                portraitImageView.badgeView(state: !reportModel.isCheck)
            }
            titleLb.text = reportModel.type == .day ? reportModel.workTypeStr : reportModel.title
            timeLb.text = Date.dateWith(timeInterval: reportModel.createDate).messageContentTimeString()
            contentLb.text = reportModel.content
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
