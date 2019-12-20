//
//  SW_ContractBoutiqueInstallCell.swift
//  SWS
//
//  Created by jayway on 2019/11/15.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_ContractBoutiqueInstallCell: Cell<String>, CellType, QMUITextFieldDelegate {
    
    @IBOutlet weak var seperateLine: UIView!
    @IBOutlet weak var installTitleLb: UILabel!
    @IBOutlet weak var installCountLb: UILabel!
    @IBOutlet weak var outCountLb: UILabel!
    @IBOutlet weak var saleCountLb: UILabel!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var numLb: UILabel!
    @IBOutlet weak var valueField: QMUITextField!
   
    private var rowForCell : SW_ContractBoutiqueInstallRow? {
        return row as? SW_ContractBoutiqueInstallRow
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        valueField.delegate = self
        valueField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        valueField.textAlignment = .center
        if rowForCell?.canInstall == false {
            valueField.isHidden = true
            installTitleLb.isHidden = true
            seperateLine.isHidden = true
        }
        if rowForCell?.maxCount == 0 {
            seperateLine.isHidden = true
            valueField.text = "0"
            valueField.textColor = UIColor.v2Color.disable
            installTitleLb.textColor = UIColor.v2Color.disable
        }
        
        setupData()
        valueField.placeholderColor = UIColor.v2Color.lightGray
        valueField.textInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        valueField.shouldResponseToProgrammaticallyTextChanges = false
    }
    
    public override func update() {
        super.update()
        setupData()
    }
    
    private func setupData() {
        if let model = rowForCell?.model {
            nameLb.text = model.name
            numLb.text = model.boutiqueNum
            saleCountLb.text = model.count.toAmoutString()
            outCountLb.text = model.concreteOutStockNum.toAmoutString()
            installCountLb.text = "已装数量:\(model.installCount.toAmoutString())"
        }
        if let value = row.value {
            valueField.text = value
        }
    }
    
    /// 控制field
    open override func cellCanBecomeFirstResponder() -> Bool {
        return !row.isDisabled && valueField.canBecomeFirstResponder == true
    }
    
    open override func cellBecomeFirstResponder(withDirection: Direction) -> Bool {
        return valueField.becomeFirstResponder()
    }
    
    open override func cellResignFirstResponder() -> Bool {
        return valueField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return rowForCell?.maxCount != 0 && rowForCell?.canInstall != false
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
//        if rowForCell?.isAmount == true {//金额输入框 ----
        let isHaveDian = textField.text?.contains(".") ?? false
        let isFirstZero = (textField.text?.firstString() == "0")
        
        if let max = rowForCell?.maxCount {//有限制最大值  判断输入的值是否超出范围
            let text: NSString = (textField.text  ?? "") as NSString
            if let amount = Double(text.replacingCharacters(in: range, with: string)), amount > max {
                valueField.text = max.toAmoutString()
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
                        if textField.text == "0.000",single == "0" {///不能输入0.0000
                            return false
                        }
                        if let dianRange = (textField.text as NSString?)?.range(of: "."), range.location <= dianRange.location {//有小数点，但输入的范围是整数部分，可以输入
                            return true
                        }
                        //用。分割后计算后面的个数 =====-----decimal  小数点后面的字符
                        let decimal = textField.text?.components(separatedBy: ".").last ?? ""
                        return decimal.count < rowForCell?.decimalCount ?? 2
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
    }
    
}

final class SW_ContractBoutiqueInstallRow: Row<SW_ContractBoutiqueInstallCell>, RowType {
    
    var canInstall = true
    
    var maxCount: Double?
    
    var model: SW_BoutiqueContractModel?
    
    /// 能输入的有效小数位数
    var decimalCount = 4
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_ContractBoutiqueInstallCell>(nibName: "SW_ContractBoutiqueInstallCell")
    }

}
