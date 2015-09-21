//
//  GitRepoManager.m
//  DailyNote
//
//  Created by WeiHan on 9/21/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import "GitRepoManager.h"
#import "FileMgrUtil.h"

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
    NSString *filename = [NSString stringWithFormat:@"Week %ldth, %ld", record.weekOfYear, record.year];
    
    if (!IsExists(filename)) {
        NSError *err = nil;
        
        if (!CreateFile(filename, &err)) {
            DDLogError(@"Create file %@ failed, error: %@", filename, err);
        }
    }
    
    NSString *content = [NSString stringWithFormat:@"TBD"];
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filename];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:[content dataUsingEncoding:NSMacOSRomanStringEncoding]];
    [fileHandle synchronizeFile];
    [fileHandle closeFile];
}

@end
