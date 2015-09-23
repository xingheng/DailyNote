//
//  GitRepoManager.h
//  DailyNote
//
//  Created by WeiHan on 9/21/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NoteRecord.h"

@interface GitRepoManager : NSObject

@property (nonatomic, assign, readonly) BOOL isValid;

- (instancetype)initWithRepoPath:(NSString *)repoPath;

+ (BOOL)isValidGitRepo:(NSString *)repoPath;

- (void)saveRecordToFile:(NoteRecord *)record shouldCommit:(BOOL)willCommit;

@end
