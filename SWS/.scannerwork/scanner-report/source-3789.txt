//
//  SW_SQLiteManager.swift
//  SWS
//
//  Created by jayway on 2017/12/29.
//  Copyright © 2017年 yuanrui. All rights reserved.
//

import UIKit
import FMDB
class SW_SQLiteManager: NSObject {
    //MARK: - 创建类的静态实例变量 <单例对象>  //let 是线程安全的
    static let instance = SW_SQLiteManager()
    //对外提供创建单例对象的接口
    class func shareInstance() -> SW_SQLiteManager {
        return instance
    }
    
    //初始化数据库
    func database() -> FMDatabase {
        //获取沙盒路径
        var path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        path = path + "/sws.db"
        //传入路径，初始化数据库，若该路径没有对应的文件，则会创建此文件
        return FMDatabase.init(path: path)
    }
    
    
    //MARK: - 创建表格
    
    /// 创建表格
    ///
    /// - Parameters:
    ///   - tableName: 表名称
    ///   - arFields: 表字段
    ///   - arFieldsType: 表属性
    func SWSCreateTable(tableName:String , arFields:NSArray, arFieldsType:NSArray){
        let db = database()
        if db.open() {
            var  sql = "CREATE TABLE IF NOT EXISTS " + tableName + "(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "
            let arFieldsKey:[String] = arFields as! [String]
            let arFieldsType:[String] = arFieldsType as! [String]
            for i in 0..<arFieldsType.count {
                if i != arFieldsType.count - 1 {
                    sql = sql + arFieldsKey[i] + " " + arFieldsType[i] + ", "
                }else{
                    sql = sql + arFieldsKey[i] + " " + arFieldsType[i] + ")"
                }
            }
            do{
                try db.executeUpdate(sql, values: nil)
                print("数据库操作====" + tableName + "表创建成功！")
            }catch{
                print(db.lastErrorMessage())
            }
            
        }
        db.close()
        
    }
    
    //MARK: - 添加数据
    /// 插入数据
    ///
    /// - Parameters:
    ///   - tableName: 表名字
    ///   - dicFields: key为表字段，value为对应的字段值
    func SWSInsertDataToTable(tableName:String,dicFields:NSDictionary){
        let db = database()
        if db.open() {
            let arFieldsKeys:[String] = dicFields.allKeys as! [String]
            let arFieldsValues:[Any] = dicFields.allValues
            var sqlUpdatefirst = "INSERT INTO '" + tableName + "' ("
            var sqlUpdateLast = " VALUES("
            for i in 0..<arFieldsKeys.count {
                if i != arFieldsKeys.count-1 {
                    sqlUpdatefirst = sqlUpdatefirst + arFieldsKeys[i] + ","
                    sqlUpdateLast = sqlUpdateLast + "?,"
                }else{
                    sqlUpdatefirst = sqlUpdatefirst + arFieldsKeys[i] + ")"
                    sqlUpdateLast = sqlUpdateLast + "?)"
                }
            }
            do{
                try db.executeUpdate(sqlUpdatefirst + sqlUpdateLast, values: arFieldsValues)
                print("数据库操作==== 添加数据成功！")
            }catch{
                print(db.lastErrorMessage())
            }
            
        }
    }
    
    //MARK: - 修改数据
    /// 修改数据
    ///
    /// - Parameters:
    ///   - tableName: 表名称
    ///   - dicFields: key为表字段，value为要修改的值
    ///   - ConditionsKey: 过滤筛选的字段
    ///   - ConditionsValue: 过滤筛选字段对应的值
    /// - Returns: 操作结果 true为成功，false为失败
    func SWSModifyToData(tableName:String , dicFields:NSDictionary ,ConditionsKey:String ,ConditionsValue :Int)->(Bool){
        var result:Bool = false
        let arFieldsKey : [String] = dicFields.allKeys as! [String]
        var arFieldsValues:[Any] = dicFields.allValues
        arFieldsValues.append(ConditionsValue)
        var sqlUpdate  = "UPDATE " + tableName +  " SET "
        for i in 0..<dicFields.count {
            if i != arFieldsKey.count - 1 {
                sqlUpdate = sqlUpdate + arFieldsKey[i] + " = ?,"
            }else {
                sqlUpdate = sqlUpdate + arFieldsKey[i] + " = ?"
            }
            
        }
        sqlUpdate = sqlUpdate + " WHERE " + ConditionsKey + " = ?"
        let db = database()
        if db.open() {
            do{
                try db.executeUpdate(sqlUpdate, values: arFieldsValues)
                print("数据库操作==== 修改数据成功！")
                result = true
            }catch{
                print(db.lastErrorMessage())
            }
        }
        return result
    }
    
    //MARK: - 查询数据
    /// 查询数据
    ///
    /// - Parameters:
    ///   - tableName: 表名称
    ///   - arFieldsKey: 要查询获取的表字段
    /// - Returns: 返回相应数据
    func SWSSelectFromTable(tableName:String,arFieldsKey:NSArray)->([NSMutableDictionary]){
        let db = database()
        
        var arFieldsValue = [NSMutableDictionary]()       //数组
        
        
        let sql = "SELECT * FROM " + tableName
        if db.open() {
            do{
                let rs = try db.executeQuery(sql, values: nil)
                PrintLog(rs)
                while rs.next() {
                    let dicFieldsValue :NSMutableDictionary = [:]
                    for i in 0..<arFieldsKey.count {
                        dicFieldsValue.setObject(rs.string(forColumn: arFieldsKey[i] as! String) as Any, forKey: arFieldsKey[i] as! NSCopying)
                    }
                    arFieldsValue.append(dicFieldsValue)
                }
            }catch{
                print(db.lastErrorMessage())
            }
            
        }
        return arFieldsValue
    }
    
    
    
    
    

    
    
    //MARK: - 删除数据
    /// 删除数据
    ///
    /// - Parameters:
    ///   - tableName: 表名称
    ///   - FieldKey: 过滤的表字段
    ///   - FieldValue: 过滤表字段对应的值
    func SWSDeleteFromTable(tableName:String,FieldKey:String,FieldValue:Any) {
        let db = database()
        
        if db.open() {
            let  sql = "DELETE FROM '" + tableName + "' WHERE " + FieldKey + " = ?"
            
            do{
                try db.executeUpdate(sql, values: [FieldValue])
                print("删除成功")
            }catch{
                print(db.lastErrorMessage())
            }
        }
    }
    
    //MARK: -清空表数据
    func SWSTruncateFromTable(tableName: String) {
        let db = database()
        if db.open() {
            let sql = "delete from " + tableName
            
            do{
                try db.executeUpdate(sql, values: nil)
                print("删除成功")
            }catch{
                print(db.lastErrorMessage())
            }
            
            
            
        }
        
    }
    
    //MARK: -删除表格方法
    
    /// 删除表格方法
    ///
    /// - Parameter tableName: 表格名称
    func SWSDropTable(tableName:String) {
        let db = database()
        if db.open() {
            let  sql = "DROP TABLE " + tableName
            do{
                try db.executeUpdate(sql, values: nil)
                print("删除表格成功")
            }catch{
                print(db.lastErrorMessage())
            }
        }
        
    }
    
    /// 新增加表字段
    ///   原理：
    ///     修改表名，新建表，将数据从新插入
    /// - Parameters:
    ///   - tableName:表名称
    ///   - newField: 新增表字段
    ///   - dicFieldsAndType: 新表的全部字段 和字段对应的属性
    func SWSChangTable(tableName:String,newField:String, arFields:NSArray, arFieldsType:NSArray){
        let db = database()
        if db.open() {
            if !db.columnExists(newField, inTableWithName: tableName) {
                //修改表明
                let  sql = "ALTER TABLE '" + tableName + "' RENAME TO 'old_Table'"
                do{
                    try db.executeUpdate(sql, values: nil)
                    //创建表
                    SWSCreateTable(tableName: tableName, arFields: arFields, arFieldsType: arFieldsType)
                    //导入数据数据
                    SWSImportData(oldTableName: "old_Table", newTableName: tableName)
                    //删除旧表
                    SWSDropTable(tableName: "old_Table")
                }catch{
                    print(db.lastErrorMessage())
                }
                
                
            }
            
        }
    }
    
    /// 导入数据
    ///
    /// - Parameters:
    ///   - oldTableName: 临时表名
    ///   - newTableName: 原表明（增加字段的表明）
    func  SWSImportData(oldTableName:String,newTableName:String)  {
        let  db = database()
        if db.open() {
            let sql = "INSERT INTO " + newTableName + " SELECT  id,usedName, date, age, phone, ''  FROM " + oldTableName
            do{
                try db.executeUpdate(sql, values: nil)
            }catch{
                print(db.lastErrorMessage())
            }
        }
        
    }
    
    /// 新增加表字段
    ///
    /// - Parameter tableName: 表名
    func SWSChangeTableWay1(tableName:String , addField:String,addFieldType:String)  {
        let db = database()
        if db.open() {
            let sql  = "ALTER TABLE " + tableName + " ADD " + addField + addFieldType
            do{
                try db.executeUpdate(sql, values: nil)
            }catch{
                print(db.lastErrorMessage())
            }
        }
    }
    
    
    
   
    
    
    
    
    
    
    
    
    
    
//    //MARK: - 数据库操作
//    //定义数据库变量
//    var db: OpaquePointer? = nil
//    //打开数据库
//    func openDB() -> Bool {
//        //数据库文件路径
//        let dicumentPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last
//        let DBPath = (dicumentPath! as NSString).appendingPathComponent("appDB.db")
//        let cDBPath = DBPath.cString(using: String.Encoding.utf8)
//        //打开数据库
//        print(cDBPath as Any)
//        //第一个参数:数据库文件路径 第二个参数: 数据库对象
//        if sqlite3_open(cDBPath, &db) != SQLITE_OK {
//            print("数据库打开失败")
//        }
//        return creatTable()
//
//
//    }
//
//    //创建表
//    func creatTable() -> Bool {
//        //建表的SQL语句
//        let creatUserTable = "CREATE TABLE IF NOT EXISTS 't_user' ( 'ID' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,name varchar(20),phone varchar(20),account varchar(20), sex varchar(5), birthday varchar(20), prefecture varchar(20), position varchar(20), clique varchar(20), area varchar(20), company varchar(20), department varchar(20));"
////        let creatCarTable = "CREATE TABLE IF NOT EXISTS 't_Car' ('ID' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'type' TEXT,'output' REAL,'master' TEXT);"
//        //执行SQL语句-创建表 依然,项目中一般不会只有一个表   //,creatCarTable
//        return creatTableExecSQL(SQL_ARR: [creatUserTable])
//    }
//
//    //执行建表SQL语句
//    func creatTableExecSQL(SQL_ARR : [String]) -> Bool {
//        for item in SQL_ARR {
//            if execSQL(SQL: item) == false {
//                return false
//            }
//        }
//        return true
//    }
//
//
//
//    //执行SQL语句
//    func execSQL(SQL : String) -> Bool {
//        // 1.将sql语句转成c语言字符串
//        let cSQL = SQL.cString(using: String.Encoding.utf8)
//        //错误信息
//        let errmsg : UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>? = nil
//        if sqlite3_exec(db, cSQL, nil, nil, errmsg) == SQLITE_OK {
//            return true
//        }else{
//            print("SQL 语句执行出错 -> 错误信息: 一般是SQL语句写错了 \(String(describing: errmsg))")
//            return false
//        }
//    }
//
//    // 查询数据库，传入SQL查询语句，返回一个字典数组
//    func queryDataBase(querySQL : String) -> [[String : AnyObject]]? {
//        // 创建一个语句对象
//        var statement : OpaquePointer? = nil
//
//        if querySQL.lengthOfBytes(using: String.Encoding.utf8) > 0 {
//            let cQuerySQL = (querySQL.cString(using: String.Encoding.utf8))!
//            // 进行查询前的准备工作
//            // 第一个参数：数据库对象，第二个参数：查询语句，第三个参数：查询语句的长度（如果是全部的话就写-1），第四个参数是：句柄（游标对象）
//            if sqlite3_prepare_v2(db, cQuerySQL, -1, &statement, nil) == SQLITE_OK {
//                var queryDataArr = [[String: AnyObject]]()
//                while sqlite3_step(statement) == SQLITE_ROW {
//                    // 获取解析到的列
//                    let columnCount = sqlite3_column_count(statement)
//                    // 遍历某行数据
//                    var temp = [String : AnyObject]()
//                    for i in 0..<columnCount {
//                        // 取出i位置列的字段名,作为temp的键key
//                        let cKey = sqlite3_column_name(statement, i)
//                        let key : String = String(validatingUTF8: cKey!)!
//                        //取出i位置存储的值,作为字典的值value
//                        let cValue = sqlite3_column_text(statement, i)
//                        let value = String(cString: cValue!)
//                        temp[key] = value as AnyObject
//                    }
//                    queryDataArr.append(temp)
//                }
//                return queryDataArr
//            }
//        }
//        return nil
//    }
//
//
}

