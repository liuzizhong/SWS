//
//  SW_NewSearchBar.swift
//  SWS
//
//  Created by jayway on 2018/11/1.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_NewSearchBar: UIView {
    
    @IBOutlet weak var searchBgView: UIButton!
    
    @IBOutlet weak var addBtn: UIButton!
    
    @IBOutlet weak var secBtn: QMUIButton!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var placeholderLb: UILabel!
    
    var placeholderString: String? {
        didSet {
            textField.placeholder = placeholderString
            placeholderLb.text = placeholderString
        }
    }
    
    /// 是否可以直接搜索
    var isCanBecomeFirstResponder: Bool = true
    
    /// 约束 动画改变
    @IBOutlet weak var textFieldLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var textFieldRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var searchBgRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addBtnWidthConstraint: NSLayoutConstraint!
    var addBtnWidth: CGFloat = 80 {
        didSet {
            addBtnWidthConstraint.constant = addBtnWidth
            textFieldRightConstraint.constant = addBtnWidth
        }
    }
    /// action block
    var addActionBlock: NormalBlock?
    
    var backActionBlock: NormalBlock?
    
    var becomeFirstBlock: NormalBlock?
    
    var cancelActionBlock: NormalBlock?
    
    var searchBlock: NormalBlock?
    
    var textChangeBlock: NormalBlock?
    
    var secActionBlock: NormalBlock?
    
    var searchText: String {
        get {
            return textField.text ?? ""
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        searchBgView.addShadow()
        layer.shadowOpacity = 0
        searchBgView.layer.cornerRadius = 3
        
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    //MARK: - 按钮点击事件
    @IBAction func searchBgClick(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        if isCanBecomeFirstResponder {
            myBecomeFirstResponder()
        }
        becomeFirstBlock?()
    }
    
    @IBAction func cancelBtnClick(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        myResignFirstResponder()
        cancelActionBlock?()
    }
    
    @IBAction func addBtnClick(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        addActionBlock?()
    }
    
    @IBAction func secBtnClick(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        secActionBlock?()
    }
    
    @IBAction func backBtnClick(_ sender: UIButton) {
        if #available(iOS 10.0, *) {
            feedbackGenerator()
        }
        backActionBlock?()
    }
    
    //MARK: - 内部动画、逻辑
    func myBecomeFirstResponder() {
        textField.isUserInteractionEnabled = true
        textField.becomeFirstResponder()
        textFieldLeftConstraint.constant = 15
        textFieldRightConstraint.constant = 10
        searchBgRightConstraint.constant = 50
//        showShadow()
        
        UIView.animate(withDuration: 0.4, animations: {
            self.layoutIfNeeded()
            self.cancelBtn.alpha = 1
            self.addBtn.alpha = 0
            self.secBtn.alpha = 0
            self.backBtn.alpha = 0
            self.placeholderLb.alpha = 0
        }) { (finish) in
            self.placeholderLb.alpha = 0
        }
        
    }
    
    func myResignFirstResponder() {
        textField.resignFirstResponder()
        textField.text = ""
        textField.isUserInteractionEnabled = false
        textFieldLeftConstraint.constant = 50
        textFieldRightConstraint.constant = addBtnWidth
        searchBgRightConstraint.constant = 15
//        hideShadow()
        
        UIView.animate(withDuration: 0.4, animations: {
            self.layoutIfNeeded()
            self.cancelBtn.alpha = 0
            self.addBtn.alpha = 1
           self.secBtn.alpha = 1
            self.backBtn.alpha = 1
            self.placeholderLb.alpha = 1
        }) { (finish) in
            self.placeholderLb.alpha = 1
        }
    }
    
    
    func showOrHideSubView(show: Bool, duration: TimeInterval = TabbarAnimationDuration) {
        let alpha: CGFloat = show ? 1 : 0
        
        UIView.animate(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {
            self.searchBgView.alpha = alpha
            self.addBtn.alpha = alpha
            self.secBtn.alpha = alpha
            self.backBtn.alpha = alpha
            self.textField.alpha = alpha
            self.placeholderLb.alpha = alpha
        }, completion: nil)
    }
    
    func showOrHideShadow(show: Bool) {
        let alpha: Float = show ? 1 : 0
        if layer.shadowOpacity != alpha {
            UIView.animate {
                self.layer.shadowOpacity = alpha
            }
        }
    }
//
//    func hideShadow() {
//        if layer.shadowOpacity != 0 {
//            UIView.animate {
//                self.layer.shadowOpacity = 0
//            }
//        }
//    }
    
    func setUpAddBtn(_ title: String, image: UIImage?, action: @escaping NormalBlock) {
        addBtn.isHidden = false
        addBtn.setTitle(title, for: UIControl.State())
        addBtn.setImage(image, for: UIControl.State())
        addActionBlock = action
    }
    
    func setUpSecBtn(_ title: String, image: UIImage?, action: @escaping NormalBlock) {
        secBtn.isHidden = false
        secBtn.setTitle(title, for: UIControl.State())
        secBtn.setImage(image, for: UIControl.State())
        secActionBlock = action
    }
    
    @IBAction func textfieldEditingChanged(_ sender: UITextField) {
        textChangeBlock?()
    }
}

extension SW_NewSearchBar: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let searchBlock = searchBlock else { return  true }
        textField.resignFirstResponder()
        if textField.text?.isEmpty == false {
            searchBlock()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty == true && string.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
            return false
        }
        return true
    }
    
}
