//
//  DWDKeyChainTool.m
//  EduChat
//
//  Created by KKK on 16/5/18.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDKeyChainTool.h"
static NSString * const DWDKeyChainService = @"com.dwd-sj.KeyChainService";
static NSString * const DWDKeyChainPassword = @"DWDKeyChainPassword";
static NSString * const DWDKeyChainToken = @"DWDKeyChainToken";
static NSString * const DWDKeyChainRefreshToken = @"DWDKeyChainRefreshToken";

@interface DWDKeyChainTool ()
@property (nonatomic, strong) UICKeyChainStore *keyChainStore;

@end

@implementation DWDKeyChainTool
static DWDKeyChainTool *_instance;

#pragma mark - Public Method

+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[DWDKeyChainTool alloc] init];
//        UICKeyChainStore *keyChainStore = [UICKeyChainStore keyChainStoreWithService:DWDKeyChainService];
        UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:DWDKeyChainService];

        _instance.keyChainStore = keychain;
    });
    return _instance;
}

- (NSString *)readKeyWithType:(KeyChainType)type {
    return [self readValueWithKey:[DWDKeyChainTool type:type]];
}

- (BOOL)writeKey:(NSString *)key WithType:(KeyChainType)type {
    return [self writeValue:key withKey:[DWDKeyChainTool type:type]];
}

- (BOOL)deleteKeyWithType:(KeyChainType)type {
    return [self deleteValueWithKey:[DWDKeyChainTool type:type]];
}

#pragma mark - Private Method
+ (NSString *)type:(KeyChainType)type {
    NSString *key;
    switch (type) {
        case KeyChainTypeToken:
            key = DWDKeyChainToken;
            break;
            
        case KeyChainTypeRefreshToken:
            key = DWDKeyChainRefreshToken;
            break;
            
        case KeyChainTypePassword:
            key = DWDKeyChainPassword;
            break;
        default:
            key = nil;
            break;
    }
    return key;
}

- (NSString *)readValueWithKey:(NSString *)key {
    if (key == nil) return nil;
    return [self.keyChainStore stringForKey:key];
}

- (BOOL)writeValue:(NSString *)value withKey:(NSString *)key {
    if (key == nil || value == nil) return NO;
    NSError *error;
    [self.keyChainStore setString:value forKey:key genericAttribute:nil error:&error];
//    [self.keyChainStore setValue:value forKey:key];
    if (error) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)deleteValueWithKey:(NSString *)key {
    if (key == nil) return NO;
    return [self.keyChainStore removeItemForKey:key];
}

@end
