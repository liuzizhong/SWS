//
//  NSDate+Convenience.h
//  FiveStar
//
//  Created by Leon on 13-1-14.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (Convenience)

- (NSInteger)year;
- (NSInteger)month;
- (NSInteger)day;
- (NSInteger)hour;
- (NSInteger)minute;
- (NSInteger)weekIndex;  //0...6
- (NSString *)weekString;
- (NSDate *)offsetDay:(int)numDays;
- (BOOL)isToday;

+ (NSDate *)dateForDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year;
+ (NSDate *)dateStartOfDay:(NSDate *)date;
+ (int)dayBetweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)format;
+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format;
+ (NSDate *)dateFromString:(NSString *)dateString;
+ (NSDate *)dateFromStringBySpecifyTime:(NSString *)dateString hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;
+ (NSDateComponents *)nowDateComponents;
+ (NSDateComponents *)dateComponentsFromNow:(NSInteger)days;
- (NSInteger)dayComponentsToDate:(NSDate *)toDate;
+ (NSDate *)getLastMonthFormDate:(NSDate *)date;
+ (NSDate *)getNextMonthFormDate:(NSDate *)date;
@end
