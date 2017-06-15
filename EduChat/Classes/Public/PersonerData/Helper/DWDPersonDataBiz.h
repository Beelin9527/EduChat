//
//  DWDPersonDataBiz.h
//  EduChat
//
//  Created by Gatlin on 16/2/20.
//  Copyright © 2016年 dwd. All rights reserved.
//  对好友或陌生人信息逻辑处理 biz

#import <Foundation/Foundation.h>

@interface DWDPersonDataBiz : NSObject

+(instancetype)sharedPersonDataBiz;


/** 判断是否备注 若无返回nickname */
- (NSString *)checkoutExistRemarkName:(NSString *)remarkName nickname:(NSString *)nickname;
@end
