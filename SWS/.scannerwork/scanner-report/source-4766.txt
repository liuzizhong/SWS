//
//  SW_CommenLabelCell.swift
//  SWS
//
//  Created by jayway on 2018/11/8.
//  Copyright © 2018 yuanrui. All rights reserved.
//


import Eureka

class SW_CommenLabelCell: Cell<String>, CellType {
    
    @IBOutlet weak var rightActionLb: UILabel!
    
    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var valueLb: UILabel!
    
    @IBOutlet weak var seperaLine: UIView!
    
    var placeholder = ""
    
    private var rowForCell : SW_CommenLabelRow? {
        return row as? SW_CommenLabelRow
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .default
        guard let rowForCell = rowForCell else { return }
        seperaLine.isHidden = !rowForCell.isShowBottomLine
        if rowForCell.allowsMultipleLine {
            valueLb.numberOfLines = 0
        }
        titleLb.text = rowForCell.rawTitle
        if let value = row.value, !value.isEmpty {
            valueLb.text = value
            valueLb.textColor = UIColor.v2Color.lightBlack
        } else {
            valueLb.text = placeholder
            valueLb.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        }
    }
    
    public override func update() {
        super.update()
        titleLb.text = rowForCell?.rawTitle
        if let value = row.value, !value.isEmpty {
            valueLb.text = value
            valueLb.textColor = UIColor.v2Color.lightBlack
        } else {
            valueLb.text = placeholder
            valueLb.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        }
        
    }
}

final class SW_CommenLabelRow: Row<SW_CommenLabelCell>, RowType {
    
    var rawTitle = ""
    
    var isShowBottomLine = true
    
    //label是否多行显示
    var allowsMultipleLine = false
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_CommenLabelCell>(nibName: "SW_CommenLabelCell")
    }
}
