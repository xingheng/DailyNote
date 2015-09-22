//
//  MainWindowController.m
//  DailyNote
//
//  Created by Will Han on 9/20/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import "MainWindowController.h"
#import "DBHelper.h"
#import "AlertUtil.h"
#import "GitRepoManager.h"
#import "PreferencesData.h"

@interface MainWindowController ()

@property (unsafe_unretained) IBOutlet NSTextView *tfNoteTextView;

- (IBAction)closeButtonClicked:(id)sender;
- (IBAction)postButtonClicked:(id)sender;

@end

@implementation MainWindowController

- (instancetype)init
{
    if (self = [super initWithWindowNibName:@"MainWindowController" owner:self]) {
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    _tfNoteTextView.font = [NSFont systemFontOfSize:15];
}

#pragma mark - Actions

- (IBAction)closeButtonClicked:(id)sender
{
    [self close];
}

- (IBAction)postButtonClicked:(id)sender
{
    /*
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"Hello, World!";
    notification.informativeText = @"A notification";
//    notification.soundName = NSUserNotificationDefaultSoundName;
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    */

    NSString *text = _tfNoteTextView.string;
    
    if (text.length <= 0) {
        RunAlertPanel(@"Content shouldn't be empty", @"");
        return;
    }
    
    NoteRecord *record = [NoteRecord createNoteRecordWithCurrentDate:text];
    [[DBHelper sharedInstance] saveRecord:record];
    
    GitRepoManager *manager = [[GitRepoManager alloc] initWithRepoPath:GetDailyNoteGitRepoPath()];
    [manager saveRecordToFile:record];
}

@end
