//
//  SW_ApplicableCarModelCell.swift
//  SWS
//
//  Created by jayway on 2019/3/27.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_ApplicableCarModelCell: Cell<Int>, CellType {
    
    @IBOutlet weak var carModelBtn: UIButton!
    
    @IBOutlet var options: [QMUIButton]!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private weak var selectButton: QMUIButton?
    
    private var rowForCell : SW_ApplicableCarModelRow? {
        return row as? SW_ApplicableCarModelRow
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
    }
    
    public override func update() {
        super.update()
        var selectTag = 101
        if let value = row.value, value == 2 {
            selectTag = 102
            carModelBtn.isHidden = false
            bottomConstraint.constant = 54
        } else {
            carModelBtn.isHidden = true
            bottomConstraint.constant = 10
        }
        /// 默认选择通用
        options.forEach { [weak self] (btn) in
            guard let self = self else { return }
            if  btn.tag == selectTag {
                btn.isSelected = true
                self.selectButton = btn
            }
        }
        if rowForCell?.carModel.isEmpty == true {
            carModelBtn.setTitleColor(UIColor.v2Color.lightGray, for: UIControl.State())
            carModelBtn.setTitle("点击选择车型", for: UIControl.State())
        } else {
            carModelBtn.setTitle(rowForCell?.carModel, for: UIControl.State())
            carModelBtn.setTitleColor(UIColor.v2Color.lightBlack, for: UIControl.State())
        }
        
    }
    
    @IBAction func optionBtnClick(_ sender: QMUIButton) {
        guard sender != selectButton else { return }
        options.forEach({ $0.isSelected = false })
        sender.isSelected = true
        selectButton = sender
        row.value = sender.tag - 100
    }
    
    
    @IBAction func carBtnClick(_ sender: UIButton) {
        rowForCell?.carClickBlock?()
    }
    
    override func didSelect() {
        super.didSelect()
    }
    
}

final class SW_ApplicableCarModelRow: Row<SW_ApplicableCarModelCell>, RowType {
    
    var carModel = ""
    
    var carClickBlock: NormalBlock?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_ApplicableCarModelCell>(nibName: "SW_ApplicableCarModelCell")
    }
    
}
