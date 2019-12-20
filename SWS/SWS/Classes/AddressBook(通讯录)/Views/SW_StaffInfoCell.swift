//
//  SW_StaffInfoCell.swift
//  SWS
//
//  Created by jayway on 2018/4/25.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_StaffInfoCell: Cell<String>, CellType {
    
    @IBOutlet weak var leftLb: UILabel!
    
    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var valueLb: UILabel!
    
    @IBOutlet weak var rightLb: UILabel!
    
    weak var bottomLine: UIView!
    
    @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomMarginConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var valueBottomMargin: NSLayoutConstraint!
    
    @IBOutlet weak var titleWidthConstraint: NSLayoutConstraint!
    
    private var rowForCell : SW_StaffInfoRow? {
        return row as? SW_StaffInfoRow
    }
    
    
    public override func setup() {
        super.setup()
        guard let rowForCell = rowForCell else { return }
        if rowForCell.isShowBottom {
            bottomLine = addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0))
        }
        if let margin = rowForCell.margin {
            topMarginConstraint.constant = margin
            bottomMarginConstraint.constant = margin
            valueBottomMargin.constant = margin
        }
        titleLb.text = rowForCell.rowTitle
        if let titleWidht = rowForCell.titleWidht {
            titleWidthConstraint.constant = max(titleWidht, rowForCell.rowTitle.size(titleLb.font, width: 0).width)
        } else {
            titleWidthConstraint.constant = rowForCell.rowTitle.size(titleLb.font, width: 0).width
        }
        if let rightValue = rowForCell.rightValue {
            rightLb.isHidden = false
            rightLb.text = rightValue
        } else {
            rightLb.isHidden = true
        }
        if let leftValue = rowForCell.leftValue {
            leftLb.isHidden = false
            leftLb.text = leftValue
        } else {
            leftLb.isHidden = true
        }
        
        if let value = row.value {
            valueLb.text = value
        }
    }
    
    public override func update() {
        super.update()
        if let value = row.value {
            valueLb.text = value
        }
        guard let rowForCell = rowForCell else { return }
        if let rightValue = rowForCell.rightValue {
            rightLb.isHidden = false
            rightLb.text = rightValue
        } else {
            rightLb.isHidden = true
        }
        
    }
}

final class SW_StaffInfoRow: Row<SW_StaffInfoCell>, RowType {
    
    var rowTitle = ""
    
    var isShowBottom = true
    
    var margin: CGFloat?
    
    var titleWidht: CGFloat?
    
    var rightValue: String?
    
    var leftValue: String?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_StaffInfoCell>(nibName: "SW_StaffInfoCell")
    }
}
