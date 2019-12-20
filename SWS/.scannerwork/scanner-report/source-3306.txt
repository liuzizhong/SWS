//
//  SW_AppendAccessoriesItemViewController.swift
//  SWS
//
//  Created by jayway on 2019/6/12.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit
import SpreadsheetView

class SW_AppendAccessoriesItemViewController: UIViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    
    private var header = ["数量","配件编号","配件名称","库存数量","零售价"]
    
    private let normalW = SCREEN_WIDTH/4
    
    private var repairOrderId = ""
    
    private var isRequesting = false
    
//    private var cellId = "SW_RepairItemCellID"
    
    /// 选择了的维修项目
    private var selectItems = [SW_BoutiquesAccessoriesModel]() {
        didSet {
//            if selectItems.count == 0 {
//                navigationItem.rightBarButtonItem?.title = InternationStr("确定")
//            } else {
                navigationItem.rightBarButtonItem?.title = InternationStr("确定(\(selectItems.count))")
//            }
        }
    }
    
    private var currentList = [SW_BoutiquesAccessoriesModel]()
    
    private var keyWord = "" {
        didSet {
            if keyWord != oldValue {
                requsetData(keyWord, byAppend: false)
            }
        }
    }
    
    private var totalCount = 0
    
//    lazy var sectionHeader: SW_RepairItemHeaderView = {
//        let view = Bundle.main.loadNibNamed("SW_RepairItemHeaderView", owner: nil, options: nil)?.first as! SW_RepairItemHeaderView
//        return view
//    }()
    
    private lazy var searchBar: SW_SearchBar = {
        let sbar = SW_SearchBar()
        sbar.searchField.placeholder = "输入配件编号/名称"
        return sbar
    }()
    
    private lazy var footerView: MJRefreshAutoNormalFooter = {
        let ftv = MJRefreshAutoNormalFooter.init { [weak self] in
            self?.requsetData(self?.keyWord ?? "", byAppend: true)
        }
//        ftv?.isAutomaticallyHidden = false
        ftv?.isHidden = true
        ftv?.triggerAutomaticallyRefreshPercent = -15
        return ftv!
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
    
//    lazy var tableView: UITableView = {
//        let tableView = UITableView(frame: CGRect.zero, style: .plain)
//        tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0)
//        tableView.registerNib(SW_RepairItemCell.self, forCellReuseIdentifier: self.cellId)
//        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
//        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.backgroundColor = UIColor.white
//        tableView.separatorStyle = .none
//        tableView.keyboardDismissMode = .onDrag
//        tableView.rowHeight = UITableView.automaticDimension
//        if #available(iOS 11.0, *) {
//            tableView.contentInsetAdjustmentBehavior = .never
//        }
//        return tableView
//    }()
    
    private var successBlock: NormalBlock?
    
    init(_ repairOrderId: String, successBlock: NormalBlock?) {
        super.init(nibName: nil, bundle: nil)
        self.repairOrderId = repairOrderId
        self.successBlock = successBlock
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
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setCanDragBack(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setCanDragBack(false)
    }
    
    
    private func setCanDragBack(_ canDragBack: Bool) {
        if let nav = navigationController as? SW_NavViewController {
            nav.canDragBack = canDragBack
        }
    }
    
    private func setup() {
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.white
        navigationItem.title = "维修配件"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: InternationStr("确定(0)"), style: .plain, target: self, action: #selector(doneAction(_:)))
        
        searchBar.changeCancelBtnHiddenState(isShow: false)
        ///搜索按钮点击
        searchBar.searchBlock = { [weak self] in
            if let key = self?.searchBar.searchField.text {//让当前显示的控制器进行搜索
                self?.keyWord = key
            }
        }
        ///输入框内容改变
        searchBar.searchMessageBlock = { [weak self] (keyWord) in
            if keyWord?.isEmpty == true {///让输入框未空时刷新一下数据显示全部
                self?.keyWord = ""
            }
        }
        
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(64)
        }
//        view.addSubview(tableView)
//        tableView.snp.makeConstraints { (make) in
//            make.leading.trailing.bottom.equalToSuperview()
//            make.top.equalTo(searchBar.snp.bottom)
//        }
        view.addSubview(spreadsheetView)
        spreadsheetView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom)
        }
        view.addSubview(noDataLb)
        noDataLb.snp.makeConstraints { (make) in
            make.edges.equalTo(spreadsheetView)
        }
        
        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self
        spreadsheetView.bounces = false
//        spreadsheetView.isScrollEnabled = true
        spreadsheetView.intercellSpacing = CGSize.zero
        spreadsheetView.gridStyle = .none
        
        spreadsheetView.register(HeaderCell.self, forCellWithReuseIdentifier: String(describing: HeaderCell.self))
        spreadsheetView.register(TextCell.self, forCellWithReuseIdentifier: String(describing: TextCell.self))
        spreadsheetView.register(SelectHeaderCell.self, forCellWithReuseIdentifier: String(describing: SelectHeaderCell.self))
        spreadsheetView.register(SelectFieldCell.self, forCellWithReuseIdentifier: String(describing: SelectFieldCell.self))
        
        ///上拉加载更多
        spreadsheetView.scrollView.bounces = false
        spreadsheetView.scrollView.keyboardDismissMode = .onDrag
        spreadsheetView.scrollView.mj_footer = footerView
        
        ///上拉加载更多
//        tableView.mj_footer = footerView
        
//        let emptyView = LYEmptyView.empty(withImageStr: "", titleStr: "暂无数据", detailStr: "")
//        emptyView?.titleLabTextColor = UIColor.v2Color.lightGray
//        emptyView?.titleLabFont = Font(14)
//        tableView.ly_emptyView = emptyView
//        spreadsheetView.scrollView.ly_emptyView = emptyView
    }
    
    /// 获取当前页面的数据
    ///
    /// - Parameter append: true 加载更多    false ： 重新获取数据
    private func requsetData(_ keyword: String = "", byAppend: Bool = false) {
        let offSet = byAppend ? currentList.count : 0
        
        SW_AfterSaleService.getAccessoriesStockList(keyword, offset: offSet).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.totalCount = json["count"].intValue
                if byAppend {
                    self.currentList.append(contentsOf: json["list"].arrayValue.map({ (value) -> SW_BoutiquesAccessoriesModel in
                        return SW_BoutiquesAccessoriesModel(value, type: .accessories)
                    }))
                    if self.currentList.count >= self.totalCount {
                        self.spreadsheetView.scrollView.mj_footer.endRefreshingWithNoMoreData()
                        self.spreadsheetView.scrollView.mj_footer.isHidden = true
                    } else {
                        self.spreadsheetView.scrollView.mj_footer.endRefreshing()
                    }
                } else {
                    self.currentList = json["list"].arrayValue.map({ (value) -> SW_BoutiquesAccessoriesModel in
                        return SW_BoutiquesAccessoriesModel(value, type: .accessories)
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
    
    @objc func doneAction(_ sender: UIBarButtonItem) {
        if selectItems.count == 0 {
            showAlertMessage("请选择维修配件", MYWINDOW)
            return
        }
        
        dealSelectItem()
    }
    
    /// 提交新增维修项目
    func dealSelectItem() {
        guard !isRequesting else { return }
        isRequesting = true
        SW_AfterSaleService.appendRepairOrderAccessories(repairOrderId, accessoriesList: selectItems.filter({ return $0.saleCount != 0 })).response({ (json, isCache, error) in
            if let _ = json as? JSON, error == nil {
                showAlertMessage("保存成功", MYWINDOW)
                self.successBlock?()
                self.navigationController?.popViewController(animated: true)
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
            self.isRequesting = false
        })
    }
    
    deinit {
        PrintLog("deinit")
    }
}

extension SW_AppendAccessoriesItemViewController {
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return header.count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1 + currentList.count
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        switch column {
        case 0:
            return 110
        case 2:
            return normalW + 50
        default:
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
            let textH = model.name.size(Font(16), width: normalW + 50).height + 24
            model.cacheHeight = textH
            return textH
        }
    }
//    ["数量","配件编号","项目名称","库存数量","零售价"]
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if case 0 = indexPath.row {
            switch indexPath.column {
            case 0:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: SelectHeaderCell.self), for: indexPath) as! SelectHeaderCell
                cell.label.text = header[indexPath.column]
                cell.label.textAlignment = .center
                cell.imageView.isHidden = true
                cell.setLabelSnpToLeft(false)
                return cell
            case 1,2,3:
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
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: SelectFieldCell.self), for: indexPath) as! SelectFieldCell
                cell.isAmount = true
                cell.decimalCount = 4
                cell.amountMax = 9999.9999
                cell.textChangeBlock = { [weak self, weak cell] (text) in
                    PrintLog(text)
                    guard let self = self, let cell = cell else { return }
                    let count = Double(text) ?? 0.0
                    model.saleCount = count
                    if !self.selectItems.contains(where: { return $0.stockId == model.stockId }) {
                        self.selectItems.append(model)
                        cell.isSelect = true
                    }
                }
                cell.field.text = model.saleCount == 0 ? "" : "\(model.saleCount)"
                cell.isSelect = selectItems.contains(where: { return $0.stockId == model.stockId })
                return cell
            case 1,2,3:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
                cell.setLabelAlignment(.center)
                cell.label.numberOfLines = 0
                switch indexPath.column {
                case 1:
                    cell.label.text = model.num
                case 2:
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
        if indexPath.row != 0 {
            let model = currentList[indexPath.row - 1]
            if let index = selectItems.firstIndex(where: { return $0.stockId == model.stockId }) {
                selectItems.remove(at: index)
                if let cell = (spreadsheetView.cellForItem(at: IndexPath(row: indexPath.row, column: 0)) as? SelectFieldCell) {
                    cell.isSelect = false
                    currentList[indexPath.row].saleCount = 0
                    cell.field.text = ""
                    cell.field.resignFirstResponder()
                }
            } else {
                selectItems.append(model)
                if spreadsheetView.contentOffset.x > 0 {
                    spreadsheetView.setContentOffset(CGPoint(x: 0, y: spreadsheetView.contentOffset.y), animated: false)
                }
                dispatch_delay(0.1) {
                    if let cell = (spreadsheetView.cellForItem(at: IndexPath(row: indexPath.row, column: 0)) as? SelectFieldCell) {
                        cell.isSelect = true
                        cell.field.becomeFirstResponder()
                        //                (spreadsheetView.cellForItem(at: IndexPath(row: indexPath.row, column: 0)) as? SelectFieldCell)?.setIsSelect(true)
                        let frame = cell.field.convert(cell.field.frame, to: nil)
                        let distance = SCREEN_HEIGHT/2 - frame.origin.y
                        if distance < 0 {
                            spreadsheetView.setContentOffset(CGPoint(x: 0, y: spreadsheetView.contentOffset.y - distance), animated: true)
                        }
                    }
                }
                
            }
        }
    }
}

//extension SW_AppendAccessoriesItemViewController: UITableViewDelegate, UITableViewDataSource {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return currentList.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! SW_RepairItemCell
//        let item = currentList[indexPath.row]
////        cell.item = item
//        cell.isSelect = selectItems.contains(where: { return $0.id == item.id })
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let model = currentList[indexPath.row]
//        if let index = selectItems.firstIndex(where: { return $0.id == model.id }) {
//            selectItems.remove(at: index)
//        } else {
//            selectItems.append(model)
//        }
//        tableView.reloadRows(at: [indexPath], with: .automatic)
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return CGFloat.leastNormalMagnitude
//    }
//
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        return UIView.init()
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 30
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return sectionHeader
//    }
//
//}

