//
//  DWDJPSHEnterBackgroundModel.h
//  EduChat
//
//  Created by Superman on 16/5/27.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 {"code":"sysmsgAppBackRun","entity":{"custId":"4101505215"}}
 */
@interface DWDJPSHEnterBackgroundModel : NSObject

@property (copy, nonatomic) NSString *msgType;
@property (nonatomic , copy) NSString *code;
@property (nonatomic , strong) NSDictionary *entity;


@end
