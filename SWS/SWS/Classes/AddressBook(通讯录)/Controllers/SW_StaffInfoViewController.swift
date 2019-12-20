//
//  SW_StaffInfoViewController.swift
//  SWS
//
//  Created by jayway on 2018/4/24.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

/// 当前显示界面数据
///
/// - work: 工作资料
/// - personal: 个人资料
enum StaffInfoType {
    case work
    case personal
}

class SW_StaffInfoViewController: FormViewController {
    
    private var type: StaffInfoType = .work {
        didSet {
            if type != oldValue {
                createTableView()
            }
        }
    }
    
    fileprivate var user: UserModel? {
        didSet {
            if user != nil {
                UserCacheManager.save(user!.huanxin.huanxinAccount, staffId: NSNumber(value: user!.id), avatarUrl: user!.portrait, nickName: user!.realName + "(\(user!.position))")
            }
        }
    }
    
    private(set) var staffId: Int = -1
    
    private var sendMessageBtn: SW_BottomBlueButton = {
        let btn = SW_BottomBlueButton()
        btn.blueBtn.isEnabled = false
        btn.blueBtn.setTitle("发送消息", for: .normal)
        btn.blueBtn.addTarget(self, action: #selector(sendMsgBtnClick(sender:)), for: .touchUpInside)
        return btn
    }()
    
    init(_ staffId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.staffId = staffId
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formConfig()
        getStaffInfo()
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //更多按钮点击
    @objc private func moreAction(_ sender: UIBarButtonItem) {
        if SWSApiCenter.isReview {//审核期间添加举报n按钮选项
            var menus = [MenuItem]()
            
            menus.append(MenuItem(title: InternationStr("举报用户"), image: nil, isShowRedDot: false, action: {
                //消息管理
                if netManager?.isReachable == false {
                    showAlertMessage("网络异常，请重试", self.view)
                } else {
                    let alert = UIAlertController.init(title: InternationStr("举报成功"), message: InternationStr("感谢您的反馈，我们将在24小时内对该用户进行审查并处理！"), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: InternationStr("我知道了"), style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }))
            if user?.huanxin.huanxinAccount != "" {
                menus.append(MenuItem(title: InternationStr("联系人设置"), image: nil, isShowRedDot: false, action: { [weak self] in
                    guard let self = self else { return }
                    
                    if let index = self.navigationController?.viewControllers.firstIndex(where: { (vc) -> Bool in
                        if let vc = vc as? SW_ChatInfoAndSettingViewController {
                            return vc.staffId == self.staffId
                        }
                        return false
                    }) {//有index则代表存在单聊页面了、直接返回原来的页面
                        self.navigationController?.popToViewController(self.navigationController!.viewControllers[index], animated: true)
                    } else {//没index代表不存在发消息页面单聊页面  新建一个
                        self.navigationController?.pushViewController(SW_ChatInfoAndSettingViewController(self.user?.huanxin.huanxinAccount ?? "",   chatType: EMConversationTypeChat), animated: true)
                    }
                }))
            }
            
            let menuViewController = MenuViewController(items: menus)
            menuViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            self.present(menuViewController, animated: true, completion: nil)
            
        } else {
            
            if let index = self.navigationController?.viewControllers.firstIndex(where: { (vc) -> Bool in
                if let vc = vc as? SW_ChatInfoAndSettingViewController {
                    return vc.staffId == self.staffId
                }
                return false
            }) {//有index则代表存在单聊页面了、直接返回原来的页面
                self.navigationController?.popToViewController(self.navigationController!.viewControllers[index], animated: true)
            } else {//没index代表不存在发消息页面单聊页面  新建一个
                self.navigationController?.pushViewController(SW_ChatInfoAndSettingViewController(self.user?.huanxin.huanxinAccount ?? "",   chatType: EMConversationTypeChat), animated: true)
            }
        }
        
    }
    
    //获取员工信息
    fileprivate func getStaffInfo() {
        SW_AddressBookService.getStaffInfoDetail(staffId).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.user = UserModel(staffJson: json)
                
                if !SWSApiCenter.isReview && self.user?.huanxin.huanxinAccount == "" {
                    self.navigationItem.rightBarButtonItem = nil
                } else {
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "AddressBook_more"), style: .plain, target: self, action: #selector(self.moreAction(_:)))
                }
                self.createTableView()
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
    
    //MARK: - Action
    private func formConfig() {

        view.backgroundColor = .white
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_HEIGHT + TABBAR_BOTTOM_INTERVAL + 50, right: 0)
        
        SW_CommenLabelRow.defaultCellUpdate = { (cell, row) in
            cell.selectionStyle = .none
        }
        tableView.ly_emptyView = SW_LoadingEmptyView.creat()
        tableView.ly_emptyView.contentViewOffset = -(SCREEN_HEIGHT - 250) * 0.1
        
        view.addSubview(sendMessageBtn)
        sendMessageBtn.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(TABBAR_HEIGHT + TABBAR_BOTTOM_INTERVAL + 35)
        }
    }
    
    
    private func createTableView() {
        guard let user = user else { return }
        form = Form()
            +++
            Eureka.Section() {   section in
                var header = HeaderFooterView<SW_InfoHeaderView>(.nibFile(name: "SW_InfoHeaderView", bundle: nil))
                header.height = {140}
                // header每次出现在屏幕的时候调用
                header.onSetupView = { view, _ in
                    // 通常是在这修改view里面的文字
                    // 不要在这修改view的大小或者层级关系
//                    guard let user = self?.user else { return }
                    if  let url = URL(string: user.portrait) {
                        view.iconImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "personalcenter_icon_personalavatar"))
                    } else {
                        view.iconImageView.image = UIImage(named: "personalcenter_icon_personalavatar")
                    }
                    view.iconImageTapBlock = { [weak view] in
                        guard let view = view else { return }
                        if let image = view.iconImageView.image {//点击头像查看大图
                            let vc = SW_ImagePreviewViewController([image])
                            vc.sourceImageView = {
                                return view.iconImageView
                            }
                            view.getTopVC().present(vc, animated: true, completion: nil)
//                            vc.customGestureExitBlock = { (aImagePreviewViewController, currentZoomImageView) in
//                                aImagePreviewViewController?.exitPreviewToRect(inScreenCoordinate: view.convert(view.iconImageView.frame, to: nil))
//                            }
//                            vc.startPreviewFromRect(inScreenCoordinate: view.convert(view.iconImageView.frame, to: nil), cornerRadius: view.iconImageView.layer.cornerRadius)
                        }
                    }
                    view.nameLb.text = user.realName
                    view.depamentLb.text = user.position
                }
                section.header = header
        }
        
            <<< SW_StaffInfoTypeHeaderRow("SW_StaffInfoTypeHeaderRow") { [weak self] in
                $0.typeChangeBlock = { (infoType) in
                    self?.type = infoType
                }
                $0.value = self?.type
        }
        
        if type == .work {
            form.last!
            
            <<< SW_CommenLabelRow("department Name") {
                $0.rawTitle = NSLocalizedString("部门", comment: "")
                $0.value = user.departmentName
                }
                
                <<< SW_CommenLabelRow("business Unit Name") {
                    $0.rawTitle = NSLocalizedString("单位", comment: "")
                    $0.value = user.businessUnitName
                }
                
                <<< SW_CommenLabelRow("region Info") {
                    $0.rawTitle = NSLocalizedString("分区", comment: "")
                    $0.value = user.regionInfo
                }
                
                <<< SW_CommenLabelRow("phoneNum1") {
                    $0.rawTitle = NSLocalizedString("联系方式 ", comment: "")
                    $0.value = user.phoneNum1
                    $0.cell.rightActionLb.isHidden = user.phoneNum1.isEmpty
                    }.onCellSelection({  (cell, row) in
                        row.deselect()
                        if user.phoneNum1.isEmpty == false {
                            UIApplication.shared.open(scheme: "tel://\(user.phoneNum1)")//
                        }
                    })
                
                <<< SW_CommenLabelRow("businessNum") {
                    $0.rawTitle = NSLocalizedString("业务号码", comment: "")
                    $0.value = user.businessNum
                    $0.cell.rightActionLb.isHidden = user.businessNum.isEmpty
                    }.onCellSelection({  (cell, row) in
                        row.deselect()
                        if user.businessNum.isEmpty == false {
                            UIApplication.shared.open(scheme: "tel://\(user.businessNum)")//
                        } 
                    })
        } else {
            form.last!
            
            <<< SW_CommenLabelRow("Sex") {
                $0.rawTitle = NSLocalizedString("性别", comment: "")
                $0.value = user.sex.rawTitle
                }
                
                <<< SW_CommenLabelRow("hobby") {
                    $0.allowsMultipleLine = true
                    $0.rawTitle = NSLocalizedString("爱好", comment: "")
                    $0.value = user.hobby.replacingOccurrences(of: "_", with: "   ")
                }
                
                <<< SW_CommenLabelRow("specialty") {
                    $0.allowsMultipleLine = true
                    $0.rawTitle = NSLocalizedString("特长", comment: "")
                    $0.value = user.specialty.replacingOccurrences(of: "_", with: "   ")
                }
            
            if !SWSApiCenter.isTestEnvironment, SW_UserCenter.shared.user?.id == 77, SW_UserCenter.shared.user?.realName == "刘梓仲" {
                form.last!
                    <<< SW_CommenLabelRow("birthday") {
                        $0.rawTitle = NSLocalizedString("生日", comment: "")
                        $0.value = user.birthdayString
                }
            }
                form.last!
                <<< SW_CommenLabelRow("Blank1") {
                    $0.isShowBottomLine = false
                    $0.rawTitle = ""
                    $0.value = ""
                }
                <<< SW_CommenLabelRow("Blank2") {
                    $0.isShowBottomLine = false
                    $0.rawTitle = ""
                    $0.value = ""
            }
            
            
        }
        
        sendMessageBtn.blueBtn.isEnabled = SW_UserCenter.shared.user?.id != user.id
        
        tableView.reloadData()
    }
    
    @objc private func sendMsgBtnClick(sender: UIButton) {
        guard let user = user else { return }
        if let index = self.navigationController?.viewControllers.firstIndex(where: { (vc) -> Bool in
            if let vc = vc as? SW_ChatViewController {
                return vc.conversation.conversationId == user.huanxin.huanxinAccount
            }
            return false
        }) {//有index则代表存在单聊页面了、直接返回原来的页面
            self.navigationController?.popToViewController(self.navigationController!.viewControllers[index], animated: true)
        } else {//没index代表不存在发消息页面单聊页面  新建一个
            if SW_UserCenter.shared.user!.huanxin.huanxinAccount.isEmpty {
                SW_UserCenter.shared.showAlert(message: "请联系管理员或稍后重试")
                SW_UserCenter.loginHuanXin()
                return
            } else {
                SW_UserCenter.loginHuanXin()
            }
            if user.huanxin.huanxinAccount.isEmpty {
                showAlertMessage("网络异常，请稍后重试", MYWINDOW)
                return
            }
            guard let vc = SW_ChatViewController(conversationChatter: user.huanxin.huanxinAccount, conversationType: EMConversationTypeChat) else { return }
            vc.title = user.realName + "(\(user.position))"
            vc.regionStr = "\(user.regionInfo)-\(user.businessUnitName)-\(user.departmentName)"
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: - FormViewControllerProtocol   重写一下方法是因为需要去除该库添加时的动画
    override func sectionsHaveBeenAdded(_ sections: [Section], at indexes: IndexSet) {

    }
    
    override func rowsHaveBeenAdded(_ rows: [BaseRow], at indexes: [IndexPath]) {

    }
}


// MARK: - TableViewDelegate
extension SW_StaffInfoViewController {
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
}


