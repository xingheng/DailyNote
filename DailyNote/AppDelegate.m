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

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
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
    
    statusItem.title = @"Note";
    statusItem.highlightMode = YES;
    
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
            exit(EXIT_SUCCESS);
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
            DDLogDebug(@"worker is sleeping in background thread....");
            
#if 1
            NSDate *tomorrow = [NSDate dateTomorrow];
            NSDate *targetTime = [tomorrow dateBySubtractingMinutes:5];
            
            [NSThread sleepUntilDate:targetTime];
#else
            [NSThread sleepForTimeInterval:20];
#endif
            
            DDLogDebug(@"worker is working in background thread....");
            
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
            
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = @"DailyNote";
            notification.informativeText = [NSString stringWithFormat:@"Committed %ld record(s) to git repository!", records.count];
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
    
    if (![[NSWorkspace sharedWorkspace] openFile:logFullPath withApplication:@"TextEdit.app"]) {
        DDLogError(@"Failed to open log file '%@'.", logFullPath);
    }
}

@end
