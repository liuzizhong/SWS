//
//  SW_SelectCarModelViewController.swift
//  SWS
//
//  Created by jayway on 2018/8/23.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

/// 选择车型列表类型
///
/// - brand: 品牌
/// - series: 车系
/// - model: 车型
/// - color: 车颜色
enum CarListType {
    case brand
    case series
    case model
//    case color
    
    var rawTitle: String{
        switch self {
        case .brand:
            return "选择品牌"
        case .series:
            return "选择车系"
        case .model:
            return "选择车型"
//        case .color:
//            return "选择颜色"
        }
    }
}

/// 汽车库类型
///
/// - unit: 单位
/// - all: 总库
enum CarLibraryType: Int {
    case unit = 0
    case all
}

typealias SelectCarSuccess = (NormalModel,NormalModel,NormalModel)->Void

class SW_SelectCarModelViewController: UIViewController {
    
    private let cellId = "sw_cellId"
    private var currentListType = CarListType.brand {
        didSet {
            navigationItem.title = currentListType.rawTitle
        }
    }
    private var libraryType = CarLibraryType.all
    private var isRequesting = false
    
    private var brandDatas: [String: [NormalModel]] = [:]
    private var keyIndex: [String] = []//存一下key的顺序
    private let AllKeys = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","#"]
    
    private var brandList = [NormalModel]() {
        didSet {
            for brand in brandList {
                if var brands = brandDatas[brand.firstChar], brands.count > 0 {
                    brands.append(brand)
                    brandDatas[brand.firstChar] = brands
                } else {
                    brandDatas[brand.firstChar] = [brand]
                    keyIndex.append(brand.firstChar)
                }
            }
            keyIndex = keyIndex.sorted(by: <)
            if keyIndex.first == "#" {
                keyIndex.remove(at: 0)
                keyIndex.append("#")
            }
        }
    }
    private var seriesList = [NormalModel]()
    private var modelList = [NormalModel]()
//    private var colorList = [NormalModel]()
    
    private var selectBrand = NormalModel()
    private var selectSeries = NormalModel()
    private var selectModel = NormalModel()
//    private var selectColor = NormalModel()
    
    private var currentList: [NormalModel] {
        get {
            switch currentListType {
            case .brand:
                return brandList
            case .series:
                return seriesList
            case .model:
                return modelList
//            case .color:
//                return colorList
            }
        }
        set {
            switch currentListType {
            case .brand:
                brandList = newValue
            case .series:
                seriesList = newValue
            case .model:
                modelList = newValue
//            case .color:
//                colorList = newValue
            }
            tableView.reloadData()
        }
    }
    /// 是否或者在售车型  默认不是
    private var saleState = false
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
//        if #available(iOS 11.0, *) {
//            tableView.contentInsetAdjustmentBehavior = .never
//        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.separatorColor = UIColor.mainColor.separator
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.cellId)
        tableView.sectionIndexColor = UIColor.mainColor.blue
        tableView.sectionIndexBackgroundColor = UIColor.clear
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 8))
//        view.backgroundColor = UIColor.mainColor.background
//        tableView.tableHeaderView = view
        tableView.ly_emptyView = self.emptyView
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.mainColor.background
        return tableView
    }()
    
    private lazy var emptyView: LYEmptyView = {
        let emptyView = LYEmptyView.empty(withImageStr: "", titleStr: "抱歉，没有找到相关内容", detailStr: "")
        emptyView?.titleLabTextColor = UIColor.mainColor.lightGray
        emptyView?.contentViewOffset = -50
        return emptyView!
    }()
    private var isFinishBySeries = false
    private var successBlock: SelectCarSuccess!
    
    init(_ libraryType: CarLibraryType, successBlock: @escaping SelectCarSuccess, isFinishBySeries: Bool = false, saleState: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        self.libraryType = libraryType
        self.successBlock = successBlock
        self.isFinishBySeries = isFinishBySeries
        self.saleState = saleState
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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
    
    fileprivate func setupView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        navigationItem.leftBarButtonItem = creatBackBtn()
        navigationItem.title = currentListType.rawTitle
        getListAndReload(.brand)
    }
    
    deinit {
        PrintLog("abcdfgr")
    }
    
    /// 获取当前页面的数据
    ///
    /// - Parameter append: true 加载更多    false ： 重新获取数据
    private func getListAndReload(_ listType: CarListType) {
        guard !isRequesting else { return }
        var requset : SWSRequest
        switch listType {
        case .brand:
            requset = SW_WorkingService.getCarBrand(libraryType.rawValue)
        case .series:
            requset = SW_WorkingService.getCarSeries(selectBrand.id)
        case .model:
            requset = SW_WorkingService.getCarModel(selectSeries.id, type: libraryType.rawValue, saleState: saleState)
//        case .color:
//            requset = SW_WorkingService.getCarProValue(selectBrand.id)
        }
        isRequesting = true
        requset.response({ (json, isCache, error) in
            self.currentListType = listType
            if let json = json as? JSON, error == nil {
                self.currentList = json["list"].arrayValue.map({ (value) -> NormalModel in
                    return NormalModel(value)
                })
            } else {
                self.currentList = []
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW)
            }
            self.isRequesting = false
        })
    }
  
    
    @objc private func backAction() {
        switch currentListType {
        case .brand:
            self.navigationController?.popViewController(animated: true)
        case .series:
            currentListType = .brand
            selectSeries = NormalModel()
            seriesList = []
            tableView.reloadData()
        case .model:
            currentListType = .series
            selectModel = NormalModel()
            modelList = []
            tableView.reloadData()
//        case .color:
//            currentListType = .model
//            selectColor = NormalModel()
//            colorList = []
//            tableView.reloadData()
        }
    }
    
    private func creatBackBtn() -> UIBarButtonItem {
        return UIBarButtonItem(image: #imageLiteral(resourceName: "nav_back").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backAction))
    }
    
}

extension SW_SelectCarModelViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if currentListType == .brand {
            return keyIndex.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentListType == .brand {
            return brandDatas[keyIndex[section]]?.count ?? 0
        } else {
            return currentList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.font = Font(14)
        cell.textLabel?.textColor = UIColor.mainColor.darkBlack
        
        if currentListType == .brand {
            guard keyIndex.count > indexPath.section else { return cell }
            guard let brands = brandDatas[keyIndex[indexPath.section]], brands.count > indexPath.row else { return cell }
            cell.accessoryType = .none
            cell.textLabel?.text = brands[indexPath.row].name
        } else {
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = currentList[indexPath.row].name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard !isRequesting else { return }
        switch currentListType {
        case .brand:
            guard keyIndex.count > indexPath.section else { return }
            guard let brands = brandDatas[keyIndex[indexPath.section]], brands.count > indexPath.row else { return }
            selectBrand = brands[indexPath.row]
            getListAndReload(.series)
        case .series:
            selectSeries = seriesList[indexPath.row]
            if isFinishBySeries {
                successBlock(selectBrand,selectSeries,selectModel)
                self.navigationController?.popViewController(animated: true)
            } else {
                getListAndReload(.model)
            }
        case .model:
            selectModel = modelList[indexPath.row]
            successBlock(selectBrand,selectSeries,selectModel)
            self.navigationController?.popViewController(animated: true)
//            getListAndReload(.color)
//        case .color:
//            selectColor = colorList[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 49
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if currentListType != .brand {
            return CGFloat.leastNormalMagnitude
        }
        return 36
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if currentListType != .brand {
            return nil
        }
        let view = SectionHeaderView(frame: CGRect(x: 0, y: 0, width: 1, height: 36))
        guard keyIndex.count > section else { return view }
        view.title = keyIndex[section]
        return view
    }
    
    //右边索引
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if currentListType != .brand {
            return nil
        }
        return AllKeys
    }
    
    ///点击索引处理对应的事情。
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if let select = keyIndex.index(where: {$0 == title}) {
            return select
        }
        /// 以下代码是找出点击字母相隔最近的一组的index
        guard keyIndex.count > 0 else { return 0 }
        let forCount = max(AllKeys.count - index - 1, index)// 最大循环次数
        for i in 1...forCount {
            if let select = keyIndex.index(where: {$0 == AllKeys[max(index - i, 0)]}) {
                return select
            }
            if let select = keyIndex.index(where: {$0 == AllKeys[min(index + i, AllKeys.count - 1)]}) {
                return select
            }
        }
        return index
    }
}
