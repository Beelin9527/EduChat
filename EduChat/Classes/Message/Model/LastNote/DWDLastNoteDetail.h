//
//  DWDLastNoteDetail.h
//  EduChat
//
//  Created by Superman on 16/3/29.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDLastNoteDetail : NSObject

@property (nonatomic , strong) NSNumber *readed;
@property (nonatomic , copy) NSString *firstPhoto;
@property (nonatomic , copy) NSString *creatTime;
@property (nonatomic , copy) NSString *title;
@property (nonatomic , strong) NSNumber *type;  //  1 表示"知道了"的通知类型  2表示 "yes/no"的通知类型
@property (nonatomic , strong) NSNumber *noticeId;
@property (nonatomic , copy) NSString *content;

@end
