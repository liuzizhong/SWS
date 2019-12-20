//
//  SW_ChatSettingTopCell.swift
//  SWS
//
//  Created by jayway on 2018/5/23.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_ChatSettingTopCell: Cell<String>, CellType {
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var titleLb: UILabel!
    
    private var rowForCell : SW_ChatSettingTopRow? {
        return row as? SW_ChatSettingTopRow
    }
    
    
    public override func setup() {
        super.setup()
        
        iconImageView.layer.cornerRadius = iconImageView.height/2
        iconImageView.layer.masksToBounds = true
        
        titleLb.text = rowForCell?.rowTitle
        if let value = row.value, let url = URL(string: value) {
            iconImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "icon_groupavatar"))
        } else {
            iconImageView.image = UIImage(named: "icon_groupavatar")
        }
    }
    
    public override func update() {
        super.update()
    }
}

final class SW_ChatSettingTopRow: Row<SW_ChatSettingTopCell>, RowType {
    
    var rowTitle = ""
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_ChatSettingTopCell>(nibName: "SW_ChatSettingTopCell")
    }
}
