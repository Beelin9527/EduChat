//
//  DWDWebManager.m
//  EduChat
//
//  Created by KKK on 16/8/23.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDWebManager.h"
#import "DWDChatClient.h"
#import "DWDChatMsgDataClient.h"
#import "DWDGuideViewController.h"
#import "DWDLoginViewController.h"

#import "DWDRSAHandler.h"
#import "DWDKeyChainTool.h"
static NSString *const kSuccessStatusCode = @"1";
static NSString *const kFailureStatusCode = @"-1";

@interface DWDWebManager ()
@property (strong, nonatomic) AFHTTPRequestSerializer *requestSerializerHTTPType;
@property (strong, nonatomic) AFHTTPRequestSerializer *requestSerializerJSONType;

@end

@implementation DWDWebManager
static DWDWebManager *_sharedManager;
+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //网络超时, 默认超时时间为40s
        //SessionConfiguration必须在session（httpclient）之前进行设置
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.timeoutIntervalForRequest = 40.0;
        
        _sharedManager = [[DWDWebManager alloc] initWithBaseURL:[NSURL URLWithString:[kDWDApiBaseUrl stringByAppendingString:@"short/"]]
                                           sessionConfiguration:sessionConfiguration];
//        _sharedManager = [[DWDWebManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://192.168.10.64:8088/DWDWebService/"]
//                                           sessionConfiguration:sessionConfiguration];
        
//        _sharedManager = [[DWDWebManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://192.168.10.64:8088/DWDWebService/"]
//                                           sessionConfiguration:sessionConfiguration];
//        
//        _sharedManager = [[DWDWebManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://192.168.10.42:8070/DWDWebService/"]
//                                           sessionConfiguration:sessionConfiguration];
        //        NSData *certData = [NSData dataWithContentsOfFile:certPath];
        //        NSSet *certSet = [[NSSet alloc] initWithObjects:certData, nil];
        //        NSArray *certAr = [NSArray arrayWithObject:certData];
        AFSecurityPolicy *security = [AFSecurityPolicy defaultPolicy];
        //        [security setAllowInvalidCertificates:];
        //        [security setPinnedCertificates:certAr];
        _sharedManager.securityPolicy = security;
        // 接收时的contenttype
        _sharedManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"application/json",@"application/x-www-form-urlencoded", nil];
        
        _sharedManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        
//                [_sharedManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; // 请求时的contenttype
        
        _sharedManager.requestSerializerHTTPType = [[AFHTTPRequestSerializer alloc] init];
        _sharedManager.requestSerializerJSONType = [[AFJSONRequestSerializer alloc] init];
        
    });
    return _sharedManager;
}


@end
