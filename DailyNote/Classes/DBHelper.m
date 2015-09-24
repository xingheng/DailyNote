//
//  DBHelper.m
//  DailyNote
//
//  Created by WeiHan on 9/21/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import "DBHelper.h"
#import <FMDB.h>
#import "FileMgrUtil.h"

#define kSTRKey_DBFileName              @"dailynote_data"
#define kSTRKey_DBFileExtension         @"sqlite3"

#define kSTRKey_TABLE_NAME              @"noterecord"

#define kSTRKey_COLUMN_UID              @"uid"
#define kSTRKey_COLUMN_Content          @"content"
#define kSTRKey_COLUMN_Date             @"date"
#define kSTRKey_COLUMN_WeekOfYear       @"weekOfYear"
#define kSTRKey_COLUMN_WeekOfMonth      @"weekOfMonth"
#define kSTRKey_COLUMN_Year             @"year"
#define kSTRKey_COLUMN_Month            @"month"


@interface DBHelper()

@property (nonatomic, strong) NSMutableArray *noteRecords;

@end

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
        if (!database) {
            [self loadDBFile];
        }
        
        [self loadDBData];
    }
    
    return self;
}

- (BOOL)loadDBFile
{
    static BOOL loadResult = YES;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSString *cacheDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        NSString *cacheRoot = [cacheDir stringByAppendingPathComponent:@"DailyNote/Data"];
        
        if (!IsExists(cacheRoot)) {
            NSError *err = nil;
            
            if (!CreateDirectory(cacheRoot, &err)) {
                DDLogError(@"Failed to create directory %@ !", cacheRoot);
                loadResult = NO;
                return;
            }
        }
        
        NSString *strDBPath = [NSString stringWithFormat:@"%@/%@.%@", cacheRoot, kSTRKey_DBFileName, kSTRKey_DBFileExtension];
        
        // DeleteFile(strDBPath, nil);
        
        if (!IsExists(strDBPath)) {
            NSString *strPath = [[NSBundle mainBundle] pathForResource:kSTRKey_DBFileName ofType:kSTRKey_DBFileExtension];
            NSError *err = nil;
            
            if (!CopyFile(strPath, strDBPath, &err)) {
                DDLogError(@"Failed to copy file %@ to %@ !", strPath, strDBPath);
                loadResult = NO;
                return;
            }
        }
        
        database = [FMDatabase databaseWithPath:strDBPath];
        
        if (![database open]) {
            DDLogError(@"Open database failed, database: %@, error: %@, code: %d", database.databasePath, database.lastErrorMessage, database.lastErrorCode);
            loadResult = NO;
            return;
        }
        
        loadResult = YES;
    });
    
    return loadResult;
}

- (void)loadDBData
{
    NSMutableArray *arrNoteRecords = [[NSMutableArray alloc] init];
    
    FMResultSet *dataSet = [database executeQuery:@"SELECT * FROM "kSTRKey_TABLE_NAME];
    while ([dataSet next]) {
        NoteRecord *model = [[NoteRecord alloc] init];
        
        model.uid = [dataSet stringForColumn:kSTRKey_COLUMN_UID];
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
    NSString *formatString = [NSString stringWithFormat:@"INSERT OR ROLLBACK INTO "kSTRKey_TABLE_NAME " (%@, %@, %@, %@, %@, %@, %@) VALUES (?, ?, ?, ?, ?, ?, ?)", kSTRKey_COLUMN_UID, kSTRKey_COLUMN_Content, kSTRKey_COLUMN_Date, kSTRKey_COLUMN_WeekOfYear, kSTRKey_COLUMN_WeekOfMonth, kSTRKey_COLUMN_Year, kSTRKey_COLUMN_Month];
    
    if (![database executeUpdate:formatString, record.uid, record.content, record.date, @(record.weekOfYear), @(record.weekOfMonth), @(record.year), @(record.month)]) {
        DDLogError(@"Insert record failed, error: %@, code: %d", database.lastErrorMessage, database.lastErrorCode);
        return;
    }
    
    [_noteRecords addObject:record];
}

- (void)removeNoteRecord:(NoteRecord *)record
{
    NSString *formatString = [NSString stringWithFormat:@"DELETE FROM "kSTRKey_TABLE_NAME " WHERE "kSTRKey_COLUMN_UID" = ?"];
    
    if (![database executeUpdate:formatString, record.uid]) {
        DDLogError(@"Delete record failed, error: %@, code: %d", database.lastErrorMessage, database.lastErrorCode);
        return;
    }
    
    for (NoteRecord *item in _noteRecords) {
        if ([item.uid isEqualToString:record.uid]) {
            [_noteRecords removeObject:item];
        }
    }
}

#pragma mark Public

- (NSArray *)allNoteRecords
{
    return [_noteRecords copy];
}

@end
