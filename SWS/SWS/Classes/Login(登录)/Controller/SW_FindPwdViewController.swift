//
//  SW_FindPwdViewController.swift
//  SWS
//
//  Created by jayway on 2018/12/7.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_FindPwdViewController: UIViewController {
    
    @IBOutlet weak var phoneRegionLb: UILabel!
    
    @IBOutlet weak var phoneField: UITextField!
    
    @IBOutlet weak var getCodeBtn: UIButton!
    
    @IBOutlet weak var nextBtn: SW_BlueButton!
    
    @IBOutlet weak var codeView: LQ_PasswordView!
    
    private var lastValidateToken: String = ""
    /// 输入的验证码
    private var code = ""
    /// 初始的账号
    var phone = ""
    
    private var isRequesting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    //MARK: - setup
    private func setupView() {
        view.layoutIfNeeded()
        
        phoneRegionLb.layer.cornerRadius = 2
        phoneRegionLb.layer.masksToBounds = true
        
        phoneField.text = phone
        phoneField.setPlaceholderColor(UIColor.white.withAlphaComponent(0.5))
        phoneField.addTarget(self, action: #selector(editChangeAction(_:)), for: .editingChanged)
        phoneField.becomeFirstResponder()
        
        getCodeBtn.isEnabled = phone.count == 11
        getCodeBtn.setBackgroundImage(UIImage.image(solidColor: UIColor.white, size: CGSize(width: 1, height: 1)), for: UIControl.State())
        getCodeBtn.setBackgroundImage(UIImage.image(solidColor: UIColor.white.withAlphaComponent(0.9), size: CGSize(width: 1, height: 1)), for: .highlighted)
        getCodeBtn.setBackgroundImage(UIImage.image(solidColor: UIColor.white.withAlphaComponent(0.9), size: CGSize(width: 1, height: 1)), for: .disabled)
        getCodeBtn.layer.cornerRadius = 3
        getCodeBtn.layer.masksToBounds = true
        
        codeView.num = 6
        codeView.lineHeight = 2
        codeView.lineViewColor = UIColor.white.withAlphaComponent(0.5)
        codeView.selectlineViewColor = UIColor.white
        codeView.lineColor = UIColor.white
        codeView.labelFont = Font(16)
        codeView.textLabelColor = UIColor.white
        codeView.callBackBlock = { [weak self] (text) in
            guard let self = self else { return }
            self.code = text ?? ""
            if text?.count == 6 {
                self.nextBtn.isEnabled = true
                self.codeView.textField.resignFirstResponder()
            } else {
                self.nextBtn.isEnabled = false
            }
        }
        
        codeView.showPassword()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func backBtnClick(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func getCodeBtnClick(_ sender: UIButton) {
        //判断网络情况
        if netManager?.isReachable == false {
            showAlertMessage("网络异常", MYWINDOW)
            return
        }
        
        guard let phone = phoneField.text, !phone.isEmpty else {
            showAlertMessage("手机号码不能为空", MYWINDOW)
            return
        }
        
        if !isPhoneNumber(phone) {   //判断是否是手机号码
            showAlertMessage("请输入正确的手机号码", MYWINDOW)
            return
        }
        getCodeBtn.setTitle("\(second)秒", for: .disabled)
        getCodeBtn.isEnabled = false
        timer = Timer.scheduledTimer(withTimeInterval: 1, block: { [weak self] (timer) in
            guard let sSelf = self else {
                return
            }
            sSelf.second -= 1
            sSelf.getCodeBtn.setTitle("\(sSelf.second)秒", for: .disabled)
            if sSelf.second == 0 {
                sSelf.reSetTimer()
            }
            }, repeats: true)
        //请求接口
        getVerificationCode()
    }
    
    @IBAction func nextBtnClick(_ sender: UIButton) {
        if lastValidateToken.isEmpty {
            showAlertMessage("请先获取验证码", MYWINDOW)
            return
        }
        guard !isRequesting else { return }
        guard let phone = phoneField.text, !phone.isEmpty else {
            showAlertMessage("请输入手机号码", MYWINDOW)
            return
        }
        if !isPhoneNumber(phone) {   //判断是否是手机号码
            showAlertMessage("请输入正确的手机号码", MYWINDOW)
            return
        }
        //其次，判断验证码
        guard !code.isEmpty else {
            showAlertMessage("请输入验证码", MYWINDOW)
            return
        }
        isRequesting = true
        QMUITips.showLoading("正在验证", in: self.view)
        SWSLoginService.checkValidate(phone, code: code, type: 0, validateToken: lastValidateToken).response { (json, isCache, error) in
            self.isRequesting = false
            QMUITips.hideAllTips(in: self.view)
            if error == nil {
                //提示成功
//                验证成功 进入修改密码界面
                self.navigationController?.pushViewController(SW_ChangePwdViewController.creat(phone, type: .loginPhone), animated: true)
            } else {
                /// 2 验证码错误
                if error?.code == 2 || error?.code == 1 {
                    self.codeView.cleanPassword("")
                    self.codeView.textField.becomeFirstResponder()
                }
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        }
        
    }
    
    @objc private func editChangeAction(_ textField: UITextField) {
        getCodeBtn.isEnabled = textField.text?.count == 11
    }
    
    @IBAction func bgviewClick(_ sender: UIControl) {
        view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    /// 调用接口获取验证码
    func getVerificationCode() {
        if netManager?.isReachable == false {
            showAlertMessage("网络异常", MYWINDOW)
            self.reSetTimer()
            return
        }
        guard let phone = phoneField.text, !phone.isEmpty else {
            return
        }
        
        SWSLoginService.sendValidate(phone, type: 0).response { (json, isCache, error) in
            //            print("\(json)---\(isCache)----\(error)")
            if let json = json as? JSON, error == nil {
                //提示成功
                self.lastValidateToken = json["validateToken"].stringValue
                showAlertMessage("验证码已发送！", MYWINDOW)
                self.codeView.textField.becomeFirstResponder()
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                self.reSetTimer()
            }
        }
    }
    
    private var timer: Timer?
    private var second: Int = 120
    
    func reSetTimer() {
        guard getCodeBtn.isEnabled == false else { return }
        dispatch_async_main_safe {
            self.getCodeBtn.isEnabled = true
            self.getCodeBtn.setTitle("获取验证码", for: .normal)
            self.getCodeBtn.setTitle("获取验证码", for: .disabled)
            self.second = 120
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    deinit {
        self.timer?.invalidate()
        self.timer = nil
        print(#file + "deinit")
    }
    
}


extension SW_FindPwdViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textcount = textField.text?.count ?? 0
        
        if textcount > string.count + textcount - range.length {
            return true
        }
        if string.count + textcount - range.length > 11 {
            return false
        }
        return true
    }
}
