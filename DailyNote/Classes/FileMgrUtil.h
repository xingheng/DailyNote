//
//  FileMgrUtil.h
//  IPAMan
//
//  Created by WeiHan on 8/14/15.
//  Copyright (c) 2015 Will Han. All rights reserved.
//

#import <Foundation/Foundation.h>

NSFileManager *GetDefaultFileManager();

BOOL IsExists(NSString *strPath);

BOOL CreateFile(NSString *strPath, NSError **outError);

BOOL DeleteFile(NSString *strPath, NSError **outError);

BOOL CopyFile(NSString *sourcePath, NSString *destPath, NSError **outError);
