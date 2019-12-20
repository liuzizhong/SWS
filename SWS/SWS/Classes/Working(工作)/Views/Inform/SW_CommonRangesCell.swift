//
//  SW_CommonRangesCell.swift
//  SWS
//
//  Created by jayway on 2018/5/11.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_CommonRangesCell: Cell<String>, CellType {
    
    @IBOutlet weak var selectImgView: UIImageView!
    
    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var valueLb: UILabel!
    
    var isSelect = false {
        didSet {
            selectImgView.image = isSelect ? #imageLiteral(resourceName: "Main_select") : #imageLiteral(resourceName: "Main_unselect")
        }
    }
    
    private var rowForCell : SW_CommonRangesRow? {
        return row as? SW_CommonRangesRow
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .default
        
        titleLb.text = rowForCell?.rowTitle
        if let value = row.value {
            valueLb.text = "(" + value + ")"
        }
    }
    
    public override func update() {
        super.update()
        titleLb.text = rowForCell?.rowTitle
        if let value = row.value {
            valueLb.text = "(" + value + ")"
        }
    }
    
    @IBAction func deleteBtnClick(_ sender: UIButton) {
        rowForCell?.deleteBlock?()
    }
    
}

final class SW_CommonRangesRow: Row<SW_CommonRangesCell>, RowType {
    
    var rowTitle = ""
    
    var isSelect = false {
        didSet {
            cell.isSelect = isSelect
        }
    }
    
    var deleteBlock: NormalBlock?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_CommonRangesCell>(nibName: "SW_CommonRangesCell")
    }
}

