//
//  DWDContact.h
//  EduChat
//
//  Created by Superman on 16/1/7.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDContact : NSObject

@property (nonatomic , strong) NSNumber *myCustId;
@property (nonatomic , strong) NSNumber *custId;
@property (nonatomic , copy) NSString *photoKey;
@property (nonatomic , copy) NSString *nickname;
@property (nonatomic , copy) NSString *remark;
@property (nonatomic , copy) NSString *state;

// using offline msg and new msg only
@property (nonatomic , copy) NSString *lastCreateTime;  // 最后一条消息的创建时间
@property (nonatomic , copy) NSString *content;  // 最后一条消息的内容
@property (nonatomic , strong) NSNumber *msgNum;  // 最新收到的消息增加了多少条

@end
