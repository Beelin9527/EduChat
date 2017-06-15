//
//  DWDIntMessageController.m
//  EduChat
//
//  Created by Beelin on 17/1/9.
//  Copyright © 2017年 dwd. All rights reserved.
//

#import "DWDIntMessageController.h"
#import "DWDIntH5ViewController.h"

#import "DWDIntMessageCell.h"

#import "DWDIntMessageModel.h"

#import "DWDIntelligentOfficeDataHandler.h"
#import "DWDRecentChatDatabaseTool.h"

#import <YYModel.h>
#import <MJRefresh/MJRefresh.h>
@interface DWDIntMessageController ()<DWDIntMessageCellDelegate>
@property (nonatomic, copy) NSMutableArray *dataSource;
@property (nonatomic, assign) NSInteger index;
@end

@implementation DWDIntMessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configData];
    [self setupControls];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] clearBadgeCountWithFriendId:@1002 myCusId:[DWDCustInfo shared].custId success:^{
    } failure:^{
    }];
    
    [DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool].currentOperationFriendId = @1002;

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] clearBadgeCountWithFriendId:@1002 myCusId:[DWDCustInfo shared].custId success:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNeedRecentChatLoad object:nil userInfo:@{@"isNeedLoadData":@YES}];
    } failure:^{
    }];
    [DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool].currentOperationFriendId = nil;
}


#pragma mark - Config
- (void)configData{
    self.title = @"智能办公";
    
    _index = 1;
    [self requestData];
    
    __weak typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.index = 1;
        [weakSelf requestData];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.index += 1;
        [weakSelf requestData];
    }];}


#pragma mark - Setup
- (void)setupControls{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
}

#pragma mark - Getter
- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
#pragma mark - TableView Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DWDIntMessageCell *cell = [DWDIntMessageCell cellWithTableView:tableView];
    cell.delegate = self;
    cell.intMessageModel = self.dataSource[indexPath.row];
    return cell;
}

#pragma mark - TableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    DWDIntMessageModel *model = self.dataSource[indexPath.row];
    return model.cellHeight;
}

#pragma mark - DWDIntMessageCellDelegate
- (void)intMessageCell:(DWDIntMessageCell *)cell didClickItemWithIntMessageModel:(DWDIntMessageModel *)model{
    DWDIntH5ViewController *vc = [[DWDIntH5ViewController alloc] init];
    vc.url = model.value;
    vc.schoolId = model.sid;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Request
- (void)requestData{
    DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:self.view];
    [DWDIntelligentOfficeDataHandler requestSmartaddrmsgCenterGetListWithCid:[DWDCustInfo shared].custId pgIdx:@(self.index) pgCnt:@(10) success:^(NSArray *dataSource, BOOL isHaveData) {
        [hud hideHud];
        if (_index == 1) {
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:dataSource];
            
            [self.tableView.mj_header endRefreshing];
            [self.tableView reloadData];
        }else{
            if (isHaveData) {
                [self.tableView.mj_footer endRefreshing];
            }else{
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.dataSource addObjectsFromArray:dataSource];
            [self.tableView reloadData];
        }
    } failure:^(NSError *error) {
         [hud hideHud];
    }];
}
@end
