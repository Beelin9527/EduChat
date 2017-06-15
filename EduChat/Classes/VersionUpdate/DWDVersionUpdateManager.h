//
//  DWDVersionUpdateManager.h
//  EduChat
//
//  Created by KKK on 16/9/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDVersionUpdateManager : NSObject

+ (instancetype)defaultManager;

- (void)checkUpdate;

@end
