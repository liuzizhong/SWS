//
//  SW_SearchShareDataViewController.swift
//  SWS
//
//  Created by jayway on 2019/1/22.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_SearchShareDataViewController: SW_TableViewController {
    /// 搜索历史记录路径 缓存
    let searchHistoryCache = YYCache(path: documentPath + "/SearchHistory.db")
    
    let searchHistoryKey = "ShareDataSearchHistory\(SW_UserCenter.getUserCachePath())"
    
    private var searchKey = ""
    /// 搜索的员工数据
    private var searchDatas = [SW_DataShareListModel]() {
        didSet {
            if searchDatas.count == 0 {
                let tipInfo = getSearchNoDataTipString(searchKey, module: "共享资料")
                noDataLabel.frame = tipInfo.1
                noDataLabel.attributedText = tipInfo.0
            }
        }
    }
    
    /// 获取搜索历史记录
    private var searchHistory: [String] = []
    
    private var isShowSearchHistory = true
    
    private var searchView: SW_BigSearchTextField = {
        let sview =  Bundle.main.loadNibNamed(String(describing: SW_BigSearchTextField.self), owner: nil, options: nil)?.first as! SW_BigSearchTextField
        sview.textField.placeholder = "输入查找内容"
        sview.maxCount = 100
        return sview
    }()
    
    private var noDataLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        return lb
    }()
    
    private lazy var emptyView: LYEmptyView = {
        let epv = LYEmptyView.emptyView(withCustomView: noDataLabel)
        epv?.contentViewY = 20
        return epv!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchHistory = searchHistoryCache?.object(forKey: searchHistoryKey) as? [String] ?? []
        setupChildView()
        // Do any additional setup after loading the view.
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
            if let index = self.searchDatas.firstIndex(where: { return $0.id == articleId }) {
                self.searchDatas[index].readedCount = readedCount
                self.tableView.reloadRow(at: IndexPath(row: index, section: 0), with: .automatic)
            }
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadChangeCollectionArticle, object: nil, queue: nil) { [weak self] (notifa) in
            guard let self = self else { return }
            let article = notifa.userInfo?["article"] as! SW_DataShareListModel
            let isCollect = notifa.userInfo?["isCollect"] as! Bool
            if let index = self.searchDatas.firstIndex(where: { return $0.id == article.id }) {
                self.searchDatas[index].isCollect = isCollect
                self.searchDatas[index].collectCount = isCollect ? self.searchDatas[index].collectCount + 1 : self.searchDatas[index].collectCount - 1
                self.tableView.reloadRow(at: IndexPath(row: index, section: 0), with: .automatic)
            }
        }
        tableView.estimatedSectionFooterHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = UITableView.automaticDimension
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_BOTTOM_INTERVAL, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom:  TABBAR_BOTTOM_INTERVAL, right: 0)
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.registerNib(SW_DataShareListCell.self, forCellReuseIdentifier: "SW_DataShareListCellID")
        tableView.registerNib(SW_SearchHistoryCell.self, forCellReuseIdentifier: "SW_SearchHistoryCellID")
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
            automaticallyAdjustsScrollViewInsets = false
        }
        ScrollToTopButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44), scrollView: tableView as UIScrollView)
        
        
        searchView.textChangeBlock = { [weak self] in
            guard let self = self else { return }
            if self.searchView.searchText.isEmpty {
                self.requsetData("")//文字被清空，显示搜索历史
            }
        }
        searchView.searchBlock = { [weak self] in
            guard let self = self else { return }
            self.requsetData(self.searchView.searchText)
        }
        searchView.textField.becomeFirstResponder()
        view.addSubview(searchView)
        searchView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(54)
        }
        
        tableView.snp.remakeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(searchView.snp.bottom)
        }
    }
    
    
    //    获取当前页面显示数据
    private func requsetData(_ keyword: String) {
        if !keyword.isEmpty {/// 有输入内容并进行搜索， 添加搜索记录
            isShowSearchHistory = false
            searchDatas = []
            tableView.reloadData()
            addSearchHistory(keyword: keyword)
            SW_WorkingService.getArticleList(keyword, articleTypeId: "", max: 9999, offset: 0).response({ (json, isCache, error) in
                if let json = json as? JSON, error == nil {
                    if keyword == self.searchView.searchText {
                        let datas = json["list"].arrayValue.map({ (value) -> SW_DataShareListModel in
                            return SW_DataShareListModel(value)
                        })
                        self.searchKey = keyword
                        self.searchDatas = datas
                        self.tableView.ly_emptyView = self.emptyView
                        self.tableView.reloadData()
                    }
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                }
            })
        } else {/// 输入的空字符串 显示搜索历史记录
            isShowSearchHistory = true
            tableView.ly_emptyView = nil
            tableView.reloadData()
        }
    }
    
    //MARK: - private func
    private func addSearchHistory(keyword: String) {
        if let index = searchHistory.firstIndex(of: keyword) {/// 原来有就先删除，然后插入第一个
            searchHistory.remove(at: index)
        }
        searchHistory.insert(keyword, at: 0)
        if searchHistory.count > 20 {/// 删除超出20条的部分
            searchHistory.removeSubrange(20 ..< searchHistory.count)
        }
        searchHistoryCache?.setObject(searchHistory as NSCoding, forKey: searchHistoryKey)
    }
    
    
    /// 删除历史记录
    ///
    /// - Parameter indexPath: 如果有值，删除特定某个记录，如果为nil 删除所有历史记录
    private func deleteSearchHistory(_ keyword: String? = nil) {
        if let keyword = keyword {
            if let index = searchHistory.firstIndex(of: keyword) {
                searchHistory.remove(at: index)
                if searchHistory.count == 0 {
                    tableView.reloadData()
                } else {
                    tableView.deleteRow(at: IndexPath(row: index, section: 0), with: .automatic)
                }
            }
            searchHistoryCache?.setObject(searchHistory as NSCoding, forKey: searchHistoryKey)
            return
        }
        /// 删除所有历史记录
        searchHistory = []
        tableView.reloadData()
        searchHistoryCache?.setObject(searchHistory as NSCoding, forKey: searchHistoryKey)
    }
    
    //MARK: - tableviewdelegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isShowSearchHistory {
            return searchHistory.count
        }
        return searchDatas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isShowSearchHistory {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SW_SearchHistoryCellID", for: indexPath) as! SW_SearchHistoryCell
            let keyword = searchHistory[indexPath.row]
            cell.keywordLb.text = keyword
            cell.deleteActionBlock = { [weak self] in
                self?.deleteSearchHistory(keyword)
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "SW_DataShareListCellID", for: indexPath) as! SW_DataShareListCell
        cell.model = searchDatas[indexPath.row]
        return cell
    }
    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return CGFloat.leastNormalMagnitude
//    }
//
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return UIView.init()
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if isShowSearchHistory {
            /// 选中搜索历史，将关键词设置到搜索栏，并进行搜索
            let keyword = searchHistory[indexPath.row]
            searchView.textField.text = keyword
            requsetData(keyword)
            return
        }
        let model = searchDatas[indexPath.row]
        let vc = SW_ArticleWebViewController(model)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {/// 70   44
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if searchView.searchText.isEmpty {// 显示搜索历史的header
            if searchHistory.count == 0 {
                let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 44))
                view.backgroundColor = .white
                return view
            }
            let view = SW_SearchHistoryHeaderView(frame: CGRect(x: 0, y: 0, width: 1, height: 44))
            view.title = "搜索历史"
            view.deleteActionBlock = { [weak self] in
                alertControllerShow(title: "确认删除全部历史记录？", message: nil, rightTitle: "确 定", rightBlock: { (controller, action) in
                    self?.deleteSearchHistory()
                }, leftTitle: "取 消", leftBlock: nil)
            }
            return view
        }
        if searchDatas.count == 0 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 44))
            view.backgroundColor = .white
            return view
        }
        let view = SW_SearchHistoryHeaderView(frame: CGRect(x: 0, y: 0, width: 1, height: 44))
        view.title = "搜索结果"
        view.deleteBtn.isHidden = true
        return view
    }
}

