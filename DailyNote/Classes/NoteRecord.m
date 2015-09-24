//
//  NoteRecord.m
//  DailyNote
//
//  Created by WeiHan on 9/21/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import "NoteRecord.h"
#import "NSDate+CalendarProperty.h"

@implementation NoteRecord

+ (instancetype)createNoteRecordWithCurrentDate:(NSString *)noteText
{
    return [[NoteRecord alloc] initWithText:noteText date:[NSDate date]];
}

- (instancetype)initWithText:(NSString *)noteText date:(NSDate *)date
{
    if (self = [super init]) {
        _uid = [[NSUUID UUID] UUIDString];
        _content = noteText;
        _date = date;
        
        NSDateComponents *components = [date components];
        _weekOfYear = components.weekOfYear;
        _weekOfMonth = components.weekOfMonth;
        _year = components.year;
        _month = components.month;
    }
    
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[%@]uid: %@, date: %@, content: %@", NSStringFromClass([self class]), _uid, _date, _content];
}

@end
