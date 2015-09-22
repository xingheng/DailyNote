//
//  GitRepoManager.m
//  DailyNote
//
//  Created by WeiHan on 9/21/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import "GitRepoManager.h"
#import "FileMgrUtil.h"
#import "NSDate+CalendarProperty.h"

@implementation GitRepoManager
{
    NSString *mainRootDir;
}

- (instancetype)initWithRepoPath:(NSString *)repoPath
{
    if (self = [super init]) {
        NSString *repositoryPath = repoPath;
        
        _isValid = [[self class] isValidGitRepo:repoPath];
        mainRootDir = [repositoryPath stringByAppendingPathComponent:@"Data"];
        
        if (_isValid && !IsExists(mainRootDir)) {
            NSError *err = nil;
            
            if (!CreateDirectory(mainRootDir, &err)) {
                DDLogError(@"Create directory %@ failed! error: %@", mainRootDir, err);
            }
        }
    }
    
    return self;
}

+ (BOOL)isValidGitRepo:(NSString *)repoPath
{
    NSString *strGitPath = [repoPath stringByAppendingPathComponent:@".git"];
    
    return IsExists(strGitPath);
}

- (void)saveRecordToFile:(NoteRecord *)record
{
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSString *filename = [NSString stringWithFormat:@"Week %ldth %ld.md", record.weekOfYear, record.year];
    NSString *fullname = [mainRootDir stringByAppendingPathComponent:filename];
    
    if (!IsExists(fullname)) {
        NSString *contentHeader = [NSString stringWithFormat:@"\n###Week %ldth, %ld###\n\n", record.weekOfYear, record.year];
        NSData *headerData = [contentHeader dataUsingEncoding:encoding];
        NSAssert(headerData, @"Convert header string to NSData failed!");
        
        NSFileManager *fileMgr = GetDefaultFileManager();
        
        if (![fileMgr createFileAtPath:fullname contents:headerData attributes:nil]) {
            DDLogError(@"Create file %@ failed.", fullname);
        }
    }
    
    NSMutableString *fileContent = [[NSMutableString alloc] initWithContentsOfFile:fullname encoding:encoding error:nil];
    const NSString *commentPrefix = @"[//]: # ";
    NSString *commentString = [NSString stringWithFormat:@"%@(%@)", commentPrefix, [record.date weekdayString]];
    
    NSMutableString *recordContent = [[NSMutableString alloc] init];
    [recordContent appendFormat:@"%@\n", commentString];
    [recordContent appendFormat:@"* %@\n", [record.date weekdayString]];
    
    NSArray *items = [record.content componentsSeparatedByString:@"\n"];
    for (NSString *item in items) {
        NSString *strTrim = [item stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (strTrim.length <= 0) {
            continue;
        }
        
        [recordContent appendFormat:@"    - %@\n", item];
    }
    
    if ([fileContent containsString:commentString]) {
        NSRange firstRange = [fileContent rangeOfString:commentString];
        NSString *subString = [fileContent substringFromIndex:firstRange.location + firstRange.length];
        NSRange secondRange = [subString rangeOfString:(NSString *)commentPrefix];
        NSRange targetRange = NSMakeRange(firstRange.location, (secondRange.location == NSNotFound ? fileContent.length - 1 : secondRange.location) - firstRange.location);
        
        [fileContent replaceCharactersInRange:targetRange withString:recordContent];
    } else {
        [fileContent appendFormat:@"%@", recordContent];
    }
    
    NSError *err = nil;
    
    if (![fileContent writeToFile:fullname atomically:YES encoding:encoding error:&err]) {
        DDLogError(@"Write data to file '%@' failed! error: %@", fullname, err);
    }
}

@end
