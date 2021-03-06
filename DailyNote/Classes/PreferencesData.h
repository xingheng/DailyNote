//
//  PreferencesData.h
//  DailyNote
//
//  Created by WeiHan on 9/21/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import <Foundation/Foundation.h>

void SetDailyNoteGitRepoPath(NSString *strPath);
NSString * GetDailyNoteGitRepoPath();

void SetDailyNoteCommitTime(NSDate *date);
NSDate * GetDailyNoteCommitTime();

void SetFShouldRemindForCommit(BOOL flag);
BOOL GetFShouldRemindForCommit();
