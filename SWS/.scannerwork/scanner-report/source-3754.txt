//
//  extension_Date.swift
//  SWS
//
//  Created by jayway on 2018/4/10.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Foundation


// MARK: Date的工具类
/// Date的格式化类型
///
/// - minite: "HH:mm"
/// - month: "MM-dd"
/// - monthMinite: "MM-dd HH:mm"
/// - year: "yyyy-MM-dd"
/// - yearNoLine: "yyyyMMdd"
/// - yearMinite: "yyyy-MM-dd HH:mm"
/// - full: "yyyy-MM-dd HH:mm:ss"
/// - monthChinese: "MM月dd日"
/// - yearChinese: "yyyy年MM月dd日"
/// - yearMiniteChinese: "yyyy年MM月dd日 HH:mm"
@objc enum TimeFormat: Int {
    case minite
    case month
    case monthMinite
    case year
    case yearNoLine
    case yearMinite
    case full
    case monthChinese
    case yearChinese
    case yearMiniteChinese
    case yearMonth
    case monthMiniteChinese
}

extension Date {
    
    /// 本APP通用时间转换--将时间戳转成Date
    ///
    /// - Parameters:
    ///   - timeInterval: 三惠通用的时间戳数值
    /// - Returns: 返回转换出来的Date
    static func dateWith(timeInterval: TimeInterval) -> Date {
        return Date(timeIntervalSince1970: timeInterval/1000.0)
    }
    
    /// 本APP通用时间转换--将Date转成时间戳
    ///
    /// - Returns: 三惠通用时间戳
    func getCurrentTimeInterval() -> TimeInterval {
        return TimeInterval(Int(self.timeIntervalSince1970*1000))
    }
    
    /// 将时间串转成Date
    ///
    /// - Parameters:
    ///   - formatStr: 格式化的串(yyyy-MM-dd HH:mm)
    ///   - dateString: 传入的时间串(2017-11-29 08:00)
    /// - Returns: 返回转换出来的Date
    static func dateWith(formatStr: String, dateString: String) -> Date? {
        let dateFormatter = DateFormatter.cacheFormatter()
        dateFormatter.dateFormat = formatStr
        return dateFormatter.date(from: dateString)
    }
    
    /// 日期格式化成字串
    ///
    /// - Parameter formatStr: 格式化的字串，如yyyy-MM-dd
    /// - Returns: 格式化好的字串 2017-05-24
    func stringWith(formatStr: String) -> String {
        let dateFormatter = DateFormatter.cacheFormatter()
        dateFormatter.dateFormat = formatStr
        return dateFormatter.string(from: self)
    }
    
    /// 常用的日期格式转换
    ///
    /// - Parameter formatter: 格式化类型TimeFormat
    /// - Returns: 格式化好的字串
    func simpleTimeString(formatter: TimeFormat) -> String {
        if  formatter == .minite {
            return self.stringWith(formatStr: "HH:mm")
        } else if formatter == .month {
            if self.isSameYear(Date()) {
                return self.stringWith(formatStr: "MM/dd")
            }
            return self.stringWith(formatStr: "yyyy/MM/dd")
        }  else if formatter == .monthMinite {
            return self.stringWith(formatStr: "MM/dd HH:mm")
        } else if  formatter == .year {
            return self.stringWith(formatStr: "yyyy/MM/dd")
        } else if  formatter == .yearNoLine {
            return self.stringWith(formatStr: "yyyyMMdd")
        } else if  formatter == .yearMinite {
            return self.stringWith(formatStr: "yyyy/MM/dd HH:mm")
        } else if  formatter == .monthChinese {
            return self.stringWith(formatStr: "MM月dd日")
        } else if  formatter == .yearChinese {
//            if self.isSameYear(Date()) {
//                return self.stringWith(formatStr: "M月d日")
//            }
            return self.stringWith(formatStr: "yyyy年M月d日")
        } else if  formatter == .yearMiniteChinese {
            return self.stringWith(formatStr: "yyyy年M月d日 HH:mm")
        } else if  formatter == .full {
            return self.stringWith(formatStr: "yyyy/MM/dd HH:mm:ss")
        } else if  formatter == .yearMonth {
            return self.stringWith(formatStr: "yyyy/MM")
        } else if formatter == .monthMiniteChinese {
            return self.stringWith(formatStr: "M月d日 HH:mm")
        }
        return self.stringWith(formatStr: "yyyy/MM/dd")
    }
    
    /// 是不是0点
    ///
    /// - Returns: Bool值，是否是0点
    func isZero() -> Bool {
        let formatStr = self.stringWith(formatStr: "HH:mm:ss")
        if formatStr == "00:00:00" {
            return true
        }
        return false
    }
    
    /// 判断时间是否是12小时制
    ///
    /// - Returns: 返回Bool值
    func isTwelveHour() -> Bool {
        if let formatStringForHours = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current) {
            if formatStringForHours.contains("a") {
                //十二小时制
                return true
            }
        }
        return false
    }
    
    /// 年
    ///
    /// - Returns: 返回Date对应的年
    func year() -> Int {
        return (self as NSDate).year()
    }
    
    /// 月
    ///
    /// - Returns: 返回Date对应的月
    func month() -> Int {
        return (self as NSDate).month()
    }
    
    /// 日
    ///
    /// - Returns: 返回Date对应的日
    func day() -> Int {
        return (self as NSDate).day()
    }
    
    /// 周
    ///
    /// - Returns: 返回Date对应的日
    func week() -> String {
        return (self as NSDate).weekString()
    }
    
    /// 同年、月、日枚举
    ///
    /// - sameYear: 同年
    /// - sameMonth: 同月
    /// - sameDay: 同日
    enum JudgeYearMonthDay {
        case sameYear
        case sameMonth
        case sameDay
    }
    
    /// 是否同一天
    ///
    /// - Parameter date: 传入的时间
    /// - Returns: 返回Bool值
    func isSameDay(_ date : Date) -> Bool {
        return self.judgeYearMonthDay(judgeType: .sameDay, date: date)
    }
    
    /// 是否同一月
    ///
    /// - Parameter date: 传入的时间
    /// - Returns: 返回Bool值
    func isSameMonth(_ date : Date) -> Bool {
        return self.judgeYearMonthDay(judgeType: .sameMonth, date: date)
    }
    
    /// 是否同一年
    ///
    /// - Parameter date: 传入的时间
    /// - Returns: 返回Bool值
    func isSameYear(_ date : Date) -> Bool{
        return self.judgeYearMonthDay(judgeType: .sameYear, date: date)
    }
    
    func judgeYearMonthDay(judgeType : JudgeYearMonthDay, date : Date) -> Bool {
        let calendar : Calendar = Calendar.current
        let calendarUnit: NSCalendar.Unit = [NSCalendar.Unit.day, NSCalendar.Unit.month, NSCalendar.Unit.year]
        let components = (calendar as NSCalendar).components(calendarUnit, from: date)
        let selfComponents = (calendar as NSCalendar).components(calendarUnit, from: self)
        
        if judgeType == .sameYear {
            return components.year == selfComponents.year
        } else if judgeType == .sameMonth {
            return (components.year == selfComponents.year && components.month == selfComponents.month)
        } else {
            return (components.year == selfComponents.year && components.month == selfComponents.month && components.day == selfComponents.day)
        }
    }
    
    
    
    /// 从某个日期开始有多少周
    ///
    /// - Parameter date: 传入的日期
    /// - Returns: 返回周数
    var weekOfYear: Int {
        get {
            return (Calendar.current as NSCalendar).components(.weekOfYear, from: self).weekOfYear!
        }
    }
    
    
    //生成文件名规则（YYYYMMddHHmmssSSS+4位随机数）
    ///
    /// - Returns: 返回生成的文件名
    func generateFileName() -> String {
        let string = stringFromFormat("YYYYMMddHHmmssSSS")
        let max: UInt32 = 9999
        let min: UInt32 = 1000
        let random = arc4random_uniform(max - min) + min
        return string + "\(random)"
    }
    
}

// MARK: NSDate的工具类
public func <(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSince1970 < rhs.timeIntervalSince1970
}

public func <=(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSince1970 <= rhs.timeIntervalSince1970
}

public func >=(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSince1970 >= rhs.timeIntervalSince1970
}

public func >(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSince1970 > rhs.timeIntervalSince1970
}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool {
    return lhs.timeIntervalSince1970 == rhs.timeIntervalSince1970
}

extension NSDate {
    /// 日期格式化成字串
    ///
    /// - Parameter formatStr: 格式化的字串，如yyyy-MM-dd
    /// - Returns: 格式化好的字串 2017-05-24
    func dateFormatter(format : String) -> String {
        return (self as Date).stringWith(formatStr: format)
    }
    
    /// 常用的日期格式转换
    ///
    /// - Parameter formatter: 格式化类型TimeFormat
    /// - Returns: 格式化好的字串
    func simpleTimeString(formatter: TimeFormat) -> String {
        return (self as Date).simpleTimeString(formatter: formatter)
    }
    
    /// 是否同一月
    ///
    /// - Parameter date: 传入的时间
    /// - Returns: 返回Bool值
    func isSameMonth(_ date : Date) -> Bool{
        return (self as Date).isSameMonth(date)
    }
    
    /// 是否同一天
    ///
    /// - Parameter date: 传入的时间
    /// - Returns: 返回Bool值
    func isSameDay(_ date : Date) -> Bool{
        return (self as Date).isSameDay(date)
    }
    
    //生成文件名规则（YYYYMMddHHmmssSSS+4位随机数）
    ///
    /// - Returns: 返回生成的文件名
    func generateFileName() -> String {
        return (self as Date).generateFileName()
    }
    
}

// MARK: DateFormatter
extension DateFormatter {
    private static let cache = NSCache<NSString, DateFormatter>()
    
    /// DateFormatter的初始化(优先取缓存，没有创建)
    ///
    /// - Returns: 返回‘DateFormatter’实例
    class func cacheFormatter() -> DateFormatter {
        let key = "DateFormatter" as NSString
        if let formatter = cache.object(forKey: key) {
            return formatter
        } else {
            let formatter = DateFormatter()
            cache.setObject(formatter, forKey: key)
            return formatter
        }
    }
}

// MARK: Date的工具类
extension Date {
    //是否是今天
    func isTodayDate() -> Bool {
        return self.isSameDay(Date())
    }
    
    //是否是昨天
    func isYesterday() -> Bool {
        return self.isSameDay(Date(timeIntervalSinceNow: -24.0 * 60.0 * 60.0))
    }
    
    //是否是今年
    func isThisYear() -> Bool {
        return self.judgeYearMonthDay(judgeType: .sameYear, date: Date())
    }
    
    func dayString() -> String {
        if self.isTodayDate() {
            return NSLocalizedString("今天", comment: "")
        } else if self.isYesterday() {
            return NSLocalizedString("昨天", comment: "")
        } else {
            return self.simpleTimeString(formatter: .yearChinese)
        }
    }
    
    func dayStringWithYear() -> String {
        if self.isTodayDate() {
            return NSLocalizedString("今天", comment: "")
        } else if self.isYesterday() {
            return NSLocalizedString("昨天", comment: "")
        } else if self.isThisYear() {
            return self.simpleTimeString(formatter: .monthChinese)
        } else {
            return self.simpleTimeString(formatter: .yearChinese)
        }
    }
    
    func createContactTime() -> String {
        if self.isThisYear() {
            return self.simpleTimeString(formatter: .monthMinite)
        } else {
            return self.simpleTimeString(formatter: .yearMinite)
        }
    }
    
    func createCloudCardRecordTime() -> String {
        if self.isThisYear() {
            return self.stringFromFormat("MM月dd日 HH:mm")
        } else {
            return self.stringFromFormat("yy年MM月dd日 HH:mm")
        }
    }
    
    func timeString() -> String {
        //1、不足1分钟显示“XX秒前”；
        //2、1分钟－1小时显示“XX分钟前”；
        //3、1小时－1天显示“18:55”；
        //4、昨天的显示“昨天 11:55”；
        //5、今年的显示“07-15 11:15”；
        //6、不是今年的显示“20XX－01-15 11:15”
        //7、任务的剩余时间不在此列，保持线上规则
        //8、记录、统计中全部按完整时间显示，即“20XX－01-15 11:15”
        if self.isTodayDate() {
            let timeInterval = abs(self.timeIntervalSinceNow)
            if timeInterval <= 60.0 {
                if timeInterval < 1.0 {
                    return NSLocalizedString("刚刚", comment: "")
                }
                return "\(Int(timeInterval))" + NSLocalizedString("秒前", comment: "")
            } else if timeInterval <= 60 * 60 {
                return String.localizedStringWithFormat("%d分钟前", Int(timeInterval / 60.0))
            } else {
                return self.simpleTimeString(formatter: .minite)
            }
        } else if self.isYesterday() {
            return NSLocalizedString("昨天", comment: "") + " " + self.stringWith(formatStr: "HH:mm")
        } else if self.isThisYear() {
            return self.simpleTimeString(formatter: .monthMinite)
        } else {
            return self.simpleTimeString(formatter: .yearMinite)
        }
    }
    
    //文件列表九宫格模式下时间格式显示
    func specialTimeString() -> String {
        //1、不足1分钟显示“XX秒前”；
        //2、1分钟－1小时显示“XX分钟前”；
        //3、1小时－1天显示“18:55”；
        //4、昨天的显示“昨天 11:55”；
        //5、今年的显示“07-15 11:15”；
        //6、不是今年的显示“20XX－01-15”
        //7、任务的剩余时间不在此列，保持线上规则
        //8、记录、统计中全部按完整时间显示，即“20XX－01-15 11:15”
        if self.isTodayDate() {
            let timeInterval = abs(self.timeIntervalSinceNow)
            if timeInterval <= 60.0 {
                if timeInterval < 1.0 {
                    return NSLocalizedString("刚刚", comment: "")
                }
                return "\(Int(timeInterval))" + NSLocalizedString("秒前", comment: "")
            } else if timeInterval <= 60 * 60 {
                return String.localizedStringWithFormat("%d分钟前", Int(timeInterval / 60.0))
            } else {
                return self.simpleTimeString(formatter: .minite)
            }
        } else if self.isYesterday() {
            return NSLocalizedString("昨天", comment: "")  + " " + self.stringWith(formatStr: "HH:mm")
        } else if self.isThisYear() {
            return self.stringFromFormat("MM/dd HH:mm")
        } else {
            return self.stringFromFormat("yyyy/MM/dd")
        }
    }
    
    //动态使用的时间规则
    func feedTimeString() -> String {
        if self.isTodayDate() {
            return self.simpleTimeString(formatter: .minite)
        } else if self.isYesterday() {
            return NSLocalizedString("昨天", comment: "")  + " " + self.stringWith(formatStr: "HH:mm")
        } else if self.isThisYear() {
            return self.simpleTimeString(formatter: .monthMinite)
        } else {
            return self.simpleTimeString(formatter: .yearMinite)
        }
    }
    
    //最近联系人列表
    func messageListTimeString() -> String {
        /*
         上午：上午 11:15
         下午：下午 1:15
         昨天：昨天
         昨天之后：05-15
         1年之后：2015-05-15
         */
        if self.isTodayDate() {
            let isTwelveHour = self.isTwelveHour()
            if let date = Int(self.stringWith(formatStr:"HH")), date < 12 {
                return isTwelveHour ? (NSLocalizedString("上午 ", comment: "") + self.stringWith(formatStr: "hh:mm")) : self.stringWith(formatStr: "HH:mm")
            } else {
                return isTwelveHour ? (NSLocalizedString("下午 ", comment: "") + self.stringWith(formatStr: "hh:mm")) : self.stringWith(formatStr: "HH:mm")
            }
        } else if self.isYesterday() {
            return NSLocalizedString("昨天", comment: "")
        } else if self.isThisYear() {
            return self.simpleTimeString(formatter: .month)
        } else {
            return self.simpleTimeString(formatter: .year)
        }
    }
    
    //最近联系人列表 (消息列表加上“今天”)
    func messageContentTimeString(showToday: Bool = true) -> String {
        /*
         上午：上午 11:15
         下午：下午 1:15
         昨天：昨天 15:15
         昨天之后：05-15 15:15
         一年之后：2015-05-15 15:15
         */
        if self.isTodayDate() {
//            let isTwelveHour = true//self.isTwelveHour()
//            let today = "" // https://yun.115.com/5/T138445.html
//            if showToday {
//                today = NSLocalizedString("今天 ", comment: "")
//            }
            if let date = Int(self.stringWith(formatStr:"HH")), date < 12 {
                return NSLocalizedString("上午 ", comment: "") + self.stringWith(formatStr: "hh:mm")
//                return isTwelveHour ? NSLocalizedString("上午 ", comment: "") + self.stringWith(formatStr: "hh:mm") : today + self.stringWith(formatStr: "HH:mm")
            } else {
                return NSLocalizedString("下午 ", comment: "") + self.stringWith(formatStr: "hh:mm")
//                return isTwelveHour ? NSLocalizedString("下午 ", comment: "") + self.stringWith(formatStr: "hh:mm") :        today + self.stringWith(formatStr: "HH:mm")
            }
        } else if self.isYesterday() {
            return NSLocalizedString("昨天 ", comment: "") + self.stringWith(formatStr: "HH:mm")
        } else if self.isThisYear() {
            return self.simpleTimeString(formatter: .monthMinite)
        } else {
            return self.simpleTimeString(formatter: .yearMinite)
        }
    }
    
    //简历列表时间
    func resumeTimeString() -> String {
        /*
         今天：00:00
         昨天：05月15日
         一年之后：2015年05月15日
         */
        if self.isTodayDate() {
            return self.simpleTimeString(formatter: .monthChinese)
        } else if self.isThisYear() {
            return self.simpleTimeString(formatter: .monthChinese)
        } else {
            return self.simpleTimeString(formatter: .yearChinese)
        }
    }
    
    func stringFromFormat(_ format: String) -> String {
        let monthArr = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        if (format == "yyyy年M月d日 E" || format == "yyyy年MM月dd日 E") {
            let month = monthArr[stringWith(formatStr: "M").intValue - 1]
            let day = stringWith(formatStr: "d") + "th"
            let year = stringWith(formatStr: "yyyy")
            let week = self.week()
            return month + " " + day + "," + year + " " + week
        } else if (format == "yyyy年M月d日" || format == "yyyy年MM月dd日") {
            let month = monthArr[stringWith(formatStr: "M").intValue - 1]
            let day = stringWith(formatStr: "d") + "th"
            let year = stringWith(formatStr: "yyyy")
            return month + " " + day + "," + year
        } else if format == "yyyy年MM月" {
            let month = monthArr[stringWith(formatStr: "M").intValue - 1]
            let year = stringWith(formatStr: "yyyy")
            return month + " " + year
        } else {
            return stringWith(formatStr: format)
        }
    }
    
    func formatterString(_ style: DateFormatterStyle = .default) -> String {
        var format = "yyyy-MM-dd"
        let units: NSCalendar.Unit = [.year, .month, .day]
        let components = (Calendar.current as NSCalendar).components(units, from: self)
        let now = (Calendar.current as NSCalendar).components(units, from: Date())
        let secondDiffer = Int(Date().timeIntervalSince(self))
        if secondDiffer < 0 {
            if components.year == now.year {
                format = "MM-dd HH:mm"
            } else {
                format = style == .default ? "yyyy-MM-dd" : "yyyy-MM-dd HH:mm"
            }
        } else {
            if secondDiffer < 60 {
                return String(format: NSLocalizedString("%ld秒前", comment: ""), max(1, secondDiffer))
            } else if secondDiffer < 60 * 60 {
                return String(format: NSLocalizedString("%ld分钟前", comment: ""), secondDiffer / 60)
            } else {
                if components.year == now.year && components.month == now.month && components.day == now.day {
                    format = "HH:mm"
                } else if isYesterday() {
                    format = "HH:mm"
                    return NSLocalizedString("昨天", comment: "") + " " + stringWith(formatStr: format)
                } else {
                    if components.year == now.year {
                        format = "MM-dd HH:mm"
                    } else {
                        format = style == .default ? "yyyy-MM-dd" : "yyyy-MM-dd HH:mm"
                    }
                }
            }
        }
        return stringWith(formatStr: format)
    }
    
    func timeStringSinceDate(_ date: Date) -> String {
        let second = self.timeIntervalSince(date)
        let day = Int(floor(second / 86400))
        let hour = Int(floor((second.truncatingRemainder(dividingBy: 86400)) / 3600))
        let min = Int(floor(Double(((Int(second) % 86400) % 3600) / 60)))
        if day > 0 {
            return "\(day)天\(hour)小时\(min)分钟"
        } else if hour > 0 {
            return "\(hour)小时\(min)分钟"
        } else {
            return "\(min)分钟"
        }
    }
}

@objc enum DateFormatterStyle: Int {
    case `default` = 0
    case yearWithHour
}
// MARK: NSDate的工具类
extension NSDate {
    
    func timeString() -> String {
        return (self as Date).timeString()
    }
    
    func formatterString(_ style: DateFormatterStyle = .default) -> String {
        return (self as Date).formatterString(style)
    }
    
    func stringFromFormat(_ format: String) -> String {
        return (self as Date).stringFromFormat(format)
    }
    
    func messageListTimeString() -> String {
        return (self as Date).messageListTimeString()
    }
    
    func messageContentTimeString() -> String {
        return (self as Date).messageContentTimeString()
    }
    
    func createContactTime() -> String {
        return (self as Date).createContactTime()
    }
    
    func messageContentTimeModifiedString() -> String{
        return (self as Date).messageContentTimeString(showToday: true)
    }
}
