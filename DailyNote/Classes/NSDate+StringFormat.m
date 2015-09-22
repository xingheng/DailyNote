//
//  NSDate+StringFormat.m
//  DailyNote
//
//  Created by WeiHan on 9/22/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import "NSDate+StringFormat.h"

#define kSTR_DATEFORMAT     @"yyyy-MM-dd HH:mm:ss"

@implementation NSDate (StringFormat)

- (NSString *)stringDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = kSTR_DATEFORMAT;
    NSString *strDate = [formatter stringFromDate:self];
    return strDate;
}

+ (NSDate *)dataFromString:(NSString *)string
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = kSTR_DATEFORMAT;
    NSDate *strDate = [formatter dateFromString:string];
    return strDate;
}

@end
