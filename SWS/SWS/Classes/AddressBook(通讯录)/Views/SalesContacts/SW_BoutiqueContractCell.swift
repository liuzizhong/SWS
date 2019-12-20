//
//  SW_BoutiqueContractCell.swift
//  SWS
//
//  Created by jayway on 2019/6/3.
//  Copyright © 2019 yuanrui. All rights reserved.
//


import Eureka

class SW_BoutiqueContractCell: Cell<SW_BoutiqueContractModel>, CellType {
    
    @IBOutlet weak var leftLb: UILabel!
    
    @IBOutlet weak var centerLb: UILabel!
    
    @IBOutlet weak var rightLb: UILabel!
    
    private var rowForCell: SW_BoutiqueContractRow? {
        return row as? SW_BoutiqueContractRow
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        addBottomLine(UIEdgeInsets.zero, height: 0.5)
        setUpValue()
    }
    
    public override func update() {
        super.update()
        setUpValue()
    }
    
    private func setUpValue() {
        if rowForCell?.isHeader == true {///
            leftLb.textColor = UIColor.v2Color.lightGray
            leftLb.font = MediumFont(14)
            centerLb.textColor = UIColor.v2Color.lightGray
            centerLb.font = MediumFont(14)
            rightLb.textColor = UIColor.v2Color.lightGray
            rightLb.font = MediumFont(14)
            leftLb.text = "精品名称"
            centerLb.text = "数量"
            rightLb.text = "安装数量"
        } else if let model = row.value {///
            leftLb.textColor = UIColor.v2Color.lightBlack
            leftLb.font = Font(15)
            centerLb.textColor = UIColor.v2Color.lightBlack
            centerLb.font = Font(15)
            rightLb.textColor = UIColor.v2Color.lightBlack
            rightLb.font = Font(15)
            leftLb.text = model.name
            centerLb.text = model.count.toAmoutString()
            rightLb.text = model.installCount.toAmoutString()
        }
        
    }
}

final class SW_BoutiqueContractRow: Row<SW_BoutiqueContractCell>, RowType {
    
    var isHeader = false
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_BoutiqueContractCell>(nibName: "SW_BoutiqueContractCell")
    }
}
