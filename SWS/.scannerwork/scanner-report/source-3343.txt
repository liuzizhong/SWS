//
//  SW_TempInformRangeCell.swift
//  SWS
//
//  Created by jayway on 2019/4/22.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_TempInformRangeCell: Cell<String>, CellType {
    
    @IBOutlet weak var selectImgView: UIImageView!
    
    @IBOutlet weak var nextBtn: QMUIButton!
    
    @IBOutlet weak var valueLb: UILabel!
    
    var isSelect = false {
        didSet {
            selectImgView.image = isSelect ? #imageLiteral(resourceName: "Main_select") : #imageLiteral(resourceName: "Main_unselect")
        }
    }
    
    private var rowForCell : SW_TempInformRangeRow? {
        return row as? SW_TempInformRangeRow
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .default
        nextBtn.imagePosition = .right
        
        if let value = row.value {
            valueLb.text = "(" + value + ")"
        } else {
            valueLb.text = "(0人)"
        }
    }
    
    public override func update() {
        super.update()
        
        if let value = row.value {
            valueLb.text = "(" + value + ")"
        } else {
            valueLb.text = "(0人)"
        }
    }
    
    @IBAction func nextBtnClick(_ sender: UIButton) {
        rowForCell?.nextBlock?()
    }
    
}

final class SW_TempInformRangeRow: Row<SW_TempInformRangeCell>, RowType {
    
    var isSelect = false {
        didSet {
            cell.isSelect = isSelect
        }
    }
    
    var nextBlock: NormalBlock?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_TempInformRangeCell>(nibName: "SW_TempInformRangeCell")
    }
}

