//
//  DWDLocationEntity.h
//  EduChat
//
//  Created by Gatlin on 15/12/24.
//  Copyright © 2015年 dwd. All rights reserved.
//

/*
 参数	类型	说明
 locationId	long	位置id
 name	String	姓名
 address	String	地址名称
 addressAlias	String	地址别名
 districtCode	String	区划编码
 postCode	String	邮政编码
 timezoneCode	String	时区
 lng	long	经度
 lat	long	维度
 isDefault	long	是否为默认地址

 */
#import <Foundation/Foundation.h>

@interface DWDLocationEntity : NSObject

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *address;
@property (copy, nonatomic) NSString *districtCode;
@property (copy, nonatomic) NSString *postCode;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (NSMutableArray *)initWithArray:(NSArray *)array;
@end
