//
//  NoteRecord.h
//  DailyNote
//
//  Created by WeiHan on 9/21/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NoteRecord : NSObject

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) NSInteger weekOfYear;
@property (nonatomic, assign) NSInteger weekOfMonth;
@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger month;

+ (instancetype)createNoteRecordWithCurrentDate:(NSString *)noteText;

- (instancetype)initWithText:(NSString *)noteText date:(NSDate *)date;

@end
