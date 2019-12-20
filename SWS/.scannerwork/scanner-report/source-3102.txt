//
//  SW_ChangeAccountViewController.swift
//  SWS
//
//  Created by jayway on 2018/12/18.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_ChangeAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var phoneRegionLb: UILabel!
    @IBOutlet weak var accountField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var forgetPwdBtn: UIButton!
    @IBOutlet weak var showPwdBtn: UIButton!
    @IBOutlet weak var contentViewTopConstraint: NSLayoutConstraint!
    
    private var phone: String?
    
    private var isRequesting = false
    
    private var keyboardManager: QMUIKeyboardManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        keyboardManager = QMUIKeyboardManager(delegate: self)
        keyboardManager.addTargetResponder(accountField)
        keyboardManager.addTargetResponder(pwdField)
        accountField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
    deinit {
        print(#file + "deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    //MARK: - private methon
    private func setupView() {
        phoneRegionLb.layer.cornerRadius = 2
        phoneRegionLb.layer.masksToBounds = true
        
        accountField.setPlaceholderColor(UIColor.white.withAlphaComponent(0.5))
        accountField.addTarget(self, action: #selector(editChangeAction(_:)), for: .editingChanged)
        pwdField.setPlaceholderColor(UIColor.white.withAlphaComponent(0.5))
        pwdField.addTarget(self, action: #selector(editChangeAction(_:)), for: .editingChanged)
        
        forgetPwdBtn.layer.borderColor = UIColor.white.cgColor
        forgetPwdBtn.layer.borderWidth = 0.5
        forgetPwdBtn.layer.cornerRadius = forgetPwdBtn.height/2
        
    }
    
    func checkLoginBtnState() {
        loginBtn.isEnabled = (phone?.isEmpty == false) && (pwdField.text?.isEmpty == false)
    }
    
    //MARK: -登录
    func login() -> Void {
        guard !isRequesting else { return }
        //首先，检查手机号码是否符合规则
        guard let phone = phone, !phone.isEmpty else {
            showAlertMessage("手机号码不能为空", view)
            return
        }
        //        if !isPhoneNumber(phone) {   //如果电话号码内容不符合规则
        //            showAlertMessage("请输入正确的手机号码", view)
        //            return;
        //        }
        
        //判断密码是否符合规则
        guard let password = pwdField.text, !password.isEmpty else {
            showAlertMessage("请输入密码", view)
            return
        }
        
        QMUITips.showLoading("正在登录", in: self.view)
        isRequesting = true
        SWSLoginService.login(phone, password: password).response { (json, isCache, error) in
            self.isRequesting = false
            if let json = json as? JSON, error == nil {//成功登陆
                if let dict = json.dictionaryObject {
                    InsertMessageToPerform(phone, USERNAMEKEY)
                    SW_UserCenter.loginSucceedLater(dict)
                }
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", self.view)
            }
            QMUITips.hideAllTips(in: self.view)
        }
    }
    
    @objc private func editChangeAction(_ textField: UITextField) {
        if textField == accountField {
            phone = textField.text
        }
        checkLoginBtnState()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - action
    @IBAction func bgViewClick(_ sender: UIControl) {
        view.endEditing(true)
    }
    
    @IBAction func backBtnClick(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func loginBtnClick(_ sender: UIButton) {
        view.endEditing(true) //退出键盘
        login()
    }
    
    @IBAction func forgetPwdBtnClick(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "SW_FindPwdViewController") as! SW_FindPwdViewController
        vc.phone = phone ?? ""
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func showPwdBtnClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        pwdField.isSecureTextEntry = !sender.isSelected
        if pwdField.isFirstResponder {
            let oldText = pwdField.text
            pwdField.text = ""
            pwdField.text = oldText
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == accountField {
            pwdField.becomeFirstResponder()
        } else {
            login()
        }
        return true
    }
    
}

extension SW_ChangeAccountViewController: QMUIKeyboardManagerDelegate {
    
    func keyboardWillChangeFrame(with keyboardUserInfo: QMUIKeyboardUserInfo!) {
        if keyboardUserInfo.endFrame.origin.y < SCREEN_HEIGHT {
            let loginFrameMaxY = loginBtn.superview!.convert(loginBtn.frame, to: nil).maxY
            if keyboardUserInfo.endFrame.origin.y - loginFrameMaxY - 20 < 0 {
                contentViewTopConstraint.constant = keyboardUserInfo.endFrame.origin.y - loginFrameMaxY - 20
            } else {
                contentViewTopConstraint.constant = 0
            }
        } else {
            contentViewTopConstraint.constant = 0
        }
        
        UIView.animate(withDuration: keyboardUserInfo.animationDuration) {
            self.view.layoutIfNeeded()
        }
        
    }
    
}
