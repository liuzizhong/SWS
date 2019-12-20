//
//  SW_CustomerEnum.swift
//  SWS
//
//  Created by jayway on 2018/8/20.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Foundation

enum CustomerLevel: Int {
    case none = 0
    case h
    case a
    case b
    case c
    case o
    case f
    case m
    
    var rawColor: UIColor {
        switch self {
        case .none:
            return #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
        case .h:
            return #colorLiteral(red: 0.6705882353, green: 0.09803921569, blue: 0.5803921569, alpha: 1)
        case .a:
            return #colorLiteral(red: 0.7921568627, green: 0.03529411765, blue: 0.03529411765, alpha: 1)
        case .b:
            return #colorLiteral(red: 0.862745098, green: 0.5098039216, blue: 0, alpha: 1)
        case .c:
            return #colorLiteral(red: 0.831372549, green: 0.7215686275, blue: 0.003921568627, alpha: 1)
        case .o:
            return #colorLiteral(red: 0, green: 0.6352941176, blue: 0.03137254902, alpha: 1)
        case .f:
            return #colorLiteral(red: 0.6117647059, green: 0.6117647059, blue: 0.6117647059, alpha: 1)
        case .m:
            return #colorLiteral(red: 0.09803921569, green: 0.07450980392, blue: 1, alpha: 1)
        }
    }
    
    /// o m  后期改成系统自动设置、不能人为修改，
    var tipText: NSAttributedString {
        var text: String
        var day = ""
        switch self {
        case .none:
            text = ""
        case .h:
            text = "距上次接待或访问2天跟进一次"
            day = "2天"
        case .a:
            text = "距上次接待或访问4天跟进一次"
            day = "4天"
        case .b:
            text = "距上次接待或访问6天跟进一次"
            day = "6天"
        case .c:
            text = "距上次接待或访问9天跟进一次"
            day = "9天"
        case .o:
            text = "已成交,暂时停止跟进"
        case .f:
            text = "已战败,暂时停止跟进"
        case .m:
            text = "已交车,暂时停止跟进"
        }
        return (text as NSString).mutableAttributedString(day, andColor: UIColor.v2Color.blue)
    }
    
//    H:#AB1994         A:#CA0909    B:#DC8200       C:#D4B801     O:#00A208  F:#9C9C9C
    var rawString: String {
        switch self {
        case .none:
            return ""
        case .h:
            return "H"
        case .a:
            return "A"
        case .b:
            return "B"
        case .c:
            return "C"
        case .o:
            return "O"
        case .f:
            return "F"
        case .m:
            return "M"
        }
    }
    
    init(_ title: String) {
        switch title {
        case "H":
            self = .h
        case "A":
            self = .a
        case "B":
            self = .b
        case "C":
            self = .c
        case "O":
            self = .o
        case "F":
            self = .f
        case "M":
            self = .m
        default:
            self = .none
        }
    }
}

/// 客户来源
enum CustomerSource: Int {
    case none = 0
    case networkPhone
    case store
    case visit
    case outside
    case motorShow
    case introduce
    case other
    
    var rawString: String {
        switch self {
        case .none:
            return ""
        case .networkPhone:
            return "网络/电话"
        case .store:
            return "来店"
        case .visit:
            return "走访"
        case .outside:
            return "外拓"
        case .motorShow:
            return "车展"
        case .introduce:
            return "转介绍"
        case .other:
            return "其他"
        }
    }
    
    init(_ title: String) {
        switch title {
        case "网络/电话":
            self = .networkPhone
        case "来店":
            self = .store
        case "走访":
            self = .visit
        case "外拓":
            self = .outside
        case "车展":
            self = .motorShow
        case "转介绍":
            self = .introduce
        case "其他":
            self = .other
        default:
            self = .none
        }
    }
}

/// 客户来源网站
enum CustomerSourceSite: Int {
    case none = 0
    case haoche
    case yiche
    case qichezhijia
    case aikaqiche
    case taipingyang
    case other
    case dongchedi
    case four00
    
    var rawString: String {
        switch self {
        case .none:
            return ""
        case .haoche:
            return "好车网"
        case .yiche:
            return "易车网"
        case .qichezhijia:
            return "汽车之家"
        case .aikaqiche:
            return "爱卡汽车网"
        case .taipingyang:
            return "太平洋汽车网"
        case .other:
            return "其他网站"
        case .dongchedi:
            return "懂车帝"
        case .four00:
            return "400"
        }
    }
    
    init(_ title: String) {
        switch title {
        case "好车网":
            self = .haoche
        case "易车网":
            self = .yiche
        case "汽车之家":
            self = .qichezhijia
        case "爱卡汽车网":
            self = .aikaqiche
        case "太平洋汽车网":
            self = .taipingyang
        case "其他网站":
            self = .other
        case "懂车帝":
            self = .dongchedi
        case "400":
            self = .four00
        default:
            self = .none
        }
    }
}


/// 汽车使用类型
enum UseforType: Int {
    case none = 0
    case corporateHospitality
    case office
    case insteadWalking
    case travel
    case ordinaryHousehold
  
    
    var rawString: String {
        switch self {
        case .none:
            return ""
        case .corporateHospitality:
            return "商务接待"
        case .office:
            return "办公"
        case .insteadWalking:
            return "代步"
        case .travel:
            return "旅行"
        case .ordinaryHousehold:
            return "普通家用"
        }
    }
    
    init(_ title: String) {
        switch title {
        case "商务接待":
            self = .corporateHospitality
        case "办公":
            self = .office
        case "代步":
            self = .insteadWalking
        case "旅行":
            self = .travel
        case "普通家用":
            self = .ordinaryHousehold
        default:
            self = .none
        }
    }
}


/// 汽车购买方式
enum BuyWay: Int {
    case none = 0
    case mortgage
    case full
   
    var rawString: String {
        switch self {
        case .none:
            return ""
        case .mortgage:
            return "按揭"
        case .full:
            return "全款"
        }
    }
    
    init(_ title: String) {
        switch title {
        case "按揭":
            self = .mortgage
        case "全款":
            self = .full
        default:
            self = .none
        }
    }
}

/// 汽车购买类型
enum BuyType: Int {
    case none = 0
    case first
    case additional
    case replace
    
    var rawString: String {
        switch self {
        case .none:
            return ""
        case .first:
            return "初购"
        case .additional:
            return "增购"
        case .replace:
            return "换购"
        }
    }
    
    init(_ title: String) {
        switch title {
        case "初购":
            self = .first
        case "增购":
            self = .additional
        case "换购":
            self = .replace
        default:
            self = .none
        }
    }
}


/// 客户访问方式
enum AccessType: Int {
    case none = 0
    case phone
    case store
    case motorShow
    case salesReception
    case tryDrive
    
    var rawString: String {
        switch self {
        case .none:
            return ""
        case .phone:
            return "电话访问"
        case .store:
            return "上门访问"
        case .motorShow:
            return "车展访问"
        case .salesReception:
            return "销售接待"
        case .tryDrive:
            return "试乘试驾"
        }
    }
    
//    var typeImage: UIImage {
//        switch self {
//        case .none:
//            return #imageLiteral(resourceName: "one")
//        case .phone:
//            return #imageLiteral(resourceName: "four")
//        case .store:
//            return #imageLiteral(resourceName: "five")
//        case .motorShow:
//            return #imageLiteral(resourceName: "one")
//        case .salesReception:
//            return #imageLiteral(resourceName: "three")
//        case .tryDrive:
//            return #imageLiteral(resourceName: "two")
//        }
//    }
    
    init(_ title: String) {
        switch title {
        case "电话":
            self = .phone
        case "上门":
            self = .store
        case "车展":
            self = .motorShow
        case "销售接待":
            self = .salesReception
        case "试乘试驾":
            self = .tryDrive
        default:
            self = .none
        }
    }
    
}

enum ComeStoreType: Int {
    case none = 0
    case other
    case invitation
    
    var rawString: String {
        switch self {
        case .none:
            return ""
        case .other:
            return "其他"
        case .invitation:
            return "邀约"
        }
    }
    
    init(_ title: String) {
        switch title {
        case "其他":
            self = .other
        case "邀约":
            self = .invitation
        default:
            self = .none
        }
    }
}

/// 客户满意度类型
enum SatisfactionType: Int {
    case none = 0
    case notSatisfied
    case general
    case satisfied
    
    var rawString: String {
        switch self {
        case .none:
            return ""
        case .notSatisfied:
            return "不满意"
        case .general:
            return "一般"
        case .satisfied:
            return "满意"
        }
    }
    
    init(_ title: String) {
        switch title {
        case "不满意":
            self = .notSatisfied
        case "一般":
            self = .general
        case "满意":
            self = .satisfied
        default:
            self = .none
        }
    }
}


/// 售后客户访问方式
enum AfterSaleAccessType: Int {
    case none = 0
    case phone
    case afterSalesReception
    
    var rawString: String {
        switch self {
        case .none:
            return ""
        case .phone:
            return "电话访问"
        case .afterSalesReception:
            return "维修接待"
        }
    }
    
    init(_ title: String) {
        switch title {
        case "电话访问":
            self = .phone
        case "维修接待":
            self = .afterSalesReception
        default:
            self = .none
        }
    }
    
}
