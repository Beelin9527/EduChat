//
//  DWDWebManager.h
//  EduChat
//
//  Created by KKK on 16/8/23.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "HttpClient.h"

@interface DWDWebManager : HttpClient

+ (instancetype)sharedManager;

@end
