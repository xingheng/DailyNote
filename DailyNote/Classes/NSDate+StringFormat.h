//
//  NSDate+StringFormat.h
//  DailyNote
//
//  Created by WeiHan on 9/22/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (StringFormat)

- (NSString *)stringDate;

+ (NSDate *)dataFromString:(NSString *)string;

@end
