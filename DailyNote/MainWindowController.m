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
#import "NSString+Utilities.h"
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
    
    NSString *strDefaultGitRepoPath = GetDailyNoteGitRepoPath();
    if (!strDefaultGitRepoPath) {
        RunAlertPanel(@"No valid git repository path configuration found!", @"Please go to Preferences window to choose one.");
        _tfNoteTextView.editable = NO;
    } else {
        _tfNoteTextView.editable = YES;
    }
}

#pragma mark - Actions

- (IBAction)closeButtonClicked:(id)sender
{
    [self close];
}

- (IBAction)postButtonClicked:(id)sender
{
    NSString *text = _tfNoteTextView.string;
    
    if ([text isEmpty]) {
        RunAlertPanel(@"Content shouldn't be empty", @"");
        return;
    }
    
    NoteRecord *record = [NoteRecord createNoteRecordWithCurrentDate:text];
    [[DBHelper sharedInstance] saveRecord:record];
    DDLogInfo(@"Saved note record '%@' to database.", record);
    
    [self closeButtonClicked:sender];
}

#pragma mark - NSWindowDelegate

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    NSLog(@"%@", notification);
    
    NSString *strLastContent = GetLastDailyNoteContent();
    
    if (![strLastContent isEmpty]) {
        SetLastDailyNoteContent(strLastContent);
    }
}

- (void)windowWillClose:(NSNotification *)notification
{
    NSLog(@"%@", notification);
    
    NSString *strLastContent = _tfNoteTextView.string;
    
    if (![strLastContent isEmpty]) {
        SetLastDailyNoteContent(strLastContent);
    }
}

@end
