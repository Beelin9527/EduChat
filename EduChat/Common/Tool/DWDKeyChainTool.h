//
//  DWDKeyChainTool.h
//  EduChat
//
//  Created by KKK on 16/5/18.
//  Copyright © 2016年 dwd. All rights reserved.
//

/**
 *  用法
 *
 *  使用三个公有方法
 - (NSString *)readKeyWithType:(KeyChainType)type;
 - (BOOL)writeKey:(NSString *)key WithType:(KeyChainType)type;
 - (BOOL)deleteKeyWithType:(KeyChainType)type;
 *  进行 读 写 删操作
 *
 *  类型依据KeyChainType
 */


#import <Foundation/Foundation.h>

#import <UICKeyChainStore.h>



@interface DWDKeyChainTool : NSObject
typedef NS_ENUM(NSInteger, KeyChainType) {
    KeyChainTypePassword,//密码 默认选项
    KeyChainTypeToken,//token
    KeyChainTypeRefreshToken,//token失效时用于请求刷新token的token
};
@property (nonatomic, assign) KeyChainType keyChainType;

+ (instancetype)sharedManager;

- (NSString *)readKeyWithType:(KeyChainType)type;
- (BOOL)writeKey:(NSString *)key WithType:(KeyChainType)type;
- (BOOL)deleteKeyWithType:(KeyChainType)type;

@end
