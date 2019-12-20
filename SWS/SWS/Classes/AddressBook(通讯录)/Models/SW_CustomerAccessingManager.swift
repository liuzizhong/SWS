//
//  SW_CustomerAccessingManager.swift
//  SWS
//
//  Created by jayway on 2018/11/21.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

protocol SW_CustomerAccessingManagerDelegate: NSObjectProtocol {
    /// 通知刷新时间 ，每1s调用1次
    func SW_CustomerAccessingManagerNotificationReloadTime(manager: SW_CustomerAccessingManager)
}


/// 试乘试驾最长时间  单位：hour
let TryDriveMaxTime = 2
/// 销售接待最长时间  单位：hour
let AccessMaxTime = 5

class SW_CustomerAccessingManager: NSObject {
    
    static let shared = SW_CustomerAccessingManager()
    
    private var timer: Timer?
    
    private var isRequesting = false
    /// 用于失败重新请求
    private var isFailRequest = false
    
    /// 保存所有需要通知刷新view的
    var delegates = [SW_CustomerAccessingManagerDelegate]()
    
    /// 正在接待的客户列表， tabbar是否显示view就用这个进行控制
    var accessingList = [SW_AccessingListModel]() {
        didSet {
            if self.accessingList.count == 0 {/// 隐藏Tabbar  关闭定时器
                tabBarVc?.hideAccessListView()
                stop()
            } else {/// 显示Tabbar  开启定时器
                tabBarVc?.showAccessListView()
                run()
            }
        }
    }
    
    weak var tabBarVc: SW_TabBarController?
    
    private override init() {
        super.init()
        /// 注册通知
        setupNotification()
    }
    
    func retry() {
        if self.isFailRequest, netManager?.isReachable == true {
            self.getAccessingList()
        }
    }
    
    //MARK: - setup
    func setupNotification() {
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { [weak self] (notifi) in
            self?.stop()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] (notifi) in
            guard let self = self else { return }
            if self.accessingList.count > 0 {
                self.run()
            }
        }
        /// 开启销售接待 刷新页面
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadStartSalesReception, object: nil, queue: nil) { [weak self] (notifa) in
            self?.run()/// 开启销售接待就开启计时器
            self?.getAccessingList()
        }
        /// 结束了销售接待 刷新页面
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadEndSalesReception, object: nil, queue: nil) { [weak self] (notifa) in
            self?.getAccessingList()
        }
        /// 开启试乘试驾 刷新页面
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadStartTryDriving, object: nil, queue: nil) { [weak self] (notifa) in
            self?.getAccessingList()
        }
        /// 结束了试乘试驾 刷新页面
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Ex.UserHadEndTryDriving, object: nil, queue: nil) { [weak self] (notifa) in
            self?.getAccessingList()
        }
    }
    
    /// 获取接待列表
    func getAccessingList() {
        guard !isRequesting else { return }
        guard let user = SW_UserCenter.shared.user, user.auth.addressBookAuth.contains(where: { return $0.type == .customer }) else { return }
        isRequesting = true
        SW_AddressBookService.getCustomerAccessingList(user.id).response({ (json, isCache, error) in
            self.isRequesting = false
            if let json = json as? JSON, error == nil {
                self.isFailRequest = false
                self.accessingList = json["list"].arrayValue.map({ (json) -> SW_AccessingListModel in
                    return SW_AccessingListModel(json)
                })
            } else {
                self.isFailRequest = true
                showAlertMessage(error?.localizedDescription ?? "网络异常", MYWINDOW!)
            }
        })
    }
    
    /// 添加到delegate队列
    ///
    /// - Parameter delegate: 需要被通知的对象
    func addDelegate(_ delegate: SW_CustomerAccessingManagerDelegate) {
        if !isContainsDelegate(delegate) {
            delegates.append(delegate)
        }
        delegate.SW_CustomerAccessingManagerNotificationReloadTime(manager: self)
    }
    
    /// 添加到delegate队列
    ///
    /// - Parameter delegate: 需要被通知的对象
    func isContainsDelegate(_ delegate: SW_CustomerAccessingManagerDelegate) -> Bool {
        if delegates.contains(where: { (obj) -> Bool in
            return delegate === obj
        }) {
            return true
        }
        return false
    }
    
    /// 添加到delegate队列
    ///
    /// - Parameter delegate: 需要m被通知的对象
    func removeDelegate(_ delegate: SW_CustomerAccessingManagerDelegate) {
        if let index = delegates.firstIndex(where: { (obj) -> Bool in
            return delegate === obj
        }) {
            delegates.remove(at: index)
        }
    }
    
    //开启定时器检查
    func run() {
        // 防止重复run，将之前的去除
        stop()
        /// 必须处于登录状态  且有销售通讯录的权限
//        guard let user = SW_UserCenter.shared.user, user.auth.addressBookAuth.contains(where: { return $0.type == .customer }) else { return }
        guard SW_UserCenter.shared.user != nil else { return }
        
        //每过1s通知刷新页面,先直接调用1次
        delegates.forEach({ (delegate) in
            delegate.SW_CustomerAccessingManagerNotificationReloadTime(manager: self)
        })
        timer = Timer.scheduledTimer(withTimeInterval: 1, block: { [weak self] (timer) in
            ///
            guard let self = self else { return }
            self.delegates.forEach({ (delegate) in
                delegate.SW_CustomerAccessingManagerNotificationReloadTime(manager: self)
            })
            }, repeats: true)
        /// 不添加这个模式scrollview滚动时定时器会停止
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    //关闭定时器
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //TODO: 逻辑较复杂，修改请慎重！
    /// 计算时间差字符串，如果超过限定时间则通知删除代理
    ///
    /// - Parameters:
    ///   - accessStartDate: 销售接待开始时间
    ///   - tryDriveStartDate: 试乘试驾开始时间
    ///   - tryDriveEndTime: 试乘试驾结束时间 如果开启并结束了也会有start跟end time
    /// - Returns: (String,String,Bool,Bool)   第一个是销售接待时间f字符串， 第二个是试乘试驾字符串，第三个是试驾按钮是否能点击的控制变量，第四个是是否删除代理停止计时
    class func calculateTimeLabel(accessStartTime: TimeInterval, tryDriveStartTime: TimeInterval, tryDriveEndTime: TimeInterval) -> (String,String,Bool?,Bool) {
        /// 当前时间
        let currentDate = Date()
        
        if tryDriveStartTime == 0 {// =0 代表没有开启过试乘试驾
            /// 没有试乘试驾，有两种情况：1、销售接待<5h，正常计时，2、销售接待>5, 停止计时，等待员工手动结束接待流程
            let startDate = Date.dateWith(timeInterval: accessStartTime)
            let commponent = Calendar.current.dateComponents([.hour,.minute,.second], from: startDate, to: currentDate)
            if commponent.hour! >= AccessMaxTime {
                return ("0\(AccessMaxTime):00:00","00:00:00",false,true)
            } else {
                return ("\(String(format:"%.2d",commponent.hour!)):\(String(format:"%.2d",commponent.minute!)):\(String(format:"%.2d",commponent.second!))","00:00:00",nil,false)
            }
        } else if tryDriveEndTime != 0 {/// 试驾开启过，并且已经结束了。
            /*
             * 计算试驾结束时间距离销售接待时间是否超过 5小时，if 》 5小时，停止计时，显示计时时间  ， if 《 5小时，s当做没有开启试驾逻辑处理
             *
             */
            let accessStartDate = Date.dateWith(timeInterval: accessStartTime)
            let tryDriveEndDate = Date.dateWith(timeInterval: tryDriveEndTime)
            /// 试驾end - 销售start 的时间差
            let dateCommponent = Calendar.current.dateComponents([.hour,.minute,.second], from: accessStartDate, to: tryDriveEndDate)
            /// 时间差已经大于5小时
            if dateCommponent.hour! > AccessMaxTime {
                return ("\(String(format:"%.2d",dateCommponent.hour!)):\(String(format:"%.2d",dateCommponent.minute!)):\(String(format:"%.2d",dateCommponent.second!))","00:00:00",false,true)
            } else {/// 时间小于5小时，按照没开启试驾的逻辑处理
                let commponent = Calendar.current.dateComponents([.hour,.minute,.second], from: accessStartDate, to: currentDate)
                if commponent.hour! >= AccessMaxTime {
                    return ("0\(AccessMaxTime):00:00","00:00:00",false,true)
                } else {
                    return ("\(String(format:"%.2d",commponent.hour!)):\(String(format:"%.2d",commponent.minute!)):\(String(format:"%.2d",commponent.second!))","00:00:00",nil,false)
                }
            }
        } else {// 试驾开启并且还没结束，按照以前的逻辑可用，用当前时间做计算
            /*
             * 如果有试乘试驾，1、试乘试驾<2h, 试乘试驾和销售接待均正常计时，等待员工结束试乘试驾流程
             * 2、试乘试驾>2h，停止试乘试驾计时，此时如果销售接待两种情况：1、销售接待<5h，正常计时，2、销售接待>5, 停止计时，等待员工手动结束接待流程
             */
            let tryDriveStartDate = Date.dateWith(timeInterval: tryDriveStartTime)
            let tryDriveCommponent = Calendar.current.dateComponents([.hour,.minute,.second], from: tryDriveStartDate, to: currentDate)
            let accessStartDate = Date.dateWith(timeInterval: accessStartTime)
            let accessCommponent = Calendar.current.dateComponents([.hour,.minute,.second], from: accessStartDate, to: currentDate)
            
            if tryDriveCommponent.hour! >= TryDriveMaxTime {
                /// 试乘试驾>2h，停止试乘试驾计时，此时如果销售接待两种情况：1、销售接待<5h，正常计时，2、销售接待>5, 停止计时，等待员工手动结束接待流程
                if accessCommponent.hour! >= AccessMaxTime {
                    let tryDriveEndDate = Date.dateWith(timeInterval: tryDriveStartTime + TimeInterval(TryDriveMaxTime*60*60*1000))
                    let tryDriveEndCommponent = Calendar.current.dateComponents([.hour,.minute,.second], from: accessStartDate, to: tryDriveEndDate)
                    /// 判断试乘试驾结束时，销售接待时间结束没有，
                    if tryDriveEndCommponent.hour! >= AccessMaxTime {
                        /// 如果结束了，要判断试乘试驾结束时间有没超过7小时，超过显示7小时
                        if tryDriveEndCommponent.hour! >= AccessMaxTime + TryDriveMaxTime {
                            return ("0\(AccessMaxTime + TryDriveMaxTime):00:00","0\(TryDriveMaxTime):00:00",nil,true)
                        } else {
                            /// 没超过7小时则显示时间差
                            return ("\(String(format:"%.2d",tryDriveEndCommponent.hour!)):\(String(format:"%.2d",tryDriveEndCommponent.minute!)):\(String(format:"%.2d",tryDriveEndCommponent.second!))","0\(TryDriveMaxTime):00:00",nil,true)
                        }
                    } else {
                        return ("0\(AccessMaxTime):00:00","0\(TryDriveMaxTime):00:00",nil,true)
                    }
                } else {
                    return ("\(String(format:"%.2d",accessCommponent.hour!)):\(String(format:"%.2d",accessCommponent.minute!)):\(String(format:"%.2d",accessCommponent.second!))","0\(TryDriveMaxTime):00:00",nil,false)
                }
            } else {
                /// 试乘试驾<2h, 试乘试驾和销售接待均正常计时，等待员工结束试乘试驾流程
                return ("\(String(format:"%.2d",accessCommponent.hour!)):\(String(format:"%.2d",accessCommponent.minute!)):\(String(format:"%.2d",accessCommponent.second!))","\(String(format:"%.2d",tryDriveCommponent.hour!)):\(String(format:"%.2d",tryDriveCommponent.minute!)):\(String(format:"%.2d",tryDriveCommponent.second!))",nil,false)
            }
        }
    }
    
    /// 清空之前的数据
    func destroy() {
        tabBarVc = nil
        accessingList = []
        delegates = []
        isFailRequest = false
        isRequesting = false
    }
    
}


/// tabbar 接待列表使用模型
class SW_AccessingListModel: NSObject {
    /// 客户id
    var customerId = ""
    /// 客户姓名
    var realName = ""
    /// 客户类型
    var customerType: CustomerType = .temp
    /// 客户头像
    var portrait = ""
    /// 临时客户编号
    var customerTempNum = ""
    /// 销售接待记录id
    var accessCustomerRecordId = ""
    /// 试乘试驾记录id
    var testDriveId = ""
    /// 正在进行的销售接待开始时间
    var accessStartDate: TimeInterval = 0
    /// 最新一条试乘试驾记录的开始时间
    var tryDriveStartDate: TimeInterval = 0
    /// 最新一条试乘试驾记录的结束时间
    var tryDriveEndDate: TimeInterval = 0
    /// 客户顾问id   用于获取访问记录列表
    var consultantInfoId = 0
    
    /// g用于标记是否需要继续计时
    var shouldCalculate = true
    
    /// 线索创建时间
    var createDate: TimeInterval = 0
    init(_ json: JSON) {
        super.init()
        customerType = CustomerType(rawValue: json["tempCustomerType"].intValue) ?? .real
        customerId = json["customerId"].stringValue
        consultantInfoId = json["consultantInfoId"].intValue
        realName = json["realName"].stringValue
        portrait = json["portrait"].stringValue
        customerTempNum = json["customerTempNum"].stringValue
        accessCustomerRecordId = json["accessCustomerRecordId"].stringValue
        testDriveId = json["testDriveId"].stringValue
        accessStartDate = json["startDate"].doubleValue
        tryDriveStartDate = json["testDriveStartDate"].doubleValue
        tryDriveEndDate = json["testDriveEndDate"].doubleValue
        createDate = json["createDate"].doubleValue
    }
    
}

