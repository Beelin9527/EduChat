//
//  DWDTabbarViewController.m
//  DWDSj
//
//  Created by apple  on 15/10/29.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDTabbarViewController.h"
#import "DWDNavViewController.h"
#import "DWDMessageViewController.h"
#import "DWDDiscoverViewController.h"
#import "DWDMeViewController.h"
#import "DWDIntelligentOfficeViewController.h"
#import "DWDInfoViewController.h"
#import "DWDIntParentClassController.h"

#import "DWDLoginViewController.h"
#import "JPUSHService.h"
#import "DWDKeyChainTool.h"
#import "DWDLoginDataHandler.h"
#import "DWDInformationDataHandler.h"

@interface DWDTabbarViewController () <UITabBarControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) DWDMessageViewController *messageVc;
@end

@implementation DWDTabbarViewController
/**
 *  一次性的初始化
 */
+ (void)initialize{
    
}
- (instancetype)init{
    if (self = [super init]) {

        self.delegate = self;
        // 初始化TabbarVc和子控制器
        // 联系
       // UIStoryboard *msgSb = [UIStoryboard storyboardWithName:@"DWDMessageViewController" bundle:nil];
        DWDMessageViewController *messageVc = [[DWDMessageViewController alloc] init];
        [self setupChildVc:messageVc title:NSLocalizedString(@"TabContact", @"tab联系") image:@"ic_contact_normal" selectedImage:@"ic_contact_press"];
        
        if ([DWDCustInfo shared].isTeacher) {
            // 智能办公
            DWDIntelligentOfficeViewController *intelligentVc = [[DWDIntelligentOfficeViewController alloc] init];
            [self setupChildVc:intelligentVc title:@"智能办公" image:@"ic_work_normal" selectedImage:@"ic_work_press"];
        }else{
            // 班级
            DWDIntParentClassController *classVc = [[DWDIntParentClassController alloc] init];
            [self setupChildVc:classVc title:NSLocalizedString(@"TabClass", @"tab班级") image:@"ic_class_normal" selectedImage:@"ic_class_press"];
        }
        
        // 资讯
        DWDInfoViewController *infoVc = [[DWDInfoViewController alloc] init];
        [self setupChildVc:infoVc title:NSLocalizedString(@"TabInfo", @"tab资讯") image:@"ic_information_normal" selectedImage:@"ic_information_press"];
        
        // 发现
        UIStoryboard *discoSb = [UIStoryboard storyboardWithName:@"DWDDiscoverViewController" bundle:nil];
        DWDDiscoverViewController *discoVc = [discoSb instantiateViewControllerWithIdentifier:@"DWDDiscoverViewController"];
        [self setupChildVc:discoVc title:NSLocalizedString(@"TabDis", @"tab发现") image:@"ic_find_normal" selectedImage:@"ic_find_press"];
        
        // 我
        UIStoryboard *meSb = [UIStoryboard storyboardWithName:@"DWDMeViewController" bundle:nil];
        DWDMeViewController *meVc = [meSb instantiateViewControllerWithIdentifier:@"DWDMeViewController"];
        [self setupChildVc:meVc title:NSLocalizedString(@"TabMe", @"tab我") image:@"ic_me_normal" selectedImage:@"ic_me_press"];
        
        
        //判断是否登录 登录显示联系控制器  未登录显示资讯控制器
        if ([DWDCustInfo shared].isLogin) {
            
            [self setSelectedIndex:0];
        }else{
            
            [self setSelectedIndex:2];
        }

        //监听极光是否登录成功
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        
        [defaultCenter addObserver:self selector:@selector(networkDidLogin:) name:kJPFNetworkDidLoginNotification object:nil];
        
        [defaultCenter addObserver:self selector:@selector(crowdedUserOffline:) name:kDWDNotificationCrowdedUserOffline object:nil];
        
        //监听登录者的身份，切换控制器
        [defaultCenter addObserver:self selector:@selector(changeViewController:) name:kDWDNotificationChangeLoginIdentify object:nil];
    }
    return self;
}

/**
 * 初始化子控制器
 */
- (void)setupChildVc:(UIViewController *)vc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage
{
    // 设置文字和图片
    vc.title = title;
    
    [vc.tabBarItem setImage:[[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
//    vc.tabBarItem.image = image1;
    vc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    
    // 包装一个导航控制器, 添加导航控制器为tabbarcontroller的子控制器
    DWDNavViewController *nav = [[DWDNavViewController alloc] initWithRootViewController:vc];
    [self addChildViewController:nav];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    //setting global appearance
    [[UITabBar appearance] setTintColor:DWDColorMain];
    
  
    
}

// 监听极光登录成功方法
- (void)networkDidLogin:(NSNotification *)notification {
    
    if ([JPUSHService registrationID]) {
        
        [DWDCustInfo shared].registrationID = [JPUSHService registrationID];
        DWDLog(@"get RegistrationID======%@",[DWDCustInfo shared].registrationID);
    }
}

// 被迫下线
- (void)crowdedUserOffline:(NSNotification *)notification {
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:DWDLoginCustIdCache];
    
    NSString *timeStr = [NSString stringFromTimeStampWithYYYYMMddHHmmss:notification.userInfo[@"loginTime"]];
    NSString *devTypeStr = [notification.userInfo[@"platform"] isEqualToString:@"iOS"] ? @"iPhone" : @"Android手机";
    NSString *message = [NSString stringWithFormat:@"您的账号于%@在另一台%@登录。如非本人操作，则密码可能已经泄露。建议马上修改密码。",timeStr, devTypeStr];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"下线通知" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"重新登录", nil];
    [alertView show];
}

//切换控制器
- (void)changeViewController:(NSNotification *)notification {
    
    NSDictionary *dict = notification.userInfo;
    NSNumber *identify = dict[@"custIdentity"];
    DWDNavViewController *nav = nil;
    
    if ([identify isEqualToNumber:@4]) {
        DWDIntelligentOfficeViewController *intelligentVc = [[DWDIntelligentOfficeViewController alloc] init];
        intelligentVc.title = @"智能办公";
        [intelligentVc.tabBarItem setImage:[[UIImage imageNamed:@"ic_work_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        intelligentVc.tabBarItem.selectedImage = [[UIImage imageNamed:@"ic_work_press"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        nav = [[DWDNavViewController alloc] initWithRootViewController:intelligentVc];
    }else{
        DWDIntParentClassController *vc = [[DWDIntParentClassController alloc] init];
        vc.title = @"班级";
        [vc.tabBarItem setImage:[[UIImage imageNamed:@"ic_class_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        vc.tabBarItem.selectedImage = [[UIImage imageNamed:@"ic_class_press"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        nav = [[DWDNavViewController alloc] initWithRootViewController:vc];
    }
    
    [self.viewControllers objectAtIndex:1];
    NSMutableArray *m = self.viewControllers.mutableCopy;
    [m replaceObjectAtIndex:1 withObject:nav];
    self.viewControllers = m;

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    
    if (buttonIndex == 0) {     // 退出登陆
        [self gotoLogin];
    }else {                     // 重新登陆
        DWDProgressHUD *hud = [DWDProgressHUD showHUD];
        NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:kDWDOrignPwdCache];
        [DWDLoginDataHandler requestGetPublicKeyWithPhoneNum:[DWDCustInfo shared].custUserName
                                                    password:pwd
                                                     success:^(NSString *publicKey,NSString *password) {
                                                         
                                                         //app登录、保存返回的Token
                                                         [DWDLoginDataHandler requestLoginWithUserName:[DWDCustInfo shared].custUserName password:pwd encryptPassword:password success:^() {
                                                             
                                                             [hud hide:YES];
                                                             
                                                         } failure:^(NSError *error) {
                                                             [hud showText:@"登录失败，请稍候重试"];
                                                             [self gotoLogin];
                                                             
                                                         }];
                                                         
                                                     } failure:^(NSError *error){
                                                         [hud showText:@"登录失败，请稍候重试!"];
                                                           [self gotoLogin];
                                                     }];
    }
}

- (void)gotoLogin{
    [[DWDCustInfo  shared] clearUserInfoData];
    
    [[DWDKeyChainTool sharedManager] deleteKeyWithType:KeyChainTypePassword];
    [[DWDKeyChainTool sharedManager] deleteKeyWithType:KeyChainTypeToken];
    [[DWDKeyChainTool sharedManager] deleteKeyWithType:KeyChainTypeRefreshToken];
    
    DWDLoginViewController *vc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDLoginViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDLoginViewController class])];
    
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    navi.navigationBarHidden = YES;
    
    //强制设置选择控制器为咨询模块。从登录返回咨询模块
    self.selectedIndex = 2;
    [self presentViewController:navi animated:YES completion:nil];
 
}



- (void)dealloc
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self name:kJPFNetworkDidLoginNotification object:nil];
    [defaultCenter removeObserver:self name:kDWDNotificationCrowdedUserOffline object:nil];
    [defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [defaultCenter removeObserver:self name:kDWDNotificationChangeLoginIdentify object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

//No double click
- (BOOL)tabBarController:(UITabBarController *)tbc shouldSelectViewController:(UIViewController *)vc {
    UIViewController *tbSelectedController = tbc.selectedViewController;
    
    if ([tbSelectedController isEqual:vc]) {
        return NO;
    }
    
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    //没有登录 且 非咨询模块 弹出登录界面
    if (![DWDCustInfo shared].isLogin && tabBarController.selectedIndex != 2 ) {
        
        DWDLoginViewController *vc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDLoginViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDLoginViewController class])];
        vc.hidesBottomBarWhenPushed = YES;
        
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
        navi.navigationBarHidden = YES;
        
        //强制设置选择控制器为咨询模块。从登录返回咨询模块
        tabBarController.selectedIndex = 2;
        [self presentViewController:navi animated:YES completion:nil];
        
        
    }
}

@end
