//
//  DWDNoteEntity.h
//  EduChat
//
//  Created by Gatlin on 15/12/30.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDNoteEntity : NSObject
@property (copy, nonatomic) NSString *creatTime;
@property (strong, nonatomic) NSNumber *noteId;
@property (strong, nonatomic) NSNumber *state;
@property (strong, nonatomic) NSNumber *type;

- (id)initWithDict:(NSDictionary *)dict;

+ (NSMutableArray *)initWithArray:(NSArray *)array;
@end


/*

 private java.lang.String	creatTime
 申请时间
 private long	noteId
 假条id
 private int	state
 审批状态
 值域:
 0-未审批
 1-同意
 2-不同意
 private int	type
 请假类型
 值域:
 1-事假
 2-病假
 3-其他

*/