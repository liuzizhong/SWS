//
//  SW_AddressBookData.swift
//  SWS
//
//  Created by jayway on 2018/4/20.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_AddressBookData: NSObject {
    
    var datas = [SW_AddressBookModel]()
    
//    case region             // 分区cell  与模型
//    case business           // 单位cell  与模型
//    case department         // 部门cell  与模型
//    case contact            // 联系人cell  与模型
    class func getDataList(_ json: [JSON], type: AddressBookType) -> [SW_AddressBookModel] {//接收一个JSON数组  返回一个Model数组？
        switch type {
        case .region:
            return json.map({ (json) -> SW_AddressBookModel in
                SW_AddressBookModel(json, type: .region)
            })
        case .business:
        return json.map({ (json) -> SW_AddressBookModel in
            SW_AddressBookModel(json, type: .business)
        })
        case .department:
        return json.map({ (json) -> SW_AddressBookModel in
            SW_AddressBookModel(json, type: .department)
        })
        case .contact:
        return json.map({ (json) -> SW_AddressBookModel in
            SW_AddressBookModel(json, type: .contact)
        })
        default:
             break
        }
        return []
    }
    
    
}
