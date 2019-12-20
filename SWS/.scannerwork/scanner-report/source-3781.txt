//
//  SW_BadgeManager.swift
//  SWS
//
//  Created by jayway on 2018/7/17.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_BadgeManager: NSObject {
    
    static let shared = SW_BadgeManager()
    
    var workBadge = WorkNoticeModel()

    var repairOrderNotice = RepairOrderNoticeModel()
    
    var backLogModel = BackLogModel()
    
    private var timer: Timer?
    
    private var isRequesting = false
    
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { [weak self] (notifi) in
            self?.stop()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] (notifi) in
            self?.run()
        }
    }
    
//    module
    
//    "workNotice" : {
//    "receiveWorkNotice" : {
//    "isNewNotice" : 1,
//    "day" : 1,
//    "month" : 0,
//    "year" : 0
//    },
//    "myWorkNotice" : {
//    "isNewNotice" : 1,
//    "day" : 1,
//    "month" : 0,
//    "year" : 0
//    },
//    "isNewNotice" : 1
//    }
    
//    "repairOrderNotice": {
//    "repairNotice": true,
//    "constructionNotice": false,
//    "qualityNotice": false
//    }
    
    func getBadgeState() {
        guard !isRequesting else { return }
        guard let user = SW_UserCenter.shared.user else { return }
        isRequesting = true
        //TODO: 这个接口中的1代表true 其余一些之前的旧接口是0代表true，现在新接口使用1为true
        let request = SWSRequest(resource: "newNotice/\(user.id).json")
        request.apiURL = SWSApiCenter.getBaseUrl() + "/api/app/notice"
        request.send(.get).completion { (json, error) -> Any? in
            if error == nil {
                return json?["data"]
            }
            return json
            }.response({ (json, isCache, error) in
                self.isRequesting = false
                if let json = json as? JSON, error == nil {
                    self.workBadge = WorkNoticeModel(json["workNotice"])
                    self.repairOrderNotice = RepairOrderNoticeModel(json["repairOrderNotice"])
                    ///通知刷新页面
                    NotificationCenter.default.post(name: NSNotification.Name.Ex.RedDotNotice, object: nil)
                }
            })
    }
    
    //开启定时器检查
    func run() {
        // 防止重复run，将之前的去除
        stop()
        guard SW_UserCenter.shared.user != nil else { return }
        //启动先获取一次
        getBadgeState()
        //定时300s获取一次红点状态。
        timer = Timer.scheduledTimer(withTimeInterval: 600, block: { [weak self] (timer) in
            self?.getBadgeState()
            }, repeats: true)
    }
    
    //关闭定时器
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

class RepairOrderNoticeModel: NSObject {
    //    "repairOrderNotice": {
    //    "repairNotice": true,
    //    "constructionNotice": false,
    //    "qualityNotice": false
    //    }
    var repairNotice = false
    var constructionNotice = false
    var qualityNotice = false
    
    override init() {
        super.init()
    }
    
    init(_ json: JSON) {
        super.init()
        repairNotice = json["repairNotice"].boolValue
        constructionNotice = json["constructionNotice"].boolValue
        qualityNotice = json["qualityNotice"].boolValue
    }
}

class WorkNoticeModel: NSObject {
    //工作模块红点
    var workModule: Bool {
        get {
            return receiveWorkNotice || myWorkNotice
        }
    }
    
    var receiveWorkNotice = false//我收到的模块红点
    
    var receiveDay = false//收到的工作日志工地
    
    var receiveMonth = false//收到的月度红点
    
    var receiveYear = false//收到的年度红点
    
    var myWorkNotice = false//我发起的模块红点
    
    var myDay = false//我的工作日志红点
    
    var myMonth = false//我的月度红点
    
    var myYear = false//我的年度红点
    
    override init() {
        super.init()
    }
    
    init(_ json: JSON) {
        super.init()
        receiveWorkNotice = json["receiveWorkNotice"]["isNewNotice"].intValue == 1
        receiveDay = json["receiveWorkNotice"]["day"].intValue == 1
        receiveMonth = json["receiveWorkNotice"]["month"].intValue == 1
        receiveYear = json["receiveWorkNotice"]["year"].intValue == 1
        myWorkNotice = json["myWorkNotice"]["isNewNotice"].intValue == 1
        myDay = json["myWorkNotice"]["day"].intValue == 1
        myMonth = json["myWorkNotice"]["month"].intValue == 1
        myYear = json["myWorkNotice"]["year"].intValue == 1
    }
}

/// 待办事项的s数量
class BackLogModel: NSObject {
    /// 总待办事项个数
    var totalCount: Int {/// 暂时只有这两个m，其他忽略
        return saleOrderCount + repairOrderCount
    }
    /// 销售合同待办事项个数
    var saleOrderCount = 0
    /// 维修单待办事项个数
    var repairOrderCount = 0
    /// 保险合同待办事项个数
    var insuranceContractCount = 0
    /// 保险单待办事项个数
    var insuranceOrderCount = 0
    
    override init() {
        super.init()
    }
    
    init(_ json: JSON) {
        super.init()
//        totalCount = json["totalCount"].intValue
        saleOrderCount = json["saleOrderCount"].intValue
        repairOrderCount = json["repairOrderCount"].intValue
        insuranceContractCount = json["insuranceContractCount"].intValue
        insuranceOrderCount = json["insuranceOrderCount"].intValue
    }
}




