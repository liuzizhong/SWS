//
//  SW_AddCell.swift
//  SWS
//
//  Created by jayway on 2018/6/26.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_AddCell: Cell<String>, CellType {
    
    public override func setup() {
        super.setup()
//        selectionStyle = .none
    }
    
    public override func update() {
        super.update()
    }
    
    
    override func didSelect() {
        super.didSelect()
    }
   
}




final class SW_AddRow: Row<SW_AddCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_AddCell>(nibName: "SW_AddCell")
    }
}
