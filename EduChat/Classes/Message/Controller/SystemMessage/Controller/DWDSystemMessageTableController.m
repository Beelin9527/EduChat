//
//  DWDSystemMessageTableController.m
//  EduChat
//
//  Created by apple on 2/28/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import "DWDSystemMessageTableController.h"
#import "DWDSystemMessageDetailModel.h"
#import "DWDSystemMessageCell.h"
#import "DWDSystemMessageDetailTableViewController.h"
#import "DWDContactsDatabaseTool.h"
#import "DWDRecentChatDatabaseTool.h"

//#import <FMDB.h>
#import <YYModel.h>
#import <MJRefresh.h>

@interface DWDSystemMessageTableController ()<UITableViewDelegate, UITableViewDataSource, DWDSystemMessageDetailTableViewControllerDelegate>

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, copy) NSArray *dataArray;

@property (nonatomic, strong) UIImageView *blankView;

@property (nonatomic, assign) NSInteger loadIndex;

@end

@implementation DWDSystemMessageTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:(CGRect){self.view.bounds.origin, self.view.bounds.size.width, self.view.bounds.size.height - 64}];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = UIColorFromRGB(0xf5f5f5);
    tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    _tableView = tableView;
    //读取sys_message表中的数据
    //设置到属性中
    self.navigationItem.title = @"消息中心";
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    _loadIndex = 1;
    [self.tableView.mj_header beginRefreshing];
    
//    [self loadNewData];
    
    [self.tableView registerClass:[DWDSystemMessageCell class] forCellReuseIdentifier:@"DWDSystemMessageCell"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] clearBadgeCountWithFriendId:@1000 myCusId:[DWDCustInfo shared].custId success:^{
    } failure:^{
    }];
    
    [DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool].currentOperationFriendId = @1000;
    
//    [self loadDataBaseData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] clearBadgeCountWithFriendId:@1000 myCusId:[DWDCustInfo shared].custId success:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNeedRecentChatLoad object:nil userInfo:@{@"isNeedLoadData":@YES}];
    } failure:^{
    }];
    [DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool].currentOperationFriendId = nil;
}

#pragma mark - private method
- (void)loadNewData {
//    FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:DWDDatabasePath];
//    [queue inDatabase:^(FMDatabase *db) {
//        FMResultSet *resultSet = [db executeQuery:@"SELECT * FROM t_message"];
//        while (resultSet.next) {
//            DWDSystemMessageDetailModel *model = [[DWDSystemMessageDetailModel alloc] init];
////            id integer PRIMARY KEY, verifyInfo TEXT, custId INTEGER, groupId INTEGER, creatTime INTEGER, verifyState INTEGER, msgType TEXT
//            model.custId = [NSNumber numberWithInt:[resultSet intForColumn:@"custId"]];
//            model.classId = [NSNumber numberWithInt:[resultSet intForColumn:@"custId"]];
//            model.verifyState = [resultSet boolForColumn:@"verifyState"];
//            model.verifyInfo = ![resultSet stringForColumn:@"verifyInfo"] ? @"":[resultSet stringForColumn:@"verifyInfo"];
//            model.createTime = [resultSet stringForColumn:@"createTime"];
//            
//            [array addObject:model];
//        };
//    }];
    WEAKSELF;
    
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.labelText = @"请稍候";
//    [hud show:YES];
    NSDictionary *params = @{@"cid" : [DWDCustInfo shared].custId,
                             @"pgIdx" : @1,
                             @"pgCnt" : @10};
    [[DWDWebManager sharedManager] getRequstClassVerifyInfoWithParams:params success:^(NSURLSessionDataTask *task, id responseObject) {
        _loadIndex = 1;
        weakSelf.dataArray = [NSArray yy_modelArrayWithClass:[DWDSystemMessageDetailModel class] json:responseObject[@"data"]];
//        NSMutableArray *array = [NSMutableArray array];
//        for (int i = 0; i < dataArray.count; i ++) {
//            DWDSystemMessageDetailModel *model = [DWDSystemMessageDetailModel yy_modelWithJSON:dataArray[i]];
//            [array addObject:model];
//        }
//        weakSelf.dataArray = array;
        dispatch_async(dispatch_get_main_queue(), ^{
//            [hud hide:YES];
            if (weakSelf.dataArray.count == 0) {
                weakSelf.tableView.backgroundView = weakSelf.blankView;
            } else {
                weakSelf.tableView.backgroundView = nil;
            }
            [weakSelf.tableView.mj_header endRefreshing];
            [weakSelf.tableView reloadData];
        });
        DWDMarkLog(@"YES get class verify info");
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        [hud hide:YES];
        weakSelf.loadIndex = 1;
        weakSelf.dataArray = nil;
        weakSelf.tableView.backgroundView = weakSelf.blankView;
        DWDMarkLog(@"NOT get class verify info");
        [weakSelf.tableView.mj_header endRefreshing];
        [weakSelf.tableView reloadData];
    }];
//    DWDMarkLog(@"data:%@", self.dataArray);
}

- (void)loadMoreData {
    NSDictionary *params = @{@"cid" : [DWDCustInfo shared].custId,
                             @"pgIdx" : @(_loadIndex + 1),
                             @"pgCnt" : @10};
    WEAKSELF;
    [[DWDWebManager sharedManager] getRequstClassVerifyInfoWithParams:params success:^(NSURLSessionDataTask *task, id responseObject) {
        weakSelf.loadIndex += 1;
        
        NSArray *dataArray = [NSArray yy_modelArrayWithClass:[DWDSystemMessageDetailModel class] json:responseObject[@"data"]];
        NSMutableArray *mutiArray = [weakSelf.dataArray mutableCopy];
        [mutiArray addObjectsFromArray:dataArray];
        weakSelf.dataArray = mutiArray;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.tableView.backgroundView = nil;
            [weakSelf.tableView.mj_footer endRefreshing];
            [weakSelf.tableView reloadData];
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf.tableView.mj_footer endRefreshing];
    }];
}

#pragma mark - event response

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.dataArray.count == 0) {
    } else {
        self.tableView.backgroundView = nil;
    }
    
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    DWDSystemMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DWDSystemMessageCell" forIndexPath:indexPath];
    DWDSystemMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DWDSystemMessageCell"];
    cell.detailModel = self.dataArray[indexPath.row];
    
    return cell;
}


#pragma mark - UITableViewDelete
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DWDSystemMessageDetailTableViewController *vc = [[DWDSystemMessageDetailTableViewController alloc] init];
    vc.eventDelegate = self;
    vc.data = self.dataArray[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //进行删除操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud setLabelText:@"正在删除..."];
        DWDSystemMessageDetailModel *model = _dataArray[indexPath.row];
        NSDictionary *params = @{@"cid" : [DWDCustInfo shared].custId,
                                 @"msgIds" : @[model.verifyId]};
        WEAKSELF;
        [[DWDWebManager sharedManager] deleteClassVerifyInfoWithParams:params success:^(NSURLSessionDataTask *task, id responseObject) {
            //删除成功 本地操作一哈 删除列表中的数据 和 界面中的cell
            NSMutableArray *dataArray = [weakSelf.dataArray mutableCopy];
            [dataArray removeObjectAtIndex:indexPath.row];
            weakSelf.dataArray = dataArray;
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud setMode:MBProgressHUDModeText];
                [hud setLabelText:@"删除成功"];
                [hud hide:YES afterDelay:1.5f];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            });
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            //删除失败
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud setMode:MBProgressHUDModeText];
                [hud setLabelText:@"删除失败"];
                [hud hide:YES afterDelay:1.5f];
            });
        }];
    }
}
#pragma mark - DWDSystemMessageDetailTableViewControllerDelegate
- (void)systemMessageDetailController:(DWDSystemMessageDetailTableViewController *)controller didChangeVerifyState:(NSNumber *)state {
    DWDSystemMessageDetailModel *model = controller.data;
    NSInteger index = [_dataArray indexOfObject:model];
    if (index != NSNotFound) {
        DWDSystemMessageDetailModel *changeData = _dataArray[index];
        changeData.verifyState = state;
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Setter / Getter

- (UIImageView *)blankView {
    if (!_blankView) {
        UIImageView *blankView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"msg_msg_center_no_data"]];
        blankView.contentMode = UIViewContentModeCenter;
//        CGRect frame = CGRectZero;
//        frame.size = CGSizeMake(pxToW(316), pxToW(377));
//        blankView.frame = frame;
//        blankView.center = CGPointMake(DWDScreenW * 0.5, DWDScreenH * 0.5);
//        blankView.frame = CGRectMake(DWDScreenW * 0.5 - pxToW(316) * 0.5, pxToH(330), pxToW(316), pxToH(377));
        blankView.frame = self.view.bounds;
        _blankView = blankView;
    }
    return _blankView;
}

@end
