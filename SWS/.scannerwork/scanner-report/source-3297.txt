//
//  SW_RevenueListViewController.swift
//  SWS
//
//  Created by jayway on 2018/6/21.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_RevenueListViewController: SW_TableViewController {
    
    private var type = RevenueReportType.dayOrder
    
    private var SW_RevenueReportListCellID = "SW_RevenueReportListCellID"
    
    /// 现在出来的数据 搜索的直接放这里面
    private var reportDatas = [SW_RevenueReportModel]()
    
    private var lastIndexPath = IndexPath(row: 0, section: 0)
    
    private lazy var emptyView: LYEmptyView = {
        return SW_NoDataEmptyView.creat()
    }()
    
    var keyWord = "" {
        didSet {
            if keyWord != oldValue {//当keyword不同时请求
                requsertreportDatas(keyWord)
            }
        }
    }
    
    init(_ type: RevenueReportType) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup() {
        //创建报表，直接重新get列表
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadCreatRevenueReport, object: nil, queue: nil) { [weak self] (notifa) in
            let type = notifa.userInfo?["revenueReportType"] as! RevenueReportType
            if self?.type == type {
                self?.requsertreportDatas(self?.keyWord ?? "")
            }
        }
        //编辑，找到对应的item再刷新对应项，不重新get列表
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadEditRevenueReport, object: nil, queue: nil) { [weak self] (notifa) in
            guard let sSelf = self else { return }
            let type = notifa.userInfo?["revenueReportType"] as! RevenueReportType
            if sSelf.type == type {//对应type列表刷新对应项
                sSelf.reportDatas[sSelf.lastIndexPath.row].fromDeptName = notifa.userInfo?["fromDeptName"] as! String
                sSelf.reportDatas[sSelf.lastIndexPath.row].reportNo = notifa.userInfo?["reportNo"] as! String
                sSelf.reportDatas[sSelf.lastIndexPath.row].reportDate = notifa.userInfo?["reportDate"] as! TimeInterval
                sSelf.tableView.reloadRows(at: [sSelf.lastIndexPath], with: .automatic)
            }
        }
        
        tableView.registerNib(SW_RevenueReportListCell.self, forCellReuseIdentifier: SW_RevenueReportListCellID)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL, right: 0)
        tableView.estimatedRowHeight = 130
        tableView.keyboardDismissMode = .onDrag
        ///上拉加载更多
        tableView.mj_footer = MJRefreshBackNormalFooter.init { [weak self] in
            self?.requsertreportDatas(self?.keyWord ?? "", byAppend: true)
            self?.tableView.mj_footer.endRefreshing()
        }
    }
    
    func requsertreportDatas(_ keyword: String, byAppend: Bool = false) {
        let offSet = byAppend ? reportDatas.count : 0
        
        var request: SWSRequest!
        if type == .dayOrder {
            request = SW_WorkingService.getSaleOrderList(keyWord: keyword, offset: offSet)
        } else {
            request = SW_WorkingService.getFlowSheetList(flowDateType: type.rawValue, keyWord: keyword, offset: offSet)
        }
        request.response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                if byAppend {
                    self.reportDatas.append(contentsOf: json["list"].arrayValue.map({ (value) -> SW_RevenueReportModel in
                        return SW_RevenueReportModel(self.type, json: value)
                    }))
                } else {
                    self.reportDatas = json["list"].arrayValue.map({ (value) -> SW_RevenueReportModel in
                        return SW_RevenueReportModel(self.type, json: value)
                    })
                    self.tableView.setContentOffset(CGPoint.zero, animated: false)
                }
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
            self.tableView.ly_emptyView = self.emptyView
            self.tableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: SW_RevenueReportListCellID, for: indexPath) as! SW_RevenueReportListCell
        cell.reportModel = reportDatas[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        lastIndexPath = indexPath
        let vc =  SW_RevenueDetailViewController(reportDatas[indexPath.row].id, type: type)
        getTopVC().navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch type {
        case .dayOrder: fallthrough
        case .dayNonOrder:
            return 130
        default:
            return 103
        }
    }
}
