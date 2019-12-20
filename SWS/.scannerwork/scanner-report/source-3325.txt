//
//  SW_WorkReportListViewController.swift
//  SWS
//
//  Created by jayway on 2018/7/5.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_WorkReportListViewController: SW_TableViewController {
    
    private var type = WorkReportType.day
    
    private var SW_WorkReportListCellID = "SW_WorkReportListCellID"
    
    /// 现在出来的数据 搜索的直接放这里面
    private var reportDatas = [SW_WorkReportListModel]()
    //最后点击的位置，编辑或查看时不用遍历去找对应的项再修改，直接使用该index进行操作。
    private var lastIndexPath = IndexPath(row: 0, section: 0)
    
    private var isRequesting = false
    
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
    
    init(_ type: WorkReportType) {
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
        /// 写了一篇报告
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadCreatWorkReport, object: nil, queue: nil) { [weak self] (notifa) in
            let type = notifa.userInfo?["workReportType"] as! WorkReportType
            if self?.type == type {
                self?.requsertreportDatas(self?.keyWord ?? "")
            }
        }
        //编辑，找到对应的item再刷新对应项，不重新get列表
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadEditWorkReport, object: nil, queue: nil) { [weak self] (notifa) in
            guard let sSelf = self else { return }
            let type = notifa.userInfo?["workReportType"] as! WorkReportType
            if sSelf.type == type {//对应type列表刷新对应项
                sSelf.reportDatas[sSelf.lastIndexPath.row].title = notifa.userInfo?["title"] as! String
                sSelf.reportDatas[sSelf.lastIndexPath.row].content = notifa.userInfo?["content"] as! String
                sSelf.reportDatas[sSelf.lastIndexPath.row].receiverTotal = notifa.userInfo?["receiverTotal"] as! Int
                sSelf.tableView.reloadRows(at: [sSelf.lastIndexPath], with: .automatic)
            }
        }
        //用户查看了自己发的报告详情的通知，如果第一次看则消除红点
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadLookMineWorkReport, object: nil, queue: nil) { [weak self] (notifa) in
            guard let sSelf = self else { return }
            let type = notifa.userInfo?["workReportType"] as! WorkReportType
            if sSelf.type == type {//对应type列表刷新对应项
                if sSelf.reportDatas[sSelf.lastIndexPath.row].isNewCheck {
                    SW_BadgeManager.shared.getBadgeState()
                    sSelf.reportDatas[sSelf.lastIndexPath.row].isNewCheck = false
                    sSelf.tableView.reloadRows(at: [sSelf.lastIndexPath], with: .automatic)
                }
            }
        }
        
        ScrollToTopButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), scrollView: tableView as UIScrollView)
        glt_scrollView = tableView
        
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
        tableView.ly_emptyView = SW_LoadingEmptyView.creat()
        tableView.ly_emptyView.contentViewOffset = -(SCREEN_HEIGHT - 250) * 0.2
        ///上拉加载更多
//        tableView.mj_footer = MJRefreshBackNormalFooter.init { [weak self] in
//            self?.requsertreportDatas(self?.keyWord ?? "", byAppend: true)
//            self?.tableView.mj_footer.endRefreshing()
//        }
//
        tableView.mj_header = SW_RefreshHeader.init(refreshingBlock: { [weak self] in
//            SW_BadgeManager.shared.getBadgeState()
            self?.requsertreportDatas(self?.keyWord ?? "")
        })
    }
    
    func requsertreportDatas(_ keyword: String, byAppend: Bool = false) {
        guard !isRequesting else { return }
        isRequesting = true
        let offSet = byAppend ? reportDatas.count : 0
        //因为排序问题，分页处理较麻烦，暂时不做分页，一次性获取所有数据，数据量大时可能要考虑异步处理数据。
        SW_WorkingService.getMineReportList(type, keyWord: keyword, offset: offSet).response({ (json, isCache, error) in
            self.isRequesting = false
            self.tableView.mj_header.endRefreshing()
            self.emptyView.contentViewOffset = -(self.tableView.height - 250) * 0.2
            self.tableView.ly_emptyView = self.emptyView
            if let json = json as? JSON, error == nil {
//                DispatchQueue.global().async {//异步处理数据,因为工作日志长期下来数据量会较大
                    if byAppend {
                        self.reportDatas.append(contentsOf: json["list"].arrayValue.map({ (value) -> SW_WorkReportListModel in
                            return SW_WorkReportListModel(self.type, ownerType: .mine, json: value)
                        }))
                    } else {
                        self.reportDatas = json["list"].arrayValue.map({ (value) -> SW_WorkReportListModel in
                            return SW_WorkReportListModel(self.type, ownerType: .mine, json: value)
                        })
                    }
//                    dispatch_async_main_safe {
                        self.tableView.reloadData()
//                    }
//                }
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
        let vc =  SW_WorkReportDetailViewController(reportDatas[indexPath.row].id, type: type, ownerType: .mine)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
}
