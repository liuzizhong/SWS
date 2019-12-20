//
//  SW_RegisterStepThreeViewController.swift
//  SWS
//
//  Created by jayway on 2018/5/4.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_RegisterStepThreeViewController: UIViewController {
    @IBOutlet weak var pwdField: UITextField!
    
    @IBOutlet weak var againPwdField: UITextField!
    
    @IBOutlet weak var sureBtn: SW_BlueButton!
    
    var name = ""
    var phone = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    @IBAction func fieldChange(_ sender: UITextField) {
        sureBtn.isEnabled = pwdField.text?.isEmpty == false && againPwdField.text?.isEmpty == false
    }

    
    @IBAction func sureBtnAction(_ sender: SW_BlueButton) {
        guard let pwd = pwdField.text else {
            showAlertMessage(InternationStr("请输入密码"), view)
            return
        }
        if !IsPassword(pwd) {
            showAlertMessage(InternationStr("密码格式错误"), view)
            return
        }
        
        guard let againPwd = againPwdField.text else {
            showAlertMessage(InternationStr("请确认密码"), view)
            return
        }
        if againPwd != pwd {
            showAlertMessage(InternationStr("两次密码输入不一致"), view)
            return
        }
        
        SWSLoginService.registerAccount(phone, realName: name, password: pwd.passwordCoder()).response { (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                //验证手机成功  进行修改手机号
                showAlertMessage(InternationStr("注册成功"), self.view)
//                self.navigationController?.popToRootViewController(animated: true)
                if let dict = json.dictionaryObject {
                    InsertMessageToPerform(self.phone, USERNAMEKEY)
                    SW_UserCenter.loginSucceedLater(dict)
                }
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", self.view)
            }
        }
        
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    deinit {
        PrintLog("deinit -------")
    }
    
}


