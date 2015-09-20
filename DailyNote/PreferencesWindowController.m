//
//  PreferencesWindowController.m
//  DailyNote
//
//  Created by Will Han on 9/20/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import "PreferencesWindowController.h"

@interface PreferencesWindowController ()

@property (weak) IBOutlet NSPathControl *pathCtlGitRepo;
@property (weak) IBOutlet NSButton *cBoxPush2Remote;

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
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)saveButtonClicked:(id)sender
{
}

- (IBAction)gitRepoPathCtlClicked:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseDirectories = YES;
    panel.canChooseFiles = NO;
    panel.showsHiddenFiles = NO;
    panel.allowsMultipleSelection = NO;
    
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if(result == NSFileHandlingPanelOKButton) {
            NSURL *url = panel.URL;
            
            _pathCtlGitRepo.URL = url;
        }
    }];
}
@end
