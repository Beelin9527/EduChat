//
//  DWDPickUpCenterChildTableViewController.m
//  EduChat
//
//  Created by Superman on 16/3/23.
//  Copyright © 2016年 dwd. All rights reserved.
//


#import "DWDPickUpCenterDataBaseModel.h"
#import "DWDClassModel.h"

#import "DWDPickUpCenterChildTableViewController.h"

#import "DWDPickUpCenterChildTimeLineViewController.h"

#import "DWDTabbarViewController.h"

#import "DWDPickUpCenterBackgroundContainerView.h"

#import "DWDPickUpCenterChildCell.h"
#import "DWDPickUpCenterChildNoLiveCell.h"

#import "DWDRecentChatDatabaseTool.h"
#import "DWDContactsDatabaseTool.h"
#import "DWDPickUpCenterDatabaseTool.h"

#import "DWDIntelligentOfficeDataHandler.h"
#import "NSString+extend.h"


@interface DWDPickUpCenterChildTableViewController() 
@property (nonatomic , strong) NSArray *dataArray;
@property (nonatomic, weak) DWDPickUpCenterBackgroundContainerView *blankView;
@end
@implementation DWDPickUpCenterChildTableViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"接送中心";
    
    self.view.superview.backgroundColor = DWDColorBackgroud;
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
    self.tableView.estimatedRowHeight = 300;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DWDPickUpCenterChildNoLiveCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ChildNoLiveCell"];
    [self.tableView registerClass:[DWDPickUpCenterChildCell class] forCellReuseIdentifier:@"ChildCell"];
    
    self.tableView.backgroundColor = UIColorFromRGB(0xf5f5f5);

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"时间轴" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonClick)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadNotificationReceived) name:DWDPickUpCenterDidUpdateChildInfomation object:nil];
    
    //检测此菜单功能是否点击过,key为menuCode
    NSString *key = [NSString stringWithFormat:@"%@-%@", [DWDCustInfo shared].custId, kDWDIntMenuCodeClassManagementTransferCenter];
    NSString *obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (!obj && self.classModel) {//classModel不为nil,才可以请求
        [self requestGetAlertWithMenuCode:kDWDIntMenuCodeClassManagementTransferCenter];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

//    int badgeNumber = [[DWDPickUpCenterDatabaseTool sharedManager] getBadgeNumberWithClassId:_classId listTableName:@"PUC_CHILDLIST"];
//    [[DWDPickUpCenterDatabaseTool sharedManager] subTeacherListBadgeNumberWithClassId:_classId subNumber:[NSNumber numberWithInt:badgeNumber]];
    
    
    int badgeNumber = [[DWDPickUpCenterDatabaseTool sharedManager] getBadgeNumberWithClassId:_classId listTableName:@"PUC_CHILDLIST"];
//    [[DWDPickUpCenterDatabaseTool sharedManager] subTeacherListBadgeNumberWithClassId:_classId subNumber:[NSNumber numberWithInt:badgeNumber]];
    [[DWDPickUpCenterDatabaseTool sharedManager] subChildListBadgeNumberWithClassId:_classId subNumber:[NSNumber numberWithInt:badgeNumber]];
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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Event Response
- (void)reloadNotificationReceived {
   self.dataArray = [[DWDPickUpCenterDatabaseTool sharedManager] selectWhichDate:[NSString getTodayDateStr] ChildDataBaseWithClassId:self.classId];
    
    [self.tableView reloadData];
}

- (void)rightBarButtonClick {
    
    DWDPickUpCenterChildTimeLineViewController *vc = [DWDPickUpCenterChildTimeLineViewController new];
    vc.classId = self.classId;
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = self.dataArray.count;
    
    if (count == 0) {
        [self.blankView setNeedsDisplay];
        tableView.backgroundView = nil;
    } else {
        [self.blankView removeFromSuperview];
        tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"msg_tf_bj"]];
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DWDPickUpCenterDataBaseModel *dataBaseModel = self.dataArray[indexPath.row];
    
    if ([dataBaseModel.contextual isEqualToString:@"OffAfterschoolBus"] || [dataBaseModel.contextual isEqualToString:@"Getoutschool"]) {
        DWDPickUpCenterChildNoLiveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChildNoLiveCell"];
        cell.dataModel = dataBaseModel;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    } else {
        DWDPickUpCenterChildCell *cell = [DWDPickUpCenterChildCell cellWithTableView:tableView ID:@"ChildCell"];
        cell.dataBaseModel = dataBaseModel;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
}




#pragma mark - Setter / Getter
- (NSArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [[DWDPickUpCenterDatabaseTool sharedManager] selectWhichDate:[NSString getTodayDateStr] ChildDataBaseWithClassId:self.classId];
    }
    return _dataArray;
}

- (DWDPickUpCenterBackgroundContainerView *)blankView {
    if (!_blankView) {
        DWDPickUpCenterBackgroundContainerView *blankView = [DWDPickUpCenterBackgroundContainerView new];
        [blankView.backgroundImageView setImage:[UIImage imageNamed:@"MSG_TF_No_Message"]];
        [blankView.infoLabel setText:@"暂无接送消息"];
        blankView.frame = CGRectMake(DWDScreenW * 0.5 - pxToW(316) * 0.5, pxToH(330), pxToW(316), pxToH(377));
        [self.tableView addSubview:blankView];
        _blankView = blankView;
    }
    return _blankView;
}

#pragma mark - Request Data
- (void)requestGetAlertWithMenuCode:(NSString *)code{
    [DWDIntelligentOfficeDataHandler requestGetAlertWithCid:[DWDCustInfo shared].custId sid:self.classModel.schoolId mncd:code sta:nil targetController:self success:^{
        
    } failure:^(NSError *error) {
        
    }];
}
@end
