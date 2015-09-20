//
//  MainWindowController.m
//  DailyNote
//
//  Created by Will Han on 9/20/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import "MainWindowController.h"

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
    
}

@end
