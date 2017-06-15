//
//  DWDRSAHandler.h
//  EduChat
//
//  Created by KKK on 16/5/20.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <openssl/rsa.h>
#import <openssl/md5.h>

@interface DWDRSAHandler : NSObject

+ (instancetype)sharedHandler;

/**
 *  存储publicKey到本地
 *
 *  @param publicKey 公钥
 *
 *  @return 是否存储成功
 */
- (BOOL)savePublicKey:(NSString *)publicKey;

/**
 *  用公钥对信息进行加密
 *
 *  @param string 要加密的的信息
 *
 *  @return base64后的信息
 */
- (NSString *)encryptPublicKeyWithInfoString:(NSString *)string;


/**
 *  用公钥对信息进行加密
 *
 *  @param data 要加密的的信息
 *
 *  @return base64后的信息
 */
- (NSString *)encryptPublicKeyWithInfoData:(NSData *)data;
@end
