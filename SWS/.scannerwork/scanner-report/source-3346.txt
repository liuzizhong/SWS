//
//  SW_InformListCell.swift
//  SWS
//
//  Created by jayway on 2018/4/27.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_InformListCell: UITableViewCell {
    
    @IBOutlet weak var typeImageView: UIImageView!
    
    @IBOutlet weak var announcementTypeLb: UILabel!
    
    @IBOutlet weak var informImageView: UIImageView!
    
    @IBOutlet weak var timeLb: UILabel!
    
    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var detailLb: UILabel!
    
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    
    var model: SW_InformModel? {
        didSet {
            guard let model = model else { return }
            announcementTypeLb.text = model.msgType.rawTitle
            
            //            var iconUrl = ""
            switch model.msgType {
            case .group:
                //                iconUrl = SW_UserCenter.shared.user!.blocIcon
                typeImageView.image = UIImage(named: "announcement_icon_bloc")
            case .business:
                //                iconUrl = SW_UserCenter.shared.user!.busIcon
                typeImageView.image = UIImage(named: "announcement_icon_company")
            case .department:
                //                iconUrl = SW_UserCenter.shared.user!.depIcon
                typeImageView.image = UIImage(named: "announcement_icon_monad")
            }
            //            if !iconUrl.isEmpty, let url = URL(string: iconUrl) {
            //                typeImageView.sd_setImage(with: url, placeholderImage: model.msgType.defaultImage)
            //            } else {
            //                typeImageView.image = model.msgType.defaultImage
            //            }
            
            
            if !model.coverImg.isEmpty, let url = URL(string: model.coverImg) {
                informImageView.isHidden = false
                informImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "article_bg_img"))
                titleTopConstraint.constant = 202
            } else {
                informImageView.isHidden = true
                titleTopConstraint.constant = 10
            }
            if model.msgCollectDate != 0 {
                timeLb.text = Date.dateWith(timeInterval: model.msgCollectDate).specialTimeString()
            } else if model.publishDate != 0 {
                timeLb.text = Date.dateWith(timeInterval: model.publishDate).specialTimeString()
            } else {
                timeLb.text = Date.dateWith(timeInterval: TimeInterval(model.timestamp)).specialTimeString()
            }
            titleLb.text = model.title
            detailLb.text = model.content
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        typeImageView.layer.cornerRadius = typeImageView.height/2
//        detailLb.setQmui_lineHeight(21)
        detailLb.qmui_lineHeight = 21
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
