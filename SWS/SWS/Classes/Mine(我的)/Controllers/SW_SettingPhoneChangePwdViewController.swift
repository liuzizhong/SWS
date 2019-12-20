//
//  SW_SettingPhoneChangePwdViewController.swift
//  SWS
//
//  Created by jayway on 2018/4/13.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_SettingPhoneChangePwdViewController: UIViewController {
    
    private var phone = SW_UserCenter.shared.user?.phoneNum1 ?? ""
    
    @IBOutlet weak var phoneLb: UILabel!
    
    @IBOutlet weak var getCodeBtn: SW_BlueButton!
    
    @IBOutlet weak var nextBtn: SW_BlueButton!
    
    @IBOutlet weak var codeView: LQ_PasswordView!
    
    private var lastValidateToken: String = ""
    /// 输入的验证码
    private var code = ""
    
    private var isRequesting = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()   //创建子控件
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupView() {
        view.layoutIfNeeded()
        phoneLb.text = phone
        nextBtn.isEnabled = false
        codeView.num = 6
        codeView.lineHeight = 1
        codeView.lineViewColor = UIColor.v2Color.lightGray
        codeView.selectlineViewColor = UIColor.v2Color.lightBlack
        codeView.lineColor = UIColor.v2Color.lightBlack
        codeView.labelFont = Font(16)
        codeView.textLabelColor = UIColor.v2Color.lightBlack
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
    
    
    @IBAction func backBtnClick(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func getCodeBtnClick(_ sender: UIButton) {
        //判断网络情况
        if netManager?.isReachable == false {
            showAlertMessage("网络异常", MYWINDOW)
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
        //其次，判断验证码
        guard !code.isEmpty else {
            showAlertMessage("请输入验证码", MYWINDOW)
            return
        }
        QMUITips.showLoading("正在验证", in: self.view)
        isRequesting = true
        SWSLoginService.checkValidate(phone, code: code, type: 0, validateToken: lastValidateToken).response { (json, isCache, error) in
            self.isRequesting = false
            QMUITips.hideAllTips(in: self.view)
            if error == nil {
                //提示成功
                //                验证成功 进入修改密码界面
                self.navigationController?.pushViewController(SW_ChangePwdViewController.creat(self.phone, type: .settingPhone), animated: true)
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
    
    @IBAction func bgViewClick(_ sender: UIView) {
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
        
        SWSLoginService.sendValidate(phone, type: 0).response { (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                //提示成功
                self.codeView.textField.becomeFirstResponder()
                self.lastValidateToken = json["validateToken"].stringValue
                showAlertMessage("验证码已发送！", MYWINDOW)
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
