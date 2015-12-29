//
//  NoteManager.h
//  DailyNote
//
//  Created by WeiHan on 12/3/15.
//  Copyright © 2015 Will Han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBHelper.h"
#import "NSDate+Utilities.h"
#import "GitRepoManager.h"
#import "PreferencesData.h"

@interface NoteManager : NSObject

- (void)run;

@end
