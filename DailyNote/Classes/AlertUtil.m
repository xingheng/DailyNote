//
//  AlertUtil.m
//  IPAMan
//
//  Created by WeiHan on 8/14/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import "AlertUtil.h"

void RunAlertPanel(NSString *title, NSString *msg)
{
    [AlertUtil showMessage:msg title:title];
}

void ShowAlertError(NSError *error)
{
    [NSAlert alertWithError:error];
}

@implementation AlertUtil

+ (void)showMessage:(NSString *)strMsg title:(NSString *)strTitle
{
    NSAlert *alert = [[NSAlert alloc] init];

    alert.messageText = strTitle;
    alert.informativeText = strMsg;

    [alert runModal];
}

+ (void)    showMessage:(NSString *)strMsg
                  title:(NSString *)strTitle
    sheetModelForWindow:(NSWindow *)sheetWindow
         defaultButton1:(NSString *)title1
                action1:(void (^)(void))action1
         defaultButton2:(NSString *)title2
                action2:(void (^)(void))action2
         defaultButton3:(NSString *)title3
                action3:(void (^)(void))action3
{
    NSAlert *alert = [[NSAlert alloc] init];

    alert.messageText = strTitle;
    alert.informativeText = strMsg;

    if (title1) {
        [alert addButtonWithTitle:title1];
    }

    if (title2) {
        [alert addButtonWithTitle:title2];
    }

    if (title3) {
        [alert addButtonWithTitle:title3];
    }

    NSAssert(sheetWindow, @"Invalid sheetWindow for NSAlert!");

    [alert beginSheetModalForWindow:sheetWindow
                  completionHandler:^(NSModalResponse returnCode) {
        switch (-returnCode) {
            case NSModalResponseStop:

                if (action1) {
                    action1();
                }

                break;

            case NSModalResponseAbort:

                if (action2) {
                    action2();
                }

                break;

            case NSModalResponseContinue:

                if (action3) {
                    action3();
                }

                break;
        }
    }];
}

@end
