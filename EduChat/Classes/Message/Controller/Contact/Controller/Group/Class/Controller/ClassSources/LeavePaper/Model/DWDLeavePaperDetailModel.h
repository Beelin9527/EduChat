//
//  DWDLeavePaperDetailModel.h
//  EduChat
//
//  Created by KKK on 16/5/13.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDLeavePaperDetailModel : NSObject

//private java.lang.String	aprdName
//审批人姓名

//private java.lang.String	aprdTime
//审批时间

//private java.lang.String	endTime
//结束时间

//private java.lang.String	excuse
//请假事由

//private java.lang.String	opinion
//审批意见

//private java.lang.String	startTime
//请假时间

//private int	state
//审批状态

//noteManName
//孩子姓名

//photoKey
//孩子头像

//relationType
//家长关系

//createTime
//假条创建时间


//请假类型
//noteType

@property (nonatomic, copy) NSString *aprdName;
@property (nonatomic, copy) NSString *aprdTime;
@property (nonatomic, copy) NSString *endTime;
@property (nonatomic, copy) NSString *excuse;
@property (nonatomic, copy) NSString *opinion;
@property (nonatomic, copy) NSString *startTime;
@property (nonatomic, strong) NSNumber *state;
@property (nonatomic, copy) NSString *noteManName;
@property (nonatomic, strong) NSNumber *relationType;
@property (nonatomic, copy) NSString *photoKey;
@property (nonatomic, copy) NSString *createTime;

//请假类型
@property (nonatomic, strong) NSNumber *noteType;

@end
