//
//  SW_ChatInfoAndSettingViewController.swift
//  SWS
//
//  Created by jayway on 2018/5/22.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_ChatInfoAndSettingViewController: FormViewController {
    
    /// 会话的id  群是群num  人是用户环信账号
    private var conversationId = ""
    /// 会话类型
    private var chatType = EMConversationTypeChat
    /// 会话对象的名称  群是群名称  人是员工真实姓名
    private var chatName = ""
    /// 员工职务名称
    private var posName = ""
    /// 员工所在分区
    private var regionStr = ""
    /// 会话对象的头像  群是群头像  人是员工头像
    private var chatImageUrl = ""
    /// 用户是否是群主
    private var isGroupOwner = false
    /// 群会话时使用  该群成员列表  最多显示3行
    private var members = [SW_RangeModel]()
    /// 单聊时使用 对象的员工id  查看详情时使用
    private(set) var staffId = 0
    /// 群组总人数
    private var membersCount = 0
    /// 群说明
    private var groupDescription = ""
    /// 群组id  我们服务器保存的id
    private var groupId = 0
    
    init(_ conversationId: String, chatType: EMConversationType) {
        super.init(nibName: nil, bundle: nil)
        self.conversationId = conversationId
        self.chatType = chatType
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        PrintLog("deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        formConfig()
        requestInfoData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup() {
        //群成员改变通知  添加或者删除都调用  重新获取群成员
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.GroupMembersHadChange, object: nil, queue: nil) { [weak self] (notifi) in
            guard let self = self else { return }
            let isAdd = notifi.userInfo!["isAdd"] as? Bool ?? true
            let count = notifi.userInfo!["count"] as? Int ?? 0
            if isAdd {
                self.membersCount = self.membersCount + count
            } else {
                self.membersCount = self.membersCount - count
            }
            self.reGetGroupMembers()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.GroupDescriptionHadChange, object: nil, queue: nil) { [weak self] (notifi) in
            guard let self = self else { return }
            let groupId =  notifi.userInfo!["groupId"] as? Int ?? 0
            self.groupDescription = notifi.userInfo!["groupDescription"] as? String ?? ""
            if self.groupId == groupId, let descriptionRow = self.form.rowBy(tag: "group description") as? SW_ChatSettingGroupNameRow {
                descriptionRow.value = self.groupDescription.isEmpty ? "未设置" : self.groupDescription
                descriptionRow.updateCell()
            }
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.GroupOwnerHadChange, object: nil, queue: nil) { [weak self] (notifi) in
            guard let self = self else { return }
            let groupNum =  notifi.userInfo!["groupNum"] as? String ?? ""
            if self.conversationId == groupNum {
                self.requestInfoData()
            }
        }
    }
    
    //MARK: - 网络请求
    /// 重新获取群成员
    private func reGetGroupMembers() {
        let max = isGroupOwner ? 8 : 10
        SW_GroupService.getGroupMemberList(conversationId, max: max).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.members = SW_RangeModel.sortGroupMembers(json.arrayValue.map({ return SW_RangeModel($0, type: .staff) }))
                if self.members.count > max {/// 删除超出max的部分
                    self.members.removeSubrange(max ..< self.members.count)
                }
                if let memberRow = self.form.rowBy(tag: "group members row") as? SW_GroupMemberRow {
                    memberRow.cell.membersCount = self.membersCount
                    memberRow.cell.members = self.members
                    memberRow.reload()
                }
            }
        })
    }
    
    /// 初始化该页面数据
    private func requestInfoData() {
        switch chatType {
        case EMConversationTypeChat:
            SW_MessageService.getConversationList("", huanxinNumStr: conversationId).response({ (json, isCache, error) in
                if let json = json as? JSON, error == nil {
                    json["HuanxinUserList"].arrayValue.forEach({ (infoJson) in
                        let huanxinId = infoJson["huanxinNum"].stringValue
                        guard !huanxinId.isEmpty else {
                            return
                        }
                        self.staffId = infoJson["staffId"].intValue
                        self.chatImageUrl = infoJson["portrait"].stringValue
                        self.chatName = infoJson["realName"].stringValue
                        self.posName = infoJson["posName"].stringValue
                        self.regionStr = infoJson["regionStr"].stringValue
                    })
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                }
                self.createTableView()
            })
        case EMConversationTypeGroupChat:
            //使用DispatchGroup 当两个请求完成时才刷新页面
            SW_GroupService.showGroup(conversationId, staffId: SW_UserCenter.shared.user!.id).response({ (json, isCache, error) in
                if let json = json as? JSON, error == nil {
                    
                    if json["groupInfoEntity"]["groupState"].intValue == 2 {// 群被停用
                       showAlertMessage("该工作群已被停用", MYWINDOW)
                        self.navigationController?.popToRootViewController(animated: true)
                    } else {
                        self.chatName = json["groupInfoEntity"]["groupName"].stringValue
                        self.groupId = json["groupInfoEntity"]["groupId"].intValue
                        self.chatImageUrl = json["groupInfoEntity"]["imageUrl"].stringValue
                        self.groupDescription = json["groupInfoEntity"]["remark"].stringValue
                        self.isGroupOwner = json["isOwner"].intValue == 1// 1是群主   其他不是
                        self.membersCount = json["groupCount"].intValue
                        
                        let max = self.isGroupOwner ? 8 : 10
                        SW_GroupService.getGroupMemberList(self.conversationId, max: max).response({ (json, isCache, error) in
                            if let json = json as? JSON, error == nil {
                                self.members = SW_RangeModel.sortGroupMembers(json.arrayValue.map({ return SW_RangeModel($0, type: .staff) }))
                                if self.members.count > max {/// 删除超出max的部分
                                    self.members.removeSubrange(max ..< self.members.count)
                                }
                                self.createTableView()
                            } else {
                                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                            }
                        })
                    }
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                }
            })
        default:
            showAlertMessage("暂时不支持聊天室", view)
        }
        
    }
    
    //MARK: - Action
    private func formConfig() {
        view.backgroundColor = UIColor.white
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
//        tableView.separatorColor = UIColor.mainColor.separator
//        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        tableView.ly_emptyView = SW_LoadingEmptyView.creat()
        tableView.ly_emptyView.contentViewOffset = -(SCREEN_HEIGHT - 250) * 0.1
        
        LabelRow.defaultCellUpdate = { (cell, row) in
            cell.accessoryView = UIImageView(image: #imageLiteral(resourceName: "Main_NextPage"))
            cell.textLabel?.textColor = UIColor.v2Color.lightBlack
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
            cell.detailTextLabel?.textColor = UIColor.mainColor.gray
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 16.0)
            cell.selectionStyle = .default
        }
        
        SwitchRow.defaultCellUpdate = { (cell, row) in
            cell.textLabel?.textColor = UIColor.v2Color.lightBlack
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
            cell.switchControl.onTintColor = UIColor.v2Color.blue
        }
        
        ImageRow.defaultCellUpdate = { (cell, row) in
            cell.textLabel?.textColor = UIColor.v2Color.lightBlack
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0)
        }
    }
    
    
    fileprivate func createTableView() {
        form = Form()
            +++
            Eureka.Section() { [weak self] section in
                var header = HeaderFooterView<BigTitleSectionHeaderView>(.class)
                header.height = {70}
                header.onSetupView = { view, _ in
                    if self?.chatType == EMConversationTypeChat {
                        view.title = "联系人设置"
                    } else {
                        view.title = "工作群设置"
                    }
                }
                section.header = header
        }
            
        switch chatType {
        case EMConversationTypeChat:
            if !chatName.isEmpty {
                form
                    +++
                    Eureka.Section() { [weak self]  section in
                        var header = HeaderFooterView<SW_InfoHeaderView>(.nibFile(name: "SW_InfoHeaderView", bundle: nil))
                        header.height = {140}
                        // header每次出现在屏幕的时候调用
                        header.onSetupView = { view, _ in
                            // 通常是在这修改view里面的文字
                            // 不要在这修改view的大小或者层级关系
                            guard let self = self else { return }
                            if  let url = URL(string: self.chatImageUrl) {
                                view.iconImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "personalcenter_icon_personalavatar"))
                            } else {
                                view.iconImageView.image = UIImage(named: "personalcenter_icon_personalavatar")
                            }
                            view.viewTapBlock = { [weak self] in
                                self?.gotoStaffInfoVC()
                            }
                            view.iconImageTapBlock = { [weak view, weak self] in
                                guard let view = view else { return }
                                if let image = view.iconImageView.image {//点击头像查看大图
                                    let vc = SW_ImagePreviewViewController([image])
                                    vc.sourceImageView = {
                                        return view.iconImageView
                                    }
                                    self?.present(vc, animated: true, completion: nil)
//                                    vc.customGestureExitBlock = { (aImagePreviewViewController, currentZoomImageView) in
//                                        aImagePreviewViewController?.exitPreviewToRect(inScreenCoordinate: view.convert(view.iconImageView.frame, to: nil))
//                                    }
//                                    vc.startPreviewFromRect(inScreenCoordinate: view.convert(view.iconImageView.frame, to: nil), cornerRadius: view.iconImageView.layer.cornerRadius)
                                }
                            }
                            view.nameLb.text = self.chatName
                            view.depamentLb.text = self.posName
                        }
                        section.header = header
                }
                
            }
        case EMConversationTypeGroupChat:
            if !chatName.isEmpty {
                form.last!
                    <<< SW_ChatSettingGroupIconRow("group Icon") {
                        $0.isGroupOwner = isGroupOwner
                        $0.value = chatImageUrl
                        }.onCellSelection({ [weak self] (cell, row) in
                            row.deselect()
                            if self?.isGroupOwner == true {
                                SW_ImagePickerHelper.shared.showPicturePicker({ (img) in
                                    self?.handleImage(img)
                                })
                            }
                        })
                    <<< SW_ChatSettingGroupNameRow("group name") {
                        $0.value = chatName
                        $0.isGroupOwner = isGroupOwner
                        }.onCellSelection({ [weak self] (cell, row) in
                            row.deselect()
                            if self?.isGroupOwner == true {
                                self?.showChangeGroupNameAlert()
                            }
                        })
                    <<< SW_ChatSettingGroupNameRow("group description") {
                        $0.value = groupDescription.isEmpty ? "未设置" : groupDescription
                        $0.isGroupOwner = true
                        $0.cell.titleLb.text = "群说明"
                        }.onCellSelection({ [weak self] (cell, row) in
                            row.deselect()
                            /// 进入群说明页面，是否群主都可以进入
                            /// 群主可编辑
                            guard let self = self else { return }
                            self.navigationController?.pushViewController(SW_GroupDescriptionViewController(self.groupId, groupDescription: self.groupDescription, isGroupOwner: self.isGroupOwner), animated: true)
                        })
                
                if isGroupOwner {
                    form.last!
                    <<< SW_ChatSettingGroupNameRow("Group of transfer") {
                        $0.value = chatName
                        $0.isGroupOwner = isGroupOwner
                        $0.cell.titleLb.text = "群转让"
                        }.onCellSelection({ [weak self] (cell, row) in
                            row.deselect()
                            /// 进入群转让页面
                           guard let self = self else { return }
                            self.navigationController?.pushViewController(SW_TransferGroupViewController(self.conversationId), animated: true)
                        })
                }
            }
        default:
            break
        }
        
        if members.count > 0 {
            form.last!
                <<< SW_GroupMemberRow("group members row") {
                    $0.cell.members = members
                    $0.cell.isOwner = isGroupOwner
                    $0.cell.membersCount = membersCount
                    $0.cell.selectionStyle = .default
                    $0.cell.didSelectRow = { [weak self] (IndexPath) in
                        guard let sSelf = self else { return }
                        if sSelf.isGroupOwner {
                            if IndexPath.row == 0 {
                                //添加群成员
                                let vc = SW_NewSelectPeopleViewController(sSelf.conversationId, navTitle: "添加群成员", type: .addGroupMember)
                                let nav = SW_NavViewController(rootViewController: vc)
                                nav.modalPresentationStyle = .fullScreen
                                sSelf.present(nav, animated: true, completion: nil)
                            } else if IndexPath.row == 1 {
                                //删除群成员
                                self?.navigationController?.pushViewController(SW_DeleteGroupMemberViewController(sSelf.conversationId), animated: true)
                            } else {
                                //查看群成员个人信息
                                sSelf.navigationController?.pushViewController(SW_StaffInfoViewController(sSelf.members[IndexPath.row - 2].id), animated: true)
                            }
                        } else {
                            //查看群成员个人信息
                            sSelf.navigationController?.pushViewController(SW_StaffInfoViewController(sSelf.members[IndexPath.row].id), animated: true)
                        }
                    }
                    }.onCellSelection({ [weak self] (cell, row) in
                        row.deselect()
                        guard let sSelf = self else { return }
                        //查看全部群成员
                        sSelf.navigationController?.pushViewController(SW_LookGroupMembersViewController(sSelf.conversationId, isGroupOwner: sSelf.isGroupOwner), animated: true)
                    })
        }
        
        form.last!
            
            <<< SwitchRow("Top chat") {
                $0.title = InternationStr("置顶聊天")
                $0.value = SW_TopConversationManager.isTopConversation(conversationId,chatType: chatType)
                $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                }.onChange { [weak self] in
                    guard let sSelf = self else { return }
                    let isOn = $0.value ?? false
                    if isOn {
                        SW_TopConversationManager.addTopConversation(sSelf.conversationId,chatType: sSelf.chatType)
                    } else {
                        SW_TopConversationManager.removeTopConversation(sSelf.conversationId,chatType: sSelf.chatType)
                    }
                    NotificationCenter.default.post(name: Notification.Name.Ex.TopConversationsHadChange, object: nil, userInfo: ["isReload": true])
            }
            
            <<< SwitchRow("Message Don disturb") {
                $0.title = InternationStr("消息免打扰")
                if chatType == EMConversationTypeGroupChat {//群组使用环信接口屏蔽
                    if let group = EMGroup(id: conversationId) {
                        $0.value = !group.isPushNotificationEnabled
                    } else {
                        $0.value = false
                    }
                } else {//单聊自己实现
                    $0.value = SW_IgnoreManager.isIgnoreStaff(conversationId)
                }
                $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                }.onChange { [weak self] in
                    guard let sSelf = self else { return }
                    let isOn = $0.value ?? false
                    if sSelf.chatType == EMConversationTypeGroupChat {
                        if let groupManager = EMClient.shared().groupManager {
                            groupManager.updatePushService(forGroup: sSelf.conversationId, isPushEnabled: !isOn, completion: { (group, error) in
                                PrintLog(error.debugDescription)
                            })
                        }
                    } else {
                        if isOn {
                            SW_IgnoreManager.addIgnoreStaff(sSelf.conversationId)
                        } else {
                            SW_IgnoreManager.removeIgnoreStaff(sSelf.conversationId)
                        }
                    }
            }

            <<< LabelRow("search chat logs") {
                $0.title = NSLocalizedString("查找聊天记录", comment: "")
                $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    guard SW_UserCenter.shared.user?.huanxin.huanxinAccount.isEmpty == false else {
                        return
                    }
                    guard let sSelf = self else { return }
                    if let conversation = EMClient.shared().chatManager.getConversation(sSelf.conversationId, type: sSelf.chatType, createIfNotExist: true) {
                        let vc = SW_SearchChatRecordsViewController(conversation)
                        vc.chatTitle = sSelf.chatType == EMConversationTypeChat ? sSelf.chatName + "(\(sSelf.posName))" : sSelf.chatName
                        vc.regionStr = sSelf.regionStr
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                })
            
            <<< LabelRow("Empty chat logs") {
                $0.title = NSLocalizedString("清空聊天记录", comment: "")
                $0.cell.addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: 0.5)
                }.onCellSelection({ [weak self] (cell, row) in
                    row.deselect()
                    self?.clearChatLogs()
                })
        
            form
            +++
            Section() { [weak self] section in
                var header = HeaderFooterView<SW_ArchiveButtonView>(.nibFile(name: "SW_ArchiveButtonView", bundle: nil))
                header.height = {150}
                header.onSetupView = { view, _ in
                    view.leftConstraint.constant = 15
                    view.rightConstraint.constant = 15
                    view.button.layer.borderWidth = 0
                    view.button.isEnabled = SW_UserCenter.shared.user?.id != self?.staffId
                    view.button.setTitle("发送消息", for: UIControl.State())
                    view.button.setBackgroundImage(UIImage(color: UIColor.v2Color.blue), for: UIControl.State())
                    view.button.setBackgroundImage(UIImage(color: UIColor(hexString: "#267cc4")), for: .highlighted)
                    view.button.setTitleColor(UIColor.white, for: UIControl.State())
                    view.button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .disabled)
                    view.button.titleLabel?.font = Font(16)
                    view.actionBlock = {
                        /// 调用发送消息按钮
                        self?.sendMsgBtnClick()
                    }
                }
                section.header = header
        }
        
        
        tableView.reloadAndFadeAnimation()
    }
    
    //MARK: - private method
    @objc private func sendMsgBtnClick() {
        if let index = navigationController?.viewControllers.firstIndex(where: { (vc) -> Bool in
            if let vc = vc as? SW_ChatViewController {
                return vc.conversation.conversationId == self.conversationId
            }
            return false
        }) {//有index则代表存在单聊页面了、直接返回原来的页面
            navigationController?.popToViewController(self.navigationController!.viewControllers[index], animated: true)
        } else {//没index代表不存在发消息页面单聊页面  新建一个
            if SW_UserCenter.shared.user!.huanxin.huanxinAccount.isEmpty {
                SW_UserCenter.shared.showAlert(message: "请联系管理员或稍后重试")
                SW_UserCenter.loginHuanXin()
                return
            } else {
                SW_UserCenter.loginHuanXin()
            }
            if conversationId.isEmpty {
                showAlertMessage("网络异常，请稍后重试", MYWINDOW)
                return
            }
            guard let vc = SW_ChatViewController(conversationChatter: conversationId, conversationType: chatType) else { return }
            vc.title = chatType == EMConversationTypeChat ? chatName + "(\(posName))" : chatName
            vc.regionStr = regionStr
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func gotoStaffInfoVC() {
        if let index = self.navigationController?.viewControllers.firstIndex(where: { (vc) -> Bool in
            if let vc = vc as? SW_StaffInfoViewController {
                return vc.staffId == self.staffId
            }
            return false
        }) {//有index则代表存在单聊页面了、直接返回原来的页面
            self.navigationController?.popToViewController(self.navigationController!.viewControllers[index], animated: true)
        } else {//没index代表不存在发消息页面单聊页面  新建一个
            self.navigationController?.pushViewController(SW_StaffInfoViewController(self.staffId), animated: true)
        }
    }
    
    private func showChangeGroupNameAlert() {
        let nameAlert = UIAlertController.init(title: InternationStr("请输入群名称"), message: nil, preferredStyle: .alert)
        var field: UITextField!
        nameAlert.addTextField { (textfield) in
            field = textfield
            textfield.placeholder = InternationStr("群名称")
            textfield.keyboardType = .default
            textfield.clearButtonMode = .whileEditing
            textfield.borderStyle = .roundedRect
        }
        field.text = chatName
        
        let sure = UIAlertAction(title: "确认", style: .default, handler: { [weak self] action in
            if let text = field.text , !text.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
                guard let sSelf = self else { return }
                SW_GroupService.updateGroup(sSelf.conversationId, groupName: text).response({ (json, isCache, error) in
                    if error == nil {
                        showAlertMessage("修改群名称成功", sSelf.view)
                        ///发起通知   全局修改群名称 ---会话列表   ---- 通讯录列表 ---- 聊天页面
                        NotificationCenter.default.post(name:  NSNotification.Name.Ex.UserHadChangeGroupName, object: nil, userInfo: ["groupNum": sSelf.conversationId, "groupName": text])
                        
                        guard let nameRow: SW_ChatSettingGroupNameRow = sSelf.form.rowBy(tag: "group name") else { return }
                        nameRow.value = text
                        sSelf.chatName = text
                        nameRow.reload()
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                    }
                })
            } else {
                showAlertMessage(InternationStr("群名称不可以为空"), MYWINDOW)
            }
        })
        nameAlert.addAction(sure)
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        nameAlert.addAction(cancel)

        present(nameAlert, animated: true, completion: nil)
        nameAlert.clearTextFieldBorder()
    }
    
    ///清空会话的聊天记录 会把会话本身删除
    private func clearChatLogs() {
        let alertController = UIAlertController.init(title: InternationStr("您确定清空与该联系人聊天记录吗?"), message: nil, preferredStyle: .actionSheet)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 16, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        let quitAction = UIAlertAction(title: "确认", style: .destructive) { (alert) -> Void in
            //清空聊天记录
            var error: EMError? = nil
            guard SW_UserCenter.shared.user?.huanxin.huanxinAccount.isEmpty == false else {
                showAlertMessage("清空成功", MYWINDOW)
                return
            }
            EMClient.shared().chatManager.getConversation(self.conversationId, type: self.chatType, createIfNotExist: true).deleteAllMessages(&error)
            if let error = error {
                showAlertMessage("清空聊天记录失败~请重试!\(String(describing: error.errorDescription))", self.view)
            } else {//清空聊天记录成功  通知会话页面清空数据
                showAlertMessage("清空成功", MYWINDOW)
                NotificationCenter.default.post(name: NSNotification.Name.Ex.ChatMessagesHadClear, object: nil, userInfo: ["conversationId": self.conversationId, "chatType": self.chatType])
            }
        }
        let cancleAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(quitAction)
        alertController.addAction(cancleAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func calculateMenberRowHeight() -> CGFloat {
        let memberCount = isGroupOwner ? members.count + 2 : members.count
        let addCount = memberCount % 5 > 0 ? 1 : 0
        let colum = memberCount / 5 + addCount
        return CGFloat(76 * colum + 15 * (colum - 1) + 59)
    }
    
    //MARK: - 选择照片、修改头像相关逻辑
    //最后的处理  上传图片  上传服务器
    private func handleImage(_ selectImage: UIImage) {
        //上传至七牛后，将七牛返回的key上传至服务端。
        SWSUploadManager.share.upLoadPortrait(selectImage) { (success, key) in
            if let key = key, success {
                SW_GroupService.updateGroup(self.conversationId, imageUrl: key).response({ (json, isCache, error) in
                    if let json = json as? JSON, error == nil {
                        showAlertMessage(InternationStr("群头像修改成功"), MYWINDOW)
                        ///发起通知   全局修改群名称 ---会话列表   ---- 通讯录列表 ---- 聊天页面
                        NotificationCenter.default.post(name:  NSNotification.Name.Ex.UserHadChangeGroupIcon, object: nil, userInfo: ["groupNum": self.conversationId, "groupIcon": json["imageUrl"].stringValue])
                        
                        guard let imageRow: SW_ChatSettingGroupIconRow = self.form.rowBy(tag: "group Icon") else { return }
                        imageRow.cell.iconImageView.image = selectImage
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                    }
                })
            }
        }
    }
    
    //MARK: - FormViewControllerProtocol   重写一下方法是因为需要去除该库添加时的动画
    override func sectionsHaveBeenAdded(_ sections: [Section], at indexes: IndexSet) {
    }
    
    override func rowsHaveBeenAdded(_ rows: [BaseRow], at indexes: [IndexPath]) {
    }
}

// MARK: - TableViewDelegate
extension SW_ChatInfoAndSettingViewController {
    
     override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch chatType {
        case EMConversationTypeChat:
            return 64
        case EMConversationTypeGroupChat:
            if !chatName.isEmpty {
                if  indexPath.row == 0 {
                    return 75
                }
                let membersRow = isGroupOwner ? 4 : 3
                if members.count > 0, indexPath.row == membersRow {
                    return calculateMenberRowHeight()
                }
                
            } else if members.count > 0, indexPath.row == 0 {
                return  calculateMenberRowHeight()
            }
        default:
            break
        }
        return 64
    }
    
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
}


