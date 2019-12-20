//
//  SW_CustomerLevelChoiceCell.swift
//  SWS
//
//  Created by jayway on 2018/11/8.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import Eureka

class SW_CustomerLevelChoiceCell: Cell<CustomerLevel>, CellType {

    private var rowForCell: SW_CustomerLevelChoiceRow? {
        return row as? SW_CustomerLevelChoiceRow
    }
    @IBOutlet weak var tipLb: UILabel!
    
    @IBOutlet var options: [QMUIButton]!
    
    @IBOutlet var OMBtns: [QMUIButton]!
    
    weak var selectButton: QMUIButton? {
        didSet {
            guard let selectButton = selectButton else { return }
            let level = CustomerLevel(selectButton.title(for: UIControl.State())!)
            tipLb.isHidden = false
            tipLb.attributedText = level.tipText
            row.value = level
        }
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        OMBtns.forEach { [weak self] (btn) in
//            guard let self = self else { return }
//            btn.isHidden = self?.rowForCell?.isShowOM == false
            if self?.rowForCell?.isShowOM == false {
                btn.removeFromSuperview()
            }
        }
        options.forEach { [weak self] (btn) in
            guard let self = self else { return }
            if let value = self.rowForCell?.value, value.rawString == btn.title(for: UIControl.State()) {
                btn.isSelected = true
                self.selectButton = btn
            }
        }
    }
    
    public override func update() {
        super.update()
    }
    
    @IBAction func optionClickAction(_ sender: QMUIButton) {
        guard sender != selectButton else { return }
        options.forEach({ $0.isSelected = false })
        sender.isSelected = true
        selectButton = sender
    }
}

final class SW_CustomerLevelChoiceRow: Row<SW_CustomerLevelChoiceCell>, RowType {
    
    var isShowOM = false
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_CustomerLevelChoiceCell>(nibName: "SW_CustomerLevelChoiceCell")
    }
}

