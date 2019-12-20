//
//  SW_SingleChoiceCell.swift
//  SWS
//
//  Created by jayway on 2018/8/17.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_SingleChoiceCell: Cell<String>, CellType {
    
    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet var options: [UIButton]!
    
    private weak var selectButton: UIButton?
    
    private var rowForCell: SW_SingleChoiceRow? {
        return row as? SW_SingleChoiceRow
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        guard let rowForCell = rowForCell else { return }
        options.forEach { [weak self] (btn) in
            guard let `self` = self else { return }
            let index = btn.tag - 100
            if index < rowForCell.allOptions.count {
                let title = rowForCell.allOptions[index]
                btn.setTitle(title, for: UIControl.State())
                btn.isHidden = false
                if let value = rowForCell.value, value == title {
                    btn.isSelected = true
                    self.selectButton = btn
                }
            } else {
                btn.isHidden = true
            }
        }
        
        titleLb.text = rowForCell.rawTitle
    }
    
    public override func update() {
        super.update()
        titleLb.text = rowForCell?.rawTitle
        
    }
    
    
    @IBAction func optionClickAction(_ sender: UIButton) {
        guard sender != selectButton else { return }
        options.forEach({ $0.isSelected = false })
        sender.isSelected = true
        selectButton = sender
        
        row.value = sender.title(for: UIControl.State())
    }
    
}

final class SW_SingleChoiceRow: Row<SW_SingleChoiceCell>, RowType {
    
    var rawTitle = ""
    
    var allOptions = [String]()
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_SingleChoiceCell>(nibName: "SW_SingleChoiceCell")
    }
}
