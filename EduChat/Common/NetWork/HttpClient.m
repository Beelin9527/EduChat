//
//  HttpClient.m
//  EduChat
//
//  Created by fanly on 14-7-21.
//  Copyright (c) 2014年 DWD. All rights reserved.
//

#import "HttpClient.h"
#import "DWDChatClient.h"
#import "DWDChatMsgDataClient.h"
#import "DWDGuideViewController.h"
#import "DWDLoginViewController.h"

#import "DWDRSAHandler.h"
#import "DWDKeyChainTool.h"
static NSString *const kSuccessStatusCode = @"1";
static NSString *const kFailureStatusCode = @"-1";
@interface HttpClient()
@property (strong, nonatomic) AFHTTPRequestSerializer *requestSerializerHTTPType;
@property (strong, nonatomic) AFHTTPRequestSerializer *requestSerializerJSONType;

@property (nonatomic, strong) DWDRSAHandler *RSAHandler;
@end
@implementation HttpClient

static HttpClient *_sharedClient;


#pragma mark Getter
- (DWDRSAHandler *)RSAHandler
{
    if (!_RSAHandler) {
        _RSAHandler = [[DWDRSAHandler alloc] init];
    }
    return _RSAHandler;
}


+ (instancetype)sharedClient
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //网络超时, 默认超时时间为40s
        //SessionConfiguration必须在session（httpclient）之前进行设置
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.timeoutIntervalForRequest = 40.0;
        
        _sharedClient = [[HttpClient alloc] initWithBaseURL:[NSURL URLWithString:kDWDApiBaseUrl]
                                       sessionConfiguration:sessionConfiguration];
        
        
//        self.requestSerializer = [AFHTTPRequestSerializer serializer];
//        self.responseSerializer = [AFJSONResponseSerializer serializer];
//        _sharedClient.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        AFSecurityPolicy *security = [AFSecurityPolicy defaultPolicy];
//        [security setAllowInvalidCertificates:];
//        [security setPinnedCertificates:certAr];
        _sharedClient.securityPolicy = security;
        // 接收时的contenttype
        _sharedClient.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"application/json",@"application/x-www-form-urlencoded",@"text/html", nil];
        
        _sharedClient.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        
//                [_sharedClient.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; // 请求时的contenttype
        
        _sharedClient.requestSerializerHTTPType = [[AFHTTPRequestSerializer alloc] init];
        _sharedClient.requestSerializerJSONType = [[AFJSONRequestSerializer alloc] init];
        
        //监听网络状态
        /*
         `AFNetworkReachabilityStatusUnknown`
         The `baseURL` host reachability is not known.
         
         `AFNetworkReachabilityStatusNotReachable`
         The `baseURL` host cannot be reached.
         
         `AFNetworkReachabilityStatusReachableViaWWAN`
         The `baseURL` host can be reached via a cellular connection, such as EDGE or GPRS.
         
         `AFNetworkReachabilityStatusReachableViaWiFi`
         The `baseURL` host can be reached via a Wi-Fi connection.
         */
        
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusUnknown:
                    if (![[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[DWDGuideViewController class]]) {
                        [DWDProgressHUD showText:@"未知的网络"];
                    }
                    break;
                    
                case AFNetworkReachabilityStatusNotReachable:
                    if (![[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[DWDGuideViewController class]]) {
                        [DWDProgressHUD showText:@"无法连接网络"];
                        
                    }
                    
                    break;
                    
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    if (![[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[DWDGuideViewController class]]) {
                        [DWDProgressHUD showText:@"正在使用WIFI网络"];
                    }
                {
                    if ([DWDCustInfo shared].isLogin ) {
                        //建立链接
                        [[DWDChatClient sharedDWDChatClient] reconnection];
                        
                    }
                    
                }break;
                    
                case AFNetworkReachabilityStatusReachableViaWWAN:
                {
                    if (![[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[DWDGuideViewController class]]) {
                        [DWDProgressHUD showText:@"正在使用手机网络"];
                    }
                    
                    if ([DWDCustInfo shared].isLogin) {
                        //建立链接
                        [[DWDChatClient sharedDWDChatClient] reconnection];
                    }
                    
                }break;
                default:
                    break;
            }
        }];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        
    });
    return _sharedClient;
}


/*
 - (NSURLSessionDataTask *)api:(NSString *)api
 params:(NSDictionary *)params
 keyPath:(NSString *)keyPath
 forModelClass:(Class)modelClass
 success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
 failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
 {
 return [self api:api version:@"v1" params:params keyPath:keyPath forModelClass:modelClass success:success failure:failure];
 }
 
 
 - (NSURLSessionDataTask *)api:(NSString *)api
 version:(NSString *)version
 params:(NSDictionary *)params
 keyPath:(NSString *)keyPath
 forModelClass:(Class)modelClass
 success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
 failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
 {
 return [self api:api version:version params:params success:^(NSURLSessionDataTask *task, id responseObject) {
 id result = nil;
 NSError *error = nil;
 
 id data = responseObject[keyPath];
 if ([data isKindOfClass:[NSArray class]]) {
 result = [MTLJSONAdapter modelsOfClass:modelClass fromJSONArray:data error:&error];
 } else {
 result = [MTLJSONAdapter modelOfClass:modelClass fromJSONDictionary:data error:&error];
 }
 
 if (!error && success) {
 success(task, result);
 } else if (failure) {
 failure(task, error);
 }
 
 } failure:failure];
 }
 
 
 - (NSURLSessionDataTask *)api:(NSString *)api
 params:(NSDictionary *) params
 success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
 failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
 {
 return [self api:api version:nil params:params success:success failure:failure];
 }
 
 
 - (NSURLSessionDataTask *)api:(NSString *)api
 version:(NSString *)version
 params:(NSDictionary *) params
 success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
 failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
 {
 NSParameterAssert(api);
 NSParameterAssert(version);
 NSMutableDictionary *finalParams = [NSMutableDictionary dictionaryWithDictionary:params];
 [finalParams setObject:version forKey:@"version"];
 
 DWDLog(@"%@",params);
 
 NSURLSessionDataTask *task;
 #ifdef DEBUG
 task = [self GET:api parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
 #else
 task = [self POST:api parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
 #endif
 NSDictionary* status = responseObject[@"_status"];
 NSString *statusCode = status[@"result"];
 NSString *result = responseObject[@"result"];
 
 if ([kSuccessStatusCode isEqual:result]) {
 if (success) {
 success(task, responseObject);
 }
 } else {
 if (failure) {
 NSString *message = responseObject[@"errordesc"];
 NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"Network request error",
 NSLocalizedFailureReasonErrorKey:message};
 NSError *error = [NSError errorWithDomain:kDWDErrorDomain code:[responseObject[@"errorcode"] intValue] userInfo:userInfo];
 
 failure(task, error);
 }
 }
 
 } failure:^(NSURLSessionDataTask *task, NSError *error) {
 if (failure) {
 failure(task, error);
 }
 }];
 
 return task;
 }
 */

- (NSURLSessionDataTask *)getApi:(NSString *)api
                          params:(NSDictionary *) params
                         success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                         failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    
    NSParameterAssert(api);
    DWDLog(@"api: ---%@",api);
    DWDLog(@"params: ---%@",params);
    self.requestSerializer = self.requestSerializerHTTPType;
//    _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
    //从本地获取缓存请求头信息
    NSDictionary *requestHeaderInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kDWDRequestHeaderInfoCache];
    
    /*  设置请求头
     *  token    加密token
     *  uid      用户标识
     *  timestamp 时间缀
     */
    if (requestHeaderInfo)
    {
        NSString *encryptToken = requestHeaderInfo[@"encryptToken"];
        [self.requestSerializer setValue:encryptToken forHTTPHeaderField:@"token"];
        
        NSString *uid = requestHeaderInfo[@"uid"];
        [self.requestSerializer setValue:uid forHTTPHeaderField:@"uid"];
        
        
        // 如果想转成int型，必须转成long long型才够大。
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        long long dTime = [[NSNumber numberWithDouble:time] longLongValue]; // 将double转为long long型
        NSString *curTime = [NSString stringWithFormat:@"%llu",dTime]; // 输出long long型
        
        NSString *encryptCurTime = [[DWDRSAHandler sharedHandler] encryptPublicKeyWithInfoData:[curTime dataUsingEncoding:NSUTF8StringEncoding]];
        
        [self.requestSerializer setValue:encryptCurTime forHTTPHeaderField:@"timestamp"];
    }
    
    
    NSURLSessionDataTask *task;
    
//    NSString *urlStr;
//    if ([api isEqualToString:@"/token/refreshToken"]) {
//        urlStr = @"token/refreshToken";
//    }else{
//        urlStr = api;
//    }
    
    
    task = [self GET:api parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSString *result = responseObject[@"result"];
        
        if ([kSuccessStatusCode isEqual:result]) {
            if (success) {
                success(task, responseObject);
            }
        } else if ([kFailureStatusCode isEqual:result]){
            
            //判断是否是token 失效
            if ( [responseObject[@"errorcode"] isEqualToString:kTokenOverdue]) {
                
                //一、1.从本地获取refreshToken
                NSString *refreshToken = [[DWDKeyChainTool sharedManager] readKeyWithType:KeyChainTypeRefreshToken];
                if (!refreshToken) return;
                
                //2.重新请求新的token
                [[HttpClient sharedClient]
                 getApi:@"token/refreshToken"
                 params:@{@"token": refreshToken}
                 success:^(NSURLSessionDataTask *task, id responseObject)
                 {
                     
                     //二.判断是否result = 1; 重新保存token 与 refreshToken
                     if ( [kSuccessStatusCode isEqual:responseObject[@"result"]])
                     {
                         //1。获取accessToken 与存储
                         NSString *token =  responseObject[DWDApiDataKey][@"accessToken"];
                         [[DWDKeyChainTool sharedManager] writeKey:token
                                                          WithType:KeyChainTypeToken];
                         
                         //2.获取refreshToken 与存储
                         NSString *refreshToken =  responseObject[DWDApiDataKey][@"refreshToken"];
                         [[DWDKeyChainTool sharedManager] writeKey:refreshToken
                                                          WithType:KeyChainTypeRefreshToken];
                         
                         //token 加密
                         NSData *tokenData = [token dataUsingEncoding:NSUTF8StringEncoding];
                         NSString *encryptToken = [[DWDRSAHandler sharedHandler] encryptPublicKeyWithInfoData:tokenData];
                        
                         //从本地获取缓存请求头信息
                         NSMutableDictionary *requestHeaderInfo = [[[NSUserDefaults standardUserDefaults] objectForKey:kDWDRequestHeaderInfoCache] mutableCopy];
                         [requestHeaderInfo setValue:encryptToken forKey:@"encryptToken"];
                         
                         [[NSUserDefaults standardUserDefaults] setObject:requestHeaderInfo forKey:kDWDRequestHeaderInfoCache];
                         
                         //3.重新请求
                         [self getApi:api params:params success:success failure:failure];
                         
                     }
                     //三.result = -1 ,重新登录、获取token 与 refreshToken
                     else if ([kFailureStatusCode isEqual:responseObject[@"result"]])
                     {
                         [[NSUserDefaults standardUserDefaults]setObject:nil forKey:DWDLoginCustIdCache];
                         //登录
                         DWDLoginViewController *vc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDLoginViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDLoginViewController class])];
                         
                         UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
                         navi.navigationBarHidden = YES;
                         [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:navi animated:YES completion:nil];
                         return;
                     }
                     
                 }
                 failure:^(NSURLSessionDataTask *task, NSError *error)
                 {
                     if (failure)
                     {
                         [[NSUserDefaults standardUserDefaults]setObject:nil forKey:DWDLoginCustIdCache];
                         //登录
                         DWDLoginViewController *vc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDLoginViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDLoginViewController class])];
                         
                         UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
                         navi.navigationBarHidden = YES;
                         [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:navi animated:YES completion:nil];
                         return;
                         
                     }
                 }];
            }
            else
            {
                NSString *message = [responseObject[@"errordesc"] isEqualToString:@""] ? @"网络请求失败" : responseObject[@"errordesc"];
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"Network request error",
                                           NSLocalizedFailureReasonErrorKey:message};
                NSError *error = [NSError errorWithDomain:kDWDErrorDomain code:[responseObject[@"errorcode"] intValue] userInfo:userInfo];
                failure(task, error);
                
            }
        }
        else
        {
            
            NSString *message = nil;
            if (!responseObject || [responseObject isEqual:@""]) {
               message  =  @"网络请求失败";
            }else{
               message = responseObject[@"errordesc"];
            }
            
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"Network request error",
                                       NSLocalizedFailureReasonErrorKey:message};
            NSError *error = [NSError errorWithDomain:kDWDErrorDomain code:[responseObject[@"errorcode"] intValue] userInfo:userInfo];
            failure(task, error);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            
//            [self showErrorHUD:error];
            failure(task, error);
            DWDLog(@"error : %@",error);
        }
    }];
    return task;
    
}

- (NSURLSessionDataTask *)postApi:(NSString *)api
                           params:(NSDictionary *)params
                          success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                          failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSParameterAssert(api);
    DWDLog(@"api: ---%@",api);
    DWDLog(@"params: ---%@",params);
    
    self.requestSerializer = self.requestSerializerJSONType;
    NSURLSessionDataTask *task;
    
    //从本地获取缓存请求头信息
    NSDictionary *requestHeaderInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kDWDRequestHeaderInfoCache];
    
    /*  设置请求头
     *  token    加密token
     *  uid      用户标识
     *  timestamp 时间缀
     */
    if (requestHeaderInfo)
    {
        NSString *encryptToken = requestHeaderInfo[@"encryptToken"];
        [self.requestSerializer setValue:encryptToken forHTTPHeaderField:@"token"];
        
        NSString *uid = requestHeaderInfo[@"uid"];
        [self.requestSerializer setValue:uid forHTTPHeaderField:@"uid"];
        
        
        // 如果想转成int型，必须转成long long型才够大。
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        long long dTime = [[NSNumber numberWithDouble:time] longLongValue]; // 将double转为long long型
        NSString *curTime = [NSString stringWithFormat:@"%llu",dTime]; // 输出long long型
        
        NSString *encryptCurTime = [[DWDRSAHandler sharedHandler] encryptPublicKeyWithInfoData:[curTime dataUsingEncoding:NSUTF8StringEncoding]];
        
        [self.requestSerializer setValue:encryptCurTime forHTTPHeaderField:@"timestamp"];
    }
    
    task = [self POST:api parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSString *result = responseObject[@"result"];
        
        if ([kSuccessStatusCode isEqual:result]) {
            
            if (success) {
                success(task, responseObject);
                DWDLog(@"responseObject : ---%@",responseObject);
            }
            
        }
        else if ([kFailureStatusCode isEqual:result]){
            
            //判断是否是token 失效
            if ( [responseObject[@"errorcode"] isEqual:kTokenOverdue]) {
                
                //一、1.从本地获取refreshToken
                NSString *refreshToken = [[DWDKeyChainTool sharedManager] readKeyWithType:KeyChainTypeRefreshToken];
                //2.重新请求新的token
                [[HttpClient sharedClient]
                 getApi:@"token/refreshToken"
                 params:@{@"token": refreshToken}
                 success:^(NSURLSessionDataTask *task, id responseObject)
                 {
                     
                     //二.判断是否result = 1; 重新保存token 与 refreshToken
                     if ( [kSuccessStatusCode isEqual:responseObject[@"result"]])
                     {
                         //1。获取accessToken 与存储
                         NSString *token =  responseObject[DWDApiDataKey][@"accessToken"];
                         [[DWDKeyChainTool sharedManager] writeKey:token
                                                          WithType:KeyChainTypeToken];
                         
                         //2.获取refreshToken 与存储
                         NSString *refreshToken =  responseObject[DWDApiDataKey][@"refreshToken"];
                         [[DWDKeyChainTool sharedManager] writeKey:refreshToken
                                                          WithType:KeyChainTypeRefreshToken];
                         
                         //token 加密
                         NSData *tokenData = [token dataUsingEncoding:NSUTF8StringEncoding];
                         NSString *encryptToken = [[DWDRSAHandler sharedHandler] encryptPublicKeyWithInfoData:tokenData];
                         
                         //从本地获取缓存请求头信息
                         NSMutableDictionary *requestHeaderInfo = [[[NSUserDefaults standardUserDefaults] objectForKey:kDWDRequestHeaderInfoCache] mutableCopy];
                         [requestHeaderInfo setValue:encryptToken forKey:@"encryptToken"];
                         
                         [[NSUserDefaults standardUserDefaults] setObject:requestHeaderInfo forKey:kDWDRequestHeaderInfoCache];
                         
                         //3.重新请求
                         [self postApi:api params:params success:success failure:failure];
                     }
                     //三.result = -1 ,重新登录、获取token 与 refreshToken
                     else if ([kFailureStatusCode isEqual:responseObject[@"result"]])
                     {
                         [[NSUserDefaults standardUserDefaults]setObject:nil forKey:DWDLoginCustIdCache];
                         //登录
                         DWDLoginViewController *vc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDLoginViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDLoginViewController class])];
                         
                         UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
                         navi.navigationBarHidden = YES;
                         [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:navi animated:YES completion:nil];
                         return;
                         
                     }
                     
                 }
                 failure:^(NSURLSessionDataTask *task, NSError *error)
                 {
                     if (failure)
                     {
                         [[NSUserDefaults standardUserDefaults]setObject:nil forKey:DWDLoginCustIdCache];
                         //登录
                         DWDLoginViewController *vc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDLoginViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDLoginViewController class])];
                         
                         UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
                         navi.navigationBarHidden = YES;
                         [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:navi animated:YES completion:nil];
                         return;
                     }
                 }];
            }
            else
            {
                NSString *message = [responseObject[@"errordesc"] isEqualToString:@""] ? @"网络请求失败" : responseObject[@"errordesc"];
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"Network request error",
                                           NSLocalizedFailureReasonErrorKey:message};
                NSError *error = [NSError errorWithDomain:kDWDErrorDomain code:[responseObject[@"errorcode"] intValue] userInfo:userInfo];
                failure(task, error);
            }
        }
        else
        {
            NSString *message = nil;
            if (!responseObject || [responseObject isEqual:@""]) {
                message  =  @"网络请求失败";
            }else{
                message = responseObject[@"errordesc"];
            }
            
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"Network request error",
                                       NSLocalizedFailureReasonErrorKey:message};
            NSError *error = [NSError errorWithDomain:kDWDErrorDomain code:[responseObject[@"errorcode"] intValue] userInfo:userInfo];
            failure(task, error);
        }

        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(task, error);
//            [self showErrorHUD:error];
            
        }
    }];
    
    return task;
    
}

/**
 *  成长记录
 */
/**
 *  上传成长记录
 *  AlbumRestService/addEntity
 */
- (NSURLSessionDataTask *)postGrowUpRecordWithParams:(NSDictionary *)params
                                             success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                             failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSString *api = @"AlbumRestService/addEntity";
    return [self postApi:api params:params success:success failure:failure];
}

//上传评论
- (NSURLSessionDataTask *)postGrowUpCommentWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSString *api = @"AlbumRestService/addComment";
    
    
    return [self postApi:api params:params success:success failure:failure];
}

//获取数据
- (NSURLSessionDataTask *)getGrowUpRequestWithClassId:(NSNumber *)classId
                                               custId:(NSNumber *)custId
                                            pageIndex:(NSInteger)pageIndex
                                              success:(void (^)(NSURLSessionDataTask *, id))success
                                              failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSString *api = @"AlbumRestService/getClassAlbumRecords";
    NSDictionary *params = @{
                             @"custId":custId,
                             @"classId":classId,
                             @"pageIndex":[NSNumber numberWithInteger:pageIndex],
                             };
    return [self getApi:api params:params success:success failure:failure];
}

//点赞
- (NSURLSessionDataTask *)postGrowUpPraiseWithAlbumId:(NSNumber *)albumId custId:(NSNumber *)custId recordId:(NSNumber *)recordId success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSString *api = @"AlbumRestService/addPraise";
    
    NSDictionary *params = @{
                             @"custId" : custId,
                             @"albumId" : albumId,
                             @"recordId" : recordId
                             };
    
    return [self postApi:api params:params success:success failure:failure];
}


//http://192.168.10.52:8080/app-api/msgctr/get.html
// short api
- (NSURLSessionDataTask *)getRequstClassVerifyInfoWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSString *api = @"msgctr/get";
//    NSDictionary *params = @{@"custId": custId};
    
    return [self getApi:api params:params success:success failure:failure];
}

//short/msgctr/delete
//short api
- (NSURLSessionDataTask *)deleteClassVerifyInfoWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSString *api = @"msgctr/delete";
    
    return [self postApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)getUserInfo:(NSNumber *)custId success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSString *api = @"AcctRestService/getUserInfoEx";
    NSDictionary *params = @{@"friendCustId": custId};
    
    return [self getApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)postUpdateClassVerifyState:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure  {
    NSString *api = @"ClassVerifyRestService/updateState2";
    
    
    return [self postApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)postUpdateClassNotificationReplyState:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure  {
    NSString *api = @"NoticeRestService/replyNotice";
    
    
    return [self postApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)getClassGroupListWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSString *api = @"ClassGroupRestService/getList";
    return [self getApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)getPickUpCenterStudentsStatusWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure  {
    NSString *api = @"punch/getPickupchild";
    return [self getApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)getPickUpCenterTimeLineStudentsStatusWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSString *api = @"ClassRestService/getAttendancerate";
    return [self getApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)postPickUpCenterStatusUpdateWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSString *api = @"punch/shuttleConfirm";
    return [self postApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)getClassNotificationDetail:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSString *api = @"NoticeRestService/getEntity";
    return [self getApi:api params:params success:success failure:failure];
}

/**
 *  删除通知
 *  NoticeRestService/deleteEntity
 */
- (NSURLSessionDataTask *)postDeleteClassNotification:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSString *api = @"NoticeRestService/deleteEntity";
    return [self postApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)postClassVerifyReplyVerifyInfoWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSString *api = @"FriendVerifyRestService/addVerifyInfos";
    return [self postApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)postAddClassLeavePaperWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSString *api = @"NoteRestService/addEntity";
    return [self postApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)getChildListWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSString *api = @"AcctRestService/getMyChildrenList";
    return [self getApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)getLeavePaperDetailWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSString *api = @"NoteRestService/getEntity";
    return [self getApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)postApproveNoteWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSString *api = @"NoteRestService/approveNote";
    return [self postApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)getInfomationInfoWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSString *api = @"EduInformationRestService/getVisitStat";
    return [self getApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)getInfomationCommentsWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSString *api = @"EduInformationRestService/getCommentList";
    
    return [self getApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)postInfomationPraiseWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    //    EduInformationRestService/addPraise
    NSString *api = @"EduInformationRestService/addPraise";
    return [self postApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)postInfomationPraiseDeleteWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    //    EduInformationRestService/deletePraise
    NSString *api = @"EduInformationRestService/deletePraise";
    return [self postApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)postInfomationCollectWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    //    CollectRestService/addEntity
    NSString *api = @"CollectRestService/addEntity";
    return [self postApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)postInfomationCollectDeleteWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSString *api = @"CollectRestService/deleteEntity";
    return [self postApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)postInfomationCommentWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    //    EduInformationRestService/addComment
    NSString *api = @"EduInformationRestService/addComment";
    return [self postApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)postInfomationCommentDeleteWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSString *api = @"EduInformationRestService/deleteComment";
    return [self postApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)postInfomationAddReadWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    //    EduInformationRestService/addRead
    NSString *api = @"EduInformationRestService/addRead";
    return [self postApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)postInviteContactsListWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSString *api = @"acct/unRegList.action";
    return [self postApi:api params:params success:success failure:failure];
}

/**
 发送好友邀请(SMS) (short Api)
 
 sms/inv.action
 */
- (NSURLSessionDataTask *)postContactInviteWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSString *api = @"sms/inv.action";
    return [self postApi:api params:params success:success failure:failure];
}

#pragma mark - 智能通讯录
/**
 获取某个学校所有分组的成员列表情况 (short Api)
 
smartAddr/getUsersByGpId
 */
- (NSURLSessionDataTask *)getSchoolGroupMembersWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSString *api = @"smartAddr/getUsersByGpId";
    return [self getApi:api params:params success:success failure:failure];
}

/**
 获取某个学校所有分组列表 (short Api)
 
 smartAddr/get
 */
- (NSURLSessionDataTask *)getSchoolGroupListWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSString *api = @"smartAddr/get";
    return [self getApi:api params:params success:success failure:failure];
}

- (NSURLSessionDataTask *)postDeleteStudentsWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    //(short Api)
    NSString *api = @"clsstu/delete";
    return [self postApi:api params:params success:success failure:failure];
}
/**
 获取某个学校所有分组的成员列表情况 (short Api)
 
 ClassMemberRestService/getStudents
 */
- (NSURLSessionDataTask *)getClassStudentsWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSString *api = @"ClassMemberRestService/getStudents";
    return [self getApi:api params:params success:success failure:failure];
}

/**
 班级菜单功能的Html获取
 
 plte/getH5
 */
- (NSURLSessionDataTask *)getClassMenuH5WithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSString *api = @"plte/getH5";
    return [self getApi:api params:params success:success failure:failure];
}

#pragma mark - 临时聊天 / 群组
/**
 临时聊天群组聊天创建群组
 GroupRestService/addGroup
 */
- (NSURLSessionDataTask *)postAddGroupChatWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSString *api = @"GroupRestService/addGroup";
    return [self postApi:api params:params success:success failure:failure];
}

//FriendVerifyRestService/temporaryFriend
- (NSURLSessionDataTask *)postAddTempFriendChatWithParams:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSString *api = @"FriendVerifyRestService/temporaryFriend";
    return [self postApi:api params:params success:success failure:failure];
}

/**
 *  请求错误时，根据错误显示HUD
 *
 *  @param error 请求错误
 */
- (void)showErrorHUD:(NSError *)error {
    DWDLog(@"*************\n");
    DWDLog(@"-----\n");
    DWDLog(@"*************\n");
    DWDLog(@"code: %ld", (long)error.code);
    switch (error.code) {
        case -1001: //-1001为请求超时
            [DWDProgressHUD showText:@"连接超时"];
            break;
            
        default:
            break;
    }
}

#pragma mark - 检查版本更新
//SysConfigRestService/getVersionNeedUpdate
- (NSURLSessionDataTask *)getIfNeedsUpdateVersion:(NSDictionary *)params success:(void (^)(NSURLSessionDataTask *, id))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSString *api = @"ver/get";
    return [self getApi:api params:params success:success failure:failure];
}

#pragma mark - 网络请求类本身相关
- (void)cancelTaskWithApi:(NSString *)api {
    for (NSURLSessionDataTask *task in [HttpClient sharedClient].tasks) {
        DWDMarkLog(@"\nurlString:%@\n", [task currentRequest].URL.absoluteString);
        if ([[task currentRequest].URL.absoluteString containsString:api]) {
            DWDMarkLog(@"\n%@ task cancel\n", api);
            [task cancel];
        }
    }
}
@end
