//
//  DWDPersonDataBiz.m
//  EduChat
//
//  Created by Gatlin on 16/2/20.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPersonDataBiz.h"
#import "DWDAccountClient.h"


@implementation DWDPersonDataBiz


+(instancetype)sharedPersonDataBiz
{
    static id  mySelf;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySelf = [[self alloc]init];
    });
    return  mySelf;
}



/** 判断是否备注 若无返回nickname */
- (NSString *)checkoutExistRemarkName:(NSString *)remarkName nickname:(NSString *)nickname
{
    if ([remarkName isEqualToString:@""] || !remarkName) {
        return nickname;
    }else{
        return remarkName;
    }
}

@end
