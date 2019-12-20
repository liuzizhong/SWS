//
//  SW_RangeListViewController.swift
//  SWS
//
//  Created by jayway on 2018/5/7.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

typealias RangeChangeBlock = ()->Void

enum RangeListType {
    case group//群组选人列表
    case inform//公告选人列表
}

class SW_RangeListViewController: UIViewController {

    private let rangeCellId = "sw_rangeCellId"
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.registerNib(SW_RangeCell.self, forCellReuseIdentifier: self.rangeCellId)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.white
        return tableView
    }()
    //选择的范围发生改变时的Block
    var rangeChangeBlock: RangeChangeBlock?
    
    var rangeManager: SW_RangeManager!
    // 上级选择的IDs
    var idStr = ""
    // 当前列表显示的数据范围
    fileprivate var type = RangeType.region
    
    private var listType = RangeListType.inform
    
    private var groupNum: String?
    
    fileprivate var currentList = [SW_RangeModel]()
    
    init(_ rangeType: RangeType, selectIds: String = "", manager: SW_RangeManager, listType: RangeListType, groupNum: String?) {
        super.init(nibName: nil, bundle: nil)
        self.type = rangeType
        self.idStr = selectIds
        self.rangeManager = manager
        self.listType = listType
        self.groupNum = groupNum
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
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
        
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    /// 获取当前页面的数据
    ///
    /// - Parameter append: true 加载更多    false ： 重新获取数据
    func getListAndReload() {
        var requset : SWSRequest
        switch listType {
        case .group:
            requset = SW_RangeService.getAddGroupMemberList(type.rawValue, GroupNum: groupNum, staffId: SW_UserCenter.shared.user!.id, idStr: idStr)
        case .inform:
            requset = SW_RangeService.getSendMessageList(type.rawValue, staffId: SW_UserCenter.shared.user!.id, idStr: idStr)
        }
        requset.response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.currentList = json["list"].arrayValue.map({ (value) -> SW_RangeModel in
                    return SW_RangeModel(value, type: self.type)
                })
                //                PrintLog(self.currentList)
                self.rangeChangeBlock?()
                self.tableView.reloadData()
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
    }
    
    func selectAllBtnClick(isSelect: Bool) {
        //进行全选 不选后、
        if isSelect {
            rangeManager.setSelectRangesAll(type: type, models: currentList)
        } else {
            rangeManager.removeSelectRanges(type: type)
        }
        rangeChangeBlock?()
        tableView.reloadData()
    }

    func isSelectAll() -> Bool {
        return rangeManager.isSelectRangesAll(type: type, models: currentList)
    }
    
    func clearCurrentList() {
        currentList = [SW_RangeModel]()
        tableView.reloadData()
    }
}

extension SW_RangeListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: rangeCellId, for: indexPath) as! SW_RangeCell
        cell.rangeModel = currentList[indexPath.row]
        cell.isSelect = rangeManager.isSelectRange(model: currentList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = currentList[indexPath.row]
        if rangeManager.isSelectRange(model: model) {
            rangeManager.removeSelectRange(model: model)
//            PrintLog("remove")
        } else {
            rangeManager.setSelectRange(model: model)
//            PrintLog("add")
        }
        rangeChangeBlock?()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if type == .region || type == .business {
            return 54
        }
        return 79
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       return nil
    }
    
    
}
