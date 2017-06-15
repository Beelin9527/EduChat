//
//  DWDIntelligenceMenuModel.h
//  EduChat
//
//  Created by Beelin on 16/12/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDIntelligenceMenuModel : NSObject
@property (nonatomic, strong) NSNumber *schoolId;   //学校id
@property (nonatomic, copy) NSString *parentCode; //父菜单编码
@property (nonatomic, copy) NSString *parentName; //父菜单名称

@property (nonatomic, strong) NSNumber *modeType;   //模块类型 0:原生、1:H5、2:混合
@property (nonatomic, strong) NSNumber *serialNumber; //序号，用于排序
@property (nonatomic, strong) NSNumber *menuType;   //0:普通、1:学校、2:班级、3:区域、4:虚拟
@property (nonatomic, copy) NSString *menuCode;   //菜单编号
@property (nonatomic, copy) NSString *menuName;   //菜单名称
@property (nonatomic, copy) NSString *menuIcon;   //菜单图标
@property (nonatomic, copy) NSString *funcDesc;   //菜单功能描述

@property (nonatomic, strong) NSNumber *isOpen; //是否开通
@property (nonatomic, strong) NSNumber *isShow; //是否显示

@property (nonatomic, strong) NSNumber *classId; //班级ID
@property (nonatomic, copy) NSString *sole;   //唯一值（@"学校ID" + @"班级ID" + @"菜单编号"）

@property (nonatomic, assign) CGFloat cellHeight; //cell高度
@end
