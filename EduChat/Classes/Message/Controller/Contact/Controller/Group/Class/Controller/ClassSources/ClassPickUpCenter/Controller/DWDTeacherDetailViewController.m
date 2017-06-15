//
//  DWDTeacherDetailViewController.m
//  EduChat
//
//  Created by KKK on 16/3/14.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDTeacherDetailViewController.h"


#import "DWDTeacherGoSchoolViewController.h"
#import "DWDTeacherLeaveSchoolViewController.h"

#import "DWDPickUpCenterCalendarViewController.h"
#import "DWDClassPickUpCenterListController.h"
#import "DWDRecentChatDatabaseTool.h"

#import "DWDTabbarViewController.h"

#import "DWDTeacherDetailViewNavigationTitleView.h"
#import "DWDTeacherGoSchoolStudentDetailModel.h"
#import "DWDPickUpCenterDataBaseModel.h"
#import "DWDClassModel.h"

#import "DWDPickUpCenterDatabaseTool.h"
#import "DWDRecentChatDatabaseTool.h"

#import "DWDIntelligentOfficeDataHandler.h"

#import <YYModel.h>

@interface DWDTeacherDetailViewController () <DWDTeacherDetailViewNavigationTitleViewDelegate>

@property (nonatomic, weak) DWDTeacherDetailViewNavigationTitleView *titleView;
@property (nonatomic, assign) BOOL currentState;

@property (nonatomic, weak) DWDTeacherGoSchoolViewController *goSchoolTableViewController;
@property (nonatomic, weak) DWDTeacherLeaveSchoolViewController *leaveSchoolTableViewController;

@property (nonatomic, strong) NSArray *totalStudentsArray;
@property (nonatomic, assign) int currentPickUpState;

@end

@implementation DWDTeacherDetailViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self getAllStudentsArray];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //设置titleView
    DWDTeacherDetailViewNavigationTitleView *titleView = [[DWDTeacherDetailViewNavigationTitleView alloc] initWithFrame:CGRectMake((DWDScreenW - 80) / 2.0, 0, 80, 44)];
    titleView.delegate = self;
    _titleView = titleView;
    self.navigationItem.titleView = _titleView;
    
//    //接受通知 用于处理红点
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(socketMessageReceive:)
//                                                 name:DWDPickUpCenterDidUpdateTeacherGoSchool
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(socketMessageReceive:)
//                                                 name:DWDPickUpCenterDidUpdateTeacherLeaveSchool
//                                               object:nil];
    //设置右导航键
     NSCalendar *calendar = [NSCalendar currentCalendar];
     NSDateComponents *components = [calendar components:(kCFCalendarUnitMonth | kCFCalendarUnitDay) fromDate:[NSDate date]];
     NSInteger month = [components month];
     NSInteger day = [components day];
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setContentEdgeInsets:UIEdgeInsetsMake(0, -pxToW(20), 0, pxToW(20))];
    [rightButton setTitle:[NSString stringWithFormat:@"%zd月%zd日", month, day]
                 forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"MSG_TF_time_NOR"]
                 forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"MSG_TF_time_HL"]
                 forState:UIControlStateHighlighted];
    
    rightButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    rightButton.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    rightButton.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    
    [rightButton sizeToFit];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
//    [rightButton setFrame:CGRectMake(0, 0, 100, 20)];
    [rightButton addTarget:self action:@selector(rightBarButtonItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    //默认初始界面是上学还是放学
    [self selectGoSchoolOrLeaveSchool];
    
    //检测此菜单功能是否点击过,key为menuCode
    NSString *key = [NSString stringWithFormat:@"%@-%@", [DWDCustInfo shared].custId, kDWDIntMenuCodeClassManagementTransferCenter];
    NSString *obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (!obj && self.classModel) {//classModel不为nil,才可以请求
       [self requestGetAlertWithMenuCode:kDWDIntMenuCodeClassManagementTransferCenter];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    int badgeNumber = [[DWDPickUpCenterDatabaseTool sharedManager] getBadgeNumberWithClassId:_classId listTableName:@"PUC_CLASSLIST"];
//    [[DWDPickUpCenterDatabaseTool sharedManager] subTeacherListBadgeNumberWithClassId:_classId subNumber:[NSNumber numberWithInt:badgeNumber]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    int badgeNumber = [[DWDPickUpCenterDatabaseTool sharedManager] getBadgeNumberWithClassId:_classId listTableName:@"PUC_CLASSLIST"];
    [[DWDPickUpCenterDatabaseTool sharedManager] subTeacherListBadgeNumberWithClassId:_classId subNumber:[NSNumber numberWithInt:badgeNumber]];
    //badge value
    NSInteger badgeValue = [[[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] getAllRecentChatBadgeNum] integerValue];
    NSString *cacheKey = [NSString stringWithFormat:@"applayCountDict_%@",[DWDCustInfo shared].custId];
    NSDictionary *applayDict = [[NSUserDefaults standardUserDefaults] objectForKey:cacheKey];
    NSInteger chatBadgeCount = [applayDict[@"chatBadgeCount"] integerValue];
    badgeValue += chatBadgeCount;
    
    DWDTabbarViewController *tabbarVc = (DWDTabbarViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    UITabBarItem *item = tabbarVc.tabBar.items[0];
    
    if (badgeNumber >= badgeValue) {
        item.badgeValue = nil;
    } else if (badgeValue - badgeNumber > 99) {
        item.badgeValue = @"99+";
    } else {
        item.badgeValue = badgeValue - badgeNumber < 0 ? nil : [NSString stringWithFormat:@"%zd", badgeValue - badgeNumber];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNeedRecentChatLoad object:nil userInfo:@{@"isNeedLoadData":@YES}];
}

//- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:DWDPickUpCenterDidUpdateTeacherGoSchool
//                                                  object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:DWDPickUpCenterDidUpdateTeacherLeaveSchool
//                                                  object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

//#pragma mark - Notification
//- (void)socketMessageReceive:(NSNotification *)note {
//    //    if ([self.navigationController.viewControllers containsObject:]) {
//    BOOL result = NO;
//    for (UIViewController *vc in self.navigationController.viewControllers) {
//        if ([vc isKindOfClass:[DWDClassPickUpCenterListController class]]) {
//            //有listController不用关心
//            result = YES;
//            break;
//        }
//    }
//    if (result == NO) {
//        //每次收到都给外层清空
//        DWDTabbarViewController *tabbarVc = (DWDTabbarViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
//        UITabBarItem *item = tabbarVc.tabBar.items[0];
//        if ([item.badgeValue isEqualToString:@"99+"]) {
//            return;
//        }
//        item.badgeValue = [NSString stringWithFormat:@"%zd",[item.badgeValue integerValue] + 1];
//    }
//}

#pragma mark - Private Method

- (void)selectGoSchoolOrLeaveSchool {
    DWDPickUpCenterDataBaseModel *dbModel = [[DWDPickUpCenterDatabaseTool sharedManager] selectLastDataWithClassId:_classId];
    if ([dbModel.type isEqualToNumber:@1]) {
        [self goSchoolStateCurrent];
    } else {
        [self leaveSchoolStateCurrent];
    }
}

- (void)rightBarButtonItemClick {
    DWDPickUpCenterCalendarViewController *vc = [[DWDPickUpCenterCalendarViewController alloc] init];
    vc.classId = self.classId;
    vc.timeState = self.currentState;
    [self.navigationController pushViewController:vc animated:YES];
    
}

/* 接受网络请求 根据请求状态变更当前页面形态 */
//点击上学按钮
- (void)goSchoolStateCurrent {
    [self.titleView goSchoolButtonClick];
}

//点击放学按钮
- (void)leaveSchoolStateCurrent {
    [self.titleView leaveSchoolButtonClick];
}

//点击啥都没有
- (void)notPickUpStateCurrent {
    [self goSchoolStateCurrent];
}


//#pragma mark - Network Request
//- (void)getAllStudentsArray {
//    NSDictionary *params = @{@"classId": self.classId};
//    
//    __block NSArray *ar = [NSArray new];
//    [[HttpClient sharedClient] cancelTaskWithApi:@"punch/getPickupchild"];
//
//    //获取当天状态
//    WEAKSELF;
//    [[HttpClient sharedClient] getPickUpCenterStudentsStatusWithParams:params success:^(NSURLSessionDataTask *task, id responseObject) {
//
//        ar = [NSArray yy_modelArrayWithClass:[DWDTeacherGoSchoolStudentDetailModel class]
//                                        json:responseObject[@"data"][@"students"]];
//        weakSelf.totalStudentsArray = ar;
//        weakSelf.currentPickUpState = [responseObject[@"data"][@"type"] intValue];
//        DWDMarkLog(@"punch detail student Success");
//        dispatch_async(dispatch_get_main_queue(), ^{
//            weakSelf.goSchoolTableViewController.index = responseObject[@"data"][@"index"];
//            weakSelf.leaveSchoolTableViewController.index = responseObject[@"data"][@"index"];
//            [weakSelf.goSchoolTableViewController.tableView reloadData];
//            [weakSelf.leaveSchoolTableViewController reloadNotificationReceived];
//        });
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        weakSelf.currentPickUpState = 0;
//        DWDMarkLog(@"punch detail student Failed");
//    }];
//}

#pragma mark - DWDTeacherDetailViewNavigationTitleViewDelegate
- (void)titleViewDidClickGoSchoolButton:(DWDTeacherDetailViewNavigationTitleView *)titleView {
    _currentState = NO;
    [self.leaveSchoolTableViewController.view removeFromSuperview];
    [self.leaveSchoolTableViewController removeFromParentViewController];
    [self.view addSubview:self.goSchoolTableViewController.view];
    [self.goSchoolTableViewController didMoveToParentViewController:self];
}

- (void)titleViewDidClickLeaveSchoolButton:(DWDTeacherDetailViewNavigationTitleView *)titleView {
    _currentState = YES;
    [self.goSchoolTableViewController.view removeFromSuperview];
    [self.goSchoolTableViewController removeFromParentViewController];
//    self.leaveSchoolTableViewController.totalStudentsArray = self.totalStudentsArray;
    [self.view addSubview:self.leaveSchoolTableViewController.view];
//    self.leaveSchoolTableViewController.classId = self.classId;
    [self.leaveSchoolTableViewController didMoveToParentViewController:self];
}


#pragma mark - setter /getter
-(DWDTeacherDetailViewNavigationTitleView *)titleView {
    if (!_titleView) {

    }
    return _titleView;
}

- (DWDTeacherGoSchoolViewController *)goSchoolTableViewController {
    if (!_goSchoolTableViewController) {
        DWDTeacherGoSchoolViewController *vc = [[DWDTeacherGoSchoolViewController alloc] init];
        vc.classId = self.classId;
        vc.isFirstRequest = YES;
        vc.requestFailed = NO;
        [self addChildViewController: vc];
        vc.view.frame = self.view.bounds;
        _goSchoolTableViewController = vc;
    }
    return _goSchoolTableViewController;
}

- (DWDTeacherLeaveSchoolViewController *)leaveSchoolTableViewController {
    if (!_leaveSchoolTableViewController) {
        DWDTeacherLeaveSchoolViewController *vc = [[DWDTeacherLeaveSchoolViewController alloc] init];
        vc.classId = self.classId;
        vc.isFirstRequest = YES;
        [self addChildViewController: vc];
        vc.view.frame = self.view.bounds;
        _leaveSchoolTableViewController = vc;
    }
    return _leaveSchoolTableViewController;
}

//- (NSArray *)totalStudentsArray {
//    if (!_totalStudentsArray) {
//        NSArray *ar = [NSArray new];
//        ar = [self getAllStudentsArray];
//        _totalStudentsArray = ar;
//    }
//    return _totalStudentsArray;
//}

- (void)setCurrentPickUpState:(int)currentPickUpState {
    //0未接送
    //1上学
    //2放学
    _currentPickUpState = currentPickUpState;
    switch (currentPickUpState) {
        case 0:
            [self notPickUpStateCurrent];
            break;
            
        case 1:
            [self goSchoolStateCurrent];
            break;
            
        case 2:
            [self leaveSchoolStateCurrent];
            break;
        default:
            break;
    }
}

//- (void)setclassId:(NSNumber *)classId {
//    _classId = classId;
//    self.goSchoolTableViewController.classId = classId;
//    self.leaveSchoolTableViewController.classId = classId;
//}

#pragma mark - Request Data
- (void)requestGetAlertWithMenuCode:(NSString *)code{
    [DWDIntelligentOfficeDataHandler requestGetAlertWithCid:[DWDCustInfo shared].custId sid:self.classModel.schoolId mncd:code sta:nil targetController:self success:^{
        
    } failure:^(NSError *error) {
        
    }];
}
@end
