//
//  SW_NoCommenCell.swift
//  SWS
//
//  Created by jayway on 2018/7/13.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_NoCommenCell: Cell<String>, CellType {
    
    @IBOutlet weak var tipLabel: UILabel!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
    }
    
    public override func update() {
        super.update()
    }
    
}

final class SW_NoCommenRow: Row<SW_NoCommenCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_NoCommenCell>(nibName: "SW_NoCommenCell")
    }
}
