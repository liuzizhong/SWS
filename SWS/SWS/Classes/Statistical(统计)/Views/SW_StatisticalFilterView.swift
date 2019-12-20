//
//  SW_StatisticalFilterView.swift
//  SWS
//
//  Created by jayway on 2018/7/24.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

/// 报表时间类型
///
/// - day: 日报
/// - month: 月报
/// - year: 年报
enum DateType: Int {
    case day      = 0
    case month
    case year
    
    var rawTitle: String {
        switch self {
        case .day:
            return "日报"
        case .month:
            return "月报"
        case .year:
            return "年报"
        }
    }
    
    var formatStr: String {
        switch self {
        case .day:
            return "yyyy年M月"
        case .month:
            return "yyyy年"
        case .year:
            return ""
        }
    }
    
    var unit: Double {
        switch self {
        case .day:
            return 10000.0
        case .month:
            return 10000.0//100000.0
        case .year:
            return 10000.0//1000000.0
        }
    }
    
    init(_ title: String) {
        switch title {
        case "日报":
            self = .day
        case "月报":
            self = .month
        case "年报":
            self = .year
        default:
            self = .day
        }
    }
}

/// 可视化报表金额账目类型
///
/// - profits: 利润
/// - cost: 成本
/// - income: 收入
enum AccountsType: Int {
    case profits = 1
    case income
    case cost
    
    var rawTitle: String {
        switch self {
        case .profits:
            return "利润"
        case .income:
            return "收入"
        case .cost:
            return "成本"
        }
    }
    
    init(_ title: String) {
        switch title {
        case "利润":
            self = .profits
        case "收入":
            self = .income
        case "成本":
            self = .cost
        default:
            self = .profits
        }
    }
   
}


class SW_StatisticalFilterView: UIView {
    var dateTypeChangeBlock: NormalBlock?
    var timeChangeBlock: NormalBlock?
    var rangeChangeBlock: NormalBlock?
    var accountsChangeBlock: NormalBlock?
    
    /// 选中的类型 默认日报
    var selectDateType = DateType.day {
        didSet {
            if selectDateType != oldValue {
                selectTime = Date().getCurrentTimeInterval()
                setupAllButtonTitle()
                timeButton.isHidden = selectDateType == .year
            }
        }
    }
    /// 选中的时间 默认时间
    var selectTime: TimeInterval = Date().getCurrentTimeInterval() {
        didSet {
//            if getTimeString(selectTime) != timeButton.title(for: UIControl.State()) {
            timeButton.setTitle(getTimeString(selectTime), for: UIControl.State())
//            }
        }
    }
    /// 选择的分区单位部门范围 默认选择全部分区
    var selectRegion: SW_FilterRegionModel?
    var selectUnit: SW_FilterUnitModel?
    var selectDept: SW_FilterDeptModel?
    /// 选择的账目类型 默认选择利润
    var selectAccounts = AccountsType(rawValue: SW_UserCenter.shared.user!.auth.statisticsAuth[0].authDetails.first ?? 1)! {
        didSet {
            if selectAccounts != oldValue {
                setupAllButtonTitle()
            }
        }
    }
    
    //当前统计类型，要根据当前统计类型来确定 下面利润数组--修改时需要重置参数
    var currentStatisticalType = SW_UserCenter.shared.user!.auth.statisticsAuth[0].type {
        didSet {
            if currentStatisticalType != oldValue {
                //不是综合报表，清空部门
                selectDept = currentStatisticalType != StatisticalType.comprehensive ? nil : selectDept
                if currentStatisticalType == .salesCustomer {
                    accountsButton.isHidden = true
                    /// 切换到客户关系类型时，时间需要重置到（当前时间），否则逻辑上不通，与折线图时间无法对应上，  ---暂时去除，
//                    selectTime = Date().getCurrentTimeInterval()
                } else {
                    ///找到对应的子权限列表
                    if let index = SW_UserCenter.shared.user!.auth.statisticsAuth.index(where: { return $0.type == currentStatisticalType }) {
                        allAccounts = SW_UserCenter.shared.user!.auth.statisticsAuth[index].authDetails.map({ return AccountsType(rawValue: $0)! })
                    }
                    selectAccounts = allAccounts.first!
                    accountsButton.isHidden = false
                }
                setupAllButtonTitle()
            }
        }
    }
    private var allDayeType: [DateType] = [.day,.month,.year]
    var allAccounts: [AccountsType] = SW_UserCenter.shared.user!.auth.statisticsAuth[0].authDetails.map({ return AccountsType(rawValue: $0)! })//[.profits,.income,.cost]//根据权限获取
    
    @IBOutlet weak var dateTypeButton: UIButton!
    
    @IBOutlet weak var timeButton: UIButton!
    
    @IBOutlet weak var rangeButton: UIButton!
    
    @IBOutlet weak var accountsButton: UIButton!
    
    weak var controller: UIViewController?
    
    /// 选择类型的view
    private lazy var selectTypeView: SW_FilterCollectionView = {
        let view = Bundle.main.loadNibNamed(String(describing: SW_FilterCollectionView.self), owner: nil, options: nil)?.first as! SW_FilterCollectionView
        return view
    }()
    
    /// 选择区域范围的view
    private lazy var selectRangeView: SW_FilterRangeView = {
        let view = Bundle.main.loadNibNamed(String(describing: SW_FilterRangeView.self), owner: nil, options: nil)?.first as! SW_FilterRangeView
        return view
    }()

    private var selectButton: UIButton?
    
    @IBOutlet var buttons: [UIButton]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupAllButtonTitle()
        
        if SW_UserCenter.shared.user!.auth.statisticsAuth[0].type == .salesCustomer {
            accountsButton.isHidden = true
            
        }
            
            
        buttons.forEach({ (button) in
            button.layer.borderColor = #colorLiteral(red: 0.831372549, green: 0.8431372549, blue: 0.8549019608, alpha: 1)
            button.layer.borderWidth = 0.5
        })
    }
    
    deinit {
        PrintLog("deinit")
    }
    
    @IBAction func selectButtonClickAction(_ sender: UIButton) {
        if sender == selectButton {//选中同一个按钮 关闭弹窗所有
            dismissWithAnimation(true)
            return
        } else {
            dismissWithAnimation()
            setButtonHighlighted(sender, isHighlighted: true)
        }
        
        switch sender {
        case dateTypeButton:
            selectTypeView.show(selectDateType.rawTitle, showItems: allDayeType.map({ return $0.rawTitle }), timeInterval: FilterViewAnimationDuretion, onView: MYWINDOW!, edgeInset: UIEdgeInsets(top: NAV_TOTAL_HEIGHT+40, left: 0, bottom: 0, right: 0), isAutoSelect: false, sureBlock: { [weak self] (typeStr) in
                if self?.selectDateType != DateType(typeStr) {
                    self?.selectDateType = DateType(typeStr)
                    self?.dateTypeChangeBlock?()
                }
                
                self?.setButtonHighlighted(sender, isHighlighted: false)
            }) { [weak self] in
                
                self?.setButtonHighlighted(sender, isHighlighted: false)
            }
            
        case timeButton:
            var mode: BRDatePickerMode!
            var formatS: String!
            if selectDateType == .day {
                mode = BRDatePickerMode.init(rawValue: 7)
                formatS = "yyyy-MM"
            } else {
                mode = BRDatePickerMode.init(rawValue: 8)
                formatS = "yyyy"
            }
            BRDatePickerView.showDatePicker(withTitle: "", on: MYWINDOW, dateType: mode, defaultSelValue: Date.dateWith(timeInterval: selectTime), minDate: Date.dateWith(timeInterval: StatisticalMinTimeInterval), maxDate: Date(), isAutoSelect: false, themeColor: UIColor.mainColor.blue, resultBlock: { [weak self] (dateStr) in
                if let dateStr = dateStr, let date = Date.dateWith(formatStr: formatS, dateString: dateStr) {
                    if self?.getTimeString(date.timeIntervalSince1970*1000) != self?.timeButton.title(for: UIControl.State())  {
                        self?.selectTime = date.timeIntervalSince1970*1000
                        self?.timeChangeBlock?()
                    }
                }
                self?.setButtonHighlighted(sender, isHighlighted: false)
            }, cancel: { [weak self] in
                
                self?.setButtonHighlighted(sender, isHighlighted: false)
            })
        case rangeButton:
            
            selectRangeView.show(selectRegion, selectUnit: selectUnit, selectDept: selectDept, timeInterval: FilterViewAnimationDuretion, onView: MYWINDOW!, edgeInset: UIEdgeInsets(top: NAV_TOTAL_HEIGHT+40, left: 0, bottom: 0, right: 0), isHideDept: currentStatisticalType != .comprehensive, sureBlock: { [weak self] (region, unit, dept) in
                if self?.selectRegion != region || self?.selectUnit != unit || self?.selectDept != dept {
                    self?.selectRegion = region
                    self?.selectUnit = unit
                    self?.selectDept = dept
                    self?.setupAllButtonTitle()
                    self?.rangeChangeBlock?()
                }
                self?.setButtonHighlighted(sender, isHighlighted: false)
            }) { [weak self] in
                self?.setButtonHighlighted(sender, isHighlighted: false)
            }
            
        case accountsButton:
            
            selectTypeView.show(selectAccounts.rawTitle, showItems: allAccounts.map({ return $0.rawTitle }), timeInterval: FilterViewAnimationDuretion, onView: MYWINDOW!, edgeInset: UIEdgeInsets(top: NAV_TOTAL_HEIGHT+40, left: 0, bottom: 0, right: 0), isAutoSelect: false, sureBlock: { [weak self] (typeStr) in
                if self?.selectAccounts != AccountsType(typeStr) {
                    self?.selectAccounts = AccountsType(typeStr)
                    self?.accountsChangeBlock?()
                }
                
                self?.setButtonHighlighted(sender, isHighlighted: false)
            }) { [weak self] in
                
                self?.setButtonHighlighted(sender, isHighlighted: false)
            }
            
        default:
            PrintLog("其他按钮")
        }
    }
    
    
    func dismissWithAnimation(_ animation: Bool = false) {
        buttons.forEach({ setButtonHighlighted($0, isHighlighted: false) })
        if animation {
            selectTypeView.hide(timeInterval: FilterViewAnimationDuretion)
            selectRangeView.hide(timeInterval: FilterViewAnimationDuretion)
        } else {
            selectTypeView.hide(timeInterval: 0)
            selectRangeView.hide(timeInterval: 0)
        }
    }
    
    //MARK: - private mothed
    private func setButtonHighlighted(_ button: UIButton, isHighlighted: Bool) {
        if isHighlighted {
            selectButton = button
            button.backgroundColor = UIColor.white
        } else {
            selectButton = nil
            button.backgroundColor = #colorLiteral(red: 0.9450980392, green: 0.9450980392, blue: 0.9450980392, alpha: 1)
        }
    }
    
    private func setupAllButtonTitle() {
        dateTypeButton.setTitle(selectDateType.rawTitle, for: UIControl.State())
        timeButton.setTitle(getTimeString(selectTime), for: UIControl.State())
        rangeButton.setTitle(getRangeString(), for: UIControl.State())
        accountsButton.setTitle(selectAccounts.rawTitle, for: UIControl.State())
    }
    
    private func getTimeString(_ time: TimeInterval) -> String {
        switch selectDateType {
        case .day,.month:
            return  Date.dateWith(timeInterval: time).stringWith(formatStr: selectDateType.formatStr)
        default:
            return ""
        }
    }
    
    private func getRangeString() -> String {
        if let selectDept = selectDept {
            return selectDept.deptName
        } else if let selectUnit = selectUnit {
            return selectUnit.bUnitName
        } else if let selectRegion = selectRegion {
            return selectRegion.regionName
        }
        return "全部分区"
    }
    
    //MARK: - publuc mothed
    
    /// 根据datetime 与 time计算时间范围
    ///
    /// - Returns: 0：starttime   1：endtime
    func getTimeRange() -> (TimeInterval,TimeInterval) {
        switch selectDateType {
        case .day:
            let startDateStr = timeButton.title(for: UIControl.State())!//Date.dateWith(timeInterval: selectTime).stringWith(formatStr: selectDateType.formatStr)
            let startDate = Date.dateWith(formatStr: selectDateType.formatStr, dateString: startDateStr)!
            let endDate = (startDate as NSDate).addingMonths(1)!
            PrintLog("startdate:\(startDate)---endDate:\(endDate)")
            return (startDate.getCurrentTimeInterval(),endDate.getCurrentTimeInterval())
        case .month:
            let startDateStr = timeButton.title(for: UIControl.State())!//Date.dateWith(timeInterval: selectTime).stringWith(formatStr: selectDateType.formatStr)
            let startDate = Date.dateWith(formatStr: selectDateType.formatStr, dateString: startDateStr)!
            let endDate = (startDate as NSDate).addingYears(1)!
            PrintLog("startdate:\(startDate)---endDate:\(endDate)")
            return (startDate.getCurrentTimeInterval(),endDate.getCurrentTimeInterval())
        case .year:
            return (StatisticalMinTimeInterval,Date().getCurrentTimeInterval())
        }
    }
    
    func getDaysCount() -> Int {
        switch selectDateType {
        case .day:
            let date = Date.dateWith(timeInterval: selectTime)
            return Int(NSDate.getDaysInYear(date.year(), month: date.month()))
        default:
            return 0
        }
    }
}









