//
//  DWDIntNoticeListController.m
//  EduChat
//
//  Created by Beelin on 17/1/5.
//  Copyright © 2017年 dwd. All rights reserved.
//

#import "DWDIntNoticeListController.h"
#import "DWDIntNoticeDetailController.h"

#import "DWDIntNoticeListCell.h"

#import "DWDIntNoticeListModel.h"

#import "DWDIntelligentOfficeDataHandler.h"

#import <MJRefresh/MJRefresh.h>
@interface DWDIntNoticeListController ()

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) NSInteger index;
@end

@implementation DWDIntNoticeListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configData];
    [self setupControls];
    
    //request
    [self requestNoticeList];
}

#pragma mark - Config
- (void)configData{
    self.title = @"通知公告";
    _index = 1;
    
    __weak typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        weakSelf.index = 1;
        [weakSelf requestNoticeList];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        weakSelf.index += 1;
        [weakSelf requestNoticeList];
    }];
}

#pragma mark - Setup UI
- (void)setupControls{
    self.tableView.estimatedRowHeight = 60;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DWDIntNoticeListCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([DWDIntNoticeListCell class])];
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
    DWDIntNoticeListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DWDIntNoticeListCell" forIndexPath:indexPath];
    cell.model = self.dataSource[indexPath.row];
    return cell;
}

#pragma mark - TableView Delegate 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DWDIntNoticeListModel *model = self.dataSource[indexPath.row];
    DWDIntNoticeDetailController *vc = [[DWDIntNoticeDetailController alloc] init];
    vc.model = model;
    vc.schoolId = self.schoolId;
    [self.navigationController pushViewController:vc animated:YES];
}

/** 
 删除模式。 但目前后台还未开发此功能，暂时屏蔽
 */
//-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return UITableViewCellEditingStyleDelete;
//}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    DWDIntNoticeListModel *model = self.dataSource[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self requestDeleteNoticeWithNoticeId:model.noticeId];
    }
}
#pragma mark - Request
- (void)requestNoticeList{
    DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:self.view];
    [DWDIntelligentOfficeDataHandler requestGetNoticeListWithCid:[DWDCustInfo shared].custId sid:self.schoolId pgIdx:@(self.index) pgCnt:@(10) success:^(NSArray *dataSource, BOOL isHaveData){
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

- (void)requestDeleteNoticeWithNoticeId:(NSNumber *)noticeId{
    DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:self.view];
    hud.detailsLabelText = @"正在删除";
    [DWDIntelligentOfficeDataHandler requestDeleteNoticeWithCid:[DWDCustInfo shared].custId sid:self.schoolId noticeId:noticeId success:^{
        
    } failure:^(NSError *error) {
        
    }];
}
@end
