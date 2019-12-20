//
//  SW_MineCollectionViewController.swift
//  SWS
//
//  Created by jayway on 2018/4/12.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_MineCollectionViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    private lazy var emptyView: LYEmptyView = {
        return SW_NoDataEmptyView.creat()
    }()
    
    lazy var footerView: MJRefreshAutoNormalFooter = {
        let ftv = MJRefreshAutoNormalFooter.init { [weak self] in
            self?.requsertInformDatas(true)
        }
        ftv?.isHidden = true
        ftv?.triggerAutomaticallyRefreshPercent = -10
        return ftv!
    }()
    
    private var informDatas = [SW_InformModel]()
    
    /// 列表总数
    private var totalCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        requsertInformDatas()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        PrintLog("deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    //MAKR: 初始化设置
    private func setup() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadChangeCollectionInform, object: nil, queue: nil) { [weak self] (notifa) in
            self?.requsertInformDatas(max: (self?.informDatas.count ?? 19) + 1)
        }
        
        glt_scrollView = tableView
        tableView.mj_header = SW_RefreshHeader.init(refreshingBlock: { [weak self] in
            self?.requsertInformDatas()
        })
        tableView.mj_footer = footerView
        tableView.ly_emptyView = SW_LoadingEmptyView.creat()
        tableView.ly_emptyView.contentViewOffset = -(SCREEN_HEIGHT - 250) * 0.2
        tableView.registerNib(SW_InformListCell.self, forCellReuseIdentifier: "SW_InformListCellID")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL, right: 0)
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = false
        }
        ScrollToTopButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), scrollView: tableView as UIScrollView)
    }
    
    //MARK: 请求收藏列表数据
    private func requsertInformDatas(_ byAppend: Bool = false, max: Int = 20) {
        let offSet = byAppend ? informDatas.count : 0
        SW_WorkingService.getMsgCollectList(SW_UserCenter.shared.user!.id, max: max, offset: offSet).response({ (json, isCache, error) in
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
    
    //MARK: - tableviewdelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return informDatas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SW_InformListCellID", for: indexPath) as! SW_InformListCell
        cell.model = informDatas[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc =  SW_InformWebViewController(urlString: informDatas[indexPath.row].showUrl, informId: informDatas[indexPath.row].id)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
