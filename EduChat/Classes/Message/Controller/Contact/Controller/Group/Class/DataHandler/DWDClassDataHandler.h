//
//  DWDClassDataHandler.h
//  EduChat
//
//  Created by apple on 16/6/2.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DWDClassModel.h"

@interface DWDClassDataHandler : NSObject

/**
 *  创建班级
 *
 *  @param custId    custId
 *  @param schoolId  学校Id
 *  @param className 班级名称
 *  @param introduce 班级简介
 *
 *  @return 班级Model
 */
+ (void)createClassWithSchoolId:(NSNumber *)schoolId
                      className:(NSString *)className
                      introduce:(NSString *)introduce
                        standardId:(NSNumber *)standardId
                        success:(void(^)(DWDClassModel *model))success
                        failure:(void(^)(NSError *error))failure;

/**
 *  创建学校
 *
 *  @param fullName 学校名
 *  @param type     类型
 *  @param success  回调
 *  @param failure  回调
 */
+ (void)createSchoolWithFullName:(NSString *)fullName
                            type:(NSNumber *)type
                    districtCode:(NSString *)districtCode
                         success:(void(^)(NSNumber *schoolId))success
                         failure:(void(^)(NSError *error))failure;

/**
 *  获取区域数据
 *
 *  @param districtCode 区域编码
 *  @param subdistrict subdistrict
 */
+ (void)getDistrictWithDistrictCode:(NSString *)districtCode
                        subdistrict:(NSNumber *)subdistrict
                            success:(void(^)(NSMutableArray *data))success
                            failure:(void(^)(NSError *error))failure;

/**
 *  获取附近学校
 *
 *  @param districtCode 区域编码
 *  @param type         类型
 *  @param fuzzyName    关键字
 *  @param success      回调
 *  @param failure      回调
 */
+ (void)getAroundSchoolWithDistrictCode:(NSString *)districtCode
                                   type:(NSNumber *)type
                              fuzzyName:(NSString *)fuzzyName
                                success:(void(^)(NSMutableArray *data))success
                                failure:(void(^)(NSError *error))failure;

/**
 *  获取班级
 *
 *  @param schoolId  学校Id
 *  @param fuzzyName 关键字
 *  @param success   回调
 *  @param failure   回调
 */
+ (void)getClassListWithSchoolId:(NSNumber *)schoolId
                       fuzzyName:(NSString *)fuzzyName
                         success:(void(^)(NSMutableArray *data))success
                         failure:(void(^)(NSError *error))failure;


/**
 获取班级功能列表

 @param custId  用户Id
 @param classId 班级Id
 @param success
 @param failure 
 */
+ (void)getClassFunctionItemListWithCustId:(NSNumber *)custId
                                   classId:(NSNumber *)classId
                                   success:(void(^)(NSMutableArray *data))success
                                   failure:(void(^)(NSError *error))failure;
@end
