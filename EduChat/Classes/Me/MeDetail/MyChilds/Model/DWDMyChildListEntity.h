//
//  DWDMyChildsListEntity.h
//  EduChat
//
//  Created by Gatlin on 16/3/17.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 参数	类型	说明
 childName	String	孩子名字
 childPhotoKey	String	孩子头像
 childEduAcct	String	孩子多维度号
 childCustId long  孩子Id
 */
@interface DWDMyChildListEntity : NSObject
@property (strong, nonatomic) NSNumber *childCustId;
@property (copy, nonatomic) NSString *childName;
@property (copy, nonatomic) NSString *childPhotoKey;
@property (copy, nonatomic) NSString *childEduAcct;
@property (strong, nonatomic) NSNumber *gender;
@end

