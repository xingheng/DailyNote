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
#import "NSDate+StringFormat.h"
#import "NSString+Utilities.h"

@implementation GitRepoManager
{
    NSString *repositoryPath;
    NSString *mainRootDir;
}

- (instancetype)initWithRepoPath:(NSString *)repoPath
{
    if (self = [super init]) {
        repositoryPath = repoPath;
        
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

- (void)saveRecordToFile:(NoteRecord *)record shouldCommit:(BOOL)willCommit
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
        if ([item isEmpty]) {
            continue;
        }
        
        [recordContent appendFormat:@"    - %@\n", item];
    }
    
    if ([fileContent containsString:commentString]) {
        NSRange firstRange = [fileContent rangeOfString:commentString];
        NSRange searchRange = NSMakeRange(firstRange.location + firstRange.length, fileContent.length - firstRange.location - firstRange.length - 1);
        NSRange secondRange = [fileContent rangeOfString:(NSString *)commentPrefix options:NSCaseInsensitiveSearch range:searchRange];
        NSRange targetRange = NSMakeRange(firstRange.location, (secondRange.location == NSNotFound ? fileContent.length - 1 : secondRange.location) - firstRange.location);
        
        [fileContent replaceCharactersInRange:targetRange withString:recordContent];
    } else {
        [fileContent appendFormat:@"\n%@", recordContent];
    }
    
    NSError *err = nil;
    
    if (![fileContent writeToFile:fullname atomically:YES encoding:encoding error:&err]) {
        DDLogError(@"Write data to file '%@' failed! error: %@", fullname, err);
    }
    
    if (willCommit) {
        [self commitChangesToGit:record];
    }
}

- (void)commitChangesToGit:(NoteRecord *)record
{
    dispatch_block_t block = ^ {
        NSString *bashScriptPath = [[NSBundle mainBundle] pathForResource:@"git_commit" ofType:@"sh"];
        NSString *strCommitMessage = [NSString stringWithFormat:@"[DailyNote] Updated!"];
        NSString *commitDate = [record.date stringDate];
        
        NSTask *task = [[NSTask alloc] init];
        task.currentDirectoryPath = repositoryPath;
        task.launchPath = @"/bin/sh";
        
        task.arguments = @[@"-c", [NSString stringWithFormat:@"%@ \"%@\" \"%@\"", bashScriptPath, strCommitMessage, commitDate]];
        
        NSPipe *pipe = [NSPipe pipe];
        [task setStandardOutput:pipe];
        [task setStandardError:pipe];
        
        @try {
            [task launch];
        }
        @catch (NSException *exception) {
            DDLogError(exception.description);
        }
        
        NSFileHandle *file = [pipe fileHandleForReading];
        NSData *data = [file readDataToEndOfFile];
        NSString *strFullLog = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        DDLogDebug(@"Log:---------\n%@\n-----------", strFullLog);
    };
    
    if ([NSThread isMainThread]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
    } else {
        block();
    }
}

@end
