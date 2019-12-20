//
//  SW_ReceiveWorkReportListViewController.swift
//  SWS
//
//  Created by jayway on 2019/1/17.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_ReceiveWorkReportListViewController: SW_TableViewController {
    
    private var type = WorkReportType.day
    
    private var SW_WorkReportListCellID = "SW_WorkReportListCellID"
    private var SW_WorkReportStaffListCellID = "SW_WorkReportStaffListCellID"
    
    /// 未审阅的工作报告列表
    private var reportDatas = [SW_WorkReportListModel]()
    
    /// 已经审阅的员工列表
    private var staffDatas = [SW_WorkReportStaffListModel]()
    
    //最后点击的位置，编辑或查看时不用遍历去找对应的项再修改，直接使用该index进行操作。
    private var lastIndexPath = IndexPath(row: 0, section: 0)
    
    private var isRequesting = false
    /// 两个分区
    private lazy var sectionArray = ["未审阅的\(type.rawTitle)","已审阅的\(type.rawTitle)"]
    /// 标记分区位置是展开还是收起，默认收起
    private var flagArray = [true,false]

    private lazy var reportHeader: SW_ReceiveWorkReportSectionHeaderView = {
        let header =  Bundle.main.loadNibNamed("SW_ReceiveWorkReportSectionHeaderView", owner: nil, options: nil)?.first as! SW_ReceiveWorkReportSectionHeaderView
        header.tapBlock = { [weak self] in
            guard let self = self else { return }
            self.flagArray[0] = !self.flagArray[0]
            self.tableView.reloadSection(0, with: UITableView.RowAnimation.automatic)
        }
        header.sectionTitleLb.text = sectionArray[0]
        return header
    }()
    private lazy var staffHeader: SW_ReceiveWorkReportSectionHeaderView = {
        let header =  Bundle.main.loadNibNamed("SW_ReceiveWorkReportSectionHeaderView", owner: nil, options: nil)?.first as! SW_ReceiveWorkReportSectionHeaderView
        header.tapBlock = { [weak self] in
            guard let self = self else { return }
            self.flagArray[1] = !self.flagArray[1]
            self.tableView.reloadSection(1, with: UITableView.RowAnimation.automatic)
        }
        header.sectionTitleLb.text = sectionArray[1]
        return header
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
        getReceiveReportStaffList()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup() {
        //审阅了一篇报告，盖章
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadCommentWorkReport, object: nil, queue: nil) { [weak self] (notifa) in
            guard let sSelf = self else { return }
            let type = notifa.userInfo?["workReportType"] as! WorkReportType
            if sSelf.type == type, sSelf.lastIndexPath.section == 0 {//对应type列表刷新对应项
                if !sSelf.reportDatas[sSelf.lastIndexPath.row].isCheck {
                    SW_BadgeManager.shared.getBadgeState()
                    sSelf.reportDatas.remove(at: sSelf.lastIndexPath.row)
                    sSelf.tableView.reloadSection(0, with: UITableView.RowAnimation.automatic)
                    sSelf.getReceiveReportStaffList()
                }
            }
        }
        //无权限看报告，删除报告
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserCantLookWorkReport, object: nil, queue: nil) { [weak self] (notifa) in
            guard let sSelf = self else { return }
            let type = notifa.userInfo?["workReportType"] as! WorkReportType
            if sSelf.type == type, sSelf.lastIndexPath.section == 0 {//对应type列表刷新对应项
//                SW_BadgeManager.shared.getBadgeState()
                sSelf.reportDatas.remove(at: sSelf.lastIndexPath.row)
                sSelf.tableView.reloadSection(0, with: UITableView.RowAnimation.automatic)
            }
        }
        
        tableView.removeFromSuperview()
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        view.addSubview(tableView)
        tableView.snp.makeConstraints({ (make) -> Void in
            make.edges.equalToSuperview()
        })
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        tableView.registerNib(SW_NoDataTableViewCell.self, forCellReuseIdentifier: "SW_NoDataTableViewCellID")
        tableView.registerNib(SW_WorkReportStaffListCell.self, forCellReuseIdentifier: SW_WorkReportStaffListCellID)
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
        
        ///上拉加载更多
        //        tableView.mj_footer = MJRefreshBackNormalFooter.init { [weak self] in
        //            self?.requsertreportDatas(self?.keyWord ?? "", byAppend: true)
        //            self?.tableView.mj_footer.endRefreshing()
        //        }
        //
        tableView.mj_header = SW_RefreshHeader.init(refreshingBlock: { [weak self] in
//            SW_BadgeManager.shared.getBadgeState()
            self?.requsertreportDatas(self?.keyWord ?? "")
            self?.getReceiveReportStaffList()
        })
    }
    
    /// 请求未审阅工作报告
    private func requsertreportDatas(_ keyword: String, byAppend: Bool = false) {
        guard !isRequesting else { return }
        isRequesting = true
        let offSet = byAppend ? reportDatas.count : 0
        //因为排序问题，分页处理较麻烦，暂时不做分页，一次性获取所有数据，数据量大时可能要考虑异步处理数据。
        SW_WorkingService.getReceiveReportList(type, keyWord: keyword, offset: offSet).response({ (json, isCache, error) in
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
    
    /// 获取已审阅的员工列表
    private func getReceiveReportStaffList() {
        SW_WorkingService.getReceiveReportStaffList(type).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.staffDatas = json["list"].arrayValue.map({ (value) -> SW_WorkReportStaffListModel in
                    return SW_WorkReportStaffListModel(value)
                })
                self.tableView.reloadSection(1, with: UITableView.RowAnimation.automatic)
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
    }
    
    deinit {
        PrintLog("deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if flagArray[section] {//展开
            if section == 0 {//未审阅工作报告
                return reportDatas.count > 0 ? reportDatas.count : 1
            } else {
                return staffDatas.count > 0 ? staffDatas.count : 1
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            reportHeader.state = flagArray[0]
            return reportHeader
        } else {
            staffHeader.state = flagArray[1]
            return staffHeader
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {/// 未审阅的工作报告
            if reportDatas.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: SW_WorkReportListCellID, for: indexPath) as! SW_WorkReportListCell
                cell.reportModel = reportDatas[indexPath.row]
                return cell
            } else {
                /// 暂无数据
                return tableView.dequeueReusableCell(withIdentifier: "SW_NoDataTableViewCellID", for: indexPath) as! SW_NoDataTableViewCell
            }
        } else {
            if staffDatas.count > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: SW_WorkReportStaffListCellID, for: indexPath) as! SW_WorkReportStaffListCell
                cell.staffModel = staffDatas[indexPath.row]
                cell.nameLb.text = staffDatas[indexPath.row].realName + "的\(type.rawTitle)"
                return cell
            } else {
                /// 暂无数据
                return tableView.dequeueReusableCell(withIdentifier: "SW_NoDataTableViewCellID", for: indexPath) as! SW_NoDataTableViewCell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        lastIndexPath = indexPath
        if indexPath.section == 0 {/// 未审阅的工作报告
            if reportDatas.count > indexPath.row {
                let vc =  SW_WorkReportDetailViewController(reportDatas[indexPath.row].id, type: type, ownerType: .received)
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            if staffDatas.count > indexPath.row {/// 审阅的员工
                
                let vc = SW_StaffWorkReportListViewController(type, staffId: staffDatas[indexPath.row].staffId, realName: staffDatas[indexPath.row].realName)
                navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    
}
