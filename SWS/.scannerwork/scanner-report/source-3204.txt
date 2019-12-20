//
//  SW_SearchChatRecordsViewController.swift
//  SWS
//
//  Created by jayway on 2018/6/19.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_SearchChatRecordsViewController: SW_TableViewController {

    ///搜索出来的聊天记录数组
    private var searchMsgs = [EMMessage]() {
        didSet {
            if searchMsgs.count == 0 {
                let tipInfo = getSearchNoDataTipString(searchKey, module: "聊天记录")
                noDataLabel.frame = tipInfo.1
                noDataLabel.attributedText = tipInfo.0
            }
        }
    }
    
    private var searchBar = SW_SearchBar()
    
    private var conversation: EMConversation!
    
    private var searchKey = ""
    
    private var isShowSearchKey = true
    
    private var noDataLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        return lb
    }()
    
    var chatTitle = ""
    var regionStr = ""
    
    private var normalBgView: SW_SearchChatRecordsBgView = {
        let bgView = Bundle.main.loadNibNamed("SW_SearchChatRecordsBgView", owner: nil, options: nil)?.first as! SW_SearchChatRecordsBgView
        return bgView
    }()
    
    init(_ conversation: EMConversation) {
        super.init(nibName: nil, bundle: nil)
        self.conversation = conversation
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildView()
        requsetData("")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    deinit {
        PrintLog("SW_SearchChatRecordsViewController deinit")
    }
    
    //MARK: -设置子控件
    private func setupChildView() -> Void {
        let navBackGround = UIView()
        view.addSubview(navBackGround)
        navBackGround.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(NAV_HEAD_INTERVAL+64)
        }
        
        navBackGround.addSubview(searchBar)
        searchBar.searchField.placeholder = InternationStr("搜索聊天记录")
        searchBar.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(64)
        }
        searchBar.maxCount = 100
        ///搜索取消按钮点击
        searchBar.cancelBlock = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        ///搜索按钮点击
        searchBar.searchBlock = { [weak self] in
            if let keyWord = self?.searchBar.searchField.text {
                self?.requsetData(keyWord)
            }
        }
        ///输入框内容改变
        searchBar.searchMessageBlock = { [weak self] (keyWord) in
            if keyWord?.isEmpty == true {
                self?.searchKey = ""
                self?.requsetData("")
            } else {
                self?.searchKey = keyWord ?? ""
                self?.isShowSearchKey = true
                self?.tableView.isHidden = false
                self?.normalBgView.isHidden = true
                self?.tableView.reloadData()
            }
        }
        tableView.backgroundColor = .white
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
//        tableView.separatorInset = UIEdgeInsets.zero
//        tableView.separatorColor = UIColor.mainColor.separator
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 79
        
        
        let emptyView = LYEmptyView.emptyView(withCustomView: noDataLabel)
        emptyView?.contentViewY = 20
        tableView.ly_emptyView = emptyView
        
        
        tableView.registerNib(SW_SearchMessageCell.self, forCellReuseIdentifier: "SW_SearchMessageCellID")
        tableView.registerNib(SW_SearchKeyCell.self, forCellReuseIdentifier: "SW_SearchKeyCellID")
        tableView.snp.remakeConstraints { (make) in
            make.top.equalTo(navBackGround.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        normalBgView.dateClickBlock = { [weak self] in
            if let self = self {
                let vc = SW_SelectSearchDateViewController(self.conversation)
                vc.chatTitle = self.chatTitle
                vc.regionStr = self.regionStr
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        normalBgView.picClickBlock = { [weak self] in
            if let self = self {
                self.navigationController?.pushViewController(SW_SearchChatPicViewController(self.conversation), animated: true)
            }
        }
        view.addSubview(normalBgView)
        normalBgView.snp.makeConstraints { (make) in
            make.edges.equalTo(tableView.snp.edges)
        }
        ScrollToTopButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), scrollView: tableView)
        tableView.isHidden = true
        normalBgView.isHidden = false
    }
    
    //    获取当前页面显示数据   后期可能需要添加缓存
    private func requsetData(_ keyWord: String) {
        ///搜索框有输入时
        if keyWord.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty == false {
            ///相同关键字不去搜索
//            guard keyWord != searchKey else { return }
            //点击搜索时先清空旧数据
            searchMsgs.removeAll()
            //查找数据库
            conversation.loadMessages(withKeyword: keyWord, timestamp: -1, count: 9999, fromUser: nil, searchDirection: EMMessageSearchDirectionUp) { (message, error) in
                self.searchKey = keyWord
                self.searchMsgs = message as? [EMMessage] ?? []
                self.isShowSearchKey = false
                self.tableView.isHidden = false
                self.normalBgView.isHidden = true
                self.tableView.reloadData()
            }
        } else {
            ///搜索框无输入时或者被情空时
            //点击搜索时先清空旧数据
            searchMsgs.removeAll()
            tableView.isHidden = true
            normalBgView.isHidden = false
            tableView.reloadData()
        }
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShowSearchKey {
            return 1
        }
        return searchMsgs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isShowSearchKey {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SW_SearchKeyCellID", for: indexPath) as! SW_SearchKeyCell
            cell.keyWord = searchKey
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SW_SearchMessageCellID", for: indexPath) as! SW_SearchMessageCell
            let msg = searchMsgs[indexPath.row]
            cell.keyWord = searchKey
            cell.message = msg
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude//30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView.init()
//        let view = SectionHeaderView(frame: CGRect(x: 0, y: 0, width: 1, height: 30))
//        view.backgroundColor = UIColor.white
//        view.title = "共\(searchMsgs.count)条与“\(searchKey)”相关的聊天记录"
//        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isShowSearchKey {
            requsetData(searchKey)
            view.endEditing(true)
        } else {
            /// 点击定位到消息
            guard searchMsgs.count > indexPath.row else { return }
//            if SW_UserCenter.shared.user!.huanxin.huanxinAccount.isEmpty {
//                SW_UserCenter.shared.showAlert(message: "请联系管理员")
//                return
//            } else {
//                SW_UserCenter.loginHuanXin()
//            }
            guard let vc = SW_ChatViewController(conversation: conversation, message: searchMsgs[indexPath.row]) else { return }
            vc.title = chatTitle
            vc.regionStr = regionStr
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 79
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
}
