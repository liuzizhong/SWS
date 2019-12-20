//
//  SW_ChatSettingsViewController.swift
//  SWS
//
//  Created by jayway on 2018/4/16.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_ChatSettingsViewController: FormViewController {
    
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
        
        LabelRow.defaultCellUpdate = { (cell, row) in
            cell.selectionStyle = .default
            cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "Main_NextPage"))
            cell.textLabel?.textColor = UIColor.v2Color.lightBlack
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
            cell.detailTextLabel?.textColor = UIColor.mainColor.gray
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 16.0)
        }
        
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
                    view.title = "聊天设置"
                }
                section.header = header
            }
            
            +++
            Eureka.Section()
            
            <<< SwitchRow("receiver plays the sound") {
                $0.title = InternationStr("使用听筒播放语音")
                $0.value = UserDefaults.standard.bool(forKey: "ReceiverPlaySound")
                $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                }.onChange {
                    guard let value = $0.value else { return }
                    UserDefaults.standard.set(value, forKey: "ReceiverPlaySound")
            }
            <<< LabelRow("Empty chat logs") {
                $0.title = NSLocalizedString("清空聊天记录", comment: "")
                $0.cell.selectionStyle = .default
                $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    
                    self?.clearChatLogs()
                })
    }
    
    fileprivate func clearChatLogs() {
        let alertController = UIAlertController.init(title: InternationStr("您确定清空与所有联系人和工作群的聊天记录吗?"), message: nil, preferredStyle: .actionSheet)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 16, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        let quitAction = UIAlertAction(title: "确认", style: .destructive) { (alert) -> Void in
            //清空聊天记录
            var error: EMError? = nil
            guard SW_UserCenter.shared.user?.huanxin.huanxinAccount.isEmpty == false else {
                return
            }
            guard let conversations = EMClient.shared().chatManager.getAllConversations() else { return }
            conversations.forEach({ (conversation) in
                if let conversation = conversation as? EMConversation {
                    conversation.deleteAllMessages(&error)
                }
            })
            if let er = error  {
                showAlertMessage(er.errorDescription, MYWINDOW)
            } else {
                showAlertMessage("清空成功", MYWINDOW)
            }
        }
        let cancleAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(quitAction)
        alertController.addAction(cancleAction)
        present(alertController, animated: true, completion: nil)
    }
    
    deinit {
        PrintLog("deinit")
    }
}

// MARK: - TableViewDelegate
extension SW_ChatSettingsViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
}
