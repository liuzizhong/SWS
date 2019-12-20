//
//  NSDate+Convenience.m
//  FiveStar
//
//  Created by Leon on 13-1-14.
//
//

//#import "NSDate.h"

static NSCalendar *kalCalendar;

@implementation NSDate (Convenience)

+ (NSCalendar *)shareCalendar {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kalCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        kalCalendar.firstWeekday = 1;
    });
    return kalCalendar;
}

- (NSInteger)year {
    NSDateComponents *components = [[NSDate shareCalendar] components:NSCalendarUnitYear fromDate:self];
    return [components year];
}


- (NSInteger)month {
    NSDateComponents *components = [[NSDate shareCalendar] components:NSCalendarUnitMonth fromDate:self];
    return [components month];
}

- (NSInteger)day {
    NSDateComponents *components = [[NSDate shareCalendar] components:NSCalendarUnitDay fromDate:self];
    return [components day];
}

- (NSInteger)hour {
    NSDateComponents *components = [[NSDate shareCalendar] components:NSCalendarUnitHour fromDate:self];
    return [components hour];
}

- (NSInteger)minute {
    NSDateComponents *components = [[NSDate shareCalendar] components:NSCalendarUnitMinute fromDate:self];
    return [components minute];
}

- (NSDate *)offsetDay:(int)numDays {
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:numDays];
    return [[NSDate shareCalendar] dateByAddingComponents:offsetComponents
                                      toDate:self options:0];
}

- (BOOL)isToday
{
    return [[NSDate dateStartOfDay:self] isEqualToDate:[NSDate dateStartOfDay:[NSDate date]]];
}

+ (NSDate *)dateForDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = day;
    components.month = month;
    components.year = year;
    return [[NSDate shareCalendar] dateFromComponents:components];
}

+ (NSDate *)dateStartOfDay:(NSDate *)date {
    NSDateComponents *components =
            [[NSDate shareCalendar]               components:(NSCalendarUnitYear | NSCalendarUnitMonth |
                    NSCalendarUnitDay) fromDate:date];
    return [[NSDate shareCalendar] dateFromComponents:components];
}

- (NSInteger)weekIndex {
    NSDateComponents *dateComponents = [[NSDate shareCalendar] components:kCFCalendarUnitWeekday fromDate:self];
    return (dateComponents.weekday + 6) % 7;
}

- (NSInteger)dayComponentsToDate:(NSDate *)toDate {
    NSDateComponents *dayComponents = [[NSDate shareCalendar] components:NSCalendarUnitDay fromDate:self toDate:toDate options:0];
    return dayComponents.day;
}

- (NSString *)weekString {
    NSDateComponents *dateComponents = [[NSDate shareCalendar] components:kCFCalendarUnitWeekday fromDate:self];
    switch (dateComponents.weekday) {
        case 1: {
            return NSLocalizedString(@"周日", nil);
        }
            break;

        case 2: {
            return NSLocalizedString(@"周一", nil);
        }
            break;

        case 3: {
            return NSLocalizedString(@"周二", nil);
        }
            break;

        case 4: {
            return NSLocalizedString(@"周三", nil);
        }
            break;

        case 5: {
            return NSLocalizedString(@"周四", nil);
        }
            break;

        case 6: {
            return NSLocalizedString(@"周五", nil);
        }
            break;

        case 7: {
            return NSLocalizedString(@"周六", nil);
        }
            break;

        default:
            break;
    }

    return @"";
}

+ (int)dayBetweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    unsigned int unitFlags = NSCalendarUnitDay;
    NSDateComponents *comps = [[NSDate shareCalendar] components:unitFlags fromDate:startDate toDate:endDate options:0];
    int days = [comps day];
    return days;
}

+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)format {
    if (!format)
        format = @"yyyy-MM-dd";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}

+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format {
    if (!format)
        format = @"yyyy-MM-dd";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}


+ (NSDate *)dateFromString:(NSString *)dateString {
    return [self dateFromStringBySpecifyTime:dateString hour:0 minute:0 second:0];
}

+ (NSDate *)dateFromStringBySpecifyTime:(NSString *)dateString hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second {
    NSArray *arrayDayTime = [dateString componentsSeparatedByString:@" "];
    NSArray *arrayDay = [arrayDayTime[0] componentsSeparatedByString:@"-"];

    NSInteger flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *tmpDateComponents = [[NSDate shareCalendar] components:flags fromDate:[NSDate date]];
    tmpDateComponents.year = [arrayDay[0] intValue];
    tmpDateComponents.month = [arrayDay[1] intValue];
    tmpDateComponents.day = [arrayDay[2] intValue];
    if ([arrayDayTime count] > 1) {
        NSArray *arrayTime = [arrayDayTime[1] componentsSeparatedByString:@":"];
        tmpDateComponents.hour = [arrayTime[0] intValue];
        tmpDateComponents.minute = [arrayTime[1] intValue];
        tmpDateComponents.second = [arrayTime[2] intValue];
    }
    else {
        tmpDateComponents.hour = hour;
        tmpDateComponents.minute = minute;
        tmpDateComponents.second = second;
    }
    return [[NSDate shareCalendar] dateFromComponents:tmpDateComponents];
}

+ (NSDateComponents *)nowDateComponents {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    return [calendar components:flags fromDate:[NSDate date]];
}

+ (NSDateComponents *)dateComponentsFromNow:(NSInteger)days {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    return [calendar components:flags fromDate:[[NSDate date] dateByAddingTimeInterval:days * 24 * 60 * 60]];
}

+ (NSDate *)getLastMonthFormDate:(NSDate *)date {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate: date];
    components.day = 1;
    [components setMonth:([components month] - 1)];
    NSDate *lastMonth = [cal dateFromComponents:components];
    return lastMonth;
}

+ (NSDate *)getNextMonthFormDate:(NSDate *)date {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate: date];
    components.day = 1;
    [components setMonth:([components month] + 1)];
    NSDate *nextMonth = [cal dateFromComponents:components];
    return nextMonth;
}

@end
