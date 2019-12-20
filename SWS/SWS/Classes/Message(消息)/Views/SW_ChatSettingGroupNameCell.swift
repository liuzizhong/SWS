//
//  SW_ChatSettingGroupNameCell.swift
//  SWS
//
//  Created by jayway on 2018/12/1.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import Eureka

class SW_ChatSettingGroupNameCell: Cell<String>, CellType {
    
    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var nameLb: UILabel!
    
    @IBOutlet weak var nextPageImgView: UIImageView!
    
    
    private var rowForCell : SW_ChatSettingGroupNameRow? {
        return row as? SW_ChatSettingGroupNameRow
    }
    
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        nameLb.text = row.value
        addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
        guard let rowForCell = rowForCell else { return }
        nextPageImgView.isHidden = !rowForCell.isGroupOwner
    }
    
    public override func update() {
        super.update()
        nameLb.text = row.value
    }
    
}

final class SW_ChatSettingGroupNameRow: Row<SW_ChatSettingGroupNameCell>, RowType {
    
    var editActionBlock: NormalBlock?
    
    var isGroupOwner = false
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_ChatSettingGroupNameCell>(nibName: "SW_ChatSettingGroupNameCell")
    }
}
