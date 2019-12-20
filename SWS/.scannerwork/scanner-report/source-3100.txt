//
//  SW_NewLoginViewController.swift
//  SWS
//
//  Created by jayway on 2018/12/7.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_NewLoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var allContentView: UIView!
    
    @IBOutlet weak var changAccountBtn: UIButton!
    
    @IBOutlet weak var phoneRegionLb: UILabel!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var accountField: UITextField!
    
    @IBOutlet weak var accountLb: UILabel!
    
    @IBOutlet weak var pwdField: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var registerBtn: UIButton!
    
    @IBOutlet weak var forgetPwdBtn: UIButton!
    
    @IBOutlet weak var developBtn: UIButton!
    
    @IBOutlet weak var appleLoginBtn: UIButton!
    @IBOutlet weak var showPwdBtn: UIButton!
    
    @IBOutlet weak var welcomeLb: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var accountContentView: UIControl!
    
    @IBOutlet weak var accountContentHeight: NSLayoutConstraint!
    @IBOutlet weak var contentViewTopConstraint: NSLayoutConstraint!
    
    private var phone: String?
    
    private var isRequesting = false
    
    private var hadAddObserver = false
    
    class func changeRootViewToLogin() {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "SW_NewLoginViewController") as! SW_NewLoginViewController
        MYWINDOW?.change(rootViewController: SW_NavViewController(rootViewController: vc))
    }
    
    private var keyboardManager: QMUIKeyboardManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        keyboardManager = QMUIKeyboardManager(delegate: self)
        keyboardManager.addTargetResponder(accountField)
        keyboardManager.addTargetResponder(pwdField)
        
        let account = AcquireValueFromPerform(USERNAMEKEY) as? String ?? "" //从沙盒获取电话号码
        let imageUrl = AcquireValueFromPerform(ICON_IMAGE) as? String ?? ""
        if let url = URL(string: imageUrl.thumbnailString()) {
            iconImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "icon_personalavatar"))
        }
        accountLb.text = account
        phone = account
        setAccountState(!account.isEmpty)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hadAddObserver {
            hadAddObserver = true
            NotificationCenter.default.addObserver(forName: Notification.Name.Ex.HadGetAppStoreVersion, object: nil, queue: nil) { [weak self] (notifa) in
                self?.view.endEditing(true)
                SWSApiCenter.checkShouldUpdateTipAlert()
            }
        }
        SW_PrivacyPolicyViewController.checkAgreedPrivacyPolicyAndShow(self)
        SWSApiCenter.checkShouldUpdateTipAlert()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print(#file + "deinit")
    }
    
    //MARK: - private methon
    private func setupView() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.ReviewStateHadChange, object: nil, queue: nil) { [weak self] (notifi) in
            self?.registerBtn.isHidden = !SWSApiCenter.isReview
        }
        
        #if DEBUG
        developBtn.isHidden = false
//        appleLoginBtn.isHidden = false
        #endif
        iconImageView.layer.borderColor = UIColor.white.cgColor
        iconImageView.layer.borderWidth = 1
        iconImageView.layer.cornerRadius = iconImageView.height/2
        iconImageView.layer.masksToBounds = true
        
        phoneRegionLb.layer.cornerRadius = 2
        phoneRegionLb.layer.masksToBounds = true
        

        accountField.setPlaceholderColor(UIColor.white.withAlphaComponent(0.5))
        accountField.addTarget(self, action: #selector(editChangeAction(_:)), for: .editingChanged)
        pwdField.setPlaceholderColor(UIColor.white.withAlphaComponent(0.5))
        pwdField.addTarget(self, action: #selector(editChangeAction(_:)), for: .editingChanged)
        
        loginBtn.setBackgroundImage(UIImage.image(solidColor: UIColor.white, size: CGSize(width: 1, height: 1)), for: UIControl.State())
        loginBtn.setBackgroundImage(UIImage.image(solidColor: UIColor.white.withAlphaComponent(0.9), size: CGSize(width: 1, height: 1)), for: .highlighted)
        loginBtn.setBackgroundImage(UIImage.image(solidColor: UIColor.white.withAlphaComponent(0.9), size: CGSize(width: 1, height: 1)), for: .disabled)
        loginBtn.layer.cornerRadius = 3.0
        
        registerBtn.layer.cornerRadius = 3.0
        registerBtn.layer.borderColor = UIColor.white.cgColor
        registerBtn.layer.borderWidth = 0.5
        
        forgetPwdBtn.layer.borderColor = UIColor.white.cgColor
        forgetPwdBtn.layer.borderWidth = 0.5
        forgetPwdBtn.layer.cornerRadius = forgetPwdBtn.height/2
        
    }
    // state : true 显示头像帐号
    private func setAccountState(_ state: Bool) {
        
        iconImageView.isHidden = !state
        accountLb.isHidden = !state
        accountContentView.isHidden = state
        welcomeLb.isHidden = state
        logoImageView.isHidden = state
        accountContentHeight.constant = state ? 30 : 89
        changAccountBtn.isHidden = !state
        registerBtn.isHidden = !SWSApiCenter.isReview
        
        checkLoginBtnState()
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
    
    @IBAction func loginBtnClick(_ sender: UIButton) {
        view.endEditing(true) //退出键盘
        login()
    }
    
    @IBAction func appleLogin(_ sender: UIButton) {
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
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        var request = URLRequest(url: URL(string: SWSApiCenter.getBaseUrl() + "/api/app/staff/login.json")!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        request.httpMethod = "POST"
        request.setValue("application/json;charset=UTF-8", forHTTPHeaderField: "Content-Type")
//        request["loginNum"] = loginNum
//        request["password"] = password.passwordCoder()
        let dict = ["loginNum":phone,"password": password.passwordCoder()]
//        let str = "loginNum=\(phone)&password=\(password.passwordCoder())"
//        let data = str.data(using: .utf8)
        let jsonData:Data = try! JSONSerialization.data(withJSONObject: dict, options: []) as Data
        
        request.httpBody = jsonData
        
        let dataTask = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                let json = JSON(data: data ?? Data())
                if json["code"].intValue == 0 {
                    if let dict = json["data"].dictionaryObject {
                        InsertMessageToPerform(phone, USERNAMEKEY)
                        SW_UserCenter.loginSucceedLater(dict)
                    }
                } else {
                    showAlertMessage(json["msg"].stringValue, MYWINDOW)
                }
            } else {
                showAlertMessage("\(error.debugDescription)", MYWINDOW)
//                SW_UserCenter.shared.showAlert(message: "网络错误：localizedDescription：\(error?.localizedDescription)---------code：\(error?.code)---domain：\(error?.domain)")
            }
        }
        
        
        dataTask.resume()
    }
    
    
    @IBAction func registerBtnClick(_ sender: UIButton) {
        if let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "SW_RegisterStepOneViewController") as? SW_RegisterStepOneViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func forgetPwdBtnClick(_ sender: UIButton) {
       let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "SW_FindPwdViewController") as! SW_FindPwdViewController
        vc.phone = phone ?? ""
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func changeAccountBtnClick(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "SW_ChangeAccountViewController") as! SW_ChangeAccountViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func developBtnClick(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "SW_DevelopSettingViewController") as! SW_DevelopSettingViewController
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
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}


extension SW_NewLoginViewController: QMUIKeyboardManagerDelegate {
    
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
