//
//  SW_DataShareCollectionViewController.swift
//  SWS
//
//  Created by jayway on 2019/1/30.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_DataShareCollectionViewController: SW_TableViewController {
    /// 共享资料
    private var shareDatas = [SW_DataShareListModel]()
    
    private lazy var emptyView: LYEmptyView = {
        return SW_NoDataEmptyView.creat()
    }()
    
    lazy var footerView: MJRefreshAutoNormalFooter = {
        let ftv = MJRefreshAutoNormalFooter.init { [weak self] in
            self?.requsetData(true)
        }
        ftv?.isHidden = true
        ftv?.triggerAutomaticallyRefreshPercent = -10
        return ftv!
    }()
    
    /// 当前人数
    private var totalCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildView()
        requsetData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    deinit {
        PrintLog("deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: -设置子控件
    private func setupChildView() -> Void {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.ArticleReadCountHadUpdate, object: nil, queue: nil) { [weak self] (notifa) in
            guard let self = self else { return }
            let articleId = notifa.userInfo?["articleId"] as! String
            let readedCount = notifa.userInfo?["readedCount"] as! Int
            if let index = self.shareDatas.firstIndex(where: { return $0.id == articleId }) {
                self.shareDatas[index].readedCount = readedCount
                self.tableView.reloadRow(at: IndexPath(row: index, section: 0), with: .automatic)
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadChangeCollectionArticle, object: nil, queue: nil) { [weak self] (notifa) in
            guard let self = self else { return }
            let article = notifa.userInfo?["article"] as! SW_DataShareListModel
            let isCollect = notifa.userInfo?["isCollect"] as! Bool
            if isCollect {
                article.isCollect = isCollect
                article.collectorDate = Date().getCurrentTimeInterval()
                self.shareDatas.insert(article, at: 0)
                self.tableView.reloadData()
            } else {
                if let index = self.shareDatas.firstIndex(where: { return $0.id == article.id }) {
                    self.shareDatas.remove(at: index)
                    self.tableView.deleteRow(at: IndexPath(row: index, section: 0), with: .automatic)
                }
            }
        }
        glt_scrollView = tableView
        tableView.estimatedSectionFooterHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL, right: 0)
        tableView.keyboardDismissMode = .onDrag
        tableView.registerNib(SW_DataShareListCell.self, forCellReuseIdentifier: "SW_DataShareListCellID")
        tableView.mj_header = SW_RefreshHeader.init(refreshingBlock: { [weak self] in
            self?.requsetData()
        })
        tableView.mj_footer = footerView
        tableView.ly_emptyView = SW_LoadingEmptyView.creat()
        tableView.ly_emptyView.contentViewOffset = -(SCREEN_HEIGHT - 250) * 0.2
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = false
        }
        ScrollToTopButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), scrollView: tableView as UIScrollView)
        
    }
    
    //    获取当前页面显示数据   后期可能需要添加缓存
    private func requsetData(_ byAppend: Bool = false) {
        let offSet = byAppend ? shareDatas.count : 0
        
        SW_WorkingService.getArticleCollectList(offset: offSet).response({ (json, isCache, error) in
            self.emptyView.contentViewOffset = -(self.tableView.height - 250) * 0.2
            self.tableView.ly_emptyView = self.emptyView
            if let json = json as? JSON, error == nil {
                self.totalCount = json["count"].intValue
                if byAppend {
                    let datas = json["list"].arrayValue.map({ (value) -> SW_DataShareListModel in
                        return SW_DataShareListModel(value)
                    })
                    
                    self.shareDatas.append(contentsOf: datas)
                    if self.shareDatas.count >= self.totalCount {
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                        self.tableView.mj_footer.isHidden = true
                    } else {
                        self.tableView.mj_footer.endRefreshing()
                    }
                    self.tableView.reloadData()
                } else {
                    self.tableView.mj_header.endRefreshing()
                    let datas = json["list"].arrayValue.map({ (value) -> SW_DataShareListModel in
                        return SW_DataShareListModel(value)
                    })
                    //                    let datas = [SW_DataShareListModel]()
                    //                    self.totalCount = 0
                    self.shareDatas = datas
                    /// 加载完毕
                    if self.shareDatas.count < self.totalCount {
                        self.tableView.mj_footer.isHidden = false
                        self.tableView.mj_footer.state = MJRefreshState(rawValue: 1)!
                    } else {
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                        self.tableView.mj_footer.isHidden = true
                    }
                    self.tableView.reloadData()
                    if self.shareDatas.count > 0 {
                        self.tableView.scroll(toRow: 0, inSection: 0, at: .top, animated: false)
                    }
                }
            } else {
                if self.shareDatas.count >= self.totalCount {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    self.tableView.mj_footer.isHidden = true
                } else {
                    self.tableView.mj_footer.endRefreshing()
                }
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
        })
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shareDatas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SW_DataShareListCellID", for: indexPath) as! SW_DataShareListCell
        cell.model = shareDatas[indexPath.row]
        cell.timeLb.text = Date.dateWith(timeInterval: shareDatas[indexPath.row].collectorDate).specialTimeString()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = shareDatas[indexPath.row]
        let vc = SW_ArticleWebViewController(model)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
