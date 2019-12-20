//
//  SW_RangeManager.swift
//  SWS
//
//  Created by jayway on 2018/5/7.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit
//import WCDBSwift

class SW_RangeManager: NSObject/*, TableCodable*/ {
    
    
//    enum CodingKeys: String, CodingTableKey {
//        typealias Root = SW_RangeManager
//        static let objectRelationalMapping = TableBinding(CodingKeys.self)
//        case name
//        case selectRegs
//        case selectBuses
//        case selectDeps
//        case selectStaffs
//    }
    
//    static let shard = SW_RangeManager()
    //添加常用范围后的名称
    var name = ""
    //选中的分区
    var selectRegs = [SW_RangeModel]() {
        didSet {
            if selectRegs != oldValue {
                selectBuses = []
                selectDeps = []
                selectStaffs = []
            }
        }
    }
    //选中的单位
    var selectBuses = [SW_RangeModel]() {
        didSet {
            if selectBuses != oldValue {
                selectDeps = []
                selectStaffs = []
            }
        }
    }
    //选中的部门
    var selectDeps = [SW_RangeModel]() {
        didSet {
            if selectDeps != oldValue {
                selectStaffs = []
            }
        }
    }
    //选中的员工
    var selectStaffs = [SW_RangeModel]()
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        selectRegs = aDecoder.decodeObject(forKey: "selectRegs") as? [SW_RangeModel] ?? []
        selectBuses = aDecoder.decodeObject(forKey: "selectBuses") as? [SW_RangeModel] ?? []
        selectDeps = aDecoder.decodeObject(forKey: "selectDeps") as? [SW_RangeModel] ?? []
        selectStaffs = aDecoder.decodeObject(forKey: "selectStaffs") as? [SW_RangeModel] ?? []
    }
    
    //后期添加编辑功能时使用该方法初始化
//    func setUpSelectRanges() {
//
//    }
    
    static let rangeDBPath = documentPath + "/Ranges.db"
    
    static let rangeCache = YYCache(path: rangeDBPath)
    
    //还有保存常用范围 需要定义保存格式
    class func saveCommonContactRange(informType: InformType, rangeManager: SW_RangeManager) {
        let newRangeM = rangeManager.copy() as! SW_RangeManager
        if var ranges = SW_RangeManager.rangeCache?.object(forKey: informType.rangeTableName) as? [SW_RangeManager] {
            ranges.append(newRangeM)
            SW_RangeManager.rangeCache?.setObject(ranges as NSCoding, forKey: informType.rangeTableName)
        } else {
            SW_RangeManager.rangeCache?.setObject([newRangeM] as NSCoding, forKey: informType.rangeTableName)
        }
        
//        let db = Database(withPath: SW_RangeManager.rangeDBPath)
//        do {
//            try db.create(table: informType.rangeTableName, of: SW_RangeManager.self)
//            //all fine with jsonData here
//        } catch {
//            //handle error
//            PrintLog(error)
//            showAlertMessage("创建数据库表失败了~！", MYWINDOW)
//        }
//
//        do {
//            try db.insertOrReplace(objects: [rangeManager], intoTable: informType.rangeTableName)
//            //all fine with jsonData here
//        } catch {
//            //handle error
//            PrintLog(error)
//            showAlertMessage("插入数据失败了~！", MYWINDOW)
//        }
        
    }
    
    //删除某个常用范围
    class func deleteCommonContactRange(informType: InformType, rangeManager: SW_RangeManager) {
        if var ranges = SW_RangeManager.rangeCache?.object(forKey: informType.rangeTableName) as? [SW_RangeManager] {
            if let index = ranges.firstIndex(where: { (range) -> Bool in
                return range == rangeManager
            }) {
                ranges.remove(at: index)
            }
            SW_RangeManager.rangeCache?.setObject(ranges as NSCoding, forKey: informType.rangeTableName)
        }
    }
    
    class func getCommonContactRange(informType: InformType) -> [SW_RangeManager] {
//        let db = Database(withPath: SW_RangeManager.rangeDBPath)

        if let ranges = SW_RangeManager.rangeCache?.object(forKey: informType.rangeTableName) as? [SW_RangeManager] {
            return ranges
        } else {
            return []
        }
        
    }
    
    //用于获取当前页面选择的范围
    func getSelectRanges(type: RangeType) -> [SW_RangeModel] {
        switch type {
        case .region:
            return selectRegs
        case .business:
            return selectBuses
        case .department:
            return selectDeps
        case .staff:
            return selectStaffs
        }
    }
    
    func getSelectRangesIdStr(type: RangeType) -> String {
        switch type {
        case .region:
            return selectRegs.map({ (model) -> String in
                return "\(model.id)"
            }).joined(separator: ",")
        case .business:
            return selectBuses.map({ (model) -> String in
                return "\(model.id)"
            }).joined(separator: ",")
        case .department:
            return selectDeps.map({ (model) -> String in
                return "\(model.busId)_\(model.id)"
            }).joined(separator: ",")
        case .staff:
            return ""
        }
    }
    
    func getSelectRangesPeopleCount() -> String {
        if selectStaffs.count > 0 {
            return "\(selectStaffs.count)人"
        }
        if selectDeps.count > 0 {
            let count = selectDeps.reduce(0) { (rusult, model) -> Int in
                return rusult + model.staffCount
            }
            return "\(count)人"
        }
        if selectBuses.count > 0 {
            let count = selectBuses.reduce(0) { (rusult, model) -> Int in
                return rusult + model.staffCount
            }
            return "\(count)人"
        }
        if selectRegs.count > 0 {
            let count = selectRegs.reduce(0) { (rusult, model) -> Int in
                return rusult + model.staffCount
            }
            return "\(count)人"
        }
        return "0人"
    }
    
//  获取发生时传递的参数
    func getSelectRangesTypeAndIdStr() -> (RangeType,String) {
        if selectStaffs.count > 0 {
            let idStr = selectStaffs.map({ (model) -> String in
                return "\(model.id)"
            }).joined(separator: ",")
            return (.staff,idStr)
        }
        if selectDeps.count > 0 {
            let idStr =  selectDeps.map({ (model) -> String in
                return "\(model.busId)_\(model.id)"
            }).joined(separator: ",")
            return (.department,idStr)
        }
        if selectBuses.count > 0 {
            let idStr =  selectBuses.map({ (model) -> String in
                return "\(model.id)"
            }).joined(separator: ",")
            return (.business,idStr)
        }
        if selectRegs.count > 0 {
             let idStr =  selectRegs.map({ (model) -> String in
                return "\(model.id)"
            }).joined(separator: ",")
            return (.region,idStr)
        }
        return (.region,"")
    }
    
    func getSelectPeopleIdStr() -> String {
        return selectStaffs.map({ (model) -> String in
            return "\(model.id)"
        }).joined(separator: "_")
    }
    
    func setSelectRange(model: SW_RangeModel) {
        switch model.type {
        case .region:
            selectRegs.append(model)
        case .business:
            selectBuses.append(model)
        case .department:
            selectDeps.append(model)
        case .staff:
            selectStaffs.append(model)
        }
    }
    
    //全选范围时使用  直接赋值整个list
    func setSelectRangesAll(type: RangeType, models: [SW_RangeModel]) {
//        for model in models {
//            if !isSelectRange(model: model) {
//                setSelectRange(model: model)
//            }
//        }
        switch type {
        case .region:
            selectRegs = models
        case .business:
            selectBuses = models
        case .department:
            selectDeps = models
        case .staff:
            selectStaffs = models
        }
    }
    
    //后面选择的都被情空过了。这里清空应该可以去除
    func removeSelectRange(model: SW_RangeModel) {//有个逻辑后面要添加  当删除分区时，后面的选择该分区下的范围都要删除
        switch model.type {
        case .region:
            if let index = selectRegs.index(where: { return $0.id == model.id }) {// 需要用id去判断  不能用对象判断
                selectRegs.remove(at: index)
//                selectBuses = selectBuses.filter( { return $0.regId != model.id})
//                selectDeps = selectDeps.filter( { return $0.regId != model.id})
//                selectStaffs = selectStaffs.filter( { return $0.regId != model.id})
            }
        case .business:
            if let index = selectBuses.index(where: { return $0.id == model.id }) {
                selectBuses.remove(at: index)
//                selectDeps = selectDeps.filter( { return $0.busId != model.id})
//                selectStaffs = selectStaffs.filter( { return $0.busId != model.id})
            }
        case .department:
            if let index = selectDeps.index(where: { return $0.id == model.id && $0.busId == model.busId }) {
                selectDeps.remove(at: index)
//                selectStaffs = selectStaffs.filter( { return !($0.depId == model.id && $0.busId == model.busId) })
            }
        case .staff:
            if let index = selectStaffs.index(where: { return $0.id == model.id }) {
                selectStaffs.remove(at: index)
            }
        }
    }
    
    func removeSelectRanges(type: RangeType) {
        switch type {
        case .region:
            selectRegs = [SW_RangeModel]()
        case .business:
            selectBuses = [SW_RangeModel]()
        case .department:
            selectDeps = [SW_RangeModel]()
        case .staff:
            selectStaffs = [SW_RangeModel]()
        }
    }
    
    /// 全选传入的员工
    ///
    /// - Parameter models: 全选的员工
    func selectAllStaffs(staffs: [SW_RangeModel]) {
        for staff in staffs {
            if !isSelectRange(model: staff) {
                selectStaffs.append(staff)
            }
        }
    }
    
    /// 取消全选传入的员工
    ///
    /// - Parameter models: 取消全选的员工
    func cancelSelectAllStaffs(staffs: [SW_RangeModel]) {
        for staff in staffs {
            if let index = selectStaffs.firstIndex(where: { return $0.id == staff.id }) {
                selectStaffs.remove(at: index)
            }
        }
    }
    
    
    func isSelectRange(model: SW_RangeModel) -> Bool {
        switch model.type {
        case .region:
            return selectRegs.contains(where: { return $0.id == model.id })// 需要用id去判断  不能用对象判断
        case .business:
            return selectBuses.contains(where: { return $0.id == model.id })
        case .department:
            return selectDeps.contains(where: { return $0.id == model.id && $0.busId == model.busId })
        case .staff:
            return selectStaffs.contains(where: { return $0.id == model.id })
        }
    }
    
    func isSelectRangesAll(type: RangeType, models: [SW_RangeModel]) -> Bool {
        if models.isEmpty { return false }
        for model in models {
            if isSelectRange(model: model) {
                continue
            } else {
                return false
            }
        }
        return true
//        switch type {
//        case .region:
//            return selectRegs.count == models.count
//        case .business:
//            return selectBuses.count == models.count
//        case .department:
//            return selectDeps.count == models.count
//        case .staff:
//            return selectStaffs.count == models.count
//        }
    }
    
    func clearAllSelect() {
        
        selectRegs = [SW_RangeModel]()
        
        selectBuses = [SW_RangeModel]()
        
        selectDeps = [SW_RangeModel]()
        
        selectStaffs = [SW_RangeModel]()
    }
    
    //获取当前页面下选中的范围
//    func getCurrentRanges(type: RangeType, regId: Int = 0, busId: Int = 0, depId: Int = 0) -> [SW_RangeModel] {
//        
//        switch type {
//        case .region:
//            return selectRanges
//        case .business:
//            
//        case .department:
//        case .staff:
//        
//        }
//        
//        
//    }
    
    
}

//MARK: - NSCoding
extension SW_RangeManager: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(selectRegs, forKey: "selectRegs")
        aCoder.encode(selectBuses, forKey: "selectBuses")
        aCoder.encode(selectDeps, forKey: "selectDeps")
        aCoder.encode(selectStaffs, forKey: "selectStaffs")
    }
    
}

//MARK: - NSCopying
extension SW_RangeManager: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let copyObj = SW_RangeManager()
        copyObj.name = name
        copyObj.selectRegs = selectRegs
        copyObj.selectBuses = selectBuses
        copyObj.selectDeps = selectDeps
        copyObj.selectStaffs = selectStaffs
        return copyObj
    }
    
}

