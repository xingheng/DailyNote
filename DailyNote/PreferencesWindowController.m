//
//  PreferencesWindowController.m
//  DailyNote
//
//  Created by Will Han on 9/20/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import "PreferencesWindowController.h"
#import "FileMgrUtil.h"
#import "AlertUtil.h"
#import "PreferencesData.h"
#import "GitRepoManager.h"

@interface PreferencesWindowController ()

@property (weak) IBOutlet NSPathControl *pathCtlGitRepo;
@property (weak) IBOutlet NSButton *cBoxReminderForCommit;
@property (weak) IBOutlet NSDatePicker *timePicker;

- (IBAction)saveButtonClicked:(id)sender;
- (IBAction)gitRepoPathCtlClicked:(id)sender;

@end

@implementation PreferencesWindowController

- (instancetype)init
{
    if (self = [super initWithWindowNibName:@"PreferencesWindowController" owner:self]) {
    }

    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    NSString *strPath = GetDailyNoteGitRepoPath();

    if (strPath) {
        _pathCtlGitRepo.URL = [NSURL fileURLWithPath:strPath isDirectory:YES];
    }

    _cBoxReminderForCommit.state = GetFShouldRemindForCommit() ? 1 : 0;

    _timePicker.locale = [NSLocale currentLocale];
    _timePicker.dateValue = [NSDate date];
}

#pragma mark - Actions

- (IBAction)saveButtonClicked:(id)sender
{
    SetDailyNoteGitRepoPath(_pathCtlGitRepo.URL.path);
    SetFShouldRemindForCommit(_cBoxReminderForCommit.state != 0);
    SetDailyNoteCommitTime(_timePicker.dateValue);

    [self close];
}

- (IBAction)gitRepoPathCtlClicked:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];

    panel.canChooseDirectories = YES;
    panel.canChooseFiles = NO;
    panel.showsHiddenFiles = NO;
    panel.allowsMultipleSelection = NO;

    [panel beginSheetModalForWindow:self.window
                  completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSURL *url = panel.URL;

            if (![GitRepoManager isValidGitRepo:url.path]) {
                RunAlertPanel(@"A valid git repo isn't found in the selected path!", @"");
                return;
            }

            _pathCtlGitRepo.URL = url;
        }
    }];
}

@end
