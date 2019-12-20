//
//  SW_CarUserCell.swift
//  SWS
//
//  Created by jayway on 2018/11/8.
//  Copyright © 2018 yuanrui. All rights reserved.
//


import Eureka

class SW_CarUserCell: Cell<String>, CellType, UITextFieldDelegate {
    
    @IBOutlet weak var valueField: UITextField!
    
    @IBOutlet var options: [QMUIButton]!
    
    private weak var selectButton: QMUIButton?
    
    private var rowForCell : SW_CarUserRow? {
        return row as? SW_CarUserRow
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        valueField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        guard let rowForCell = rowForCell else { return }
        options.forEach { [weak self] (btn) in
            guard let self = self else { return }
            if  rowForCell.sex.rawTitle == btn.title(for: UIControl.State()) {
                btn.isSelected = true
                self.selectButton = btn
            }
        }

        valueField.setPlaceholderColor(UIColor.v2Color.lightGray)
        if let value = row.value {
            valueField.text = value
        }
    }
    
    public override func update() {
        super.update()
        
        if let value = row.value {
            valueField.text = value
        }
    }
    
    @IBAction func optionBtnClick(_ sender: QMUIButton) {
        guard sender != selectButton else { return }
        options.forEach({ $0.isSelected = false })
        sender.isSelected = true
        selectButton = sender
        let sex = Sex(rawValue: sender.tag - 100) ?? .women
        rowForCell?.sex = sex
        rowForCell?.sexChangeBlock?(sex)
    }
    open override func cellCanBecomeFirstResponder() -> Bool {
        return !row.isDisabled && valueField.canBecomeFirstResponder == true
    }
    
    open override func cellBecomeFirstResponder(withDirection: Direction) -> Bool {
        return valueField.becomeFirstResponder()
    }
    
    open override func cellResignFirstResponder() -> Bool {
        return valueField.resignFirstResponder()
    }
    
    override func didSelect() {
        super.didSelect()
    }
    
    @objc open func textFieldDidChange(_ textField: UITextField) {
        row.value = textField.text
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty == true && string.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {///限制不能全输入空格,必须要有非空格的内容
            return false
        }
        //设置了限制长度 名字最多10位
        let textcount = textField.text?.count ?? 0
        if string.count + textcount - range.length > 10 {
            return false
        }
        return true
        
    }
    
}

final class SW_CarUserRow: Row<SW_CarUserCell>, RowType {
    
    var rawTitle = ""
    
    var sex = Sex.unkown
    
    var sexChangeBlock: ((Sex)->Void)?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_CarUserCell>(nibName: "SW_CarUserCell")
    }
    
}
