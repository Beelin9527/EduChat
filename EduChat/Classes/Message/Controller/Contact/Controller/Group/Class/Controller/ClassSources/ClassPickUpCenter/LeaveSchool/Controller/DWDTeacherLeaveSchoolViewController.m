//
//  DWDTeacherLeaveSchoolViewController.m
//  EduChat
//
//  Created by KKK on 16/3/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#define windowWH pxToW(120)

#import "DWDTeacherLeaveSchoolViewController.h"
#import "DWDSegmentedControl.h"
#import "DWDPickUpCenterHelper.h"

#import "DWDTeacherLeaverSchoolGateController.h"
#import "DWDTeacherLeaveSchoolBusController.h"
#import "DWDTeacherLeaveSchoolWaitController.h"
#import "DWDTeacherLeaveSchoolCompleteController.h"

#import "DWDTabbarViewController.h"

#import "DWDPickUpCenterDatabaseTool.h"
#import "DWDRecentChatDatabaseTool.h"

#import "DWDPUCLoadingView.h"

#import "DWDPickUpCenterDataBaseModel.h"
#import "DWDTeacherGoSchoolStudentDetailModel.h"
#import "DWDPickUpCenterTotalStudentsModel.h"

#import "NSString+extend.h"
#import "NSDictionary+dwd_extend.h"

#import <YYModel.h>

@interface DWDTeacherLeaveSchoolViewController () <DWDSegmentedControlDelegate, DWDPUCLoadingViewDelegate>

@property (nonatomic, strong) NSDictionary *totalDict;

@property (nonatomic, strong) DWDTeacherLeaverSchoolGateController *gateController;
@property (nonatomic, strong) DWDTeacherLeaveSchoolBusController *busController;
@property (nonatomic, strong) DWDTeacherLeaveSchoolWaitController *waitController;
@property (nonatomic, strong) DWDTeacherLeaveSchoolCompleteController *completeController;

@property (nonatomic, weak) DWDPUCLoadingView *loadingView;

@property (nonatomic, weak) UIView *leaveView;
@property (nonatomic, weak) UILabel *leaveLabel;
@property (nonatomic, weak) UIView *attendView;
@property (nonatomic, weak) UILabel *attendLabel;

@property (nonatomic, assign) BOOL requestFailed;

@property (nonatomic, strong) DWDSegmentedControl *segmentControl;
@property (nonatomic, assign) NSInteger lastSelectSegment;



@end

@implementation DWDTeacherLeaveSchoolViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
//    setTopDetailView
    [self.view addSubview:self.segmentControl];
    self.view.backgroundColor = UIColorFromRGB(0xf5f5f5);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNotificationReceived:) name:DWDPickUpCenterDidUpdateTeacherLeaveSchool object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [self performSelector:@selector(setSuspendWindow) withObject:nil afterDelay:1];
//    [self setSuspendView];
//    self.leaveView.hidden = NO;
//    self.attendView.hidden = NO;
//    self.leaveLabel.hidden = NO;
//    self.attendLabel.hidden = NO;
    
    [self segmentedControlIndexButtonView:self.segmentControl index:!_lastSelectSegment ? 0 : _lastSelectSegment];

    [self.view setNeedsLayout];
    
//    [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] clearBadgeCountWithFriendId:@1001 myCusId:[DWDCustInfo shared].custId success:^{
//    } failure:^{
//    }];
//    
//    [DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool].currentOperationFriendId = @1001;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.leaveView.frame = CGRectMake(DWDScreenW - windowWH - pxToW(30), self.view.frame.size.height - (windowWH + pxToW(30)) * 2 - pxToW(20), windowWH, windowWH);
    self.attendView.frame = CGRectMake(DWDScreenW - windowWH - pxToW(30), self.view.frame.size.height - windowWH - pxToW(30) - pxToW(20), windowWH, windowWH);
   
    self.leaveLabel.frame = self.leaveView.bounds;
    self.attendLabel.frame = self.attendView.bounds;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self updateWindowValue];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    WEAKSELF;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [weakSelf.leaveLabel removeFromSuperview];
//        [weakSelf.attendLabel removeFromSuperview];
//        [weakSelf.leaveView removeFromSuperview];
//        [weakSelf.attendView removeFromSuperview];
//    });
//    [self.leaveView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
//    [self.attendView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
//    self.leaveView = nil;
//    self.attendView = nil;
//    int badgeNumber = [[DWDPickUpCenterDatabaseTool sharedManager] getBadgeNumberWithClassId:_classId listTableName:@"PUC_CLASSLIST"];
//    [[DWDPickUpCenterDatabaseTool sharedManager] subTeacherListBadgeNumberWithClassId:_classId subNumber:[NSNumber numberWithInt:badgeNumber]];
//    //badge value
//    NSInteger badgeValue = [[[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] getAllRecentChatBadgeNum] integerValue];
//    NSString *cacheKey = [NSString stringWithFormat:@"applayCountDict_%@",[DWDCustInfo shared].custId];
//    NSDictionary *applayDict = [[NSUserDefaults standardUserDefaults] objectForKey:cacheKey];
//    NSInteger chatBadgeCount = [applayDict[@"chatBadgeCount"] integerValue];
//    badgeValue += chatBadgeCount;
//    
//    DWDTabbarViewController *tabbarVc = (DWDTabbarViewController *)[UIApplication sharedApplication].keyWindow.rootViewController;
//    UITabBarItem *item = tabbarVc.tabBar.items[0];
//    
//    if (badgeNumber >= badgeValue) {
//        item.badgeValue = nil;
//    } else if (badgeValue - badgeNumber > 99) {
//        item.badgeValue = @"99+";
//    } else {
//        item.badgeValue = badgeValue - badgeNumber < 0 ? nil : [NSString stringWithFormat:@"%zd", badgeValue - badgeNumber];
//    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNeedRecentChatLoad object:nil userInfo:@{@"isNeedLoadData":@YES}];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Method
- (void)reloadNotificationReceived {
    [self requestOrCache];
}

- (void)reloadNotificationReceived:(NSNotification *)noti {
    if (noti == nil) {
        [self requestOrCache];
    } else {
        NSNumber *classId = noti.userInfo[@"classId"];
        if ([classId isEqualToNumber:_classId]) {
            [self requestOrCache];
        }
    }
    

}

- (void)requestOrCache {
    if ([DWDPickUpCenterHelper isNecessaryToNewRequestWithClassId:_classId]) {
        [self needNewRequest];
    } else {
        NSString *key = [DWDPickUpCenteruserDefaultPickUpCenterTodayStudentsKey stringByAppendingString:[NSString stringWithFormat:@"_%@_%@", _classId, [DWDCustInfo shared].custId]];
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        DWDPickUpCenterTotalStudentsModel *model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [self setChildDataWithTotalModel:model];
    }
}

- (void)needNewRequest {
    
    /*
     发送请求
     根据请求下来的数据
     分成 成功数组 和 失败数组
     在请求里面调用一个方法进行处理
     **/
    DWDPUCLoadingView *loadingView;
    if (_isFirstRequest && _loadingView == nil) {
        //310 * 271
        loadingView = [[DWDPUCLoadingView alloc] initWithFrame:(CGRect){(DWDScreenW - 310 * 0.5) * 0.5, (DWDScreenH - 271 + 20 +46 * 0.5) * 0.5, 310 * 0.5, 271 + 20 + 46 * 0.5}];
        loadingView.delegate = self;
        //        loadingView.center = self.tableView.center;
//        [self.tableView insertSubview:loadingView aboveSubview:self.tableView];
//        [self.view insertSubview:loadingView aboveSubview:self.view];
        [self.view addSubview:loadingView];
        [self.view bringSubviewToFront:loadingView];
        loadingView.layer.zPosition = MAXFLOAT;
        _loadingView = loadingView;
    }
    
    
    NSDictionary *params = @{@"classId": self.classId};
//    [[HttpClient sharedClient] cancelTaskWithApi:@"punch/getPickupchild"];
    //获取当天状态
    WEAKSELF;
    [[HttpClient sharedClient] getPickUpCenterStudentsStatusWithParams:params success:^(NSURLSessionDataTask *task, id responseObject) {
        weakSelf.requestFailed = NO;
        weakSelf.isFirstRequest = NO;
        weakSelf.gateController.requestFailed = NO;
        weakSelf.busController.requestFailed = NO;
        weakSelf.waitController.requestFailed = NO;
        weakSelf.completeController.requestFailed = NO;
        
        weakSelf.gateController.isFirstRequest = NO;
        weakSelf.busController.isFirstRequest = NO;
        weakSelf.waitController.isFirstRequest = NO;
        weakSelf.completeController.isFirstRequest = NO;
        [weakSelf.loadingView removeFromSuperview];
        
        
        DWDPickUpCenterTotalStudentsModel *model = [DWDPickUpCenterTotalStudentsModel yy_modelWithDictionary:responseObject[@"data"]];
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.locale = [NSLocale currentLocale];
        formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
        model.deadline = [formatter dateFromString:responseObject[@"data"][@"deadline"]];
        model.dateTime = [NSDate date];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:model];
        NSString *key = [DWDPickUpCenteruserDefaultPickUpCenterTodayStudentsKey stringByAppendingString:[NSString stringWithFormat:@"_%@_%@", weakSelf.classId, [DWDCustInfo shared].custId]];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
        
        [weakSelf setChildDataWithTotalModel:model];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf updateWindowValue];
        //刷新所有tableView
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.requestFailed = YES;
            weakSelf.gateController.requestFailed = YES;
            weakSelf.busController.requestFailed = YES;
            weakSelf.waitController.requestFailed = YES;
            weakSelf.completeController.requestFailed = YES;
            
            weakSelf.isFirstRequest = NO;
            weakSelf.gateController.isFirstRequest = NO;
            weakSelf.busController.isFirstRequest = NO;
            weakSelf.waitController.isFirstRequest = NO;
            weakSelf.completeController.isFirstRequest = NO;
            //            [loadingView removeFromSuperview];
            if ([weakSelf.loadingView respondsToSelector:@selector(changeToFailedView)]) {
                [weakSelf.loadingView changeToFailedView];
            }
        weakSelf.totalStudentsArray = [NSArray array];
        [weakSelf.gateController.tableView reloadData];
        [weakSelf.busController.tableView reloadData];
        [weakSelf.waitController.tableView reloadData];
        [weakSelf.completeController.tableView reloadData];
        });
    }];
    
}

- (void)setChildDataWithTotalModel:(DWDPickUpCenterTotalStudentsModel *)model {
//    NSNumber *type = model.type;
//    if ([type isEqualToNumber:@1]) {
//        self.totalStudentsArray = [NSArray array];
//        //刷新所有tableView
//        [self.gateController.tableView reloadData];
//        [self.busController.tableView reloadData];
//        [self.waitController.tableView reloadData];
//        [self.completeController.tableView reloadData];
//        WEAKSELF;
//        [self.leaveView removeFromSuperview];
//        [self.attendView removeFromSuperview];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [weakSelf.leaveLabel removeFromSuperview];
//            [weakSelf.attendLabel removeFromSuperview];
//            [weakSelf.leaveView removeFromSuperview];
//            [weakSelf.attendView removeFromSuperview];
//        });
//        return;
//}
    
    self.index = model.index;
    //如果当前是上学时间段
    
    //那么 在 放学页面
    //只显示 已经到达学校的人数
    if ([model.type isEqualToNumber:@1]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSMutableArray *waitArray = [NSMutableArray array];
        [dict setObject:[NSArray array] forKey:@"gate"];
        [dict setObject:[NSArray array] forKey:@"bus"];
        [dict setObject:[NSArray array] forKey:@"complete"];
        
        for (DWDTeacherGoSchoolStudentDetailModel *md in model.students) {
            if ([md.contextual isEqualToString:@"Reachschool"]) {
                [waitArray addObject:md];
            }
        }
        [dict setObject:waitArray forKey:@"wait"];
        
        self.totalDict = dict;
    } else {
    self.totalStudentsArray = model.students;
    //reset大字典
    self.totalDict = [self totalDictReset];
    }
    self.gateController.dataArray = self.totalDict[@"gate"];
    self.busController.dataArray = self.totalDict[@"bus"];
    self.waitController.dataArray = self.totalDict[@"wait"];
    self.completeController.dataArray = self.totalDict[@"complete"];
    
    [self setSuspendView];
    [self updateWindowValue];
    //刷新所有tableView
    WEAKSELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.gateController.tableView reloadData];
        [weakSelf.busController.tableView reloadData];
        [weakSelf.waitController.tableView reloadData];
        [weakSelf.completeController.tableView reloadData];
    });
}

- (void)setSuspendView {
//    UIWindow *leaveView = [[UIWindow alloc] initWithFrame:CGRectMake(DWDScreenW - windowWH - pxToW(30), DWDScreenH - (windowWH + pxToW(30)) * 2, windowWH, windowWH)];
    if (!_leaveView && !_attendView) {
        UIView *leaveView = [[UIView alloc] initWithFrame:CGRectMake(DWDScreenW - windowWH - pxToW(30), self.view.frame.size.height - (windowWH + pxToW(30)) * 2 - pxToW(20), windowWH, windowWH)];
        //    [self.view.superview insertSubview:leaveView aboveSubview:self.view];
        //    [self.view.superview addSubview:leaveView];
        self.leaveView = leaveView;
        [self.view insertSubview:leaveView aboveSubview:self.view];
        leaveView.layer.zPosition = MAXFLOAT;
        leaveView.backgroundColor = DWDRGBColor(53, 157, 246);
        leaveView.layer.opacity = 0.9;
        leaveView.layer.cornerRadius = windowWH / 2.0;
        leaveView.layer.masksToBounds = YES;
        
        //    UIWindow *attendView = [[UIWindow alloc] initWithFrame:CGRectMake(DWDScreenW - windowWH - pxToW(30), DWDScreenH - windowWH - pxToW(30), windowWH, windowWH)];
        UIView *attendView = [[UIView alloc] initWithFrame:CGRectMake(DWDScreenW - windowWH - pxToW(30), self.view.frame.size.height - windowWH - pxToW(30) - pxToW(20), windowWH, windowWH)];
        self.attendView = attendView;
        [self.view insertSubview:attendView aboveSubview:self.view];
        attendView.layer.zPosition = MAXFLOAT;
        attendView.backgroundColor = DWDRGBColor(0, 187, 157);
        attendView.layer.opacity = 0.9;
        attendView.layer.cornerRadius = windowWH / 2.0;
        attendView.layer.masksToBounds = YES;
        
        UILabel *leaveLabel = [UILabel new];
        leaveLabel.font = DWDFontContent;
        leaveLabel.textColor = [UIColor whiteColor];
        leaveLabel.numberOfLines = 0;
        leaveLabel.preferredMaxLayoutWidth = sqrt((windowWH / 2.0) * (windowWH / 2.0) * 2);
        leaveLabel.textAlignment = NSTextAlignmentCenter;
        self.leaveLabel = leaveLabel;
        [leaveView addSubview:leaveLabel];
        [leaveView bringSubviewToFront:leaveLabel];
        
        UILabel *attendLabel = [UILabel new];
        attendLabel.font = DWDFontContent;
        attendLabel.textColor = [UIColor whiteColor];
        attendLabel.numberOfLines = 0;
        attendLabel.preferredMaxLayoutWidth = sqrt((windowWH / 2.0) * (windowWH / 2.0) * 2);
        attendLabel.textAlignment = NSTextAlignmentCenter;
        self.attendLabel = attendLabel;
        [attendView addSubview:attendLabel];
        [attendView bringSubviewToFront:attendLabel];
    }
}

- (void)updateWindowValue {
    NSInteger complete;
    if ([self.totalDict containsKey:@"complete"]) {
        complete = [self.totalDict[@"complete"] count];
    } else {
        complete = 0;
    }
//#warning ToDo:need change to <predicate + count>
//    @"Reachschool", @"Getoutschool", @"OffAfterschoolBus"
    NSInteger total = 0;
//    for (int i = 0; i < self.totalStudentsArray.count;  i ++) {
//        DWDTeacherGoSchoolStudentDetailModel *model = self.totalStudentsArray[i];
//        if (
//            [model.contextual isEqualToString:@"Reachschool"] ||
//            [model.contextual isEqualToString:@"Getoutschool"] ||
//            [model.contextual isEqualToString:@"OffAfterschoolBus"] ||
//            [model.contextual isEqualToString:@"WaitparentOut"] ||
//            [model.contextual isEqualToString:@"OnAfterschoolBus"]
//            ) {
//            total ++;
//        }
//    }
    total =  [(NSArray *)self.totalDict[@"gate"] count] + [(NSArray *)self.totalDict[@"bus"] count] + [(NSArray *)self.totalDict[@"wait"] count] + [(NSArray *)self.totalDict[@"complete"] count];
    
    WEAKSELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.leaveLabel.text = [NSString stringWithFormat:@"%zd人\n离校", complete];
        weakSelf.attendLabel.text = [NSString stringWithFormat:@"%zd人\n出勤", total];
        [weakSelf.leaveLabel setNeedsLayout];
        [weakSelf.attendLabel setNeedsLayout];
    });
}

- (NSDictionary *)totalDictReset {
    NSMutableArray *array = [[[DWDPickUpCenterDatabaseTool sharedManager] selectWhichDate:[NSString getTodayDateStr] type:@2 index:self.index teacherDataBaseWithClassId:self.classId] mutableCopy];
    
    //初始化字典
    NSMutableDictionary *totalDict = [NSMutableDictionary dictionary];
    NSMutableArray *waitArray = [NSMutableArray new];
    for (DWDTeacherGoSchoolStudentDetailModel *requestModel in self.totalStudentsArray) {
//        if ([requestModel.contextual isEqualToString:@"Reachschool"]) {
        BOOL contain = NO;
        if (requestModel.leave == 0) {
            for (DWDPickUpCenterDataBaseModel *containsModel in array) {
                if ([containsModel.custId isEqual:requestModel.custId]) {
                    contain = YES;
                    break;
                }
            }
            if (contain == NO) {
                [waitArray addObject:requestModel];
            }
        }
        
//        }
    }
    if (waitArray != nil) {
    [totalDict setObject:waitArray forKey:@"wait"];
    }
    /*
     请求里Reachschool状态的学生就是出勤&待接学生
     */
    if (array.count == 0) {
        return totalDict;
    }
    
    //初始化4个数组
    NSMutableArray *gateArray = [NSMutableArray new];
    NSMutableArray *busArray = [NSMutableArray new];
    NSMutableArray *completeArray = [NSMutableArray new];
    
    for (int i = 0; i < array.count; i ++) {
        
        NSString *state = ((DWDPickUpCenterDataBaseModel *)array[i]).contextual;
        if ([state isEqualToString:@"WaitparentOut"]) {
            [gateArray addObject:array[i]];
        } else if ([state isEqualToString:@"OnAfterschoolBus"]) {
            [busArray addObject:array[i]];
        } else if ([state isEqualToString:@"Getoutschool"] || [state isEqualToString:@"OffAfterschoolBus"]) {
            [completeArray addObject:array[i]];
        }
    }
    
    [totalDict setObject:gateArray forKey:@"gate"];
    [totalDict setObject:busArray forKey:@"bus"];
    [totalDict setObject:completeArray forKey:@"complete"];
    return totalDict;
}

- (NSArray *)removeSameCustIdObject:(NSArray *)ar {
    //删除已经收到消息的人
    NSMutableArray *mAr = [NSMutableArray new];
    
    for (int i = 0; i < self.totalStudentsArray.count; i ++) {
        DWDTeacherGoSchoolStudentDetailModel *detailModel = self.totalStudentsArray[i];
        BOOL flag = NO;
        for (DWDPickUpCenterDataBaseModel *model in ar) {
            if ([model.custId isEqualToNumber:detailModel.custId]) {
                flag = YES;
                break;
            }
        }
        if (flag == NO) {
            [mAr addObject:self.totalStudentsArray[i]];
        }
    }
    return mAr;
}


#pragma mark - Event Response
- (void)segmentControlDidSelectGate {
    [self.view addSubview:self.gateController.view];
    if (_loadingView != nil) {
        [self.view bringSubviewToFront:_loadingView];
    }
    [self.gateController didMoveToParentViewController:self];
}

- (void)segmentControlDidSelectBus {
    [self.view addSubview:self.busController.view];
    
    if (_loadingView != nil) {
        [self.view bringSubviewToFront:_loadingView];
    }
    [self.busController didMoveToParentViewController:self];
}

- (void)segmentControlDidSelectWait {
    [self.view addSubview:self.waitController.view];
    
    if (_loadingView != nil) {
        [self.view bringSubviewToFront:_loadingView];
    }
    [self.waitController didMoveToParentViewController:self];
    
}

- (void)segmentControlDidSelectComplete {
    [self.view addSubview:self.completeController.view];
    
    if (_loadingView != nil) {
        [self.view bringSubviewToFront:_loadingView];
    }
    [self.completeController didMoveToParentViewController:self];
}


#pragma mark - DWDPUCLoadingViewDelegate
- (void)loadingViewDidClickReloadButton:(DWDPUCLoadingView *)view {
    _isFirstRequest = YES;
    _requestFailed = NO;
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
    [self needNewRequest];
}

#pragma mark - DWDSegmentedControlDelegate
- (void)segmentedControlIndexButtonView:(DWDSegmentedControl *)indexButtonView index:(NSInteger)index {
    _lastSelectSegment = index;
    [self.gateController.view removeFromSuperview];
    [self.busController.view removeFromSuperview];
    [self.waitController.view removeFromSuperview];
    [self.completeController.view removeFromSuperview];
    
    //    [@"校门待接", @"校车待接", @"待接学生", @"已接学生"];
    //          0           1           2           3
    [self reloadNotificationReceived];
    switch (index) {
        case 0:
            //    [self reloadNotificationReceived];
            [self segmentControlDidSelectGate];
            break;
        case 1:
            [self segmentControlDidSelectBus];
            break;
        case 2:
            [self segmentControlDidSelectWait];
            break;
        case 3:
            [self segmentControlDidSelectComplete];
            break;
        default:
            break;
    }
}

#pragma mark - setter / getter
/*
 key:
 gate
 bus
 wait
 complete
 */

- (DWDSegmentedControl *)segmentControl {
    if (!_segmentControl) {
        DWDSegmentedControl *segmentControl = [[DWDSegmentedControl alloc] init];
        segmentControl.frame = CGRectMake(0, 0, DWDScreenW, 44);
        segmentControl.arrayTitles = @[@"校门待接", @"校车待接", @"待接学生", @"已接学生"];
        segmentControl.delegate = self;
        _segmentControl = segmentControl;
    }
    return _segmentControl;
}

- (DWDTeacherLeaverSchoolGateController *)gateController {
    if (!_gateController) {
        DWDTeacherLeaverSchoolGateController *vc = [[DWDTeacherLeaverSchoolGateController alloc] init];
        vc.isFirstRequest = YES;
        vc.requestFailed = NO;
        
        [self addChildViewController: vc];
        CGRect frame = self.view.bounds;
        frame.origin.y = CGRectGetMaxY(self.segmentControl.frame) + pxToW(20);
        frame.size.height = self.view.bounds.size.height - self.segmentControl.frame.size.height;
        vc.view.frame = frame;
        
        _gateController = vc;
    }
    return _gateController;
}

- (DWDTeacherLeaveSchoolBusController *)busController {
    if (!_busController) {
        DWDTeacherLeaveSchoolBusController *vc = [[DWDTeacherLeaveSchoolBusController alloc] init];
        vc.isFirstRequest = YES;
        vc.requestFailed = NO;
        
        [self addChildViewController: vc];
        CGRect frame = self.view.bounds;
        frame.origin.y = CGRectGetMaxY(self.segmentControl.frame) + pxToW(20);
        frame.size.height = self.view.bounds.size.height - self.segmentControl.frame.size.height;
        vc.view.frame = frame;
        
        _busController = vc;
    }
    return _busController;
}

- (DWDTeacherLeaveSchoolWaitController *)waitController {
    if (!_waitController) {
        DWDTeacherLeaveSchoolWaitController *vc = [[DWDTeacherLeaveSchoolWaitController alloc] init];
        vc.isFirstRequest = YES;
        vc.requestFailed = NO;
        
        [self addChildViewController: vc];
        CGRect frame = self.view.bounds;
        frame.origin.y = CGRectGetMaxY(self.segmentControl.frame) + pxToW(20);
        frame.size.height = self.view.bounds.size.height - self.segmentControl.frame.size.height;
        vc.view.frame = frame;
        
        _waitController = vc;
    }
    return _waitController;
}

- (DWDTeacherLeaveSchoolCompleteController *)completeController {
    if (!_completeController) {
        DWDTeacherLeaveSchoolCompleteController *vc = [[DWDTeacherLeaveSchoolCompleteController alloc] init];
        vc.isFirstRequest = YES;
        vc.requestFailed = NO;
        
        [self addChildViewController: vc];
        CGRect frame = self.view.bounds;
        frame.origin.y = CGRectGetMaxY(self.segmentControl.frame) + pxToW(20);
        frame.size.height = self.view.bounds.size.height - self.segmentControl.frame.size.height;
        vc.view.frame = frame;
        
        _completeController = vc;
    }
    return _completeController;
}

- (NSArray *)totalStudentsArray {
    if (!_totalStudentsArray) {
        NSArray *ar = [NSArray new];
        _totalStudentsArray = ar;
    }
    return _totalStudentsArray;
}

@end
