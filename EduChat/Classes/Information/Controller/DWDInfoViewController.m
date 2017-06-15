//
//  DWDInfoViewController.m
//  EduChat
//
//  Created by Catskiy on 16/8/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDInfoViewController.h"
#import "DWDInfoSelectView.h"

#import "DWDInfoRecoViewController.h"
#import "DWDInfoNewsViewController.h"
#import "DWDInfoExpertViewController.h"
#import "DWDInfoSubscribeViewController.h"
#import "UITabBarController+Badge.h"

#import "OOLocationManager.h"
#import "DWDInformationDataHandler.h"
#import "DWDInfoPlateModel.h"

@interface DWDInfoViewController ()

@property (nonatomic, strong) OOLocationManager *locManager;
@property (nonatomic, strong) DWDInfoSelectView *selectView;
@property (nonatomic, strong) UIViewController *currentVC;
@property (nonatomic, strong) UIView *containView;
@property (nonatomic, strong) NSString *regionCode;
@property (nonatomic, strong) NSMutableArray *plateArray;

@end

@implementation DWDInfoViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(getData)
                                                     name:kDWDNotificationRefreshInformation
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(getSubUpdataTips)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];

    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kDWDNotificationRefreshInformation
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setSubviews];
    
    [self getLocation];
    
    [self getData];
}

- (void)setSubviews
{
    [self.view addSubview:self.selectView];
    [self.view addSubview:self.containView];
}

- (void)getLocation
{
    _locManager = [[OOLocationManager alloc] init];
    [_locManager startLocationSuccess:^(NSString *areaName, NSString *province, NSString *city, NSString *district) {
        
        NSMutableDictionary *params = @{@"province" : province ? province : [NSNull null], @"city" : city ? city : [NSNull null]}.mutableCopy;
        district ? [params setValue:district forKey:@"district"] : nil;
        
        [[HttpClient sharedClient] getApi:@"DistrictRestService/getEntityByName" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSArray *arr = responseObject[@"data"];
            NSLog(@"arr === %@", arr);
            NSString *curRegionCode = [arr firstObject][@"districtCode"];
            if (![curRegionCode isEqualToString:[DWDCustInfo shared].regionCode]) {
                [DWDCustInfo shared].regionCode = curRegionCode;
//                [self getData];
            }
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    }];
}

- (void)getData
{
    [self.tabBarController hideBadgeOnItemIndex:2];
    DWDProgressHUD *hud = [DWDProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud showText:@"正在加载"];
    [DWDInformationDataHandler requestGetPlateListWithCustId:[DWDCustInfo shared].custId dcode:[DWDCustInfo shared].regionCode success:^(NSArray *array) {
        
        self.plateArray = [NSMutableArray arrayWithArray:array];
        self.selectView.items = self.plateArray;
        [self addChildControllers];
        [self getSubUpdataTips];
        
        // 缓存板块信息
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [docPath stringByAppendingPathComponent:@"infoPlate.cache"];
        [NSKeyedArchiver archiveRootObject:self.plateArray toFile:path];
        [hud hide:YES];
        
    } failure:^(NSError *error) {
        
        // 网络请求失败,从缓存获取板块信息
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [docPath stringByAppendingPathComponent:@"infoPlate.cache"];
        self.plateArray = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        if (self.plateArray.count > 0) {
            self.selectView.items = self.plateArray;
            [self addChildControllers];
        }
        [hud hide:YES];
    }];
}

- (void)addChildControllers
{
    // 移除所有子视图控制器
    for (UIViewController *vc in self.childViewControllers) {
        [vc willMoveToParentViewController:nil];
        [vc removeFromParentViewController];
    }
    // 根据板块类型,选择不同的控制器
    for (DWDInfoPlateModel *plate in self.plateArray) {
        
        Class class;
        switch (plate.plateCode) {
            case InfoPlateTypeRecomment:
                class = NSClassFromString(@"DWDInfoRecoViewController");
                break;
            case InfoPlateTypeNewAndPolicy:
                class = NSClassFromString(@"DWDInfoNewsViewController");
                break;
            case InfoPlateTypeUenonExpert:
                class = NSClassFromString(@"DWDInfoExpertViewController");
                break;
            case InfoPlateTypeSubscribe:
                class = NSClassFromString(@"DWDInfoSubscribeViewController");
                break;
            default:
                break;
        }
        
        if (class) {
            UIViewController *vCtrl = [class new];
            [self addChildViewController:vCtrl];
            
            if (plate.isDefault) {
                self.currentVC = vCtrl;
                [self.containView addSubview:self.currentVC.view];
            }
        }
    }
}

- (void)switchControllerToIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    [_currentVC.view removeFromSuperview];
    _currentVC = [self.childViewControllers objectAtIndex:toIndex];
    [self.containView addSubview:_currentVC.view];
    [self resetUpdateTipsStatusAtIndex:toIndex];

//    [self transitionFromViewController:[self.childViewControllers objectAtIndex:fromIndex]
//                      toViewController:[self.childViewControllers objectAtIndex:toIndex]
//                              duration:0.1
//                               options:UIViewAnimationOptionTransitionNone
//                            animations:nil completion:^(BOOL finished) {
//        [[self.childViewControllers objectAtIndex:toIndex] didMoveToParentViewController:self];
//        _currentVC = [self.childViewControllers objectAtIndex:toIndex];
//    }];
}

- (DWDInfoSelectView *)selectView
{
    if (!_selectView) {
        WEAKSELF;
        _selectView = [[DWDInfoSelectView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, selectViewHeight)];
        [_selectView setSelectViewBlock:^(NSUInteger fromIndex ,NSUInteger toIndex) {
            [weakSelf switchControllerToIndex:fromIndex toIndex:toIndex];
        }];
    }
    return _selectView;
}

- (UIView *)containView
{
    if (!_containView) {
        _containView = [[UIView alloc] initWithFrame:CGRectMake(0, selectViewHeight, DWDScreenW, DWDScreenH - selectViewHeight)];
    }
    return _containView;
}

- (void)getSubUpdataTips
{
    if (![DWDCustInfo shared].isLogin) return;
    
    [DWDInformationDataHandler requestGetSubTipsWithCustId:[DWDCustInfo shared].custId success:^(NSNumber *cnt) {
        
        if ([cnt intValue] > 0 && _selectView.selectIndex != 3) {
            
            [self.tabBarController showBadgeOnItemIndex:2];
            for (DWDInfoPlateModel *plate in self.plateArray) {
                if (plate.plateCode == InfoPlateTypeSubscribe) {
                    // KVO实现,直接修改plate.showBadge,即可改变导航条对应选项的小红点显示状态(YES:显示)
                    plate.showBadge = YES;
                }
            }
        }
    } failure:^(NSError *error) {
       
    }];
}

// 重置更新提示状态(当前只针对订阅)
- (void)resetUpdateTipsStatusAtIndex:(NSInteger)index
{
    // 点击导航条选项时,清除上面的小红点
    DWDInfoPlateModel *plate = self.plateArray[index];
    plate.showBadge = NO;
    
    if (plate.plateCode == InfoPlateTypeSubscribe) {
        
        [self.tabBarController hideBadgeOnItemIndex:2];
        [DWDInformationDataHandler requestUpdateSubTipsWithCustId:[DWDCustInfo shared].custId success:^(NSInteger status) {
            
        } failure:^(NSError *error) {
            
        }];
    }
}

@end
