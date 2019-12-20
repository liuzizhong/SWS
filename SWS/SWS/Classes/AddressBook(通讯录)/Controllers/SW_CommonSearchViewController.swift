//
//  SW_CommonSearchViewController.swift
//  SWS
//
//  Created by jayway on 2018/5/30.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_CommonSearchViewController: SW_TableViewController {
    ///放员工数组 和 群组数组
    var allDatas = [Array<Any>]()

    private var searchBar = SW_SearchBar()
    
//    private var normalBgView: SW_SearchNormalBgView = {
//        let bgView = Bundle.main.loadNibNamed("SW_SearchNormalBgView", owner: nil, options: nil)?.first as! SW_SearchNormalBgView
//        return bgView
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildView()
        requsetData("")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        //        tableView.reloadData()
    }

    deinit {
        PrintLog("searchviewcongtroller deinit")
    }

    //MARK: -设置子控件
    private func setupChildView() -> Void {
        let navBackGround = UIView()
        view.addSubview(navBackGround)
        navBackGround.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(NAV_TOTAL_HEIGHT)
        }
        
        
        navBackGround.addSubview(searchBar)
        searchBar.searchField.placeholder = InternationStr("搜索联系人和群组")
        searchBar.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
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
                self?.requsetData("")
            }
        }
        
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.separatorColor = UIColor.mainColor.separator
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 79
        automaticallyAdjustsScrollViewInsets = false

        let emptyView = LYEmptyView.empty(withImageStr: "", titleStr: "抱歉，没有找到相关内容", detailStr: "")
        emptyView?.titleLabTextColor = UIColor.mainColor.lightGray
        emptyView?.contentViewOffset = -100
        tableView.ly_emptyView = emptyView
        
        tableView.registerNib(SW_AddressBookMainCell.self, forCellReuseIdentifier: "SW_AddressBookMainCellSearchID")
        tableView.snp.remakeConstraints { (make) in
            make.top.equalTo(navBackGround.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
//        view.addSubview(normalBgView)
//        normalBgView.snp.makeConstraints { (make) in
//            make.edges.equalTo(tableView.snp.edges)
//        }
        
        tableView.isHidden = true
//        normalBgView.isHidden = false
    }

    //    获取当前页面显示数据   后期可能需要添加缓存
    private func requsetData(_ keyWord: String) {
        allDatas = [Array<Any>]()//点击搜索时先清空旧数据
        ///搜索框有输入时
        if keyWord.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty == false {
            SW_GroupService.getStaffAndGroupList(keyWord, staffId: SW_UserCenter.shared.user!.id).response({ (json, isCache, error) in
                if let json = json as? JSON, error == nil {
                    if !json["staffList"].arrayValue.isEmpty {
                        self.allDatas.append(json["staffList"].arrayValue.map({ (staffJson) -> SW_AddressBookModel in
                            return SW_AddressBookModel(staffJson: staffJson)
                        }))
                    }
                    
                    if !json["groupList"].arrayValue.isEmpty {
                        self.allDatas.append(json["groupList"].arrayValue.map({ (json) -> SW_GroupModel in
                            return SW_GroupModel(json)
                        }))
                    }
                    self.tableView.isHidden = false
//                    self.normalBgView.isHidden = true
                    self.tableView.reloadData()
                    
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
                }
            })
        } else {
            ///搜索框无输入时或者被情空时

            tableView.isHidden = true
//            normalBgView.isHidden = false
            tableView.reloadData()
        }
        
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return  allDatas.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard allDatas.count > section else { return 0 }
        return allDatas[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SW_AddressBookMainCellSearchID", for: indexPath) as! SW_AddressBookMainCell
        guard allDatas.count > indexPath.section else { return cell }
        guard allDatas[indexPath.section].count > indexPath.row else { return cell }
        if let model = allDatas[indexPath.section][indexPath.row] as? SW_AddressBookModel {
            cell.model = model
            cell.staffDeatil.text = model.regionName
            cell.groupModel = nil
        }
        if let model = allDatas[indexPath.section][indexPath.row] as? SW_GroupModel {
            cell.model = nil
            cell.groupModel = model
        }
        return cell
    }


    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 79
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 26
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SectionHeaderView(frame: CGRect(x: 0, y: 0, width: 1, height: 26))
        guard allDatas.count > section else { return view }
        guard allDatas[section].count > 0 else { return view }
        if  allDatas[section][0] is SW_AddressBookModel {
            view.title = "联系人"
        }
        if  allDatas[section][0] is SW_GroupModel {
            view.title = "工作群"
        }
        return view
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard allDatas.count > indexPath.section else { return }
        guard allDatas[indexPath.section].count > indexPath.row else { return }
        if let model = allDatas[indexPath.section][indexPath.row] as? SW_AddressBookModel {
            let vc = SW_StaffInfoViewController(model.id)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if let model = allDatas[indexPath.section][indexPath.row] as? SW_GroupModel {
            let vc = SW_ChatViewController(conversationChatter: model.groupNum, conversationType: EMConversationTypeGroupChat)
            vc?.title = model.groupName
            self.navigationController?.pushViewController(vc!, animated: true)
        }
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
