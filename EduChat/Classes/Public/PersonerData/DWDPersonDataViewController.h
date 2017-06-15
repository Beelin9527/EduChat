//
//  DWDPersonDataViewController.h
//  EduChat
//
//  Created by Gatlin on 16/3/8.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "BaseViewController.h"
#import "DWDSendVerifyInfoViewController.h"

#import "DWDRecentChatModel.h"
/** DWDTypeIsStrangerAdd 添加到通讯录
    DWDTypeIsStrangerApply 通过验证
    DWDTypeIsFriend 好友
    DWDPersonTypeMySelf 自己
 */
typedef NS_OPTIONS(NSUInteger, DWDPersonType) {
     DWDPersonTypeIsStrangerAdd,DWDPersonTypeIsStrangerApply,DWDPersonTypeIsFriend,DWDPersonTypeMySelf
};


/**
 * 申请来源 类型
 0:未知来源|
 1:通过多维度号添加|
 2:通过手机号添加|
 3:通过名片添加|
 4:通过二维码添加|
 5:通过附近人添加|
 6:通过摇一摇添加|
 7:通过群加为好友|
 8:通过班级加为好友|
 9:通过手机通讯录加为好友|
 10:通过雷达加为好友
 */
typedef NS_ENUM(NSInteger, DWDSourceType) {
    DWDSourceTypeNone,
    DWDSourceTypeEduchatSearch,
    DWDSourceTypePhoneSearch,
    DWDSourceTypeCard,
    DWDSourceTypeQR,
    DWDSourceTypeNearby,
    DWDSourceTypeShake,
    DWDSourceTypeGroup,
    DWDSourceTypeClass,
    DWDSourceTypePhoneContact,
    DWDSourceRadarType
};
@interface DWDPersonDataViewController : BaseViewController

@property (assign, nonatomic) DWDPersonType personType;
@property (strong, nonatomic) NSNumber *custId;  //用户custId
@property (nonatomic , strong) DWDRecentChatModel *recentChatModel;
@property (nonatomic, assign) DWDSourceType sourceType;

@property (nonatomic, getter=isNeedShowSetGag) BOOL needShowSetGag; //若从班级进来，右上角显示进入设置禁言
@property (nonatomic, strong) NSNumber *classId; //班级ID，用于设置禁言

/** 通讯录进来，显示电话号码 */
@property (nonatomic, getter=isShowPhoneNumber) BOOL showPhoneNumber;
@end
