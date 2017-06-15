//
//  AppDelegate.m
//  DWDSj
//
//  Created by apple  on 15/10/29.
//  Copyright © 2015年 dwd. All rights reserved.
//

#define kVersionString @"appVersionString"

#import "AppDelegate.h"
#import "DWDTabbarViewController.h"
#import "DWDNavViewController.h"
#import "DWDLoginViewController.h"
#import "UIImage+Utils.h"
#import "DWDClassInfoViewController.h"
#import "DWDMessageViewController.h"
#import "DWDChatController.h"
#import "DWDInfoDetailViewController.h"
#import "DWDConst.h"

#import "HttpClient.h"
#import "DWDGuideViewController.h"

#import "DWDVersionUpdateManager.h"

#import "JPUSHService.h"
#import <UMMobClick/MobClick.h>


#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"
//#import "UMSocialWhatsappHandler.h"
//#import "UMSocialTumblrHandler.h"
//#import "UMSocialLineHandler.h"

#import "DWDPickUpCenterDatabaseTool.h"
#import "DWDContactsDatabaseTool.h"
#import "DWDRecentChatDatabaseTool.h"
#import "DWDMessageDatabaseTool.h"
#import "DWDClassDataBaseTool.h"
#import "DWDGroupDataBaseTool.h"

#import "DWDChatMsgDataClient.h"
#import "DWDChatClient.h"
#import "DWDRecentChatModel.h"

#import "DWDBaseChatMsg.h"


#import "DWDJPSHEnterBackgroundModel.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif


#define DWDMsgCachFilePath [NSHomeDirectory() stringByAppendingString:@"/Documents/errorMsgCach.dwd"]
#define version [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]  //版本号

//#define Educhat_web @"Educhat_web"  //定义宏、多维度官网   app stroe 上请注释此宏

@interface AppDelegate () <JPUSHRegisterDelegate>


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    NSURLCache *urlCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
//    [NSURLCache setSharedURLCache:urlCache];
    
    [[HttpClient sharedClient] getApi:@"SysConfigRestService/getEntity" params:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        DWDLog(@"SysConfigRestService/getEntity : %@" , responseObject[@"data"]);
        
        [DWDCustInfo shared].AccessKey = responseObject[@"data"][@"accessKeyId"];
        [DWDCustInfo shared].SecretKey = responseObject[@"data"][@"accessKeySecret"];
        [DWDCustInfo shared].ossUrl = responseObject[@"data"][@"ossUrl"];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDLog(@"error : %@",error);
        
    }];
    
    //golbal appearance settings
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:DWDColorMain] forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setBarTintColor:DWDColorMain];
    
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"ic_return_normal"]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"ic_return_normal"]];
    [[UINavigationBar appearance] setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[UIBarButtonItem appearance] setTitleTextAttributes:
     @{NSFontAttributeName: DWDFontContent}
     forState:UIControlStateNormal];
    
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    
    //判断是否登录、已登录加载用户信息
    if ([DWDCustInfo shared].isLogin) {
        
        [DWDContactsDatabaseTool sharedContactsClient]; // 先把数据表格建好
        [DWDPickUpCenterDatabaseTool sharedManager];
        
        [[DWDCustInfo shared] loadUserInfoData];

    }
    
    //查看版本是否是新版本 新版本增加增加引导页
    NSString *userDefaultVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kVersionString];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    if ([userDefaultVersion isEqualToString:appVersion]) {
//    if (/* DISABLES CODE */ (0)) {
        DWDTabbarViewController *vc = [[DWDTabbarViewController alloc]init];
//        vc.delegate = self;
        window.rootViewController = vc;
        window.backgroundColor = [UIColor whiteColor];
        [window makeKeyAndVisible];
        self.window = window;
        [[DWDVersionUpdateManager defaultManager] checkUpdate];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:DWDCheckVersionForceUpdateKey];
        [[NSUserDefaults standardUserDefaults] setObject:appVersion forKey:kVersionString];
        DWDGuideViewController *vc = [[DWDGuideViewController alloc] init];
        window.rootViewController = vc;
        window.backgroundColor = [UIColor whiteColor];
        [window makeKeyAndVisible];
        self.window = window;
    }

    

    /*——————————————————————————————注册极光推送 ——————————————————————————————————————————————*/
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
#endif
    } else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    }
    
#ifdef DEBUG
    [JPUSHService setupWithOption:launchOptions appKey:kJPushAppkey channel:@"" apsForProduction:NO];
#else
    [JPUSHService setupWithOption:launchOptions appKey:kJPushAppkey channel:@"" apsForProduction:YES];
#endif
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
            NSLog(@"registrationID获取成功：%@",registrationID);
            
        }
        else{
            NSLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];
   /*——————————————————————————————注册极光推送 —————————————————————————————————————————————— */

                                /*麻烦给个空间给我*/
    
    /*——————————————————————————————友盟统计 —————————————————————————————————————————————— */
    
    //版本标识
    [MobClick setAppVersion:version];
   
    //友盟Appkey
    UMConfigInstance.appKey = kUMAppkey;
    
    //渠道
#ifdef Educhat_web
    //多维度官网

    UMConfigInstance.channelId = Educhat_web;
#else
    //channelId为nil或@""时，默认会被当作@"App Store"渠道。"App Store" 及其各种大小写形式，作为友盟保留的字段，不可以作为渠道名。
    UMConfigInstance.channelId = nil;
#endif
    
    
#ifdef DEBUG
    //测试环境 设置为YES
    [MobClick setLogEnabled:YES];
#else
    //开启友盟统计
    [MobClick startWithConfigure:UMConfigInstance];
#endif
    
     /*——————————————————————————————友盟统计 —————————————————————————————————————————————— */
    
    
    /*——————————————————————————————友盟分享 —————————————————————————————————————————————— */
    [UMSocialData setAppKey:kUMAppkey];
    //设置分享到QQ空间的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:@"1105577333" appKey:@"n2uD0JVvqmCsDWJd" url:@"https://itunes.apple.com/app/id1089148311"];
    //设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:@"wxc3486cc1ca6d594d" appSecret:@"9833c5af4f09f9de2725202a452d7145" url:@"https://itunes.apple.com/app/id1089148311"];

    /*——————————————————————————————友盟分享 —————————————————————————————————————————————— */
    
//    if (launchOptions) {
//        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//        if (userInfo) {
//            [self goToMessageViewController:userInfo];
//        }
//    }
    //监测更新
    
    return YES;
}

//注册deviceToken
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceTokenString2 = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
                                     
                                     stringByReplacingOccurrencesOfString:@">" withString:@""]
                                    
                                    stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    DWDLog(@"方式2：%@", deviceTokenString2);
    DWDLog(@"方式1：%@",[NSString stringWithFormat:@"%@",deviceToken]);
    [JPUSHService registerDeviceToken:deviceToken];
   
    DWDLog(@"方式2：%@", deviceTokenString2);
    DWDLog(@"方式1：%@",[NSString stringWithFormat:@"%@",deviceToken]);
    [JPUSHService registerDeviceToken:deviceToken];
}

//收到推送
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    UIApplicationState state = application.applicationState;
    if ( state == UIApplicationStateActive) return;
    if (![[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[DWDGuideViewController class]]) {
        [self pushViewController:userInfo];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    DWDLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}


- (void)applicationDidEnterBackground:(UIApplication *)application {

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [JPUSHService resetBadge];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    //清除小红点
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [JPUSHService resetBadge];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    DWDLog(@"程序失去焦点");
    if ([DWDCustInfo shared].isLogin) {
        //主动断开Scoket
        DWDJPSHEnterBackgroundModel *jpshu = [[DWDJPSHEnterBackgroundModel alloc] init];
        jpshu.code = @"sysmsgAppBackRun";
        jpshu.entity = @{@"custId" : [DWDCustInfo shared].custId};
        
        [[DWDChatClient sharedDWDChatClient] sendData:[[DWDChatMsgDataClient sharedChatMsgDataClient] makeJPSHUObject:jpshu]];
        [[DWDChatClient sharedDWDChatClient] disConnect];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([[UIApplication sharedApplication].keyWindow.rootViewController isKindOfClass:[DWDTabbarViewController class]]) {
        DWDTabbarViewController *tabVc = (DWDTabbarViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        DWDNavViewController *navVc = tabVc.childViewControllers[0];
        DWDMessageViewController *msgVc = navVc.viewControllers[0];
        msgVc.isNeedGlobleLoadData = YES;
    }
    
    
    DWDLog(@"程序重新获取了焦点");
    if ([DWDCustInfo shared].isLogin) {
        
        if ([[DWDChatClient sharedDWDChatClient] isConnecting]) {
            [[DWDChatClient sharedDWDChatClient] disConnect];
        }
        //连接Scoket
        [[DWDChatClient sharedDWDChatClient] getConnect];

        
        
        DWDJPSHEnterBackgroundModel *jpshu = [[DWDJPSHEnterBackgroundModel alloc] init];
        jpshu.code = @"sysmsgAppFrontRun";
        jpshu.entity = @{@"custId" : [DWDCustInfo shared].custId};
        [[DWDChatClient sharedDWDChatClient] sendData:[[DWDChatMsgDataClient sharedChatMsgDataClient] makeJPSHUObject:jpshu]];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    if ([DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool].currentOperationMyCusId || [DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool].currentOperationFriendId) {
        // 证明在聊天界面退出了程序
        // 清空该界面相关badgeCount
        [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] clearBadgeCountWithFriendId:[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool].currentOperationFriendId myCusId:[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool].currentOperationMyCusId success:^{
            
        } failure:^{
            
        }];
    }
    
    // 发送错误的图片,文本,语音先更改数据库,然后缓存到沙盒
    // 1.更改数据库
    [[DWDChatMsgDataClient sharedChatMsgDataClient].sendingMsgCachDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary *  _Nonnull obj, BOOL * _Nonnull stop) {
        
        [[DWDMessageDatabaseTool sharedMessageDatabaseTool] updateMsgStateToState:DWDChatMsgStateError WithMsgId:key toUserId:obj[@"toUser"] chatType:[obj[@"chatType"] integerValue] success:^{
            
            DWDLog(@"app 在死的时候更新了 和 %@ 的 %@ 消息为 error " , obj[@"toUser"] , key);
            
        } failure:^(NSError *error) {
            
        }];
    }];
    
    // 2.存到沙盒
    if ([DWDChatMsgDataClient sharedChatMsgDataClient].sendingMsgCachDict) {
       [NSKeyedArchiver archiveRootObject:[DWDChatMsgDataClient sharedChatMsgDataClient].sendingMsgCachDict toFile:DWDMsgCachFilePath];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@{@"ISCHAT":@0,@"SESSIONID":@""} forKey:@"ISONCHAT"];
}

#pragma mark - 根据推送的类型跳转界面
- (void)pushViewController:(NSDictionary *)userInfo
{
    NSString *msgType = [userInfo objectForKey:@"notificationMsgType"];

    // 聊天消息
    if ([msgType isEqualToString:@"chatmsg"]) {
        
        NSString *chatType = [userInfo objectForKey:@"chatType"];
        NSNumber *toUserId = [NSNumber numberWithLongLong:[[userInfo objectForKey:@"friendCustId"] longLongValue]];
        
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"ISONCHAT"];
        if ([toUserId isEqual:[DWDCustInfo shared].custId] || ([dict[@"ISCHAT"] isEqual:@1] && [dict[@"SESSIONID"] isEqual:toUserId])) {
            return;
        }
        
        DWDTabbarViewController *tabVC = (DWDTabbarViewController *)self.window.rootViewController;
        tabVC.selectedIndex = 0;
        DWDNavViewController *VC = [[tabVC viewControllers] firstObject];
        
        DWDChatController *chatController = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class])
                                                                       bundle:nil]
                                      instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
        chatController.hidesBottomBarWhenPushed = YES;
        chatController.toUserId = toUserId;
        
        if ([chatType isEqualToString:@"ClassChat"]) {
            
            chatController.chatType = DWDChatTypeClass;
            DWDClassModel *model = [[DWDClassDataBaseTool sharedClassDataBase] getClassInfoWithClassId:toUserId myCustId:[DWDCustInfo shared].custId];
            chatController.myClass = model;
          
          
            
        }else if ([chatType isEqualToString:@"GroupChat"]) {
        
            chatController.chatType = DWDChatTypeGroup;
            //根据groupId 从本地库获取群组信息
             DWDGroupEntity * model = [[DWDGroupDataBaseTool sharedGroupDataBase] getGroupInfoWithMyCustId:[DWDCustInfo shared].custId groupId:toUserId];

            chatController.groupEntity = model;
            
        }else {
            
            DWDRecentChatModel *model = [[DWDRecentChatModel alloc] init];
            
            NSMutableDictionary *contact = [[[DWDContactsDatabaseTool sharedContactsClient] getContactsByIds:@[toUserId]] firstObject];
            model.nickname = [contact objectForKey:@"nickname"];
            model.remarkName = [contact objectForKey:@"remarkName"];
            
            chatController.chatType = DWDChatTypeFace;
            chatController.recentChatModel = model;
            
        }
        CATransition *animation = [CATransition animation];
        animation.type = @"fade";
        animation.duration = 1.0;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        [VC.view.layer addAnimation:animation forKey:nil];
        [VC pushViewController:chatController animated:YES];

    }else if ([msgType isEqualToString:@"infomationMsg"]) {
    
        DWDTabbarViewController *tabVC = (DWDTabbarViewController *)self.window.rootViewController;
        tabVC.selectedIndex = 2;
        DWDNavViewController *infoVC = [[tabVC viewControllers] objectAtIndex:2];
        
        DWDInfoDetailViewController *detailVC = [[DWDInfoDetailViewController alloc] init];
        detailVC.contentCode = [NSNumber numberWithInteger:[userInfo[@"contentCode"] integerValue]];
        detailVC.commendId = [NSNumber numberWithInteger:[userInfo[@"commendId"] integerValue]];
        detailVC.contentLink = userInfo[@"contentLink"];
        [userInfo[@"contentCode"] isEqualToString:@"8"] ? detailVC.expertId = userInfo[@"custId"] : nil;
        detailVC.hidesBottomBarWhenPushed = YES;
        [infoVC pushViewController:detailVC animated:YES];
        
    }else {
    //系统消息
        DWDTabbarViewController *tabVC = (DWDTabbarViewController *)self.window.rootViewController;
        tabVC.selectedIndex = 0;
    }
    
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    if (result == FALSE) {
        //调用其他SDK，例如支付宝SDK等
    }
    return result;
}

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#pragma mark- JPUSHRegisterDelegate
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler
{
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
//        NSLog(@"iOS10 前台收到远程通知:%@", [self logDic:userInfo]);
        
    }else {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
//    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
//        NSLog(@"iOS10 收到远程通知:%@", [self logDic:userInfo]);
        
        [self pushViewController:userInfo];
        
    }else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    completionHandler();  // 系统要求执行这个方法
}
#endif
@end
