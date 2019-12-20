//
//  SW_MessageViewController.swift
//  SWS
//
//  Created by jayway on 2018/5/14.
//  Copyright © 2018年 yuanrui. All rights reserved.
//


import UIKit

class SW_MessageViewController: EaseConversationListViewController {
    
    ///管理默认的3个公告会话   原来是3个现在变成1个了、
    private var defaultConversations = SW_DefaultConversations()
    
    /// 标记是否请求数据出错过、如果是下次进来时会重新请求
    private var isFaildRequest = false
    
    /// 在创建置顶联系人时会一直调用会话列表改变方法  利用该变量减少调用次数，
    var creatingConversation = false
    /// 是否是删除会话
    var isDelete = false
    /// view是否加载完成
    private var hadDidLoad = false
    /// 是否有待办事项相关权限，有则为1，无为0
    private var backLog = 0
    /// 搜索的数据
    private var searchDatas = [SW_ConversationModel]()
    
    private lazy var searchBar: SW_NewSearchBar = {
        let sbar =  Bundle.main.loadNibNamed(String(describing: SW_NewSearchBar.self), owner: nil, options: nil)?.first as! SW_NewSearchBar
        sbar.placeholderString = "搜索"
        sbar.backBtn.setImage(#imageLiteral(resourceName: "Main_Search"), for: UIControl.State())
        sbar.backBtn.isUserInteractionEnabled = false
        sbar.addBtnWidth = 50
        sbar.cancelBtn.setTitleColor(UIColor.v2Color.lightBlack, for: UIControl.State())
        return sbar
    }()
    
    private var popupAtBarButtonItem: QMUIPopupMenuView!
    
    lazy var searchTableView: UITableView = {
        let tbv = UITableView.init(frame: .zero, style: .grouped)
        tbv.isHidden = true
        tbv.delegate = self
        tbv.dataSource = self
        tbv.backgroundColor = UIColor.white
        tbv.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tbv.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        tbv.keyboardDismissMode = .onDrag
        tbv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL + SHOWACCESS_TABBAR_HEIGHT, right: 0)
        tbv.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL + TABBAR_HEIGHT, right: 0)
        tbv.register(EaseConversationCell.self, forCellReuseIdentifier: EaseConversationCell.cellIdentifier(withModel: nil))
        tbv.rowHeight = 79
        return tbv
    }()
    
    private lazy var searchEmptyView: LYEmptyView = {
        let emptyView = LYEmptyView.empty(withImageStr: "", titleStr: "抱歉，没有找到相关内容", detailStr: "")
        emptyView?.titleLabTextColor = UIColor.v2Color.darkGray
        emptyView?.titleLabFont = Font(14)
        emptyView?.contentViewY = 20
        return emptyView!
    }()
    
    lazy var tap: UITapGestureRecognizer = {
        let t = UITapGestureRecognizer(actionBlock: { [weak self] (gesture) in
            self?.searchBar.cancelBtnClick(UIButton())
        })
        return t!
    }()
    
    lazy var searchBgView: UIView = {
        let v = UIView()
        v.addGestureRecognizer(self.tap)
        v.alpha = 0
        v.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8)
        v.addSubview(searchTableView)
        searchTableView.snp.makeConstraints({ (make) in
            make.top.leading.trailing.bottom.equalToSuperview()
        })
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupNotification()
        hadDidLoad = true
        isHideTabBar = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if isFaildRequest {//请求失败过，再次显示该页面时重新请求
            tableViewDidTriggerHeaderRefresh()
        } else {//正常显示时都进行一次排序  可以看看需不需要
            NotificationCenter.default.post(name: NSNotification.Name.Ex.SetupUnreadMessageCount, object: nil)
            refreshAndSortView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /// 权限判断
        if SW_UserCenter.shared.user!.auth.backLogAuth.count > 0 {
            backLog = 1
            getBackLogCount()
        }
    }
    
    private func setup() {
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        tableView.backgroundColor = UIColor.white
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL + SHOWACCESS_TABBAR_HEIGHT, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL + TABBAR_HEIGHT, right: 0)
        tableView.separatorStyle = .none
        tableView.register(EaseConversationCell.self, forCellReuseIdentifier: EaseConversationCell.cellIdentifier(withModel: nil))
        tableView.register(SWInformMessageCell.self, forCellReuseIdentifier: SWInformMessageCell.cellIdentifier())
        //头部搜索条
        searchBar.setUpAddBtn("", image: #imageLiteral(resourceName: "Main_Add"), action: { [weak self] in
            self?.moreAction()
        })
        searchBar.setUpSecBtn("", image: #imageLiteral(resourceName: "messages_icon_scan"), action: { [weak self] in
            self?.scanAction()
        })
        searchBar.becomeFirstBlock = { [weak self] in
            guard let self = self else { return }
            
            self.view.addSubview(self.searchBgView)
            self.searchBgView.snp.makeConstraints({ (make) in
                make.leading.trailing.bottom.equalToSuperview()
                make.top.equalTo(self.searchBar.snp.bottom)
            })
            UIView.animate(withDuration: 0.4, animations: {
                self.searchBgView.alpha = 1
            }, completion: nil)
        }
        searchBar.cancelActionBlock = { [weak self] in
            guard let self = self else { return }
            
            self.tap.isEnabled = true
            self.searchTableView.isHidden = true
            self.searchDatas = []
            self.searchTableView.reloadData()
            
            UIView.animate(withDuration: 0.4, animations: {
                self.searchBgView.alpha = 0
            }, completion: { (finish) in
                self.searchBgView.removeFromSuperview()
                self.refreshAndSortView()
            })
        }
        searchBar.textChangeBlock = { [weak self] in
            guard let self = self else { return }
            self.tap.isEnabled = self.searchBar.searchText.isEmpty
            self.searchTableView.isHidden = self.searchBar.searchText.isEmpty
            if self.searchBar.searchText.isEmpty {
                self.searchDatas = []
                self.searchTableView.ly_emptyView = nil
                self.searchTableView.reloadData()
            }
        }
        searchBar.searchBlock = { [weak self] in
            guard let self = self else { return }
            self.searchMessages(self.searchBar.searchText)
        }
        
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(NAV_HEAD_INTERVAL + 74)
        }
        
        tableView.snp.remakeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom)
        }
        
        popupAtBarButtonItem = QMUIPopupMenuView()
        
        popupAtBarButtonItem.maskViewBackgroundColor = .clear
        popupAtBarButtonItem.automaticallyHidesWhenUserTap = true
        popupAtBarButtonItem.itemTitleFont = Font(15)
        popupAtBarButtonItem.itemTitleColor = UIColor.v2Color.darkGray
        popupAtBarButtonItem.safetyMarginsOfSuperview = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 15)
        popupAtBarButtonItem.itemHeight = 54
        popupAtBarButtonItem.itemConfigurationHandler = { (menuView,item,section,index) in
            print(index)
            if let item = item as? QMUIPopupMenuButtonItem {
                item.button.highlightedBackgroundColor = #colorLiteral(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
            }
        }
        popupAtBarButtonItem.padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        popupAtBarButtonItem.borderWidth = 0
        popupAtBarButtonItem.cornerRadius = 3
        popupAtBarButtonItem.shadowColor = UIColor(r: 48, g: 55, b: 80, alpha: 1).withAlphaComponent(0.3)
        popupAtBarButtonItem.arrowSize = CGSize(width: 10, height: 5)
        popupAtBarButtonItem.maximumWidth = 140
        popupAtBarButtonItem.shouldShowItemSeparator = true
        popupAtBarButtonItem.itemSeparatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        popupAtBarButtonItem.itemSeparatorColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        popupAtBarButtonItem.items = [QMUIPopupMenuButtonItem(image: #imageLiteral(resourceName: "messages_icon_addgroupchat"), title: "创建工作群") { [weak self] (item) in
            self?.popupAtBarButtonItem.hideWith(animated: true)
            if SW_UserCenter.shared.user!.huanxin.huanxinAccount.isEmpty {
                let alert = UIAlertController.init(title: nil, message: InternationStr("请联系管理员或稍后重试"), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
                SW_UserCenter.loginHuanXin()
                return
            }
            //创建工作群
            let vc = SW_NewSelectPeopleViewController(nil, navTitle: "选择联系人",type: .creatGroup)
            let nav = SW_NavViewController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self?.present(nav, animated: true, completion: nil)

            }]
        
        if (SW_UserCenter.shared.user!.auth.messageAuth.first?.authDetails.count ?? 0) > 0 {        
            popupAtBarButtonItem.items?.append(QMUIPopupMenuButtonItem(image: #imageLiteral(resourceName: "messages_icon_sendannouncement"), title: "发公告") { [weak self] (item) in
                self?.popupAtBarButtonItem.hideWith(animated: true)
                
                let vc = SW_SendInformTwoViewController("")
                self?.navigationController?.pushViewController(vc, animated: true)
            })
        }
        
        if SWSApiCenter.isTestEnvironment {
            popupAtBarButtonItem.items?.append(QMUIPopupMenuButtonItem(image: #imageLiteral(resourceName: "message_icon_platerecognition"), title: "车牌识别") { [weak self] (item) in
                self?.popupAtBarButtonItem.hideWith(animated: true)
                let vc = CameraViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            })
        }
        
        /// 权限判断
//        if SW_UserCenter.shared.user!.auth.backLogAuth.count > 0 {
//            backLog = 1
//            getBackLogCount()
//        }
        
    }
    
    private func setupNotification() {
        /// 工作群状态修改 {"groupId":131,"groupNum":"80242616107009","groupState":1}
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.GroupStateHadChange, object: nil, queue: nil) { [weak self] (notification) in
            let groupNum = notification.userInfo?["groupNum"] as? String ?? ""
            let groupState = notification.userInfo?["groupState"] as? Int ?? 1
            self?.dataArray.forEach({ (data) in
                if let conversation = data as? SW_ConversationModel, conversation.conversation.conversationId == groupNum {
                    conversation.groupState = groupState != 2
                    if groupState == 2 {/// 设置消息未读全部为已读
                        conversation.conversation.markAllMessages(asRead: nil)
                        NotificationCenter.default.post(name: NSNotification.Name.Ex.SetupUnreadMessageCount, object: nil)
                    }
                    self?.safeReloadData()
                }
            })
            self?.searchDatas.forEach({ (conversation) in
                if conversation.conversation.conversationId == groupNum {
                    conversation.groupState = groupState != 2
                    self?.safeReloadData()
                }
            })
        }
        
        ///群名称改变，刷新页面
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadChangeGroupName, object: nil, queue: nil) { [weak self] (notification) in
            let groupNum = notification.userInfo?["groupNum"] as? String ?? ""
            self?.dataArray.forEach({ (data) in
                if let conversation = data as? SW_ConversationModel, conversation.conversation.conversationId == groupNum {
                    conversation.title = notification.userInfo?["groupName"] as? String ?? ""
                    self?.safeReloadData()
                }
            })
        }
        ///群头像改变，刷新页面
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadChangeGroupIcon, object: nil, queue: nil) { [weak self] (notification) in
            let groupNum = notification.userInfo?["groupNum"] as? String ?? ""
            self?.dataArray.forEach({ (data) in
                if let conversation = data as? SW_ConversationModel, conversation.conversation.conversationId == groupNum {
                    conversation.avatarURLPath = notification.userInfo?["groupIcon"] as? String ?? ""
                    self?.safeReloadData()
                }
            })
        }
        ///置顶联系人改变，刷新页面
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.TopConversationsHadChange, object: nil, queue: nil) { [weak self] (notification) in
            let isReload = notification.userInfo?["isReload"] as? Bool ?? true
            if isReload {
                self?.refreshAndSortView()
            } else {
                self?.tableViewDidTriggerHeaderRefresh()
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadCheckAndUpdate, object: nil, queue: nil) { [weak self] (notification) in
            /// 权限判断
            if let user = SW_UserCenter.shared.user, user.auth.backLogAuth.count > 0 {
                self?.backLog = 1
                self?.tableView.reloadData()
                self?.getBackLogCount()
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.BackLogCountUpdate, object: nil, queue: nil) { [weak self] (notification) in
            /// 权限判断
            if SW_UserCenter.shared.user!.auth.backLogAuth.count > 0 {
                self?.getBackLogCount()
            }
        }
    }
    
    func searchMessages(_ keyword: String = "") {
        var datas = [SW_ConversationModel]()
        
        if dataArray.count > 0, let dataArray = dataArray as? [SW_ConversationModel] {
            dataArray.forEach { (model) in
                if model.title.contains(keyword) || model.position.contains(keyword) {
                    datas.append(model)
                }
            }
        }
        searchDatas = []
        if !datas.isEmpty {
            searchDatas = sortData(datas)
            searchTableView.reloadData()
            searchTableView.setContentOffset(CGPoint.zero, animated: false)
            searchTableView.isHidden = false
            tap.isEnabled = false
        } else {
            tap.isEnabled = keyword.isEmpty
            searchTableView.isHidden = keyword.isEmpty
            if !keyword.isEmpty {
                searchTableView.ly_emptyView = searchEmptyView///
                searchTableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: -private methon
    @objc private func moreAction() {
        if popupAtBarButtonItem.isShowing() {
            popupAtBarButtonItem.hideWith(animated: true)
        } else {
            popupAtBarButtonItem.sourceView = searchBar.addBtn
//            popupAtBarButtonItem.layout(withTargetView: searchBar.addBtn)
            popupAtBarButtonItem.showWith(animated: true)
        }
    }
    
    @objc private func scanAction() {
        self.navigationController?.pushViewController(SW_CommonScanViewController(nil, titleString: "扫码"), animated: true)
    }
    
    /// 获取待办事项的个数并刷新
    private func getBackLogCount() {
        guard SW_UserCenter.shared.user!.auth.backLogAuth.count > 0 else {
            return
        }
        /// 去获取一次待办事项个数
        SWSLoginService.getBackLogCount().response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                SW_BadgeManager.shared.backLogModel = BackLogModel(json)
                if self.backLog == 1 {
                    NotificationCenter.default.post(name: NSNotification.Name.Ex.SetupUnreadMessageCount, object: nil)
                    self.tableView.reloadData()
                }
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
        })
    }
    
    //MARK: - data 处理 get  排序等
    /// 排序并刷新
    override func refreshAndSortView() {
        ////数量大于1才需要排序否则直接刷新显示即可
        if dataArray.count > 1, let datas = dataArray as? [SW_ConversationModel] {
            dataArray = NSMutableArray(array: sortData(datas))
        }
        safeReloadData()
    }
    
    private func safeReloadData() {
        if hadDidLoad {
            tableView.reloadData()
        }
    }
    
    /// 接收一个会话数组，按照规定排序后返回
    ///
    /// - Parameter datas: 需要排序的数组
    /// - Returns: 排序后的数组
    func sortData(_ datas: [SW_ConversationModel]) -> [SW_ConversationModel] {
        //后期看如何抽取出来 -- 先把置顶跟非置顶分开排序后再合并
        ///置顶的会话
       var topDatas = datas.filter({ return SW_TopConversationManager.isTopConversation($0.conversation.conversationId, chatType: $0.conversation.type) })
        topDatas = sortMsgs(topDatas)
        ///非置顶会话
        let normalDatas = datas.filter({ return !SW_TopConversationManager.isTopConversation($0.conversation.conversationId, chatType: $0.conversation.type) })
        topDatas.append(contentsOf: sortMsgs(normalDatas))
        return topDatas
    }
    
    /// 接收一个会话数组，按照规定排序后返回
    ///
    /// - Parameter datas: 需要排序的数组
    /// - Returns: 排序后的数组
    private func sortMsgs(_ msgs: [SW_ConversationModel]) -> [SW_ConversationModel] {
        return msgs.sorted { (obj1, obj2) -> Bool in
            if let msg1 = obj1.conversation.latestMessage, let msg2 = obj2.conversation.latestMessage {
                return msg1.timestamp > msg2.timestamp
            } else if (obj1.conversation.latestMessage) != nil {
                return true
            } else if (obj2.conversation.latestMessage) != nil {
                return false
            } else {
                return false
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        PrintLog("deinit")
    }
    
    /// 获取所有会话列表，然后请求获取头像与名称
    override func tableViewDidTriggerHeaderRefresh() {
        if isDelete {
            isDelete = false
            return
        }
        ///有添加置顶会话则默认创建会话
        SW_TopConversationManager.getAllTopConversations().forEach { (model) in
            self.creatingConversation = true
            EMClient.shared().chatManager.getConversation(model.conversationId, type: model.chatType, createIfNotExist: true)
        }
        
        guard var conversations = EMClient.shared().chatManager.getAllConversations() as? [EMConversation] , conversations.count > 0 else {///没有会话数据
            creatingConversation = false
            isFaildRequest = false
            dataArray = []
            safeReloadData()
            tableViewDidFinishTriggerHeader(true, reload: false)
            return
        }
        
        //将会话中的admin去除  公告会话为固定的会话
        conversations = conversations.filter({ return $0.conversationId != "admin" })
        
        //将会话中的空会话去除，置顶联系人则不去除----再考虑看看如何处理
//        conversations = conversations.filter({ return $0.latestMessage != nil || SW_TopConversationManager.isTopConversation($0.conversationId, chatType: $0.type) })
//        if conversations.count == dataArray.count {//如果数量没变、就不去请求接口，因为
//            creatingConversation = false
//            tableView.reloadData()
//            tableViewDidFinishTriggerHeader(true, reload: false)
//            return
//        }
        
        ////这里可以进行排序 --- 转换数据类型
        var datas = conversations.map({ return SW_ConversationModel(conversation: $0)! })
        ///数量大于1时才需要排序
        if datas.count > 1 {
            datas = sortData(datas)
        }
        
        //生成群组查询字符串
        let groupNumStr = conversations.filter({ return $0.type == EMConversationTypeGroupChat }).map({ return $0.conversationId! }).joined(separator: ",")
        //生成联系人查询字符串
        let huanxinNumStr = conversations.filter({ return $0.type == EMConversationTypeChat }).map({ return $0.conversationId! }).joined(separator: ",")
        
        SW_MessageService.getConversationList(groupNumStr, huanxinNumStr: huanxinNumStr).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.isFaildRequest = false
                DispatchQueue.global().async {
                    ///找到对应是群组修改基本数据
                    json["GroupInfoList"].arrayValue.forEach({ (infoJson) in
                        let groupId = infoJson["groupNum"].stringValue
                        guard !groupId.isEmpty else {
                            return
                        }
                        if let index = datas.firstIndex(where: { $0.conversation.conversationId == groupId && $0.conversation.type == EMConversationTypeGroupChat }) {
                            datas[index].setInfo(json: infoJson)
                        }
                    })
                    ///找到对应联系人修改基本数据
                    json["HuanxinUserList"].arrayValue.forEach({ (infoJson) in
                        let huanxinId = infoJson["huanxinNum"].stringValue
                        guard !huanxinId.isEmpty else {
                            return
                        }
                        if let index = datas.firstIndex(where: { $0.conversation.conversationId == huanxinId && $0.conversation.type == EMConversationTypeChat }) {
                            ///这里讲联系人的基本数据进行了存储，可以不要，有的话头像昵称更准确 --不要了，因为会话多时存数据耗时较大-影响性能
                            datas[index].setInfo(json: infoJson)
                        }
                    })
                    //这里的排序放在前面进行，暂时屏蔽
//                datas = self.sortData(datas)
                    
                    self.dataArray =  NSMutableArray(array: datas)
                    
                    self.creatingConversation = false
                    dispatch_async_main_safe {
                        self.safeReloadData()
                        self.tableViewDidFinishTriggerHeader(true, reload: false)
                    }
                }
            } else {
                self.isFaildRequest = true
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
    }
    
    private func setCellModel(cell: EaseConversationCell, model: SW_ConversationModel) {
        cell.model = model
        //最后一条内容显示
        cell.isTop = SW_TopConversationManager.isTopConversation(model.conversation.conversationId, chatType: model.conversation.type)
        //            cell.detailLabel.attributedText =  attributedText;
        cell.isForbidden = !model.groupState
        if let lastMsg = model.conversation.latestMessage {//时间lable
            cell.timeLabel.text = Date.dateWith(timeInterval: TimeInterval(lastMsg.timestamp)).messageContentTimeString()//[_dataSource conversationListViewController:self latestMessageTimeForConversationModel:model];//最后的时间
            
            var detailText = SW_SearchMessageCell.messageTitleForMessageModel(message: lastMsg)
            if lastMsg.chatType == EMChatTypeGroupChat,
                let user = UserCacheManager.getUserInfo(lastMsg.from) {//如果是群聊，添加消息发送者昵称
                detailText = user.nickName + "：" + detailText
            }
            cell.detailLabel.text = detailText
        } else {
            cell.timeLabel.text = ""
            cell.detailLabel.text = ""
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

//MARK: -  UITableViewDelegate, UITableViewDataSource
extension SW_MessageViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchTableView {
            return searchDatas.count
        }
        return dataArray.count + 1 + backLog
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == searchTableView {
            if searchDatas.count > indexPath.row {
                let cell = tableView.dequeueReusableCell(withIdentifier: EaseConversationCell.cellIdentifier(withModel: nil), for: indexPath) as! EaseConversationCell
                let model = searchDatas[indexPath.row]
                setCellModel(cell: cell, model: model)
                return cell
            }
        } else {
            if indexPath.row < 1 + backLog {//1个固定的会话 内部公告
                let cell = tableView.dequeueReusableCell(withIdentifier: SWInformMessageCell.cellIdentifier(), for: indexPath) as! SWInformMessageCell
                if backLog == 1, indexPath.row == 1 {
                    cell.titleLabel.text = "待办事项"
                    cell.avatarView.imageView.image = UIImage(named: "announcement_icon_todo")
                    cell.titleShowCenter(true)
                    if SW_BadgeManager.shared.backLogModel.totalCount > 0 {
                        cell.avatarView.showBadge = true
                        cell.avatarView.badge = SW_BadgeManager.shared.backLogModel.totalCount
                    } else {
                        cell.avatarView.showBadge = false
                    }
                } else {
                    cell.titleLabel.text = "内部公告"
                    cell.avatarView.imageView.image = UIImage(named: "announcement_icon")
                    //获取最新的一条公告显示内容
                    if let inform = SW_DefaultConversations.getAllLastInformMsg() {
                        cell.titleShowCenter(false)
                        cell.detailLabel.text = inform.content
                        cell.timeLabel.text = Date.dateWith(timeInterval: TimeInterval(inform.timestamp)).messageContentTimeString()
                    } else {///空公告无内容
                        cell.titleShowCenter(true)
                    }
                    let unreadCount = SW_DefaultConversations.getAllInformUnreadCount()
                    if unreadCount > 0 {
                        cell.avatarView.showBadge = true
                        cell.avatarView.badge = unreadCount
                    } else {
                        cell.avatarView.showBadge = false
                    }
                }
                return cell
            } else if dataArray.count > indexPath.row - 1 - backLog {//对话
                let cell = tableView.dequeueReusableCell(withIdentifier: EaseConversationCell.cellIdentifier(withModel: nil), for: indexPath) as! EaseConversationCell
                let model = dataArray[indexPath.row - 1 - backLog] as! SW_ConversationModel
                setCellModel(cell: cell, model: model)
                return cell
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == searchTableView {
            if searchDatas.count > indexPath.row {
                let model = searchDatas[indexPath.row]
                if !model.groupState {
                    showAlertMessage("该工作群已被停用，不能聊天", MYWINDOW)
                    return
                }
                let vc = SW_ChatViewController(conversationChatter: model.conversation.conversationId, conversationType: model.conversation.type)
                vc?.title = model.title + model.position
                vc?.regionStr = model.regionStr
                self.navigationController?.pushViewController(vc!, animated: true)
                NotificationCenter.default.post(name: NSNotification.Name.Ex.SetupUnreadMessageCount, object: nil)
            }
        } else {
            if indexPath.row < 1 + backLog {///点击公告cell 或待办事项
                if backLog == 1, indexPath.row == 1 {
                    navigationController?.pushViewController(SW_BackLogManagerViewController(), animated: true)
                } else {
                    SW_DefaultConversations.clearAllInformUnreadCount()
                    if let vc = UIStoryboard(name: "Message", bundle: nil).instantiateViewController(withIdentifier: "SW_AllInformMessageViewController") as? SW_AllInformMessageViewController {
                        navigationController?.pushViewController(vc, animated: true)
                    }
                }
            } else if dataArray.count > indexPath.row - 1 - backLog {//点击会话进入聊天
                let model = dataArray[indexPath.row - 1 - backLog] as! SW_ConversationModel
                if !model.groupState {
                    showAlertMessage("该工作群已被停用，不能聊天", MYWINDOW)
                    return
                }
                let vc = SW_ChatViewController(conversationChatter: model.conversation.conversationId, conversationType: model.conversation.type)
                vc?.title = model.title + model.position
                vc?.regionStr = model.regionStr
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            NotificationCenter.default.post(name: NSNotification.Name.Ex.SetupUnreadMessageCount, object: nil)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView == searchTableView {
            return false
        }
        return indexPath.row >= 1 + backLog
    }
    
    override func deleteCellAction(_ aIndexPath: IndexPath!) {
        let model = dataArray[aIndexPath.row - 1 - backLog] as! SW_ConversationModel
        SW_TopConversationManager.removeTopConversation(model.conversation.conversationId, chatType: model.conversation.type)
        isDelete = true
        super.deleteCellAction(IndexPath(row: aIndexPath.row - 1 - backLog, section: aIndexPath.section))
        safeReloadData()
    }
}










