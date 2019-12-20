//
//  SW_DeleteGroupMemberViewController.swift
//  SWS
//
//  Created by jayway on 2018/5/24.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_DeleteGroupMemberViewController: UIViewController {

    private let rangeCellId = "sw_rangeCellId"

    private lazy var emptyView: LYEmptyView = {
        return SW_NoDataEmptyView.creat()
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
//        if #available(iOS 11.0, *) {
//            tableView.contentInsetAdjustmentBehavior = .never
//        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.registerNib(SW_RangeCell.self, forCellReuseIdentifier: self.rangeCellId)
        let view = BigTitleSectionHeaderView(frame: CGRect(x: 0, y: 0, width: 1, height: 70))
        view.title = "删除群成员"
        tableView.tableHeaderView = view
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.white
        return tableView
    }()

    private var groupNum: String = ""
    private var isRequesting = false
    private var currentList = [SW_RangeModel]()
    private var selectList = [SW_RangeModel]()

    init(_ groupNum: String) {
        super.init(nibName: nil, bundle: nil)
        self.groupNum = groupNum
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getListAndReload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func setupView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        ScrollToTopButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), scrollView: tableView)
    }

    deinit {
        PrintLog("abcdfgr deinit")
    }

    /// 获取当前页面的数据
    ///
    /// - Parameter
    private func getListAndReload() {
        SW_GroupService.getGroupMemberList(groupNum, max: 99999, offset: 0, type: 1).response({ (json, isCache, error) in
            self.tableView.ly_emptyView = self.emptyView
            if let json = json as? JSON, error == nil {
                self.currentList = json.arrayValue.map({ return SW_RangeModel($0, type: .staff) })
                self.checkDelBtnState()
                self.tableView.reloadData()
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
    }
    
    /// 删除群成员事件
    ///
    /// - Parameter sender: 右边按钮
    @objc private func deleteGroupMembersAction(_ sender: UIBarButtonItem) {
        guard selectList.count > 0 else {
            showAlertMessage("请选择要删除的群成员", self.view)
            return
        }
        alertControllerShow(title: "确认删除选中的群成员?", message: nil, rightTitle: "删 除", rightBlock: { (_, _) in
            self.delAction()
        }, leftTitle: "取 消", leftBlock: nil)
        
    }
    
    private func delAction() {
        guard !isRequesting else { return }
        isRequesting = true
        QMUITips.showLoading("正在删除", in: self.view)
        let delList = selectList
        SW_GroupService.delGroupMember(groupNum, staffIds: getSelectIdString()).response({ (json, isCache, error) in
            QMUITips.hideAllTips(in: self.view)
            if let _ = json as? JSON, error == nil {
                showAlertMessage("删除群成员成功", self.view)
               
                NotificationCenter.default.post(name: Notification.Name.Ex.GroupMembersHadChange, object: nil, userInfo: ["isAdd": false,"count": delList.count])
                
                delList.forEach({ (model) in
                    if let index = self.currentList.index(where: { return $0.id == model.id }) {
                        self.currentList.remove(at: index)
                    }
                })
                self.selectList.removeAll()
                self.checkDelBtnState()
                self.tableView.reloadData()
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
            self.isRequesting = false
        })
    }
    
    private func checkDelBtnState() {
        if currentList.count > 0 {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "删除", style: .plain, target: self, action: #selector(deleteGroupMembersAction(_:)))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    //获取选中要删除成员的idString
    private func getSelectIdString() -> String {
        return selectList.map({ return "\($0.id)" }).joined(separator: "_")
    }
    
    /// 判断是否选择了该成员
    ///
    /// - Parameter model: 判断的目标成员
    /// - Returns: true 已经选择
    private func isSelectPeople(model: SW_RangeModel) -> Bool {
        return selectList.contains(where: { return $0.id == model.id })
    }
    
    private func removeSelectPeople(model: SW_RangeModel) {
        if let index = selectList.index(where: { return $0.id == model.id }) {
            selectList.remove(at: index)
        }
    }
}

extension SW_DeleteGroupMemberViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rangeCellId, for: indexPath) as! SW_RangeCell
        cell.rangeModel = currentList[indexPath.row]
        cell.isSelect = isSelectPeople(model: currentList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = currentList[indexPath.row]
        if isSelectPeople(model: model) {
            removeSelectPeople(model: model)
        } else {
            selectList.append(model)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 79
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    
}

