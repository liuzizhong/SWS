//
//  SW_StaffWorkReportListViewController.swift
//  SWS
//
//  Created by jayway on 2019/1/18.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_StaffWorkReportListViewController: SW_TableViewController {
    
    private var staffId = 0
    
    private var realName = ""
    
    private var type = WorkReportType.day
    
    private var SW_WorkReportListCellID = "SW_WorkReportListCellID"
    
    /// 未审阅的工作报告列表
    private var reportDatas = [SW_WorkReportListModel]()
    
    //最后点击的位置，编辑或查看时不用遍历去找对应的项再修改，直接使用该index进行操作。
    private var lastIndexPath = IndexPath(row: 0, section: 0)

    private var isRequesting = false
    
    var keyWord = "" {
        didSet {
            if keyWord != oldValue {//当keyword不同时请求
                requsertreportDatas(keyWord)
            }
        }
    }
    
    init(_ type: WorkReportType, staffId: Int, realName: String) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
        self.staffId = staffId
        self.realName = realName
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        requsertreportDatas(keyWord)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup() {
        //无权限看报告，删除报告
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserCantLookWorkReport, object: nil, queue: nil) { [weak self] (notifa) in
            guard let sSelf = self else { return }
            let type = notifa.userInfo?["workReportType"] as! WorkReportType
            if sSelf.type == type {//对应type列表刷新对应项
//                SW_BadgeManager.shared.getBadgeState()
                sSelf.reportDatas.remove(at: sSelf.lastIndexPath.row)
                sSelf.tableView.reloadData()
            }
        }
        navigationItem.title = "\(realName)的\(type.rawTitle)"
        
        tableView.registerNib(SW_WorkReportListCell.self, forCellReuseIdentifier: SW_WorkReportListCellID)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL, right: 0)
        tableView.keyboardDismissMode = .onDrag
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        
        ScrollToTopButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), scrollView: tableView as UIScrollView)
        glt_scrollView = tableView
        
        tableView.mj_header = SW_RefreshHeader.init(refreshingBlock: { [weak self] in
//            SW_BadgeManager.shared.getBadgeState()
            self?.requsertreportDatas(self?.keyWord ?? "")
        })
    }
    
    /// 请求员工已审阅工作报告
    private func requsertreportDatas(_ keyword: String, byAppend: Bool = false) {
        guard !isRequesting else { return }
        isRequesting = true
        let offSet = byAppend ? reportDatas.count : 0
        //因为排序问题，分页处理较麻烦，暂时不做分页，一次性获取所有数据，数据量大时可能要考虑异步处理数据。
        SW_WorkingService.getReceiveReportList(type, keyWord: keyword, offset: offSet, reporterId: staffId, isCheck: 0).response({ (json, isCache, error) in
            self.isRequesting = false
            self.tableView.mj_header.endRefreshing()
            if let json = json as? JSON, error == nil {
                //                DispatchQueue.global().async {//异步处理数据,因为工作日志长期下来数据量会较大
                if byAppend {
                    self.reportDatas.append(contentsOf: json["list"].arrayValue.map({ (value) -> SW_WorkReportListModel in
                        return SW_WorkReportListModel(self.type, ownerType: .received, json: value)
                    }))
                } else {
                    self.reportDatas = json["list"].arrayValue.map({ (value) -> SW_WorkReportListModel in
                        return SW_WorkReportListModel(self.type, ownerType: .received, json: value)
                    })
                }
                self.tableView.reloadSection(0, with: UITableView.RowAnimation.automatic)
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
    }
    
    deinit {
        PrintLog("deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportDatas.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SW_WorkReportListCellID, for: indexPath) as! SW_WorkReportListCell
        cell.reportModel = reportDatas[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        lastIndexPath = indexPath
        let vc =  SW_WorkReportDetailViewController(reportDatas[indexPath.row].id, type: type, ownerType: .received)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
