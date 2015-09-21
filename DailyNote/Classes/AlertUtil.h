//
//  AlertUtil.h
//  IPAMan
//
//  Created by WeiHan on 8/14/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import <Cocoa/Cocoa.h>

void RunAlertPanel(NSString *title, NSString *msg);
void ShowAlertError(NSError *error);

@interface AlertUtil : NSObject

+ (void)showMessage:(NSString *)strMsg title:(NSString *)strTitle;

+ (void)showMessage:(NSString *)strMsg
              title:(NSString *)strTitle
sheetModelForWindow:(NSWindow *)sheetWindow
     defaultButton1:(NSString *)title1
            action1:(void (^)(void))action1
     defaultButton2:(NSString *)title2
            action2:(void (^)(void))action2
     defaultButton3:(NSString *)title3
            action3:(void (^)(void))action3;

@end
