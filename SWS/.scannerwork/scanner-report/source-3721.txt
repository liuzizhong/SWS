//
//  SW_AddressBookHomeCell.swift
//  SWS
//
//  Created by jayway on 2018/11/1.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit


class SW_AddressBookHomeCell: UITableViewCell {
    
    @IBOutlet weak var titleLb: QMUIButton!
    
    @IBOutlet weak var describeLb: UILabel!
    
    var titleClickBlock: NormalBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        titleLb.imagePosition = .right
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func titleBtnClick(_ sender: UIButton) {
        if #available(iOS 10.0, *) {//添加触感反馈
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        } else {
            // Fallback on earlier versions
        }
        titleClickBlock?()
    }
}
