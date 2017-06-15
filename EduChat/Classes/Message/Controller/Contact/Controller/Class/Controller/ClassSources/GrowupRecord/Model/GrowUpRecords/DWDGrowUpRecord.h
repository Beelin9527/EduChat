//
//  DWDGrowUpRecord.h
//  EduChat
//
//  Created by Superman on 15/12/29.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDGrowUpRecord : NSObject

@property (nonatomic , copy) NSString *address; //
@property (nonatomic , strong) NSNumber *albumId; //
@property (nonatomic , copy) NSString *content; // 正文
@property (nonatomic , strong) NSNumber *logId; //
@property (nonatomic , strong) NSNumber *albumsType;  // 相册类型

@end
