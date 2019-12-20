//
//  SW_SettingAccountViewController.swift
//  SWS
//
//  Created by jayway on 2018/4/13.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_SettingAccountViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formConfig()
        createTableView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Action
    private func formConfig() {
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
//        tableView.separatorColor = UIColor.mainColor.separator
//        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserPhoneNum1HadChange, object: nil, queue: nil) { [weak self] (notifi) in
            self?.createTableView()
        }
    }
    
    fileprivate func createTableView() {
        form = Form()
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = "账号"
                }
                section.header = header
            }
            
            +++
            Eureka.Section()
            
            <<< SW_CommenLabelRow("account") {
                $0.rawTitle = NSLocalizedString("账号", comment: "")
                $0.value = SW_UserCenter.shared.user?.phoneNum1 ?? "无"
                }.onCellSelection({ (cell, row) in
                    row.deselect()
                })
            
            <<< SW_CommenLabelRow("phone Num") {
                $0.rawTitle = NSLocalizedString("手机号", comment: "")
                $0.value = SW_UserCenter.shared.user?.phoneNum1 ?? "无"
                }.onCellSelection({ (cell, row) in
                    row.deselect()
                })
        
            +++
            Section() { [weak self] section in
                var header = HeaderFooterView<SW_ArchiveButtonView>(.nibFile(name: "SW_ArchiveButtonView", bundle: nil))
                header.height = {150}
                header.onSetupView = { view, _ in
                    view.leftConstraint.constant = 15
                    view.rightConstraint.constant = 15
                    view.button.layer.borderWidth = 0
                    view.button.setTitle("更换手机号", for: UIControl.State())
                    view.button.setBackgroundImage(UIImage(color: UIColor.v2Color.blue), for: UIControl.State())
                    view.button.setBackgroundImage(UIImage(color: UIColor(hexString: "#267cc4")), for: .highlighted)
                    view.button.setTitleColor(UIColor.white, for: UIControl.State())
                    view.button.titleLabel?.font = Font(16)
                    view.actionBlock = {
                        /// 调用发送消息按钮
                        self?.changeBtnAction()
                    }
                }
                section.header = header
        }
        
    }
    
    func changeBtnAction() {
        let alert = UIAlertController.init(title: InternationStr("密码验证"), message: nil, preferredStyle: .alert)
        var field: UITextField!
        alert.addTextField { (textfield) in
            field = textfield
            textfield.placeholder = InternationStr("请输入您的密码")
            textfield.keyboardType = .asciiCapable
            textfield.isSecureTextEntry = true
            textfield.clearButtonMode = .whileEditing
            textfield.borderStyle = .roundedRect
        }
        
        let sure = UIAlertAction(title: "确定", style: .default, handler: { [weak self] action in
            
            if let text = field.text , !text.isEmpty {
                SWSLoginService.checkPwd(SW_UserCenter.shared.user?.phoneNum1 ?? "", password: text).response({ (json, isCache, error) in
                    if error == nil {
                        //验证手机成功  进行修改手机号
                        if let vc = UIStoryboard(name: "Mine", bundle: nil).instantiateViewController(withIdentifier: "SW_SettingChangePhoneTwoViewController") as? SW_SettingChangePhoneTwoViewController {
                            self?.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                    }
                })
                
                
            } else {
                showAlertMessage(InternationStr("请输入您的密码"), MYWINDOW)
            }
        })
        
        alert.addAction(sure)
        
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
        alert.clearTextFieldBorder()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        PrintLog("deinit")
    }
}

// MARK: - TableViewDelegate
extension SW_SettingAccountViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 89
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
