//
//  DBHelper.h
//  DailyNote
//
//  Created by WeiHan on 9/21/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoteRecord.h"

@interface DBHelper : NSObject

@property (nonatomic, copy, readonly) NSArray *allNoteRecords;

+ (instancetype)sharedInstance;

- (BOOL)loadDBFile;

- (void)saveRecord:(NoteRecord *)record;

- (void)removeNoteRecord:(NoteRecord *)record;

@end
