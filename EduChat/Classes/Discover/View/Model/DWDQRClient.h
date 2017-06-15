//
//  DWDQRClient.h
//  EduChat
//
//  Created by Gatlin on 16/2/16.
//  Copyright © 2016年 dwd. All rights reserved.
//  二维码扫描到的信息，在此进行解析

#import <Foundation/Foundation.h>
#import "DWDSingleton.h"
@interface DWDQRClient : NSObject

DWDSingletonH(QRClient)

- (void)requestAcctRestServiceGetQRInfoWithCustId:(NSNumber *)custId friendCustId:(NSString *)friendCustId success:(void(^)(id responObject))success failure:(void(^)(NSError *error))failure;

+ (void)requestAnalysisWithQRInfo:(NSString *)QRInfo controller:(UIViewController *)controller;
@end
