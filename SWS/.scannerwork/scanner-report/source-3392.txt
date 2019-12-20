//
//  SW_DataShareListCell.swift
//  SWS
//
//  Created by jayway on 2019/1/22.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_DataShareListCell: UITableViewCell {

    @IBOutlet weak var portraitImageView: UIImageView!
    
    @IBOutlet weak var publisherLb: UILabel!
    
    @IBOutlet weak var articleImageView: UIImageView!
    
    @IBOutlet weak var timeLb: UILabel!
    
    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var detailLb: UILabel!
    
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var readCountLb: UILabel!
    
    @IBOutlet weak var collectionCountBtn: QMUIButton!
    
    var model: SW_DataShareListModel? {
        didSet {
            guard let model = model else { return }
            publisherLb.text = model.positionName.isEmpty ? model.publisher : model.publisher + "(\(model.positionName))"
            
            let iconUrl = model.publisherPortrait.thumbnailString()
            if !iconUrl.isEmpty, let url = URL(string: iconUrl) {
                portraitImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "icon_personalavatar"))
            } else {
                portraitImageView.image = #imageLiteral(resourceName: "icon_personalavatar")
            }
            if !model.coverImg.isEmpty, let url = URL(string: model.coverImg) {
                articleImageView.isHidden = false
                articleImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "article_bg_img"))
                titleTopConstraint.constant = 202
            } else {
                articleImageView.isHidden = true
                titleTopConstraint.constant = 10
            }
            readCountLb.text = "阅 \(model.readedCount)"
            collectionCountBtn.setTitle("\(model.collectCount)", for: UIControl.State())
            collectionCountBtn.isSelected = model.isCollect
            
//            if model.collectorDate != 0 {
//                timeLb.text = Date.dateWith(timeInterval: model.collectorDate).specialTimeString()
//            } else {
                timeLb.text = Date.dateWith(timeInterval: model.publishDate).specialTimeString()
//            }
            titleLb.text = model.title
            detailLb.text = model.summary
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        portraitImageView.layer.cornerRadius = portraitImageView.height/2
        detailLb.qmui_lineHeight = 21
//        detailLb.setQmui_lineHeight(21)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
