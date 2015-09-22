//
//  NSDate+CalendarProperty.h
//  DailyNote
//
//  Created by WeiHan on 9/21/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (CalendarProperty)

- (NSDateComponents *)components;

- (NSString *)weekdayString;

@end
