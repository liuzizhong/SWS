//
//  SWInformMessageCell.swift
//  SWS
//
//  Created by jayway on 2018/5/19.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SWInformMessageCell: UITableViewCell {

    var avatarView = EaseImageView()
    var titleLabel = UILabel()
    var detailLabel = UILabel()
    var timeLabel = UILabel()
    
    var model: informConversationModel? {
        didSet {
            guard let model = model else { return }
            if !model.iconUrl.isEmpty, let url = URL(string: model.iconUrl) {
                avatarView.imageView.sd_setImage(with: url)
            } else {
                titleLabel.text = model.title
                avatarView.imageView.image = model.type.defaultImage
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
    }
    
    func titleShowCenter(_ isCenter: Bool) {
        if isCenter {
            detailLabel.isHidden = true
            timeLabel.isHidden = true
            titleLabel.snp.remakeConstraints({ (make) in
                make.leading.equalTo(avatarView.snp.trailing).offset(10)
                make.trailing.equalTo(timeLabel.snp.leading).offset(-10)
                make.centerY.equalToSuperview()
                make.height.equalToSuperview().multipliedBy(0.5).offset(-12)
            })
        } else {
            detailLabel.isHidden = false
            timeLabel.isHidden = false
            titleLabel.snp.remakeConstraints({ (make) in
                make.leading.equalTo(avatarView.snp.trailing).offset(10)
                make.trailing.equalTo(timeLabel.snp.leading).offset(-10)
                make.top.equalTo(12)
                make.height.equalToSuperview().multipliedBy(0.5).offset(-12)
            })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        // Initialization code
    }

    private func setup() {
        
        self.accessibilityIdentifier = "tablecell"
        
        timeLabel.font = Font(12)
        timeLabel.textColor = UIColor.v2Color.lightGray
        timeLabel.textAlignment = .right
        titleLabel.accessibilityIdentifier = "title"
        titleLabel.numberOfLines = 1
        titleLabel.font = MediumFont(16)
        titleLabel.textColor = UIColor.v2Color.lightBlack
        detailLabel.font = Font(14)
        detailLabel.textColor = UIColor.v2Color.lightGray
        
        contentView.addSubview(avatarView)
        avatarView.snp.makeConstraints { (make) in
            make.leading.equalTo(15)
            make.centerY.equalToSuperview()
            make.height.equalTo(54)
            make.width.equalTo(avatarView.snp.height)
        }
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(-15)
            make.top.equalTo(10)
            make.height.equalToSuperview().multipliedBy(0.5)
        }
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(avatarView.snp.trailing).offset(10)
            make.trailing.equalTo(timeLabel.snp.leading).offset(-10)
            make.top.equalTo(12)
            make.height.equalToSuperview().multipliedBy(0.5).offset(-12)
        }
        contentView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.trailing.bottom.equalTo(-12)
            make.leading.equalTo(titleLabel.snp.leading)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if (avatarView.badge > 0) {
            avatarView.badgeBackgroudColor = #colorLiteral(red: 1, green: 0.2509803922, blue: 0.2509803922, alpha: 1)
        }
        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if (avatarView.badge > 0) {
            avatarView.badgeBackgroudColor = #colorLiteral(red: 1, green: 0.2509803922, blue: 0.2509803922, alpha: 1)
        }
    }
    
    class func cellIdentifier() -> String {
        return "SWInformMessageCellIdentifier"
    }

}
