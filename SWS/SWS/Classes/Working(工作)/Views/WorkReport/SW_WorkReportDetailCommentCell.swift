//
//  SW_WorkReportDetailCommentCell.swift
//  SWS
//
//  Created by jayway on 2018/7/13.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_WorkReportDetailCommentCell: Cell<SW_RangeModel>, CellType {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLable: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        iconImageView.layer.cornerRadius = iconImageView.height/2
        setupCommen()
    }
    
    public override func update() {
        super.update()
        setupCommen()
    }
    
    private func setupCommen() {
        guard let model = row.value else { return }
        if let url = URL(string: model.portrait.thumbnailString()) {
            iconImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "icon_personalavatar"))
        } else {
            iconImageView.image = UIImage(named: "icon_personalavatar")
        }
        nameLabel.text = model.realName
        messageLable.text = model.comment
        dateLabel.text = Date.dateWith(timeInterval: model.checkDate).messageContentTimeString()
    }
}

final class SW_WorkReportDetailCommentRow: Row<SW_WorkReportDetailCommentCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_WorkReportDetailCommentCell>(nibName: "SW_WorkReportDetailCommentCell")
    }
}

