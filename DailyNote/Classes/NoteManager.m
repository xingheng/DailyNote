//
//  NoteManager.m
//  DailyNote
//
//  Created by WeiHan on 12/3/15.
//  Copyright © 2015 Will Han. All rights reserved.
//

#import "NoteManager.h"
#import "AppDelegate.h"

#define DefaultUserNotificationCenter    ([NSUserNotificationCenter defaultUserNotificationCenter])
#define kNoteManagerNotificationReminder @"NoteManagerNotificationReminder"

static dispatch_queue_t workerQueue;


@interface NoteManager () <NSUserNotificationCenterDelegate>

@end

@implementation NoteManager

- (instancetype)init
{
    if (self = [super init]) {
        DefaultUserNotificationCenter.delegate = self;

        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            workerQueue = dispatch_queue_create("dailynote_gitrepo_writer", NULL);
        });
    }

    return self;
}

- (void)dealloc
{
    DefaultUserNotificationCenter.delegate = nil;
}

- (void)run
{
    dispatch_async(workerQueue, ^{
        while (true) {
#if DEBUG
            [NSThread sleepForTimeInterval:20];
#endif
            BOOL hasReminder = GetFShouldRemindForCommit();
            NSTimeInterval reminderMinutesBefore = 5; // reminder before committing 5 minutes.


            NSDate *now = [NSDate date];
            NSDate *targetTime = GetDailyNoteCommitTime() ? : [now dateAtEndOfDay];

            NSDate *targetDate = [now dateAtStartOfDay];
            targetDate = [targetDate dateByAddingHours:targetTime.hour];
            targetDate = [targetDate dateByAddingMinutes:targetTime.minute];
            // targetDate = [targetDate dateByAddingTimeInterval:targetTime.seconds];

            if ([targetDate isEarlierThanDate:now]) {
                targetDate = [targetDate dateByAddingDays:1];
            }

            NSUserNotification *notificationForReminder = nil;

            if (hasReminder) {
                NSDate *reminderDate = [targetDate dateBySubtractingMinutes:reminderMinutesBefore];

                NSString *strReminder = [NSString stringWithFormat:@"What a funny day! Let's save it!"];
                DDLogInfo(strReminder);

                notificationForReminder = [[NSUserNotification alloc] init];
                notificationForReminder.title = @"DailyNote";
                notificationForReminder.informativeText = strReminder;
                notificationForReminder.soundName = NSUserNotificationDefaultSoundName;
                notificationForReminder.deliveryDate = reminderDate;
                notificationForReminder.userInfo = @{ NSApplicationLaunchUserNotificationKey: kNoteManagerNotificationReminder };

                [DefaultUserNotificationCenter scheduleNotification:notificationForReminder];
            }

            DDLogDebug(@"DailyNote worker is sleeping in background thread, now: %@...., wake date: %@", now, targetDate);
            [NSThread sleepUntilDate:targetDate];

            NSDate *dateBeforeTask = [NSDate date];
            DDLogDebug(@"DailyNote worker is working in background thread, now: %@....", dateBeforeTask);

            if (notificationForReminder) {
                [DefaultUserNotificationCenter removeScheduledNotification:notificationForReminder];
            }

            DBHelper *dbHelper = [DBHelper sharedInstance];
            GitRepoManager *manager = [[GitRepoManager alloc] initWithRepoPath:GetDailyNoteGitRepoPath()];
            NSArray *records = dbHelper.allNoteRecords;

            if (records.count > 0) {
                records = [records sortedArrayUsingComparator:^(id obj1, id obj2) {
                    NoteRecord *record1 = obj1;
                    NoteRecord *record2 = obj2;

                    if ([record1.date
                         isEarlierThanDate:record2.date]) {
                        return NSOrderedAscending;
                    } else {
                        return NSOrderedDescending;
                    }

                    return NSOrderedSame;
                }];

                for (NoteRecord *item in records) {
                    [manager saveRecordToFile:item shouldCommit:YES];
                    [dbHelper removeNoteRecord:item];
                }

                NSString *strFinishedLog = [NSString stringWithFormat:@"Committed %ld record(s) to git repository!", records.count];
                DDLogInfo(strFinishedLog);

                NSUserNotification *notification = [[NSUserNotification alloc] init];
                notification.title = @"DailyNote";
                notification.informativeText = strFinishedLog;
                // notification.soundName = NSUserNotificationDefaultSoundName;

                [DefaultUserNotificationCenter deliverNotification:notification];
            }

            NSDate *dateAfterTask = [NSDate date];

            if ([dateBeforeTask isEqualToDateIgnoringTime:dateAfterTask]) {
                DDLogInfo(@"Take a break, now: %@", dateAfterTask);
                [NSThread sleepUntilDate:[[NSDate dateTomorrow] dateAtStartOfDay]];
                DDLogInfo(@"Wake up after a break, now: %@", dateAfterTask);
            }
        }
    });
}

#pragma mark - NSUserNotificationCenterDelegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
{
    DDLogDebug(@"%s: %@", __func__, notification);
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    NSLog(@"%s: %@", __func__, notification);

    NSDictionary *dict = notification.userInfo;
    NSString *strType = dict[NSApplicationLaunchUserNotificationKey];

    if ([strType isEqualToString:kNoteManagerNotificationReminder]) {
        [(AppDelegate *)(NSApp.delegate)showMainWindow];
    }
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

@end
