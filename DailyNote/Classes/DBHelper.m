//
//  DBHelper.m
//  DailyNote
//
//  Created by WeiHan on 9/21/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import "DBHelper.h"

@implementation DBHelper

+ (instancetype)sharedInstance
{
    static DBHelper *gDBHelper;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gDBHelper = [[DBHelper alloc] init];
    });
    
    return gDBHelper;
}

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    
    return self;
}

@end
