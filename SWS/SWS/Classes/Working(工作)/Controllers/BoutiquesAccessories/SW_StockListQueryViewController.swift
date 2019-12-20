//
//  SW_StockListQueryViewController.swift
//  SWS
//
//  Created by jayway on 2019/11/11.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit
import SpreadsheetView

class SW_StockListQueryViewController: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    private var type: ProcurementType = .boutiques
    
    fileprivate var header: [String]
    
    private let normalW = (SCREEN_WIDTH - 150)/2
    
    private var currentList = [SW_BoutiquesAccessoriesModel]()
    
    private var keyWord = "" {
        didSet {
//            if keyWord != oldValue {
                requsetData(keyWord, byAppend: false)
//            }
        }
    }
    
    private var totalCount = 0

    private lazy var searchBar: SW_NewSearchBar = { [weak self] in
        let sbar =  Bundle.main.loadNibNamed(String(describing: SW_NewSearchBar.self), owner: nil, options: nil)?.first as! SW_NewSearchBar
        sbar.placeholderString = "输入\(self?.type.rawTitle ?? "")编号/名称"
        return sbar
    }()
    
    private lazy var footerView: MJRefreshAutoNormalFooter = {
        let ftv = MJRefreshAutoNormalFooter.init { [weak self] in
            self?.requsetData(self?.keyWord ?? "", byAppend: true)
        }
        ftv?.isHidden = true
        ftv?.triggerAutomaticallyRefreshPercent = -15
        return ftv!
    }()
    var titleView: BigTitleSectionHeaderView = {
        let view = BigTitleSectionHeaderView()
        return view
    }()
    
    
    
    private var spreadsheetView = SpreadsheetView(frame: CGRect.zero)
    
    var noDataLb: UILabel = {
        let lb = UILabel()
        lb.isHidden = true
        lb.text = "暂无数据"
        lb.textColor = UIColor.v2Color.lightGray
        lb.font = Font(14)
        lb.backgroundColor = .white
        lb.textAlignment = .center
        return lb
    }()
    
    init(_ type: ProcurementType) {
        self.type = type
        self.header = ["\(type.rawTitle)编号","\(type.rawTitle)名称","库存","零售价"]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        requsetData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func setup() {
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.white
        searchBar.backActionBlock = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        searchBar.cancelActionBlock = { [weak self] in
            guard let self = self else { return }
            self.keyWord = ""
        }
        ///搜索按钮点击
        searchBar.searchBlock = { [weak self] in
            if let key = self?.searchBar.searchText {//让当前显示的控制器进行搜索
                self?.keyWord = key
            }
        }
        ///输入框内容改变
//        searchBar.textChangeBlock = { [weak self] in
//            guard let self = self else { return }
//            if self.searchBar.searchText.isEmpty {///让输入框未空时刷新一下数据显示全部
//                self.keyWord = ""
//            }
//        }
        titleView.title = "\(type.rawTitle)库存查询"
        
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(NAV_HEAD_INTERVAL + 74)
        }
        view.addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom)
            make.height.equalTo(70)
        }
        view.addSubview(spreadsheetView)
        spreadsheetView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(titleView.snp.bottom)
        }
        view.addSubview(noDataLb)
        noDataLb.snp.makeConstraints { (make) in
            make.edges.equalTo(spreadsheetView)
        }
        
        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self
        spreadsheetView.bounces = true
//        spreadsheetView.isScrollEnabled = true
        spreadsheetView.intercellSpacing = CGSize.zero
        spreadsheetView.gridStyle = .none
        
        spreadsheetView.register(HeaderCell.self, forCellWithReuseIdentifier: String(describing: HeaderCell.self))
        spreadsheetView.register(TextCell.self, forCellWithReuseIdentifier: String(describing: TextCell.self))
        
        ///上拉加载更多
        spreadsheetView.scrollView.bounces = true
        spreadsheetView.scrollView.keyboardDismissMode = .onDrag
        spreadsheetView.scrollView.mj_footer = footerView
        spreadsheetView.scrollView.mj_header = SW_RefreshHeader.init(refreshingBlock: { [weak self] in
            self?.requsetData(self?.keyWord ?? "", byAppend: false)
            self?.spreadsheetView.scrollView.mj_header.endRefreshing()
        })
    }
    
    /// 获取当前页面的数据
    ///
    /// - Parameter append: true 加载更多    false ： 重新获取数据
    private func requsetData(_ keyword: String = "", byAppend: Bool = false) {
        let offSet = byAppend ? currentList.count : 0
        
        let request = type == .accessories ? SW_AfterSaleService.queryAccessoriesStockList(keyword, offset: offSet) : SW_WorkingService.queryBoutiqueStockList(keyword, offset: offSet)
//
        request.response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.totalCount = json["count"].intValue
                if byAppend {
                    self.currentList.append(contentsOf: json["list"].arrayValue.map({ (value) -> SW_BoutiquesAccessoriesModel in
                        return SW_BoutiquesAccessoriesModel(value, type: self.type)
                    }))
                    if self.currentList.count >= self.totalCount {
                        self.spreadsheetView.scrollView.mj_footer.endRefreshingWithNoMoreData()
                        self.spreadsheetView.scrollView.mj_footer.isHidden = true
                    } else {
                        self.spreadsheetView.scrollView.mj_footer.endRefreshing()
                    }
                } else {
                    self.currentList = json["list"].arrayValue.map({ (value) -> SW_BoutiquesAccessoriesModel in
                        return SW_BoutiquesAccessoriesModel(value, type: self.type)
                    })
                    /// 加载完毕
                    if self.currentList.count < self.totalCount {
                        self.spreadsheetView.scrollView.mj_footer.isHidden = false
                        self.spreadsheetView.scrollView.mj_footer.state = MJRefreshState(rawValue: 1)!
                        /// 进入时判断是否显示了销售接待条 控制偏移量
                    } else {
                        self.spreadsheetView.scrollView.mj_footer.endRefreshingWithNoMoreData()
                        self.spreadsheetView.scrollView.mj_footer.isHidden = true
                    }
                }
                let originPoint = self.spreadsheetView.scrollView.contentOffset
                self.noDataLb.isHidden = self.currentList.count != 0
                self.spreadsheetView.reloadData()
                self.spreadsheetView.scrollView.setContentOffset(self.currentList.count == 0 ? CGPoint.zero : originPoint, animated: false)
            } else {
                if self.currentList.count >= self.totalCount {
                    self.spreadsheetView.scrollView.mj_footer.endRefreshingWithNoMoreData()
                    self.spreadsheetView.scrollView.mj_footer.isHidden = true
                } else {
                    self.spreadsheetView.scrollView.mj_footer.endRefreshing()
                }
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
        })
    }
    
    deinit {
        PrintLog("deinit")
    }
}

extension SW_StockListQueryViewController {
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return header.count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1 + currentList.count
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        if column == 2 || column == 3 {
            return 75
        } else {
            return normalW
        }
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 0
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        if case 0 = row {
            return 30
        } else {
            /// 计算高度赋值
            let model = currentList[row-1]
            if let height = model.cacheHeight {
                return height
            }
            let textH = max(model.name.size(Font(16), width: normalW).height + 24, model.num.size(Font(16), width: normalW-15).height + 24)
            model.cacheHeight = textH
            return textH
        }
    }
    
//    ["配件编号","项目名称","库存数量","零售价"]
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if case 0 = indexPath.row {
            switch indexPath.column {
            case 0:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
                cell.label.text = header[indexPath.column]
                cell.setLabelAlignment(.left)
                return cell
            case 1,2:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
                cell.label.text = header[indexPath.column]
                cell.setLabelAlignment(.center)
                return cell
            default:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
                cell.label.text = header[indexPath.column]
                cell.setLabelAlignment(.right)
                return cell
            }
        } else {
            let model = currentList[indexPath.row - 1]
            switch indexPath.column {
            case 0:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
                cell.setLabelAlignment(.left)
                cell.label.text = model.num
                cell.label.numberOfLines = 0
                return cell
            case 1,2:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
                cell.setLabelAlignment(.center)
                cell.label.numberOfLines = 0
                switch indexPath.column {
                case 1:
                    cell.label.text = model.name
                default:
                    cell.label.text = model.stockNum.toAmoutString()
                }
                return cell
            default:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
                cell.setLabelAlignment(.right)
                cell.label.text = model.retailPrice.toAmoutString()
                return cell
            }
        }
    }
    
    /// Delegate
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
    }
}
