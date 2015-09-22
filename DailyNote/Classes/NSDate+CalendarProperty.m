//
//  NSDate+CalendarProperty.m
//  DailyNote
//
//  Created by WeiHan on 9/21/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import "NSDate+CalendarProperty.h"

@implementation NSDate (CalendarProperty)

- (NSDateComponents *)components
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal | NSCalendarUnitWeekdayOrdinal | NSCalendarUnitQuarter | NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekOfYear | NSCalendarUnitYearForWeekOfYear | NSCalendarUnitNanosecond | NSCalendarUnitCalendar | NSCalendarUnitTimeZone;
    
    return [calendar components:unit fromDate:self];
}

- (NSString *)weekdayString
{
    NSString *weekday = nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal;
    NSDateComponents *components = [calendar components:unit fromDate:self];
    
    switch (components.weekday) {
        case 1:
            weekday = @"Monday";
            break;
        case 2:
            weekday = @"Tuesday";
            break;
        case 3:
            weekday = @"Wednesday";
            break;
        case 4:
            weekday = @"Thursday";
            break;
        case 5:
            weekday = @"Friday";
            break;
        case 6:
            weekday = @"Saturday";
            break;
        case 7:
            weekday = @"Sunday";
            break;
        default:
            weekday = @"";
            break;
    }
    
    return weekday;
}

@end
