//
//  SW_BigSearchTextField.swift
//  SWS
//
//  Created by jayway on 2018/11/20.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_BigSearchTextField: UIView {

    @IBOutlet weak var textField: UITextField!
    
    var searchBlock: NormalBlock?
    
    var textChangeBlock: NormalBlock?
    
    var maxCount: Int?
    
    var searchText: String {
        get {
            return textField.text ?? ""
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        searchBgView.addShadow()
//        layer.shadowOpacity = 0
//        searchBgView.layer.cornerRadius = 3
        
    }

    @IBAction func textfieldEditingChanged(_ sender: UITextField) {
        textChangeBlock?()
    }
    
}

extension SW_BigSearchTextField: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let searchBlock = searchBlock else { return  true}
        textField.resignFirstResponder()
        searchBlock()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty == true && string.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
            return false
        }
        if let maxCount = maxCount {
            //设置了限制长度 名字最多6位 可以改
            let textcount = textField.text?.count ?? 0
            if string.count + textcount - range.length > maxCount {
                return false
            }
        }
        return true
    }
    
}
