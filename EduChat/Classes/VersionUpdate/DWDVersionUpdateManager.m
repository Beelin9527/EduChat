//
//  DWDVersionUpdateManager.m
//  EduChat
//
//  Created by KKK on 16/9/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDVersionUpdateManager.h"
#import "DWDVersionUpdateView.h"
#import "DWDWebManager.h"

@interface DWDVersionUpdateManager ()<DWDVersionUpdateViewDelegate>

@property (nonatomic, weak) DWDVersionUpdateView *updateView;

@property (nonatomic, copy) NSString *urlString;

@property (nonatomic, assign) BOOL forceUpdate;

@end

@implementation DWDVersionUpdateManager


+ (instancetype)defaultManager {
    
    static DWDVersionUpdateManager *_defaultManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultManager = [[DWDVersionUpdateManager alloc] init];
    });
    return _defaultManager;
}

- (void)checkUpdate {
    //用于测试
//    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:ignoreVersionArray];
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
   
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DWDCheckVersionForceUpdateKey]) {
        NSDictionary *localDict = [[NSUserDefaults standardUserDefaults] objectForKey:DWDCheckVersionForceUpdateContentKey];

        DWDVersionUpdateView *view = [[DWDVersionUpdateView alloc] initWithVersion:localDict[@"ver"]
                                                                           content:localDict[@"cont"]
                                                                       forceUpdate:YES];
        self.urlString = localDict[@"appUrl"];
        view.delegate = self;
        [[UIApplication sharedApplication].keyWindow addSubview:view];
        self.updateView = view;
        
        NSDictionary *para = @{
                               @"plte" : @"ios",
                               @"ver" : appVersion,
                               };
        [[DWDWebManager sharedManager] getIfNeedsUpdateVersion:para success:^(NSURLSessionDataTask *task, id responseObject) {
            //result dict
            if (![localDict[@"ver"] isEqualToString:responseObject[@"data"][@"ver"]]) {
                
                [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"data"]
                                                          forKey:DWDCheckVersionForceUpdateContentKey];

                [view refreshWithVersion:responseObject[@"data"][@"ver"]
                                 content:responseObject[@"data"][@"cont"]];
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DWDLog(@"\n\
                       ############################\n\
                       #                          #\n\
                       # Get updateVersion Failed #\n\
                       #                          #\n\
                       ############################\n");
        }];
    } else {
    NSDictionary *para = @{
                           @"plte" : @"ios",
                           @"ver" : appVersion,
                           };
    WEAKSELF;
    //网络请求
    [[DWDWebManager sharedManager] getIfNeedsUpdateVersion:para success:^(NSURLSessionDataTask *task, id responseObject) {
        //result dict
        
        /**
         isUpd 是否有更新
         cont 更新内容
         ver 版本号
         appUrl 新版本url
         isMt 是否强制更新
         */
        
        BOOL isUpdate = [responseObject[@"data"][@"isUpd"] boolValue];
        if (!isUpdate) return;
        BOOL isForceUpdate = [responseObject[@"data"][@"isMt"] boolValue];
        //test code
//        BOOL isForceUpdate = YES;
        
        if (isForceUpdate) {
            [[NSUserDefaults standardUserDefaults] setBool:YES
                                                    forKey:DWDCheckVersionForceUpdateKey];
            [[NSUserDefaults standardUserDefaults] setObject:responseObject[@"data"]
                                                      forKey:DWDCheckVersionForceUpdateContentKey];
        }
//            weakSelf.forceUpdate = isForceUpdate;
        DWDVersionUpdateView *view = [[DWDVersionUpdateView alloc] initWithVersion:responseObject[@"data"][@"ver"]
                                                                           content:responseObject[@"data"][@"cont"]
                                                                       forceUpdate:isForceUpdate];
        weakSelf.urlString = responseObject[@"data"][@"appUrl"];
        view.delegate = weakSelf;
        [[UIApplication sharedApplication].keyWindow addSubview:view];
        weakSelf.updateView = view;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDLog(@"\n\
               ############################\n\
               #                          #\n\
               # Get UpdateVersion Failed #\n\
               #                          #\n\
               ############################\n");
    }];
    }
    
}

- (void)versionUpdateViewDidClickUpdateButton:(DWDVersionUpdateView *)view {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:_urlString]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_urlString]];
    }
}

- (void)versionUpdateView:(DWDVersionUpdateView *)view didClickCancelButtonWithVersion:(NSString *)version {
}

@end
