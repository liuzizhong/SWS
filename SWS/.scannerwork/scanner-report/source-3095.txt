//
//  SW_RegisterStepOneViewController.swift
//  SWS
//
//  Created by jayway on 2018/5/3.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit


class SW_RegisterStepOneViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var phoneField: UITextField!
    
    @IBOutlet weak var nextButton: SW_BlueButton!
    
    private var timer: Timer?
    private var second: Int = 120
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if second != 120 && timer == nil {//不等于120代表不能进行下一步  如果有开启定时器则不需要再开启
            //            开启定时器
            nextButton?.isEnabled = false
            timer = Timer.scheduledTimer(withTimeInterval: 1, block: { [weak self] (timer) in
                guard let sSelf = self else {
                    return
                }
                sSelf.second -= 1
                sSelf.nextButton?.setTitle("\(sSelf.second)秒", for: .disabled)
                if sSelf.second == 0 {
                    sSelf.reSetTimer()
                }
                }, repeats: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
//        timer?.invalidate()
//        timer = nil
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
        nextButton.isEnabled = nameField.text?.isEmpty == false && phoneField.text?.isEmpty == false && second == 120
    }
    
    @IBAction func nextBtnAction(_ sender: SW_BlueButton) {
        guard let name = nameField.text else { return }
        guard let phone = phoneField.text else { return }

        guard  isPhoneNumber(phone) else {
            showAlertMessage("请输入正确的手机号", view)
            return
        }
        SWSLoginService.sendValidate(phone, type: 2).response { (json, isCache, error) in
            if  error == nil {
//                showAlertMessage("验证码已发送！", self.view)
                if let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "SW_RegisterStepTwoViewController") as? SW_RegisterStepTwoViewController {
                    vc.name = name
                    vc.phone = phone
                    vc.delegate = self
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", self.view)
//                self.reSetTimer()
            }
        }
    }
    
    @IBAction func protrolBtnAction(_ sender: UIButton) {
//        if let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "SW_ProtocolViewController") as?  {
            self.navigationController?.pushViewController(SW_ProtocolViewController(), animated: true)
//        }
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func reSetTimer() {
        guard nextButton?.isEnabled == false else { return }
        dispatch_async_main_safe {
            self.nextButton?.isEnabled = true
            self.nextButton?.setTitle("下一步", for: .normal)
            self.nextButton?.setTitle("120秒", for: .disabled)
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

extension SW_RegisterStepOneViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneField {
            let textcount = textField.text?.count ?? 0
            if string.count + textcount - range.length > 11 {
                return false
            }
            return true
        }
        return true
    }
}

extension SW_RegisterStepOneViewController: SW_RegisterStepTwoViewControllerDelegate {
    func SW_RegisterStepTwoViewControllerTimerSecondChange(_ second: Int) {
        nextButton.setTitle("\(second)秒", for: .disabled)
        self.second = second
    }
    
}
