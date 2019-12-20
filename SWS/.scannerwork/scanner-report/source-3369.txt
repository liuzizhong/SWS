//
//  SW_RevenueDetailNormalCell.swift
//  SWS
//
//  Created by jayway on 2018/6/28.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_RevenueDetailNormalCell: Cell<String>, CellType {
    
    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var valueLb: UILabel!
    
    @IBOutlet weak var dottedLine: UIImageView!
    
    
    private var rowForCell : SW_RevenueDetailNormalRow? {
        return row as? SW_RevenueDetailNormalRow
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        
        titleLb.text = rowForCell?.rawTitle
        if let value = row.value {
            valueLb.text = value
        }
    }
    
    public override func update() {
        super.update()
    }
}

final class SW_RevenueDetailNormalRow: Row<SW_RevenueDetailNormalCell>, RowType {
    
    var rawTitle = ""
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_RevenueDetailNormalCell>(nibName: "SW_RevenueDetailNormalCell")
    }
}
