//
//  SW_CarBudgetCell.swift
//  SWS
//
//  Created by jayway on 2018/11/9.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import Eureka

class SW_CarBudgetCell: Cell<String>, CellType, UITextFieldDelegate {
    
    @IBOutlet weak var valueField: UITextField!
    
    @IBOutlet weak var countField: UITextField!
    
    @IBOutlet var options: [QMUIButton]!
    
    private weak var selectButton: QMUIButton?
    
    private var rowForCell : SW_CarBudgetRow? {
        return row as? SW_CarBudgetRow
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        valueField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        countField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        guard let rowForCell = rowForCell else { return }
        options.forEach { [weak self] (btn) in
            guard let self = self else { return }
            if  rowForCell.buyWay.rawString == btn.title(for: UIControl.State()) {
                btn.isSelected = true
                self.selectButton = btn
            }
        }
        valueField.setPlaceholderColor(UIColor.v2Color.lightGray)
        countField.setPlaceholderColor(UIColor.v2Color.lightGray)

        
        if let value = row.value {
            valueField.text = value
        }
        if let count = rowForCell.count, count != 0 {
            countField.text = "\(count)"
        } else {
            countField.text = ""
        }
    }
    
    public override func update() {
        super.update()
        guard let rowForCell = rowForCell else { return }
        if let value = row.value {
            valueField.text = value
        }
        if let count = rowForCell.count, count != 0 {
            countField.text = "\(count)"
        } else {
            countField.text = ""
        }
    }
    
    @IBAction func optionBtnClick(_ sender: QMUIButton) {
        guard sender != selectButton else { return }
        options.forEach({ $0.isSelected = false })
        sender.isSelected = true
        selectButton = sender
        let buyWay = BuyWay(rawValue: sender.tag - 100) ?? .none
        rowForCell?.buyWay = buyWay
        rowForCell?.buyWayChangeBlock?(buyWay)
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == valueField {
            row.value = textField.text
        } else {
            rowForCell?.count = Int(textField.text ?? "0") ?? 0
            rowForCell?.buyCountChangeBlock?(Int(textField.text ?? "0") ?? 0)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty == true && string.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {///限制不能全输入空格,必须要有非空格的内容
            return false
        }
        //设置了限制长度 名字最多3位 可以改
        let textcount = textField.text?.count ?? 0
        if string.count + textcount - range.length > 3 {
            return false
        }
        return true
        
    }
    
}

final class SW_CarBudgetRow: Row<SW_CarBudgetCell>, RowType {
    
    var buyWay = BuyWay.none
    
    var count: Int?
    
    var buyWayChangeBlock: ((BuyWay)->Void)?
    
    var buyCountChangeBlock: ((Int)->Void)?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_CarBudgetCell>(nibName: "SW_CarBudgetCell")
    }
    
}

