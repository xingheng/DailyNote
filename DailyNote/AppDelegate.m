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

typedef NS_OPTIONS(NSUInteger, DNMenuItemKind) {
    DNMenuItemKindMain,
    DNMenuItemKindPreferences,
    DNMenuItemKindQuit
};

@interface AppDelegate ()
{
    NSStatusItem *statusItem;
    MainWindowController *mainWC;
    PreferencesWindowController *prefWC;
}

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    [self initStatusBarConfig];
    [self showDefaultWindow];
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

#pragma mark - 

- (void)initStatusBarConfig
{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    statusItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    
    statusItem.title = @"Note";
    statusItem.highlightMode = YES;
    
    NSMenu *menu = [[NSMenu alloc] init];
    statusItem.menu = menu;
    
    NSMenuItem *item = nil;
    
    item = [[NSMenuItem alloc] initWithTitle:@"Main Window" action:@selector(menuItemClicked:) keyEquivalent:@""];
    item.tag = DNMenuItemKindMain;
    [menu addItem:item];
    item = [[NSMenuItem alloc] initWithTitle:@"Preferences" action:@selector(menuItemClicked:) keyEquivalent:@""];
    item.tag = DNMenuItemKindPreferences;
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
        case DNMenuItemKindQuit:
            exit(EXIT_SUCCESS);
            break;
    }
}

- (void)showDefaultWindow
{
    [self showMainWindow];
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

@end
