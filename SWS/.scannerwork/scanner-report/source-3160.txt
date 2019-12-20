//
//  SW_SettingMessageViewController.swift
//  SWS
//
//  Created by jayway on 2018/4/16.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_SettingMessageViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationItem.title = NSLocalizedString("消息提醒", comment: "")
        formConfig()
        createTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        tableView.reloadData()
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
       
        SwitchRow.defaultCellUpdate = { (cell, row) in
            cell.textLabel?.textColor = UIColor.v2Color.lightBlack
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
            cell.switchControl.onTintColor = UIColor.v2Color.blue
        }
        
    }
    
    
    
    fileprivate func createTableView() {
        form = Form()
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    view.title = "消息提醒"
                }
                section.header = header
        }
            
        +++
        Eureka.Section() { section in
            var header = HeaderFooterView<SectionHeaderView>(.class)
            header.height = {30}
            header.onSetupView = { view, _ in
                view.titleView.font = MediumFont(12)
                view.titleView.textColor = UIColor.v2Color.darkGray
                view.backgroundColor = .white
                view.title = "“效率+”未打开时"
            }
            section.header = header
            }
            
            <<< SwitchRow("acect New Message") {
                $0.title = InternationStr("接收消息通知")
                $0.value = !UserDefaults.standard.bool(forKey: "UnReceiverMsgPush")
                $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                }.onChange {
                    guard let value = $0.value else { return }
                    UserDefaults.standard.set(!value, forKey: "UnReceiverMsgPush")
             
                    if value {//打开接收消息通知
                        // 设置免打扰时段，设置后，在改时间内不收推送
                        let options = EMClient.shared().pushOptions
                        options?.noDisturbStatus = EMPushNoDisturbStatusClose
                        EMClient.shared().updatePushOptionsToServer()
                    } else {
                        // 设置全天免打扰，设置后，您将收不到任何推送
                        let options = EMClient.shared().pushOptions
                        options?.noDisturbStatus = EMPushNoDisturbStatusDay
                        options?.noDisturbingStartH = 0
                        options?.noDisturbingEndH = 24
                        EMClient.shared().updatePushOptionsToServer()
                    }
            }
            
            +++
            Eureka.Section() { section in
                var header = HeaderFooterView<SectionHeaderView>(.class)
                header.height = {64}
                header.onSetupView = { view, _ in
                    view.titleView.font = MediumFont(12)
                    view.titleView.textColor = UIColor.v2Color.darkGray
                    view.backgroundColor = .white
                    view.title = "“效率+”打开时"
                }
                section.header = header
            }
            
            <<< SwitchRow("voice") {
                $0.title = InternationStr("声音")
                $0.value = !UserDefaults.standard.bool(forKey: "UnPlayMsgVoice")
                $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                }.onChange {
                    guard let value = $0.value else { return }
                    UserDefaults.standard.set(!value, forKey: "UnPlayMsgVoice")
            }
        
        
            <<< SwitchRow("vibration") {
                $0.title = InternationStr("震动")
                $0.value = !UserDefaults.standard.bool(forKey: "UnPlayVibration")
                $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                }.onChange {
                    guard let value = $0.value else { return }
                    UserDefaults.standard.set(!value, forKey: "UnPlayVibration")
            }
    }
    
    deinit {
        PrintLog("deinit")
    }
}

// MARK: - TableViewDelegate
extension SW_SettingMessageViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
