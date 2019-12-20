//
//  SW_InsuranceInfoCell.swift
//  SWS
//
//  Created by jayway on 2019/5/29.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_InsuranceInfoCell: Cell<String>, CellType {
    
    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var valueLb: UILabel!
    
    @IBOutlet weak var rightLb: UILabel!
    
    private var rowForCell : SW_InsuranceInfoRow? {
        return row as? SW_InsuranceInfoRow
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        guard let rowForCell = rowForCell else { return }
        
        titleLb.text = rowForCell.rowTitle
        rightLb.text = rowForCell.rightValue
        valueLb.text = row.value
//        if let value = row.value {
//        }
    }
    
    public override func update() {
        super.update()
        guard let rowForCell = rowForCell else { return }
        
        titleLb.text = rowForCell.rowTitle
        rightLb.text = rowForCell.rightValue
        valueLb.text = row.value
    }
}

final class SW_InsuranceInfoRow: Row<SW_InsuranceInfoCell>, RowType {
    
    var rowTitle = ""
    
    var rightValue: String?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_InsuranceInfoCell>(nibName: "SW_InsuranceInfoCell")
    }
}
