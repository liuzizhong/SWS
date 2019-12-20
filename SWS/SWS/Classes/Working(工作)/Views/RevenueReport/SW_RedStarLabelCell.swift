//
//  SW_RedStarLabelCell.swift
//  SWS
//
//  Created by jayway on 2018/6/22.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_RedStarLabelCell: Cell<String>, CellType {
    
    @IBOutlet weak var redStarImgView: UIImageView!
    
    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var valueLb: UILabel!
    
    @IBOutlet weak var nextPageImgView: UIImageView!
    
    var placeholder = ""
    
    var isMustChoose = false {
        didSet {
            redStarImgView.isHidden = !isMustChoose
        }
    }
    
    private var rowForCell : SW_RedStarLabelRow? {
        return row as? SW_RedStarLabelRow
    }
    
    
    public override func setup() {
        super.setup()
        selectionStyle = .default
        
        titleLb.text = rowForCell?.rawTitle
        if let value = row.value, !value.isEmpty {
            valueLb.text = value
            valueLb.textColor = UIColor.mainColor.darkBlack
        } else {
            valueLb.text = placeholder
            valueLb.textColor = #colorLiteral(red: 0.7450980392, green: 0.7450980392, blue: 0.7450980392, alpha: 1)
        }
    }
    
    public override func update() {
        super.update()
        titleLb.text = rowForCell?.rawTitle
        if let value = row.value, !value.isEmpty {
            valueLb.text = value
            valueLb.textColor = UIColor.mainColor.darkBlack
        } else {
            valueLb.text = placeholder
            valueLb.textColor = #colorLiteral(red: 0.7450980392, green: 0.7450980392, blue: 0.7450980392, alpha: 1)
        }
    }
}

final class SW_RedStarLabelRow: Row<SW_RedStarLabelCell>, RowType {
    
    var rawTitle = ""
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_RedStarLabelCell>(nibName: "SW_RedStarLabelCell")
    }
}
