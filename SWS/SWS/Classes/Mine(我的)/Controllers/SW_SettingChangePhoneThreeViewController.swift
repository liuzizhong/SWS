//
//  SW_SettingChangePhoneThreeViewController.swift
//  SWS
//
//  Created by jayway on 2018/4/13.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_SettingChangePhoneThreeViewController: UIViewController {

    @IBOutlet weak var tipLb: UILabel!
    
    @IBOutlet weak var getCodeBtn: UIButton!
    var newPhone = ""
    private var isRequesting = false
    
    @IBOutlet weak var codeView: LQ_PasswordView!
    /// 输入的验证码
    private var code = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
       
        // Do any additional setup after loading the view.
    }

    
    private func setupView() {
        tipLb.text = "验证码已发送至手机：\(newPhone)"
//        verifyBtnClick(getCodeBtn)
        view.layoutIfNeeded()
        
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
                self.changePhoneAction()
                self.codeView.textField.resignFirstResponder()
            } else {
                
            }
        }
        codeView.showPassword()
        
        getCodeBtn?.isEnabled = false
        timer = Timer.scheduledTimer(withTimeInterval: 1, block: { [weak self] (timer) in
            guard let sSelf = self else {
                return
            }
            sSelf.second -= 1
            sSelf.getCodeBtn?.setTitle("\(sSelf.second)秒", for: .disabled)
            if sSelf.second == 0 {
                sSelf.reSetTimer()
            }
            }, repeats: true)
        showAlertMessage("验证码已发送！", self.view)
        self.codeView.textField.becomeFirstResponder()
    }
    
   
    
    
    func changePhoneAction() {
        guard !isRequesting else { return }
        if netManager?.isReachable == false {
            showAlertMessage("网络异常", self.view)
            return
        }
        isRequesting = true
        QMUITips.showLoading("正在修改", in: self.view)
        SWSLoginService.checkValidate(newPhone, code: code, type: 1).response { (json, isCache, error) in
            self.isRequesting = false
            QMUITips.hideAllTips(in: self.view)
            if error == nil {
                //验证手机成功  进行修改手机号
                SWSLoginService.setMobile(SW_UserCenter.shared.user?.id ?? 0, newPhoneNum: self.newPhone).response({ (json, isCache, error) in
                    if error == nil {
                        let alert = UIAlertController.init(title: InternationStr("完成"), message: InternationStr("登陆手机号修改成功"), preferredStyle: .alert)
                        let sure = UIAlertAction(title: "确定", style: .default, handler: { [weak self] action in
                            if let index = self?.navigationController?.viewControllers.index(where: { return $0 is SW_SettingAccountViewController }),
                                let vc = self?.navigationController?.viewControllers[index] as? SW_SettingAccountViewController {
                                SW_UserCenter.shared.user?.phoneNum1 = self?.newPhone ?? ""
                                InsertMessageToPerform(self?.newPhone ?? "", USERNAMEKEY)
                                SW_UserCenter.shared.user?.updateUserDataToCache()
                                //修改手机号后需通知 刷新数据
                                NotificationCenter.default.post(name: NSNotification.Name.Ex.UserPhoneNum1HadChange, object: nil)
                                self?.navigationController?.popToViewController(vc, animated: true)
                            }
                            
                        })
                        alert.addAction(sure)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", self.view)
                    }
                })
            } else {
                /// 2 验证码错误
                if error?.code == 2 || error?.code == 1 {
                    self.codeView.cleanPassword("")
                    self.codeView.textField.becomeFirstResponder()
                }
                showAlertMessage(error?.localizedDescription ?? "网络异常", self.view)
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

    @IBAction  func verifyBtnClick(_ sender: UIButton) {
        //判断网络情况
        if netManager?.isReachable == false {
            showAlertMessage("网络异常", self.view)
            return
        }
        
        getCodeBtn?.isEnabled = false
        timer = Timer.scheduledTimer(withTimeInterval: 1, block: { [weak self] (timer) in
            guard let sSelf = self else {
                return
            }
            sSelf.second -= 1
            sSelf.getCodeBtn?.setTitle("\(sSelf.second)秒", for: .disabled)
            if sSelf.second == 0 {
                sSelf.reSetTimer()
            }
            }, repeats: true)
        //请求接口
        getVerificationCode()
    }
    
    /// 调用接口获取验证码
    func getVerificationCode() {
        if netManager?.isReachable == false {
            showAlertMessage("网络异常", self.view)
            self.reSetTimer()
            return
        }
        
        SWSLoginService.sendValidate(newPhone, type: 1).response { (json, isCache, error) in
            if  error == nil {
                showAlertMessage("验证码已发送！", self.view)
                self.codeView.textField.becomeFirstResponder()
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", self.view)
                self.reSetTimer()
            }
        }
        
    }
    private var timer: Timer?
    private var second: Int = 120
    
    func reSetTimer() {
        guard getCodeBtn?.isEnabled == false else { return }
        dispatch_async_main_safe {
            self.getCodeBtn?.isEnabled = true
            self.getCodeBtn?.setTitle("重新获取验证码", for: .normal)
            self.getCodeBtn?.setTitle("120秒", for: .disabled)
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


