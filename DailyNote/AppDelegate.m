//
//  AppDelegate.m
//  DailyNote
//
//  Created by Will Han on 9/20/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"
#import "PreferencesWindowController.h"
#import "FileMgrUtil.h"
#import "DBHelper.h"
#import "NSDate+Utilities.h"
#import "GitRepoManager.h"
#import "PreferencesData.h"
#import "AlertUtil.h"

typedef NS_OPTIONS(NSUInteger, DNMenuItemKind) {
    DNMenuItemKindMain,
    DNMenuItemKindPreferences,
    DNMenuItemKindLog,
    DNMenuItemKindQuit
};

@interface AppDelegate () <NSUserNotificationCenterDelegate, NSMenuDelegate>
{
    NSStatusItem *statusItem;
    MainWindowController *mainWC;
    PreferencesWindowController *prefWC;
    
    DDLogFileInfo *currentLogFileInfo;
}

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self initDDLog];
    [self initDBFile];
    [self initStatusBarConfig];
    [self showDefaultWindow];
    [self runBackgroundWorker];
    
    [NSUserNotificationCenter defaultUserNotificationCenter].delegate = self;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    if (!flag) {
        [self showDefaultWindow];
    }
    
    return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    DBHelper *dbHelper = [DBHelper sharedInstance];
    if (dbHelper.allNoteRecords.count > 0) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"DailyNote Notice";
        alert.informativeText = @"It seems you have some uncommited note records in schedular task list, quitting this app will cancel the records in task and save them in local cache, they will be delay to commit in the next running time. Press 'OK' button to quit";
        [alert addButtonWithTitle:@"Quit"];
        [alert addButtonWithTitle:@"Cancel"];
        
        NSModalResponse result = [alert runModal];
        
        if (result == -NSModalResponseStop) {
            return NSTerminateNow;
        } else {
            return NSTerminateCancel;
        }
    }
    
    return NSTerminateNow;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    DDLogInfo(@"App will exit, date: %@", [NSDate date]);
}

#pragma mark - NSUserNotificationCenterDelegate

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

#pragma mark - NSMenuDelegate

- (void)menuWillOpen:(NSMenu *)menu
{
    __block NSMenuItem *logItem = nil;
    
    [menu.itemArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMenuItem *item = obj;
        
        if (item.tag == DNMenuItemKindLog) {
            logItem = item;
            *stop = YES;
        }
    }];
    
    if (logItem) {
        NSString *logFile = currentLogFileInfo.filePath;
        logItem.hidden = !IsExists(logFile);
    }
}

#pragma mark -

- (void)initDDLog
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    NSString *appName = [[NSProcessInfo processInfo] processName];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? paths[0] : NSTemporaryDirectory();
    NSString *logFileDirectory = [[basePath stringByAppendingPathComponent:@"Logs"] stringByAppendingPathComponent:appName];
    
    DDLogFileManagerDefault *logFileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:logFileDirectory];
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:logFileManager];
    fileLogger.rollingFrequency = 60 * 60 * 24 * 7; // 7 * 24 hour rolling
    // fileLogger.maximumFileSize = 1024 * 512;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 30;
    
    currentLogFileInfo = fileLogger.currentLogFileInfo;
    
    [DDLog addLogger:fileLogger];
}

- (void)initDBFile
{
    if (![[DBHelper sharedInstance] loadDBFile]) {
        DDLogError(@"Failed to load core database file!");
    }
}

- (void)initStatusBarConfig
{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    statusItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    statusItem.title = @"♨︎";
    statusItem.highlightMode = YES;
    statusItem.toolTip = @"DailyNote";
    
    NSMenu *menu = [[NSMenu alloc] init];
    menu.delegate = self;
    statusItem.menu = menu;
    
    NSMenuItem *item = nil;
    
    item = [[NSMenuItem alloc] initWithTitle:@"Editor" action:@selector(menuItemClicked:) keyEquivalent:@""];
    item.tag = DNMenuItemKindMain;
    [menu addItem:item];
    item = [[NSMenuItem alloc] initWithTitle:@"Preferences" action:@selector(menuItemClicked:) keyEquivalent:@""];
    item.tag = DNMenuItemKindPreferences;
    [menu addItem:item];
    item = [[NSMenuItem alloc] initWithTitle:@"Show Log" action:@selector(menuItemClicked:) keyEquivalent:@""];
    item.tag = DNMenuItemKindLog;
    [menu addItem:item];
    item = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(menuItemClicked:) keyEquivalent:@""];
    item.tag = DNMenuItemKindQuit;
    [menu addItem:item];
}

- (void)menuItemClicked:(id)sender
{
    if (!sender) {
        return;
    }
    
    NSAssert([sender isKindOfClass:[NSMenuItem class]], @"Unexpected sender, sender: %@, func: %s", sender, __func__);
    NSMenuItem *item = (NSMenuItem *)sender;
    
    switch (item.tag) {
        case DNMenuItemKindMain:
            [self showMainWindow];
            break;
        case DNMenuItemKindPreferences:
            [self showPreferencesWindow];
            break;
        case DNMenuItemKindLog:
            [self openLogFile];
            break;
        case DNMenuItemKindQuit:
            [[NSRunningApplication currentApplication] terminate];
            break;
    }
}

- (void)showDefaultWindow
{
    [self showMainWindow];
}

- (void)runBackgroundWorker
{
    dispatch_queue_t worker = dispatch_queue_create("dailynote_gitrepo_writer", NULL);
    
    dispatch_async(worker, ^ {
        while (true) {
#if 1
            NSDate *targetTime = [[NSDate date] dateAtEndOfDay];
            
            DDLogDebug(@"DailyNote worker is sleeping in background thread, now: %@...., wake date: %@", [NSDate date], targetTime);
            [NSThread sleepUntilDate:targetTime];
#else
            [NSThread sleepForTimeInterval:20];
#endif
            
            DDLogDebug(@"DailyNote worker is working in background thread, now: %@....", [NSDate date]);
            
            DBHelper *dbHelper = [DBHelper sharedInstance];
            GitRepoManager *manager = [[GitRepoManager alloc] initWithRepoPath:GetDailyNoteGitRepoPath()];
            NSArray *records = dbHelper.allNoteRecords;
            
            records = [records sortedArrayUsingComparator:^(id obj1, id obj2) {
                NoteRecord *record1 = obj1;
                NoteRecord *record2 = obj2;
                
                if ([record1.date isEarlierThanDate:record2.date]) {
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

            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        }
    });
}

#pragma mark - Actions

- (void)showMainWindow
{
    if (!mainWC) {
        mainWC = [[MainWindowController alloc] init];
    }
    
    [mainWC showWindow:self];
    [mainWC becomeFirstResponder];
}

- (void)showPreferencesWindow
{
    if (!prefWC) {
        prefWC = [[PreferencesWindowController alloc] init];
    }
    
    [prefWC showWindow:self];
    [prefWC becomeFirstResponder];
}

- (void)openLogFile
{
    NSString *logFullPath = currentLogFileInfo.filePath;
    
    if (!IsExists(logFullPath)) {
        DDLogError(@"Log file doesn't exist. '%@'.", logFullPath);
        return;
    }
    
    if (![[NSWorkspace sharedWorkspace] openFile:logFullPath/* withApplication:@"TextEdit.app"*/]) {
        DDLogError(@"Failed to open log file '%@'.", logFullPath);
    }
}

@end
