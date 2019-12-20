//
//  SW_FieldButtonCell.swift
//  SWS
//
//  Created by jayway on 2018/11/15.
//  Copyright © 2018 yuanrui. All rights reserved.
//


import Eureka
import VehicleKeyboard_swift

class SW_FieldButtonCell: Cell<String>, CellType, QMUITextFieldDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var valueField: QMUITextField!
    
    @IBOutlet weak var button: SW_BlueButton!
    
    private var rowForCell: SW_FieldButtonRow? {
        return row as? SW_FieldButtonRow
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        
        valueField.delegate = self
        valueField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        valueField.placeholder = rowForCell?.placeholder
        
        titleLabel.text = rowForCell?.rawTitle
        button.setTitle(rowForCell?.buttonTitle, for: UIControl.State())
        valueField.setPlaceholderColor(UIColor.v2Color.lightGray)
        if let value = row.value {
            valueField.text = value
            if let count = rowForCell?.enabledCount {
                button.isEnabled = value.count == count
            } else {
                button.isEnabled = value.count > 0
            }
        }
        if rowForCell?.isPlateKeyBoard == true {
            valueField.changeToPlatePWKeyBoardInpurView()
            valueField.changePlateInputType(isNewEnergy: true)
        } else {
            valueField.keyboardType = rowForCell?.keyboardType ?? .default
            valueField.shouldResponseToProgrammaticallyTextChanges = false
        }
    }
    
    public override func update() {
        super.update()
        
        titleLabel.text = rowForCell?.rawTitle
        button.setTitle(rowForCell?.buttonTitle, for: UIControl.State())
        if let value = row.value {
            valueField.text = value
            if let count = rowForCell?.enabledCount {
                button.isEnabled = value.count == count
            } else {
                button.isEnabled = value.count > 0
            }
        }
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
    
    
    @IBAction func buttonClick(_ sender: SW_BlueButton) {
        rowForCell?.buttonActionBlock?()
    }
    
    @objc open func textFieldDidChange(_ textField: UITextField) {
        row.value = textField.text
        
        if let count = rowForCell?.enabledCount {
            button.isEnabled = (textField.text?.count ?? 0) == count
        } else {
            button.isEnabled = (textField.text?.count ?? 0) > 0
        }
        if rowForCell?.isPlateKeyBoard == true, textField.text?.count == 0 {
            textField.refreshKeyboard(isMoreType: false)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty == true && string.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {///限制不能全输入空格,必须要有非空格的内容
            return false
        }
        if rowForCell?.isAmount == true {//金额输入框 ----
            let isHaveDian = textField.text?.contains(".") ?? false
            let isFirstZero = (textField.text?.firstString() == "0")
            
            if let max = rowForCell?.amountMax {//有限制最大值  判断输入的值是否超出范围
                let text: NSString = (textField.text  ?? "") as NSString
                if let amount = Double(text.replacingCharacters(in: range, with: string)), amount > max {
                    return false
                }
            }
            
            if string.count > 0 {//有输入
                let single = string.firstString()//当前输入的字符
                if "0123456789.".contains(single) {//可以输入的内容
                    if textField.text?.count == 0 {//输入第一个字符
                        if single == "." {//首字母不能为小数点
                            return false
                        }
                        return true//第一位只有.不能输入
                    }
                    //已经有输入内容
                    if single == "." {
                        if isHaveDian {
                            return false
                        } else {//text中还没有小数点
                            return true
                        }
                    } else {
                        if isHaveDian {//存在小数点，保留两位小数
                            //首位有0有.（0.01）或首位没0有.（10200.00）可输入两位数的0
                            if textField.text == "0.0",single == "0" {///不能输入0.00
                                return false
                            }
                            if let dianRange = (textField.text as NSString?)?.range(of: "."), range.location <= dianRange.location {//有小数点，但输入的范围是整数部分，可以输入
                                return true
                            }
                            //用。分割后计算后面的个数 =====-----decimal  小数点后面的字符
                            let decimal = textField.text?.components(separatedBy: ".").last ?? ""
                            return decimal.count < 2
                        } else if isFirstZero && !isHaveDian {//首位有0没点 不能输入了  金额就是0了
                            return false
                        } else {///其余可以直接输入
                            return true
                        }
                    }
                } else {//输入错误字符
                    return false
                }
            } else {
                return true
            }
        } else if let limit = rowForCell?.limitCount {//设置了限制长度
            let textcount = textField.text?.count ?? 0
            if string.count + textcount - range.length > limit {
                return false
            }
            return true
        }
        return true
    }
    
}

final class SW_FieldButtonRow: Row<SW_FieldButtonCell>, RowType {
    
    var buttonTitle = ""
    
    var buttonActionBlock: NormalBlock?
    
    var rawTitle = ""
    
    var placeholder = ""
    
    var isAmount = false
    
    var keyboardType:UIKeyboardType = .default
    
    var amountMax: Double?
    
    var limitCount: Int?
    
    var enabledCount: Int?
    
    var isPlateKeyBoard = false
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_FieldButtonCell>(nibName: "SW_FieldButtonCell")
    }
    
}
