//
//  SW_StatisticalMainViewController.swift
//  SWS
//
//  Created by jayway on 2018/7/23.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

/// 数据统计类型
///
/// - comprehensive: 综合报表
/// - sales: 销售订单分析
/// - afterSales: 售后订单分析
/// - staff: 员工分析
enum StatisticalType: Int {
    case comprehensive = 1
    case sales
    case afterSales
//    case staff
    case salesCustomer = 5
    
    var rawTitle: String {
        switch self {
        case .comprehensive:
            return "综合报表"
        case .sales:
            return "销售订单分析"
        case .afterSales:
            return "售后订单分析"
//        case .staff:
//            return "员工分析"
        case .salesCustomer:
            return "客户分析"
        }
    }
    
    init(_ title: String) {
        switch title {
        case "综合报表":
            self = .comprehensive
        case "销售订单分析":
            self = .sales
        case "售后订单分析":
            self = .afterSales
//        case "员工分析":
//            self = .staff
        case "客户分析":
            self = .salesCustomer
        default:
            self = .comprehensive
        }
    }
}


enum FilterViewChangeType {
    case none           // 需要重新计算时间
    case dateType       // 需要重新计算时间
    case time           // 需要重新计算时间 -》判断是否当天当月当年，否则默认用1号，1月，当年
    case range          // 不需要重新计算时间，使用上次请求时间，需要存起来
    case accounts
}

let FilterViewAnimationDuretion = 0.3

class SW_StatisticalMainViewController: SW_TableViewController {

    /// 当前统计类型-默认综合报表 -- 进入这个页面，最少有一个权限 所有可以用0下标来取
    private var statisticalType = SW_UserCenter.shared.user!.auth.statisticsAuth[0].type {
        didSet {
            if oldValue != statisticalType {
                //改变了统计类型 dosomething
                self.filterView.currentStatisticalType = statisticalType
                getChartsDatas(.none)
            }
        }
    }
    
    //用于存所有图表数据
    private var charts = [SW_BaseChartModel]()
    
    //所有统计类型 -- 根据权限动态生成
    private var allTypes: [StatisticalType] = SW_UserCenter.shared.user!.auth.statisticsAuth.map({ return $0.type })
    
    ///筛选总view
    private var filterView: SW_StatisticalFilterView = {
        let view = Bundle.main.loadNibNamed(String(describing: SW_StatisticalFilterView.self), owner: nil, options: nil)?.first as! SW_StatisticalFilterView
        return view
    }()
    
    ///导航栏标题view
    private var navTitleView = SW_StatisticalNavTitleView()
    
    private lazy var emptyView: LYEmptyView = {
        let emptyView = LYEmptyView.empty(withImageStr: "", titleStr: "抱歉，没有找到相关内容", detailStr: "")
        emptyView?.titleLabTextColor = UIColor.mainColor.lightGray
        emptyView?.contentViewOffset = -50
        return emptyView!
    }()
    
    /// 选择统计类型的view
    private lazy var selectStatisticalTypeView: SW_FilterCollectionView = {
        let view = Bundle.main.loadNibNamed(String(describing: SW_FilterCollectionView.self), owner: nil, options: nil)?.first as! SW_FilterCollectionView
        return view
    }()
    
    //MARK:- 保存请求的数据
    /// 报表模块数据
    private var lineChartData: SW_LineChartModel?
    private var revenueBarChartData: SW_BarChartModel?
    private var costBarChartData: SW_BarChartModel?
    private var carModelData: SW_CarModelDataModel?
    /// 客户关系模块数据
    private var customerLineChartData: SW_CustomerLineChartModel?
    private var levelBarChartData: SW_BarChartModel?
    private var customerSourceBarChartData: SW_BarChartModel?
    private var likeCarPieChartData: SW_PieChartModel?
    /// 横向滑动圆形数据
    private var customerAccessTypeChartData: SW_CustomerAccessTypeChartModel?
    /// 留存-接待数据
    private var customerReceptionChartData :SW_CustomerReceptionChartModel?
    
    //MARK: - setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        getChartsDatas(.none)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.navigationBar.shadowImage = UIImage()
//        self.navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//        self.navigationController?.navigationBar.isTranslucent = false
//        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController?.navigationBar.shadowImage = UIImage.image(solidColor: #colorLiteral(red: 0.831372549, green: 0.831372549, blue: 0.831372549, alpha: 1), size: CGSize(width: 1, height: 1.0 / UIScreen.main.scale))
//        self.navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6)
//        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    /// 上次选择的时间，点击折线图时存起来
    var lastTimeStrAndRange: (String,TimeInterval,TimeInterval)?
    
    //MARK: - setup function
    private func setup() {
        ///初始化导航栏标题
        navTitleView.setupTitle(title: statisticalType.rawTitle)
        navTitleView.navDidClickBlock = { [weak self] in
            guard let `self` = self else { return }
            if self.selectStatisticalTypeView.superview != nil {
                self.selectStatisticalTypeView.hide(timeInterval: FilterViewAnimationDuretion)
                self.navTitleView.changeArrowDirection(timeInterval: FilterViewAnimationDuretion, isToDown: true)
            } else {
                self.navTitleView.changeArrowDirection(timeInterval: FilterViewAnimationDuretion, isToDown: false)
                self.filterView.dismissWithAnimation()
                self.selectStatisticalTypeView.show(self.statisticalType.rawTitle, showItems: self.allTypes.map({ return $0.rawTitle }), timeInterval: FilterViewAnimationDuretion, onView: MYWINDOW!, edgeInset: UIEdgeInsets(top: NAV_TOTAL_HEIGHT, left: 0, bottom: 0, right: 0), isAutoSelect: true, sureBlock: { [weak self] (typeStr) in
                    self?.statisticalType = StatisticalType(typeStr)
                    self?.navTitleView.setupTitle(title: typeStr)
                    self?.navTitleView.changeArrowDirection(timeInterval: FilterViewAnimationDuretion, isToDown: true)
                    }, cancelBlock: { [weak self] in
                        self?.navTitleView.changeArrowDirection(timeInterval: FilterViewAnimationDuretion, isToDown: true)
                })
            }
        }
        navigationItem.titleView = navTitleView
        view.backgroundColor = UIColor.mainColor.background
        //表格view还没做
        tableView.separatorStyle = .none
        ///报表模块UI CELL
        tableView.registerNib(SW_LineChartViewCell.self, forCellReuseIdentifier: "SW_LineChartViewCellId")
        tableView.registerNib(SW_BarChartViewCell.self, forCellReuseIdentifier: "SW_BarChartViewCellId")
        tableView.registerNib(SW_CarModelDataCell.self, forCellReuseIdentifier: "SW_CarModelDataCellId")
        ///客户关系UI CELL
        tableView.registerNib(SW_CustomerLineChartViewCell.self, forCellReuseIdentifier: "SW_CustomerLineChartViewCellId")
        tableView.registerNib(SW_PieChartViewCell.self, forCellReuseIdentifier: "SW_PieChartViewCellId")
        tableView.registerNib(SW_CustomerReceptionChartCell.self, forCellReuseIdentifier: "SW_CustomerReceptionChartCellID")
        tableView.registerNib(SW_CustomerAccessTypeChartCell.self, forCellReuseIdentifier: "SW_CustomerAccessTypeChartCellID")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        tableView.ly_emptyView = emptyView
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: TABBAR_HEIGHT + TABBAR_BOTTOM_INTERVAL, right: 0)
        
        filterView.controller = self
        filterView.dateTypeChangeBlock = { [weak self] in
            self?.getChartsDatas(.dateType)
        }
        filterView.timeChangeBlock = { [weak self] in
            self?.getChartsDatas(.time)
        }
        filterView.rangeChangeBlock = { [weak self] in
            self?.getChartsDatas(.range)
        }
        filterView.accountsChangeBlock = { [weak self] in
            self?.getChartsDatas(.accounts)
        }
        view.addSubview(filterView)
        filterView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        tableView.snp.remakeConstraints { (make) in
            make.top.equalTo(filterView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    //MARK: - private func
    /// 获取可视化数据
    ///
    /// - Parameter changeType: 改变的筛选条件
    private func getChartsDatas(_ changeType: FilterViewChangeType) {
        let timeRange = filterView.getTimeRange()
        
        switch statisticalType {
        case .comprehensive://综合报表
            let group = DispatchGroup()
            group.enter()
            let dateType = filterView.selectDateType
            let accounts = filterView.selectAccounts
            let days = filterView.getDaysCount()
            ///不管什么权限都有折线图
            SW_StatisticalService.getComprehensiveLineChart(dateType: dateType, accountsType: accounts, regionId: filterView.selectRegion, bUnitId: filterView.selectUnit, deptId: filterView.selectDept, startDate: timeRange.0, endDate: timeRange.1).response({ (json, isCache, error) in
                if let json = json as? JSON, error == nil {
                    self.lineChartData = SW_LineChartModel(dateType, accountsType: accounts, days: days, json: json)
                    self.lineChartData?.lineChartTitle = self.statisticalType.rawTitle
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                }
                group.leave()
            })
            
            //选中
            if accounts != .cost, filterView.allAccounts.contains(.income) {
                group.enter()
                //获取收入金额
                SW_StatisticalService.getRevenueAmountChart(regionId: filterView.selectRegion, bUnitId: filterView.selectUnit, deptId: filterView.selectDept, startDate: timeRange.0, endDate: timeRange.1).response({ (json, isCache, error) in
                    if let json = json as? JSON, error == nil {
                        self.revenueBarChartData = SW_BarChartModel(.income, json: json)
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                    }
                    group.leave()
                })
            } else {
                revenueBarChartData = nil
            }

            if accounts != .income, filterView.allAccounts.contains(.cost) {
                group.enter()
                //获取成本金额
                SW_StatisticalService.getCostAmountChart(regionId: filterView.selectRegion, bUnitId: filterView.selectUnit, deptId: filterView.selectDept, startDate: timeRange.0, endDate: timeRange.1).response({ (json, isCache, error) in
                    if let json = json as? JSON, error == nil {
                        self.costBarChartData = SW_BarChartModel(.cost, json: json)
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                    }
                    group.leave()
                })
            } else {
                costBarChartData = nil
            }
            self.carModelData = nil//综合报表不显示车型分析
            
            group.notify(queue: .main, execute: {
                self.assemblyChartDatas()
            })
        case .salesCustomer://客户关系分析
            let group = DispatchGroup()
            group.enter()
            let dateType = filterView.selectDateType
            let days = filterView.getDaysCount()
            /// 通用时间范围字符串   横向滑动卡片不适用
            let dateString = dateType == .year ? "\(Date.dateWith(timeInterval: timeRange.0).stringWith(formatStr: "yyyy年"))-\(Date.dateWith(timeInterval: timeRange.1).stringWith(formatStr: "yyyy年"))" : filterView.timeButton.title(for: UIControl.State()) ?? ""
            
            /// 销售接访客户数据 折线图数据
            SW_StatisticalService.getCustomerLineData(dateType: dateType, regionId: filterView.selectRegion, bUnitId: filterView.selectUnit, startDate: timeRange.0, endDate: timeRange.1).response({ (json, isCache, error) in
                if let json = json as? JSON, error == nil {
                    self.customerLineChartData = SW_CustomerLineChartModel(dateType, days: days, json: json)
                    self.customerLineChartData?.dateString = dateString
                    self.customerLineChartData?.lineChartTitle = dateString + "销售接访客户数据(前8名)"
                } else {
                    self.customerLineChartData = nil
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                }
                group.leave()
            })
            
            var timeStrAndRange: (String, TimeInterval, TimeInterval)!
            var dateStr = dateString
            if dateType == .year {
                dateStr = Date.dateWith(timeInterval: timeRange.1).stringWith(formatStr: "yyyy年")
            }
            switch changeType {
//            case .none:
//                break
//            case .dateType:
                /// 切换这个的时候，时间回到默认 -  当天，当月，当年
                /// 这个时候 dateString 分别是  当月  当年  2015-当年---》需要转换至当年
//                break
//            case .time:
                /// 切换这个时间时，
                /// 日报 判断是否是 当月 -》 用当天时间，否则默认 使用 选择月份的1号
                /// 月报 判断是否是 当年 -》 用当月时间，否则默认 使用 选择年份的1月
//                break
            case .range:
                /// 不计算时间，直接使用上次请求的时间范围---改变范围时应该有时间了，如果没有时间就要重新算时间，
                if let lastTimeStrAndRange = lastTimeStrAndRange {
                    timeStrAndRange = lastTimeStrAndRange
                } else {
                    timeStrAndRange = calculateTypeChartDate(dateType, dateString: dateStr, dateIndex: nil)
                }
            default:
                /// 切换这个时间时，
                /// 日报 判断是否是 当月 -》 用当天时间，否则默认 使用 选择月份的1号
                /// 月报 判断是否是 当年 -》 用当月时间，否则默认 使用 选择年份的1月
                timeStrAndRange = calculateTypeChartDate(dateType, dateString: dateStr, dateIndex: nil)
            }
            /// 接访客户统计 横向滑动数据
            /// 接访客户统计数据
            var customerAccessTypeJson: JSON? = nil
            group.enter()
            SW_StatisticalService.getCustomerAccessTypeData(regionId: filterView.selectRegion, bUnitId: filterView.selectUnit, startDate: timeStrAndRange.1, endDate: timeStrAndRange.2).response({ (json, isCache, error) in
                if let json = json as? JSON, error == nil {
                    customerAccessTypeJson = json
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                }
                group.leave()
            })
            
            /// 接访客户数据
            var customerReceptionJson: JSON? = nil
            /// 留存客户数据
            var customerRetentionJson: JSON? = nil
            if dateType == .day {
                group.enter()
                SW_StatisticalService.getCustomerReceptionData(dataType: 1, regionId: filterView.selectRegion, bUnitId: filterView.selectUnit, startDate: timeRange.0, endDate: timeRange.1).response({ (json, isCache, error) in
                    if let json = json as? JSON, error == nil {
                        customerReceptionJson = json
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                    }
                    group.leave()
                })
                
                group.enter()
                SW_StatisticalService.getCustomerReceptionData(dataType: 2, regionId: filterView.selectRegion, bUnitId: filterView.selectUnit, startDate: timeRange.0, endDate: timeRange.1).response({ (json, isCache, error) in
                    if let json = json as? JSON, error == nil {
                        customerRetentionJson = json
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                    }
                    group.leave()
                })
            }
            
            /// 获取客户意向车型分析数据
            if dateType != .year {
                group.enter()
                SW_StatisticalService.getCustomerLikeCarData(regionId: filterView.selectRegion, bUnitId: filterView.selectUnit, startDate: timeRange.0, endDate: timeRange.1).response({ (json, isCache, error) in
                    if let json = json as? JSON, error == nil {
                        self.likeCarPieChartData = SW_PieChartModel(json)
                        self.likeCarPieChartData?.pieChartTitle = dateString + "接访客户意向车型(前15名)"
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                    }
                    group.leave()
                })
            } else {
                self.likeCarPieChartData = nil
            }
            
            /// 获取客户来源分析数据
            group.enter()
            SW_StatisticalService.getCustomerSourceData(regionId: filterView.selectRegion, bUnitId: filterView.selectUnit, startDate: timeRange.0, endDate: timeRange.1).response({ (json, isCache, error) in
                if let json = json as? JSON, error == nil {
                    self.customerSourceBarChartData = SW_BarChartModel(.customerSource, json: json)
                    self.customerSourceBarChartData!.barChartTitle = dateString + self.customerSourceBarChartData!.barChartTitle
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                }
                group.leave()
            })
            
            /// 获取客户等级分析数据
            if dateType != .year {
                group.enter()
                SW_StatisticalService.getCustomerLevelData(regionId: filterView.selectRegion, bUnitId: filterView.selectUnit, startDate: timeRange.0, endDate: timeRange.1).response({ (json, isCache, error) in
                    if let json = json as? JSON, error == nil {
                        self.levelBarChartData = SW_BarChartModel(.level, json: json)
                        self.levelBarChartData!.barChartTitle = dateString + self.levelBarChartData!.barChartTitle
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                    }
                    group.leave()
                })
            } else {
                self.levelBarChartData = nil
            }
            
            self.carModelData = nil//客户关系不显示车型分析
            
            group.notify(queue: .main, execute: {
                if let customerLineChartData = self.customerLineChartData,
                    dateType == .day {
                    self.customerReceptionChartData = SW_CustomerReceptionChartModel(customerLineChartData, receptionJson: customerReceptionJson, retainedJson: customerRetentionJson)
                    self.customerReceptionChartData?.dateString = dateString
                } else {
                    self.customerReceptionChartData = nil
                }
                if let customerLineChartData = self.customerLineChartData {
                    //  横向图时间另外算
                    self.customerAccessTypeChartData = SW_CustomerAccessTypeChartModel(customerLineChartData, accessTypeJson: customerAccessTypeJson)
                    self.customerAccessTypeChartData?.dateString = timeStrAndRange.0
                    self.lastTimeStrAndRange = timeStrAndRange
                } else {
                    self.customerAccessTypeChartData = nil
                }
                self.assemblyCustomerChartDatas()
            })
            break
        default://售前售后订单
            let group = DispatchGroup()
            group.enter()
            let dateType = filterView.selectDateType
            let accounts = filterView.selectAccounts
            let days = filterView.getDaysCount()
            
            SW_StatisticalService.getSaleOrderDataShowLineChart(dateType: dateType, accountsType: accounts, orderTypeKey: statisticalType.rawValue - 1, regionId: filterView.selectRegion, bUnitId: filterView.selectUnit, deptId: filterView.selectDept, startDate: timeRange.0, endDate: timeRange.1).response({ (json, isCache, error) in
                if let json = json as? JSON, error == nil {
                    self.lineChartData = SW_LineChartModel(dateType, accountsType: accounts, days: days, json: json)
                    self.lineChartData?.lineChartTitle = self.statisticalType.rawTitle
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                }
                group.leave()
            })
            
            if accounts != .cost, filterView.allAccounts.contains(.income) {
                group.enter()
                //获取收入金额
                SW_StatisticalService.getSaleOrderRevenueType(orderTypeKey: statisticalType.rawValue - 1, regionId: filterView.selectRegion, bUnitId: filterView.selectUnit, startDate: timeRange.0, endDate: timeRange.1).response({ (json, isCache, error) in
                    if let json = json as? JSON, error == nil {
                        self.revenueBarChartData = SW_BarChartModel(.income, json: json)
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                    }
                    group.leave()
                })
            } else {
                revenueBarChartData = nil
            }
            
            if accounts != .income, filterView.allAccounts.contains(.cost) {
                group.enter()
                //获取成本金额
                SW_StatisticalService.getSaleOrderCostType(orderTypeKey: statisticalType.rawValue - 1, regionId: filterView.selectRegion, bUnitId: filterView.selectUnit, startDate: timeRange.0, endDate: timeRange.1).response({ (json, isCache, error) in
                    if let json = json as? JSON, error == nil {
                        self.costBarChartData = SW_BarChartModel(.cost, json: json)
                    } else {
                        showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                    }
                    group.leave()
                })
                
            } else {
                costBarChartData = nil
            }

            group.enter()
            //根据车型获取成本、收入
            SW_StatisticalService.getSaleOrderRevenueAndCostByCarModel(orderTypeKey: statisticalType.rawValue - 1, regionId: filterView.selectRegion, bUnitId: filterView.selectUnit, startDate: timeRange.0, endDate: timeRange.1).response({ (json, isCache, error) in
                if let json = json as? JSON, error == nil {
                    self.carModelData = SW_CarModelDataModel(accounts, json: json)
                } else {
                    showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
                }
                group.leave()
            })
            
            group.notify(queue: .main, execute: {
                self.assemblyChartDatas()
            })
        }
    }
    
    private func getAccessTypeChartDatas(_ dateType: DateType, dateString: String, dateIndex: Int) {
        /// 计算出点击的时间范围，以及显示时间字符串
        let timeStrAndRange = calculateTypeChartDate(dateType, dateString: dateString, dateIndex: dateIndex)
        if let lastTimeStrAndRange = lastTimeStrAndRange,
            lastTimeStrAndRange == timeStrAndRange {//日期相同直接返回
            return
        }
        lastTimeStrAndRange = timeStrAndRange
        let region = filterView.selectRegion
        let unit = filterView.selectUnit
        
        SW_StatisticalService.getCustomerAccessTypeData(regionId: region, bUnitId: unit, startDate: timeStrAndRange.1, endDate: timeStrAndRange.2).response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                /// 获取到数据后， 判断这次时间是否已经过时，如果没过时才赋值并刷新数据，
                if let lastTimeStrAndRange = self.lastTimeStrAndRange,
                    lastTimeStrAndRange == timeStrAndRange,
                    region == self.filterView.selectRegion,
                    unit == self.filterView.selectUnit,
                    let customerLineChartData = self.customerLineChartData {
                    //  横向图时间另外算
                    self.customerAccessTypeChartData = SW_CustomerAccessTypeChartModel(customerLineChartData, accessTypeJson: json)
                    self.customerAccessTypeChartData?.dateString = timeStrAndRange.0
                    /// 经过多重判断，确定数据有效性后再刷新页面。
                    if let index = self.charts.index(where: { return $0 is SW_CustomerAccessTypeChartModel}) {
                        self.charts[index] = self.customerAccessTypeChartData!
                        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    }
                }
            } else {
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
        })
    }
    
    
    /// 计算横向图的时间范围，以及最后显示的时间字符串
    ///
    /// - Parameters:
    ///   - dateType: 当前请求的类型 时间类型
    ///   - dateString: 当前选择的时间字符串
    ///   - dateIndex: 当前选择的时间下标 为空时 取当前时间
    /// - Returns: 返回的是一个元组， 第一个是时间字符串，第二个是开始时间，第三个是结束时间
    private func calculateTypeChartDate(_ dateType: DateType, dateString: String, dateIndex: Int?) -> (String,TimeInterval,TimeInterval) {
        ////   dateIndex 用来区分点击折线图还是过滤条件切换
        switch dateType {
        case .day:
            /// 日报 判断是否是 当月 -》 用当天时间，否则默认 使用 选择月份的1号
            
            if let dateIndex = dateIndex {
                var string = "\(dateString)\(dateIndex+1)日"
                let date = Date.dateWith(formatStr: "yyyy年M月dd日", dateString: string)!
                if date.isTodayDate() {
                    string = string + "(今天)"
                }
                return (string,date.getCurrentTimeInterval(),(date as NSDate).addingDays(1).getCurrentTimeInterval())
            } else {
                var date = Date()
                var string = Date().stringWith(formatStr: "yyyy年M月dd日")
                if string.contains(dateString) {// 当月
                    date = Date.dateWith(formatStr: "yyyy年M月dd日", dateString: string)!
                    string = string + "(今天)"
                } else {//不是当月
                    string = "\(dateString)\(1)日"
                    date = Date.dateWith(formatStr: "yyyy年M月dd日", dateString: string)!
                }
                return (string,date.getCurrentTimeInterval(),(date as NSDate).addingDays(1).getCurrentTimeInterval())
            }
            
        case .month:
            /// 月报 判断是否是 当年 -》 用当月时间，否则默认 使用 选择年份的1月
            if let dateIndex = dateIndex {
                let string = "\(dateString)\(dateIndex+1)月"
                let date = Date.dateWith(formatStr: "yyyy年M月", dateString: string)!
                return (string,date.getCurrentTimeInterval(),(date as NSDate).addingMonths(1).getCurrentTimeInterval())
            } else {
                var date = Date()
                var string = Date().stringWith(formatStr: "yyyy年M月")
                if string.contains(dateString) {// 当年
                    date = Date.dateWith(formatStr: "yyyy年M月", dateString: string)!
                } else {//不是当月
                    string = "\(dateString)\(1)月"
                    date = Date.dateWith(formatStr: "yyyy年M月", dateString: string)!
                }
                return (string,date.getCurrentTimeInterval(),(date as NSDate).addingMonths(1).getCurrentTimeInterval())
            }
            
        case .year:
            /// 年报 使用传入的时间字符串
            let date = Date.dateWith(formatStr: "yyyy年", dateString: dateString)!
            return (dateString,date.getCurrentTimeInterval(),(date as NSDate).addingYears(1).getCurrentTimeInterval())
        }
    }
    
    /// 组装报表数据类型
    ///
    /// - Parameter reload: 是否刷新页面
    private func assemblyChartDatas(reload: Bool = true) {
        charts = []
        customerLineChartData = nil
        customerAccessTypeChartData = nil
        customerReceptionChartData = nil
        levelBarChartData = nil
        customerSourceBarChartData = nil
        likeCarPieChartData = nil
        charts.append(safe: lineChartData)
        charts.append(safe: revenueBarChartData)
        charts.append(safe: costBarChartData)
        if reload {
            tableView.reloadData()
        }
    }
    
    /// 组装客户关系数据类型
    ///
    /// - Parameter reload: 是否刷新页面
    private func assemblyCustomerChartDatas(reload: Bool = true) {
        charts = []
        lineChartData = nil
        revenueBarChartData = nil
        costBarChartData = nil
        charts.append(safe: customerLineChartData)
        charts.append(safe: customerAccessTypeChartData)
        charts.append(safe: customerReceptionChartData)
        charts.append(safe: levelBarChartData)
        charts.append(safe: customerSourceBarChartData)
        charts.append(safe: likeCarPieChartData)
        if reload {
            tableView.reloadData()
        }
    }
    
    //MARK: - uitableviewdelegate
    override func numberOfSections(in tableView: UITableView) -> Int {
        //有车型分析数据 2组
        return (carModelData?.data.count ?? 0) > 0 ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? charts.count : (carModelData?.data.count ?? 0)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {//用section去数据
        if indexPath.section == 0 {
            guard charts.count > indexPath.row else { return UITableViewCell() }
            let chart = charts[indexPath.row]
            if chart is SW_LineChartModel {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SW_LineChartViewCellId", for: indexPath) as! SW_LineChartViewCell
                cell.chartModel = chart as? SW_LineChartModel
                return cell
            } else if chart is SW_BarChartModel {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SW_BarChartViewCellId", for: indexPath) as! SW_BarChartViewCell
                cell.chartModel = chart as? SW_BarChartModel
                return cell
            } else if chart is SW_CustomerLineChartModel {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SW_CustomerLineChartViewCellId", for: indexPath) as! SW_CustomerLineChartViewCell
                cell.chartModel = chart as? SW_CustomerLineChartModel
                cell.selectDateBlock = { [weak self] (dateType,dateString,dateIndex) in
                    /// 点击折线图某个日期，获取这个日期的数据  横向图
                    self?.getAccessTypeChartDatas(dateType, dateString: dateString, dateIndex: dateIndex)
                }
                return cell
            } else if chart is SW_PieChartModel {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SW_PieChartViewCellId", for: indexPath) as! SW_PieChartViewCell
                cell.chartModel = chart as? SW_PieChartModel
                return cell
            } else if chart is SW_CustomerReceptionChartModel {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SW_CustomerReceptionChartCellID", for: indexPath) as! SW_CustomerReceptionChartCell
                cell.chartModel = chart as? SW_CustomerReceptionChartModel
                return cell
            } else if chart is SW_CustomerAccessTypeChartModel {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SW_CustomerAccessTypeChartCellID", for: indexPath) as! SW_CustomerAccessTypeChartCell
                cell.chartModel = chart as? SW_CustomerAccessTypeChartModel
                return cell
            }
        } else if indexPath.section == 1 {//车型分析
            if let carModelData = carModelData {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SW_CarModelDataCellId", for: indexPath) as! SW_CarModelDataCell
                guard carModelData.data.count > indexPath.row else { return cell }
                let model = carModelData.data[indexPath.row]
                cell.sectionTitleBgView.isHidden = indexPath.row != 0
                cell.sectionTitleLb.text = carModelData.barChartTitle
                cell.model = model
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

}




