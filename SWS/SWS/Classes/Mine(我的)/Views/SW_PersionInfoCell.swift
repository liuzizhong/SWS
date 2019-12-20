//
//  SW_PersionInfoCell.swift
//  SWS
//
//  Created by jayway on 2018/12/10.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import Eureka

class SW_PersionInfoCell: Cell<String>, CellType {
   
    
    @IBOutlet weak var bottomLine: UIView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        
        if let userLogo = row.value ,
            let url = URL(string: userLogo) {
            iconImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "personalcenter_icon_personalavatar"))
        } else {
            iconImageView.image = UIImage(named: "personalcenter_icon_personalavatar")
        }
        bottomLine.addShadow()
    }
    
    
    public override func update() {
        super.update()
    }
    
}

final class SW_PersionInfoRow: Row<SW_PersionInfoCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_PersionInfoCell>(nibName: "SW_PersionInfoCell")
    }
    
}

