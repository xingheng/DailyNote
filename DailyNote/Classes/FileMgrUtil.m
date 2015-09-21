//
//  FileMgrUtil.m
//  IPAMan
//
//  Created by WeiHan on 8/14/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import "FileMgrUtil.h"

NSFileManager *GetDefaultFileManager()
{
    return [NSFileManager defaultManager];
}

BOOL IsExists(NSString *strPath)
{
    NSFileManager *fileMgr = GetDefaultFileManager();
    return [fileMgr fileExistsAtPath:strPath];
}

BOOL CreateFile(NSString *strPath, NSError **outError)
{
    NSFileManager *fileMgr = GetDefaultFileManager();
    return [fileMgr createFileAtPath:strPath contents:nil attributes:nil];
}

BOOL DeleteFile(NSString *strPath, NSError **outError)
{
    NSFileManager *fileMgr = GetDefaultFileManager();
    return [fileMgr removeItemAtPath:strPath error:outError];
}

BOOL CopyFile(NSString *sourcePath, NSString *destPath, NSError **outError)
{
    NSFileManager *fileMgr = GetDefaultFileManager();
    return [fileMgr copyItemAtPath:sourcePath toPath:destPath error:outError];
}
