//
//  DWDNoteDetailEntity.h
//  EduChat
//
//  Created by Bharal on 15/12/31.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDNoteDetailEntity : NSObject
@property (copy, nonatomic) NSString *startTime;
@property (copy, nonatomic) NSString *endTime;
@property (copy, nonatomic) NSString *excuse;
@property (copy, nonatomic) NSString *opinion;
@property (copy, nonatomic) NSString *aprdName;
@property (copy, nonatomic) NSString *aprdTime;
@property (copy, nonatomic) NSNumber *state;

- (id)initWithDict:(NSDictionary *)dict;
@end


/*
 
 private java.lang.String	endTime
 结束时间
 private java.lang.String	excuse
 请假事由
 private java.lang.String	opinion
 审批意见
 private java.lang.String	startTime
 请假时间

 aprdName  审批者
 aprdTime   审批时间
state       状态  0 无 1同意 2不同意;
*/