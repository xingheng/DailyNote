//
//  NSString+Utilities.m
//  DailyNote
//
//  Created by WeiHan on 9/24/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import "NSString+Utilities.h"

@implementation NSString (Utilities)

- (BOOL)isEmpty
{
    NSString *strTrim = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return strTrim.length <= 0;
}

@end
