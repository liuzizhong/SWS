//
//  AuthModel.swift
//  SWS
//
//  Created by jayway on 2019/5/14.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit


class AuthModel: NSObject {
    
    var searchCarInfoAuth = [NormalAuthModel]()
    
    var contractAuth = [NormalAuthModel]()
    
    var statisticsAuth = [StatisticsAuthModel]()
    
    var addressBookAuth = [AddressBookAuthModel]()
    
    var repairAuth = [RepairAuthModel]()
    
    var accessoriesAuth = [NormalAuthModel]()
    
    var boutiqueAuth = [NormalAuthModel]()
    
    var messageAuth = [MessageAuthModel]()
    
    var backLogAuth = [NormalAuthModel]()
    
    var carStockAuth = [NormalAuthModel]()
    
    init(json: JSON) {
        ///这里判断大于0且小于4是要把不是当前版本的type过滤掉、只留[1-3]
        statisticsAuth = json["statisticsAuth"].arrayValue.filter({ return ($0["type"].intValue < 4 && $0["type"].intValue > 0) || $0["type"].intValue == 5 }).map({ return StatisticsAuthModel($0) })
        addressBookAuth = json["addressBookAuth"].arrayValue.map({ return AddressBookAuthModel($0) })
        repairAuth = json["repairAuth"].arrayValue.map({ return RepairAuthModel($0) })
        accessoriesAuth = json["accessoriesAuth"].arrayValue.map({ return NormalAuthModel($0) })
        boutiqueAuth = json["boutiqueAuth"].arrayValue.map({ return NormalAuthModel($0) })
        messageAuth = json["messageAuth"].arrayValue.map({ return MessageAuthModel($0) })
        contractAuth = json["contractAuth"].arrayValue.map({ NormalAuthModel($0) })
        searchCarInfoAuth = json["searchCarInfoAuth"].arrayValue.map({ return NormalAuthModel($0) })
        backLogAuth = json["logbackAuth"].arrayValue.map({ return NormalAuthModel($0) })
        carStockAuth = json["carStockAuth"].arrayValue.map({ return NormalAuthModel($0) })
    }
    
    func toDictionary() -> [String: Any] {
        var dict = [String: Any]()
        dict["statisticsAuth"] = statisticsAuth.map({ return $0.toDictionary() })
        dict["addressBookAuth"] = addressBookAuth.map({ return $0.toDictionary() })
        dict["repairAuth"] = repairAuth.map({ return $0.toDictionary() })
        dict["accessoriesAuth"] = accessoriesAuth.map({ return $0.toDictionary() })
        dict["boutiqueAuth"] = boutiqueAuth.map({ return $0.toDictionary() })
        dict["messageAuth"] = messageAuth.map({ return $0.toDictionary() })
        dict["contractAuth"] = contractAuth.map({ return $0.toDictionary() })
        dict["searchCarInfoAuth"] = searchCarInfoAuth.map({ return $0.toDictionary() })
        dict["backLogAuth"] = backLogAuth.map({ return $0.toDictionary() })
        dict["carStockAuth"] = carStockAuth.map({ return $0.toDictionary() })
        return dict
    }
    
}

class StatisticsAuthModel: NSObject {
    var name = ""
    var type = StatisticalType.comprehensive
    var authDetails = [Int]()
    
    init(_ json: JSON) {
        name = json["name"].stringValue
        type = StatisticalType(rawValue: json["type"].intValue) ?? .comprehensive
        ///这里判断大于0且小于4是要把不是当前版本的type过滤掉、只留[1-3]
        authDetails = json["authDetails"].arrayValue.filter({ return $0["type"].intValue < 4 && $0["type"].intValue > 0 }).map({ return $0["type"].intValue })
    }
    
    func toDictionary() -> [String: Any] {
        var dict = [String: Any]()
        dict["name"] = name
        dict["type"] = type.rawValue
        dict["authDetails"] = authDetails.map({ return ["type": $0] })
        return dict
    }
    
}

/// 通讯录模块权限
///
/// - customer: 有销售客户通讯录权限
enum AddressBookAuthType: Int {
    case staff = 6
    case customer = 11
    case afterSale = 12
}

class AddressBookAuthModel: NSObject {
    var name = ""
    var type: AddressBookAuthType = .customer
    var authDetails = [Int]()
    
    init(_ json: JSON) {
        name = json["name"].stringValue
        type = AddressBookAuthType(rawValue: json["type"].intValue) ?? .staff
        authDetails = json["authDetails"].arrayValue.map({ return $0["type"].intValue })
    }
    
    func toDictionary() -> [String: Any] {
        var dict = [String: Any]()
        dict["name"] = name
        dict["type"] = type.rawValue
        dict["authDetails"] = authDetails.map({ return ["type": $0] })
        return dict
    }
}


/// 发送公告权限
class MessageAuthModel: NSObject {
    var name = ""
    var type = 0
    var authDetails = [InformType]() ///  0 1 2
    
    init(_ json: JSON) {
        name = json["name"].stringValue
        type = json["type"].intValue
        authDetails = json["authDetails"].arrayValue.map({ return InformType(rawValue: $0["type"].intValue - 1) ?? .group })
    }
    
    func toDictionary() -> [String: Any] {
        var dict = [String: Any]()
        dict["name"] = name
        dict["type"] = type
        dict["authDetails"] = authDetails.map({ return ["type": $0.rawValue + 1] })
        return dict
    }
    
}

/// 维修单权限
enum RepairAuthType: Int {
    case none
    case order = 18
    case construction
    case quality
    case kanban
}

class RepairAuthModel: NSObject {
    var name = ""
    var type: RepairAuthType = .none
    var authDetails = [Int]()
    
    init(_ json: JSON) {
        name = json["name"].stringValue
        type = RepairAuthType(rawValue: json["type"].intValue) ?? .none
        authDetails = json["authDetails"].arrayValue.map({ return $0["type"].intValue })
    }
    
    func toDictionary() -> [String: Any] {
        var dict = [String: Any]()
        dict["name"] = name
        dict["type"] = type.rawValue
        dict["authDetails"] = authDetails.map({ return ["type": $0] })
        return dict
    }
    
}

/// 通用权限模型
class NormalAuthModel: NSObject {
    var name = ""
    var type = 0
    var authDetails = [Int]()
    
    init(_ json: JSON) {
        name = json["name"].stringValue
        type = json["type"].intValue
        authDetails = json["authDetails"].arrayValue.map({ return $0["type"].intValue })
    }
    
    func toDictionary() -> [String: Any] {
        var dict = [String: Any]()
        dict["name"] = name
        dict["type"] = type
        dict["authDetails"] = authDetails.map({ return ["type": $0] })
        return dict
    }
    
}
