//
//  SW_ChangePwdViewController.swift
//  SWS
//
//  Created by jayway on 2018/12/8.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit


enum ChangePwdType {
    case first                 //第一次登录修改密码
    case loginPhone            //登录界面忘记密码
    case settingPhone          //设置界面修改密码
}

class SW_ChangePwdViewController: UIViewController {
    
    @IBOutlet weak var bgImageView: UIImageView!
    
    @IBOutlet var labels: [UILabel]!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var sureBtn: SW_BlueButton!
    
    @IBOutlet weak var pwdField: UITextField!
    
    @IBOutlet weak var surePwdField: UITextField!
    
    @IBOutlet weak var showPwdBtn: UIButton!
    
    @IBOutlet weak var pwdTipLb: UILabel!
    
    @IBOutlet weak var showSurePwdBtn: UIButton!
    
    var newPassword: String = ""    //新密码
    var againNewPwd: String = ""    //重复新密码
    var type = ChangePwdType.loginPhone
    var phone = ""
    var staffId = -1
    private var isRequesting = false
    
    
    class func creat(_ phone: String = "", staffId: Int = -1, type: ChangePwdType) -> SW_ChangePwdViewController {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "SW_ChangePwdViewController") as! SW_ChangePwdViewController
        vc.phone = phone
        vc.staffId = staffId
        vc.type = type
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setupView() {
        checkSureBtnState()
        
        pwdField.addTarget(self, action: #selector(editChangeAction(_:)), for: .editingChanged)
        surePwdField.addTarget(self, action: #selector(editChangeAction(_:)), for: .editingChanged)
        pwdField.becomeFirstResponder()
        if type == .loginPhone || type == .first {
            pwdField.setPlaceholderColor(UIColor.white.withAlphaComponent(0.5))
            pwdField.tintColor = UIColor.white
            surePwdField.setPlaceholderColor(UIColor.white.withAlphaComponent(0.5))
            pwdTipLb.textColor = .white
            surePwdField.tintColor = UIColor.white
            backBtn.isHidden = type == .first
            sureBtn.setTitleColor(UIColor.v2Color.blue, for: UIControl.State())
            sureBtn.setBackgroundImage(UIImage.image(solidColor: UIColor.white, size: CGSize(width: 1, height: 1)), for: UIControl.State())
            sureBtn.setBackgroundImage(UIImage.image(solidColor: UIColor.white.withAlphaComponent(0.9), size: CGSize(width: 1, height: 1)), for: .highlighted)
            sureBtn.setBackgroundImage(UIImage.image(solidColor: UIColor.white.withAlphaComponent(0.9), size: CGSize(width: 1, height: 1)), for: .disabled)
        } else {
            pwdField.textColor = UIColor.v2Color.lightBlack
            surePwdField.textColor = UIColor.v2Color.lightBlack
            pwdTipLb.textColor = UIColor.v2Color.darkGray
            bgImageView.isHidden = true
            backBtn.setImage(UIImage(named: "nav_back"), for: UIControl.State())
            
            labels.forEach({ $0.textColor = UIColor.v2Color.lightBlack })
            showPwdBtn.setTitleColor(UIColor.v2Color.lightBlack, for: UIControl.State())
//            showSurePwdBtn.setTitleColor(UIColor.v2Color.lightBlack, for: UIControl.State())
        }
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    func checkSureBtnState() {
        
        sureBtn.isEnabled = (newPassword.isEmpty == false) && (againNewPwd.isEmpty == false)
    }
    
    //MARK: -修改密码
    
    @IBAction func showPwdBtnClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        pwdField.isSecureTextEntry = !sender.isSelected
        if pwdField.isFirstResponder {
            let oldText = pwdField.text
            pwdField.text = ""
            pwdField.text = oldText
        }
        surePwdField.isSecureTextEntry = !sender.isSelected
        if surePwdField.isFirstResponder {
            let oldText = surePwdField.text
            surePwdField.text = ""
            surePwdField.text = oldText
        }
    }
    
    @IBAction func showSurePwdBtnClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        surePwdField.isSecureTextEntry = !sender.isSelected
        if surePwdField.isFirstResponder {
            let oldText = surePwdField.text
            surePwdField.text = ""
            surePwdField.text = oldText
        }
    }
    
    @IBAction func popBtnClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sureAction(_ sender: SW_BlueButton) {
        guard !isRequesting else { return }
        //1.首先判断新密码是否符合规则
        guard  !newPassword.isEmpty else {
            showAlertMessage(InternationStr("请输入新密码"), MYWINDOW)
            return
        }
        if !IsPassword(newPassword) {
            showAlertMessage(InternationStr("密码格式错误"), MYWINDOW)
            return
        }
        
        guard !againNewPwd.isEmpty else {
            showAlertMessage(InternationStr("请确认新密码"), MYWINDOW)
            return
        }
        if againNewPwd != newPassword {
            showAlertMessage(InternationStr("两次密码输入不一致"), MYWINDOW)
            return
        }
        isRequesting = true
        QMUITips.showLoading("正在修改", in: self.view)
        switch type {
        case .first:
            SWSLoginService.setPassWordByFirst(staffId, newPwd: newPassword).response({ (json, isCache, error) in
                self.isRequesting = false
                QMUITips.hideAllTips(in: self.view)
                if error == nil {
                    //提示成功
                    showAlertMessage("密码修改成功", MYWINDOW)
                    dispatch_delay(1, block: {//第一次修改成功进入首页
                        //                         isFirstLogin  会缓存  会导致每次重启都使用了这个缓存值进入修改页面。   成功修改密码后需要将这个dict的值变为1
                        SW_UserCenter.shared.user?.isFirstLogin = false
                        SW_UserCenter.shared.user?.updateUserDataToCache()
                        MYWINDOW?.change(rootViewController: SW_TabBarController())
                    })
                    
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                }
            })
        case .loginPhone,.settingPhone:
            SWSLoginService.setPassWordByPhone(phone, newPwd: newPassword).response({ (json, isCache, error) in
                self.isRequesting = false
                QMUITips.hideAllTips(in: self.view)
                if error == nil {
                    //提示成功
                    showAlertMessage("密码修改成功", MYWINDOW)
                    InsertMessageToPerform(self.phone, USERNAMEKEY)
                    
                    if self.type == .loginPhone {
                        //登录页修改成功 后自动调用登陆获取用户信息  延迟2s进行提示
                        dispatch_delay(2, block: {
                            SWSLoginService.login(self.phone, password: self.newPassword).response { (json, isCache, error) in
                                if let json = json as? JSON, error == nil {//成功登陆
                                    if let dict = json.dictionaryObject {
                                        SW_UserCenter.loginSucceedLater(dict, isShowTip: false)
                                    }
                                } else {
                                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                                }
                            }
                        })
                    } else {
                        //设置界面修改密码后进入退出到登录页面
                        dispatch_delay(2, block: {
                            SWSLoginService.delLoginToken(SW_UserCenter.shared.user?.token ?? "").response { (json, isCache, error) in
//                                if error == nil {//退出登录成功
//                                } else {//  退出登录失败
//                                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
//                                }
                            }
                            SW_UserCenter.logout({
                                showAlertMessage("修改密码成功，请重新登录", MYWINDOW)
                            })
                        })
                    }
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                }
            })
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if type == .settingPhone {
            if #available(iOS 13.0, *) {
                return .darkContent
            } else {
                return .default
            }
        }
        return .lightContent
    }
    
    @objc private func editChangeAction(_ textField: UITextField) {
        if textField == pwdField {
            newPassword = textField.text ?? ""
        } else {
            againNewPwd = textField.text ?? ""
        }
        checkSureBtnState()
    }
    
    
    deinit {
        print(#file + "deinit")
    }
    
    @IBAction func bgTapAction(_ sender: UIView) {
        view.endEditing(true)
    }
    
}
