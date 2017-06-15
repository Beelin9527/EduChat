//
//  DWDCollectViewController.m
//  EduChat
//
//  Created by Gatlin on 16/8/25.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDCollectViewController.h"
#import "DWDInfoDetailViewController.h"
#import "DWDExpertHomeViewController.h"

#import "DWDInformationCell.h"
#import "DWDCollectioinCell.h"

#import "DWDCollectDataHandler.h"
#import "DWDCollectModel.h"

#import "DWDRefreshGifHeader.h"
#import <MJRefresh/MJRefresh.h>
@interface DWDCollectViewController ()
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) NSInteger index;  //页码
@end

@implementation DWDCollectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.title = NSLocalizedString(@"MyCollect", nil);
   
    self.tableViewStyle = UITableViewStyleGrouped;
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        _index ++;
        [self requestCollectList];
    }];
    
    DWDRefreshGifHeader *header = [DWDRefreshGifHeader headerWithRefreshingBlock:^{
        _index = 1;
        [self requestCollectList];
    }];
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:64];
    for (int i = 1; i < 8; i ++ )
    {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"img_loading_%d",i]];
        [images addObject:image];
    }
    [header setImages:images duration:0.5 forState:MJRefreshStateIdle];
    [header setImages:images duration:0.5 forState:MJRefreshStatePulling];
    [header setImages:images duration:0.5 forState:MJRefreshStateRefreshing];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    [self.tableView.mj_header beginRefreshing];
}


#pragma mark - Getter
- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource  = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}
#pragma mark - TableView Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DWDCollectModel *model = self.dataSource[indexPath.section];
    DWDCollectioinCell *cell = [[DWDCollectioinCell alloc] initWithTableView:tableView collectModel:model];
  
    return cell;
}


#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DWDCollectModel *model = self.dataSource[indexPath.section];
    if ([model.contentCode isEqualToNumber:@4]) {
        DWDInfoDetailViewController *vc = [[DWDInfoDetailViewController alloc] init];
        vc.contentCode = model.contentCode;
        vc.commendId = model.New.infoId;
        vc.contentLink = model.New.contentLink;
        vc.hidesBottomBarWhenPushed = YES;
        
        //call back
        __weak typeof(self) weakSelf = self;
        vc.collectCancleBlock = ^(NSNumber *collectId){
            [weakSelf requestCanCleCollectWithId:collectId indexPath:indexPath];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([model.contentCode isEqualToNumber:@8]){
        DWDInfoDetailViewController *vc = [[DWDInfoDetailViewController alloc] init];
        vc.contentCode = model.contentCode;
        vc.commendId = model.article.infoId;
        vc.contentLink = model.article.contentLink;
        vc.hidesBottomBarWhenPushed = YES;
        
        //call back
        __weak typeof(self) weakSelf = self;
        vc.collectCancleBlock = ^(NSNumber *collectId){
            [weakSelf requestCanCleCollectWithId:collectId indexPath:indexPath];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([model.contentCode isEqualToNumber:@7]){
        DWDExpertHomeViewController *vc = [[DWDExpertHomeViewController alloc] init];
        vc.expertId = model.expert.custId;
        
        //call back
        __weak typeof(self) weakSelf = self;
        vc.collectCancleBlock = ^(NSNumber *collectId){
            [weakSelf requestCanCleCollectWithId:collectId indexPath:indexPath];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    DWDCollectModel *model = self.dataSource[indexPath.section];
    return model.height;
   
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"Delete", nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        DWDCollectModel *collectModel = self.dataSource[indexPath.row];
        [self requestCanCleCollectWithId:collectModel.collectId indexPath:indexPath];
        
        
    }];
    
    return @[deleteAction];
}

#pragma mark - Request
- (void)requestCollectList
{
    DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:self.view];
    [DWDCollectDataHandler requestCollectListWithCustId:[DWDCustInfo shared].custId idx:@(self.index) cnt:@10 success:^(NSArray *dataSource, BOOL isHaveData) {
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
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [hud showText:error.localizedFailureReason];
    }];
}

//cancle collect
- (void)requestCanCleCollectWithId:(NSNumber *)collectId indexPath:(NSIndexPath *)indexPath
{
    DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:self.view];
    [DWDCollectDataHandler requestDeleteCollectWithCustId:[DWDCustInfo shared].custId collectId:@[collectId]  success:^(NSNumber *collectId) {
        [hud hideHud];
        
        NSMutableArray *Marray = [NSMutableArray arrayWithCapacity:self.dataSource.count];
        Marray = [self.dataSource mutableCopy];
        [Marray removeObjectAtIndex:indexPath.section];
        self.dataSource = Marray.mutableCopy;
        
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
        
    } failure:^(NSError *error) {
        [hud showText:error.localizedFailureReason];
    }];
 
}
@end
