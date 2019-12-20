//
//  SW_RegisterStepTwoViewController.swift
//  SWS
//
//  Created by jayway on 2018/5/4.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

protocol SW_RegisterStepTwoViewControllerDelegate: NSObjectProtocol {
     func SW_RegisterStepTwoViewControllerTimerSecondChange(_ second: Int)
}

class SW_RegisterStepTwoViewController: UIViewController {

    @IBOutlet weak var phoneTipLb: UILabel!
    @IBOutlet weak var nextBtn: SW_BlueButton!
    @IBOutlet weak var codeField: UITextField!
    @IBOutlet weak var getCodeBtn: UIButton!
    
    var name = ""
    var phone = ""
    weak var delegate: SW_RegisterStepTwoViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phoneTipLb.text = InternationStr("验证码已发送至手机：\(phone)")
        showAlertMessage("验证码已发送！", self.view)
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
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func fieldChange(_ sender: UITextField) {
        if let text = sender.text, text.count >= 6 {
            nextBtn.isEnabled = true
        } else {
            nextBtn.isEnabled = false
        }
    }

    @IBAction func nextBtnAction(_ sender: SW_BlueButton) {
        if netManager?.isReachable == false {
            showAlertMessage("网络异常", self.view)
            return
        }
        
        guard let code = codeField.text else { return }
        
        SWSLoginService.checkValidate(phone, code: code, type: 2).response { (json, isCache, error) in
            if error == nil {
                //验证手机成功  进行修改手机号
                self.reSetTimer()
                if let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "SW_RegisterStepThreeViewController") as? SW_RegisterStepThreeViewController {
                    vc.name = self.name
                    vc.phone = self.phone
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", self.view)
            }
        }
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
        
        SWSLoginService.sendValidate(phone, type: 2).response { (json, isCache, error) in
            if  error == nil {
                showAlertMessage("验证码已发送！", self.view)
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", self.view)
                self.reSetTimer()
            }
            
        }
        
    }
    private var timer: Timer?
    private var second: Int = 120 {
        didSet {
            delegate?.SW_RegisterStepTwoViewControllerTimerSecondChange(second)
        }
    }
    
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

extension SW_RegisterStepTwoViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
            let textcount = textField.text?.count ?? 0
            if string.count + textcount - range.length > 6 {
                return false
            }
            return true
       
    }
}
