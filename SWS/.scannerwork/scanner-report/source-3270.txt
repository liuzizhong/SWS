//
//  SW_InformListViewController.swift
//  SWS
//
//  Created by jayway on 2018/4/27.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_InformListViewController: SW_TableViewController {

    private var type = InformType.group
    
    private var SW_InformListCellID = "SW_InformListCellID"
    
    /// 现在出来的数据 搜索的直接放这里面
    private var informDatas = [SW_InformModel]()
    
    private lazy var emptyView: LYEmptyView = {
        return SW_NoDataEmptyView.creat()
    }()
    
    lazy var footerView: MJRefreshAutoNormalFooter = {
        let ftv = MJRefreshAutoNormalFooter.init { [weak self] in
            self?.requsertInformDatas(self?.keyWord ?? "", byAppend:true)
        }
        ftv?.isHidden = true
        ftv?.triggerAutomaticallyRefreshPercent = -10
        return ftv!
    }()
    
    var keyWord = "" {
        didSet {
            if keyWord != oldValue {//当keyword
                requsertInformDatas(keyWord)
            }
        }
    }
    
    /// 列表总数
    private var totalCount = 0
    
    init(_ type: InformType) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        requsertInformDatas(keyWord)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadPostInform, object: nil, queue: nil) { [weak self] (notifa) in
            let type = notifa.userInfo?["informType"] as! InformType
            if self?.type == type {
                dispatch_delay(0.5, block: {
                    self?.requsertInformDatas(self?.keyWord ?? "", max: (self?.informDatas.count ?? 19) + 1)
                })
            }
        }
        
        ScrollToTopButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), scrollView: tableView as UIScrollView)
        glt_scrollView = tableView
        tableView.ly_emptyView = SW_LoadingEmptyView.creat()
        tableView.ly_emptyView.contentViewOffset = -(SCREEN_HEIGHT - 250) * 0.2
        tableView.keyboardDismissMode = .onDrag
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        tableView.registerNib(SW_InformListCell.self, forCellReuseIdentifier: SW_InformListCellID)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL, right: 0)
        tableView.mj_header = SW_RefreshHeader.init(refreshingBlock: { [weak self] in
            self?.requsertInformDatas(self?.keyWord ?? "")
        })
        ///上拉加载更多
        tableView.mj_footer = footerView
        let headerV = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 15))
        headerV.backgroundColor = .white
        tableView.tableHeaderView = headerV
    }
    
    func requsertInformDatas(_ keyword: String, byAppend: Bool = false, max: Int = 20) {
        let offSet = byAppend ? informDatas.count : 0
        SW_WorkingService.getInformList(type.rawValue, staffId: SW_UserCenter.shared.user!.id, businessUnitId: SW_UserCenter.shared.user!.staffWorkDossier.businessUnitId, departmentId: SW_UserCenter.shared.user!.staffWorkDossier.departmentId, keyWord: keyword, max: max, offset: offSet).response({ (json, isCache, error) in
            self.emptyView.contentViewOffset = -(self.tableView.height - 250) * 0.2
            self.tableView.ly_emptyView = self.emptyView
            if let json = json as? JSON, error == nil {
                self.totalCount = json["count"].intValue
                if byAppend {
                    self.informDatas.append(contentsOf: json["list"].arrayValue.map({ (value) -> SW_InformModel in
                        return SW_InformModel(value)
                    }))
                    if self.informDatas.count >= self.totalCount {
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                        self.tableView.mj_footer.isHidden = true
                    } else {
                        self.tableView.mj_footer.endRefreshing()
                    }
                    
                } else {
                    self.tableView.mj_header.endRefreshing()
                    self.informDatas = json["list"].arrayValue.map({ (value) -> SW_InformModel in
                        return SW_InformModel(value)
                    })
                    /// 加载完毕
                    if self.informDatas.count < self.totalCount {
                        self.tableView.mj_footer.isHidden = false
                        self.tableView.mj_footer.state = MJRefreshState(rawValue: 1)!
                    } else {
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                        self.tableView.mj_footer.isHidden = true
                    }
                }
                self.tableView.reloadData()
            } else {
                if self.informDatas.count >= self.totalCount {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    self.tableView.mj_footer.isHidden = true
                } else {
                    self.tableView.mj_footer.endRefreshing()
                }
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
    }
    
    deinit {
        PrintLog("deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return informDatas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SW_InformListCellID, for: indexPath) as! SW_InformListCell
        cell.model = informDatas[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc =  SW_InformWebViewController(urlString: informDatas[indexPath.row].showUrl, informId: informDatas[indexPath.row].id)
        navigationController?.pushViewController(vc, animated: true)
    }

}
