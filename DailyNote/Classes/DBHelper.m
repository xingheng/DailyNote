//
//  DBHelper.m
//  DailyNote
//
//  Created by WeiHan on 9/21/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import "DBHelper.h"
#import <FMDB.h>

#define kSTRKey_TABLE_NAME              @"noterecord"

#define kSTRKey_COLUMN_Content          @"content"
#define kSTRKey_COLUMN_Date             @"date"
#define kSTRKey_COLUMN_WeekOfYear       @"weekOfYear"
#define kSTRKey_COLUMN_WeekOfMonth      @"weekOfMonth"
#define kSTRKey_COLUMN_Year             @"year"
#define kSTRKey_COLUMN_Month            @"month"


@implementation DBHelper
{
    FMDatabase *database;
}

+ (instancetype)sharedInstance
{
    static DBHelper *gDBHelper;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gDBHelper = [[DBHelper alloc] init];
    });
    
    return gDBHelper;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self loadDBData];
    }
    
    return self;
}

- (void)loadDBData
{
    NSString *strPath = [[NSBundle mainBundle] pathForResource:@"dailynote_data" ofType:@"sqlite3"];
    
    if (!strPath) {
        DDLogError(@"No default tenant database file found, you should go to Preferences to choose one.");
        return;
    }
    
    database = [FMDatabase databaseWithPath:strPath];
    
    if (![database open]) {
        DDLogError(@"Open database failed, database: %@, error: %@, code: %d", strPath, database.lastErrorMessage, database.lastErrorCode);
        return;
    }
    
    NSMutableArray *arrNoteRecords = [[NSMutableArray alloc] init];
    
    FMResultSet *dataSet = [database executeQuery:@"SELECT * FROM "kSTRKey_TABLE_NAME];
    while ([dataSet next]) {
        NoteRecord *model = [[NoteRecord alloc] init];
        
        model.content = [dataSet stringForColumn:kSTRKey_COLUMN_Content];
        model.date = [dataSet dateForColumn:kSTRKey_COLUMN_Date];
        model.weekOfYear = [dataSet intForColumn:kSTRKey_COLUMN_WeekOfYear];
        model.weekOfMonth = [dataSet intForColumn:kSTRKey_COLUMN_WeekOfMonth];
        model.year = [dataSet intForColumn:kSTRKey_COLUMN_Year];
        model.month = [dataSet intForColumn:kSTRKey_COLUMN_Month];
        
        [arrNoteRecords addObject:model];
    }
    
    _noteRecords = arrNoteRecords;
}

- (void)saveRecord:(NoteRecord *)record
{
    NSString *formatString = [NSString stringWithFormat:@"INSERT OR ROLLBACK INTO "kSTRKey_TABLE_NAME " (%@, %@, %@, %@, %@, %@) VALUES (?, ?, ?, ?, ?, ?)", kSTRKey_COLUMN_Content, kSTRKey_COLUMN_Date, kSTRKey_COLUMN_WeekOfYear, kSTRKey_COLUMN_WeekOfMonth, kSTRKey_COLUMN_Year, kSTRKey_COLUMN_Month];
    
    if (![database executeUpdate:formatString, record.content, record.date, @(record.weekOfYear), @(record.weekOfMonth), @(record.year), @(record.month)]) {
        DDLogError(@"Insert record failed, error: %@, code: %d", database.lastErrorMessage, database.lastErrorCode);
        return;
    }
    
    [_noteRecords addObject:record];
}

@end
