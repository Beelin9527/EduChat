//
//  DWDInfomationToolModel.h
//  EduChat
//
//  Created by KKK on 16/5/22.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDInfomationToolModel : NSObject

@property (nonatomic, strong) NSNumber *readCount;//阅读数
@property (nonatomic, strong) NSNumber *praiseCount;//点赞数
@property (nonatomic, strong) NSNumber *collectCount;
@property (nonatomic, strong) NSNumber *commentCount;//评论数
@property (nonatomic, strong) NSNumber *readState;//是否已读
@property (nonatomic, strong) NSNumber *praiseState;//是否收藏
@property (nonatomic, strong) NSNumber *collectState;//是否点赞

@end

