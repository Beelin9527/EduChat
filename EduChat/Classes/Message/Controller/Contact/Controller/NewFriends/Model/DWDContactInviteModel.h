//
//  DWDContactInviteModel.h
//  EduChat
//
//  Created by KKK on 16/11/14.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDContactInviteModel : NSObject

@property (nonatomic, copy) NSString *name; //姓名(本来只要姓, 但是无法确定他lastName真的是姓)
@property (nonatomic, strong) NSArray *mobile;//电话号码数组(不一定只有一个,所以是一个数组)
@property (nonatomic, copy) NSString *identifier;//记录单条通讯录的唯一标示(abaddress为int类型,自转string)
@property (nonatomic, strong) UIImage *image;//头像
@property (nonatomic, assign) BOOL invited;


@end
