//
//  SW_SearchMessageCell.swift
//  SWS
//
//  Created by jayway on 2018/6/20.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_SearchMessageCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLable: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var keyWord = ""
    
    var message: EMMessage? {
        didSet {
            guard let message = message else { return }
            
            if let info = UserCacheManager.getUserInfo(message.from) {
                if let url = URL(string: info.avatarUrl.thumbnailString()) {
                    iconImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "icon_personalavatar"))
                } else {
                    iconImageView.image = UIImage(named: "icon_personalavatar")
                }
                nameLabel.text = info.nickName
            }
            
            var messageText = SW_SearchMessageCell.messageTitleForMessageModel(message: message)
            if keyWord.isEmpty {
                messageLable.text = messageText
            } else {
                if let index = messageText.range(of: keyWord)?.lowerBound {
                    if String(messageText[..<index]).count > 12 {
                        messageText = "..." + String(messageText[messageText.index(index, offsetBy: -12)...])
                    }
                }
                messageLable.attributedText = NSString(string:messageText).mutableAttributedString(keyWord, andColor: UIColor.v2Color.blue, andSeparator: true)
            }
            dateLabel.text = Date.dateWith(timeInterval: TimeInterval(message.timestamp)).messageContentTimeString()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        iconImageView.layer.cornerRadius = iconImageView.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    class func messageTitleForMessageModel(message: EMMessage?) -> String {
        guard let message = message else { return "" }
        
        var messageTitle = ""//""
        
        let messageBody = message.body!
        switch messageBody.type {
        case EMMessageBodyTypeImage:
            messageTitle = "[图片]"
        case EMMessageBodyTypeText:
            let didReceiveText = EaseConvertToCommonEmoticonsHelper.convert(toSystemEmoticons: (messageBody as! EMTextMessageBody).text)
            messageTitle = didReceiveText ?? ""
        case EMMessageBodyTypeVoice:
            messageTitle = "[语音]"
        case EMMessageBodyTypeLocation:
            messageTitle = "[位置]"
        case EMMessageBodyTypeVideo:
            messageTitle = "[视频]"
        case EMMessageBodyTypeFile:
            messageTitle = "[文件]"
        default:
            break
        }

        return messageTitle
    }
    
}
