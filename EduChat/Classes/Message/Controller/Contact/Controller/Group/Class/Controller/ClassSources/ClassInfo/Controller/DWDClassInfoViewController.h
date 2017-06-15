//
//  DWDClassInfoViewController.h
//  EduChat
//
//  Created by Superman on 15/11/19.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 班级功能

 - DWDClassFunctionGroupRecord:  成长记录
 - DWDClassFunctionNotification: 通知
 - DWDClassFunctionHomeWork:     作业
 - DWDClassFunctionLeavePaper:   假条
 - DWDClassFunctionPickupCenter: 接送
 - DWDClassFunctionInnerGroup:   分组
 - DWDClassFunctionSetting:      设置
 - DWDClassFunctionOther:        其他第三方
 */
typedef NS_ENUM(NSUInteger, DWDClassFunction) {
    DWDClassFunctionGroupRecord = 0,
    DWDClassFunctionNotification,
    DWDClassFunctionHomeWork,
    DWDClassFunctionLeavePaper,
    DWDClassFunctionPickupCenter,
    DWDClassFunctionInnerGroup,
    DWDClassFunctionSetting,
    DWDClassFunctionOther = 999
};

/** 显示进入班级图标
    DWDClassTypeNone: 默认不需要
    DWDClassTypeShowComeInChat: 需要
 */
typedef NS_ENUM(NSUInteger, DWDClassTypeShow) {
    DWDClassTypeNone,
    DWDClassTypeShowComeInChat
};

@class DWDClassModel;
@interface DWDClassInfoViewController : UIViewController

@property (nonatomic, assign) DWDClassTypeShow typeShow;
@property (nonatomic , strong) DWDClassModel *myClass;
@end
