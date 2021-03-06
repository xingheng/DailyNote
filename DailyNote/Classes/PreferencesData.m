//
//  PreferencesData.m
//  DailyNote
//
//  Created by WeiHan on 9/21/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import "PreferencesData.h"

#define kSTRKey_UserDefault_ShouldAutoPushWhenPosting       @"kSTRKey_UserDefault_ShouldAutoPushWhenPosting" // DEPRECATED!
#define kSTRKey_UserDefault_DailyNote_GitRepoPath           @"kSTRKey_UserDefault_DailyNote_GitRepoPath"
#define kSTRKey_UserDefault_DailyNote_ShouldRemindForCommit @"kSTRKey_UserDefault_DailyNote_ShouldRemindForCommit"
#define kSTRKey_UserDefault_DailyNote_CommitTime            @"kSTRKey_UserDefault_DailyNote_CommitTime"


BOOL HasUserDefaultKey(NSString *strKey);


void SetDailyNoteGitRepoPath(NSString *strPath)
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    [userDefault setObject:strPath forKey:kSTRKey_UserDefault_DailyNote_GitRepoPath];
    [userDefault synchronize];
}

NSString * GetDailyNoteGitRepoPath()
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    return [userDefault objectForKey:kSTRKey_UserDefault_DailyNote_GitRepoPath];
}

void SetDailyNoteCommitTime(NSDate *date)
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    [userDefault setObject:date forKey:kSTRKey_UserDefault_DailyNote_CommitTime];
    [userDefault synchronize];
}

NSDate * GetDailyNoteCommitTime()
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    return [userDefault objectForKey:kSTRKey_UserDefault_DailyNote_CommitTime];
}

void SetFShouldRemindForCommit(BOOL flag)
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    [userDefault setBool:flag forKey:kSTRKey_UserDefault_DailyNote_ShouldRemindForCommit];
    [userDefault synchronize];
}

BOOL GetFShouldRemindForCommit()
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    if (!HasUserDefaultKey(kSTRKey_UserDefault_DailyNote_ShouldRemindForCommit)) {
        return YES;
    }

    return [userDefault boolForKey:kSTRKey_UserDefault_DailyNote_ShouldRemindForCommit];
}

#pragma mark - Private

BOOL HasUserDefaultKey(NSString *strKey)
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [userDefault dictionaryRepresentation];

    return [dict.allKeys containsObject:strKey];
}
