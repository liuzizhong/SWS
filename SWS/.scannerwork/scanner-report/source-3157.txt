//
//  SW_SettingChangePhoneTwoViewController.swift
//  SWS
//
//  Created by jayway on 2018/4/13.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_SettingChangePhoneTwoViewController: UIViewController {

    @IBOutlet weak var phoneField: UITextField!
    
    @IBOutlet weak var nextBtn: SW_BlueButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        phoneField.becomeFirstResponder()
        nextBtn.isEnabled = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func fieldChange(_ sender: UITextField) {
//        nextBtn.isEnabled = sender.text?.isEmpty == false
        if let text = sender.text, text.count >= 11 {
            nextBtn.isEnabled = true
        } else {
            nextBtn.isEnabled = false
        }
    }
    
    @IBAction func nextBtnAction(_ sender: UIButton) {
        
        guard let text = phoneField.text else { return }
        
        guard  isPhoneNumber(text) else {
            showAlertMessage("请输入正确的手机号", view)
            return
        }
        
        guard text != SW_UserCenter.shared.user!.phoneNum1 else {
            showAlertMessage("新手机号与原手机号一致", view)
            return
        }
        
        alertControllerShow(title: "确认手机号", message: InternationStr("我们将发送验证码短信到这个号码：\n \(text)"), rightTitle: "确 定", rightBlock: { (_, _) in
            
            SWSLoginService.sendValidate(text, type: 1).response { (json, isCache, error) in
                if  error == nil {
                    if let vc = UIStoryboard(name: "Mine", bundle: nil).instantiateViewController(withIdentifier: "SW_SettingChangePhoneThreeViewController") as? SW_SettingChangePhoneThreeViewController {
                        vc.newPhone = text
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                }
            }
        }, leftTitle: "取 消", leftBlock: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    deinit {
        PrintLog("deinit")
    }
}

extension SW_SettingChangePhoneTwoViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textcount = textField.text?.count ?? 0
        if string.count + textcount - range.length > 11 {
            return false
        }
        return true
    }
    
    
}
