//
//  DWDInfoExpertListViewController.m
//  EduChat
//  专家排行列表
//  Created by Catskiy on 16/8/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDInfoExpertListViewController.h"
#import "DWDExpertHomeViewController.h"
#import "DWDLoginViewController.h"
#import "DWDExpertListCell.h"
#import "DWDInformationDataHandler.h"
#import "DWDInfoExpertModel.h"
#import <MJRefresh.h>

@interface DWDInfoExpertListViewController ()<DWDInfoExpertCellDelegate>

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) NSMutableArray *dataSources;

@end

@implementation DWDInfoExpertListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _index = 1;
    self.title = self.type == ExpertListTypeNomal ? @"优能专家" : @"已订阅";
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        _index ++;
        [self getData];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:@"updateSubscribeState" object:nil];

    [self getData];
}

- (void)refreshData
{
    _index = 1;
    [self getData];
}

- (void)getData
{
    if (self.type == ExpertListTypeNomal)
    {
        [DWDInformationDataHandler requestGetExpertListWithCustId:[DWDCustInfo shared].custId plateCode:@3 idx:@(_index) cnt:@10 success:^(NSArray *array) {
            
            array.count == 0 ? [self.tableView.mj_footer endRefreshingWithNoMoreData] : [self.tableView.mj_footer endRefreshing];
            if (_index == 1) {  // 刷新
                self.dataSources = [NSMutableArray arrayWithArray:array];
            }else {             // 更多
                [self.dataSources addObjectsFromArray:array];
            }
            [self.tableView reloadData];
            
        } failure:^(NSError *error) {
            [self.tableView.mj_footer endRefreshing];

        }];
    }
    else
    {
        [DWDInformationDataHandler requestGetSubscribeExpertWithCustId:[DWDCustInfo shared].custId plateCode:@4 idx:@(_index) cnt:@10 success:^(NSArray *array) {
            if (_index == 1) {  // 刷新
                self.dataSources = [NSMutableArray arrayWithArray:array];
            }else {             // 更多
                [self.dataSources addObjectsFromArray:array];
            }
            [self.tableView.mj_footer endRefreshing];
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            if(self.dataSources.count == 1) {[self.dataSources removeAllObjects];
                [self.tableView reloadData];
            }
            [self.tableView.mj_footer endRefreshing];
        }];
    }
}

- (NSMutableArray *)dataSources
{
    if (!_dataSources) {
        _dataSources = [NSMutableArray arrayWithCapacity:64];
    }
    return _dataSources;
}

#pragma mark - TableViewDelegate && TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSources.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ExpertCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *ID = @"expertListCell";
    DWDExpertListCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[DWDExpertListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    if (self.type == ExpertListTypeSubsc) {
        cell.style = ExpertListCellStyleSubsc;
    }else {
        cell.style = ExpertListCellStyleNomal;
        cell.delegate = self;
    }
    cell.model = self.dataSources[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DWDExpertHomeViewController *expertHomeVC = [[DWDExpertHomeViewController alloc] init];
    expertHomeVC.expertId = [self.dataSources[indexPath.row] custId];
    [expertHomeVC setSubscribeBlock:^(BOOL isSub) {
        DWDExpertListCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.isSub = isSub;
    }];
    [self.navigationController pushViewController:expertHomeVC animated:YES];
}


#pragma mark - expertCellDelegate

- (void)expertCellDidClickedSubscribeButton:(UIButton *)button WithExpert:(DWDInfoExpertModel *)expert
{
    // 未登录,弹出登录界面
    if (![DWDCustInfo shared].isLogin)
    {
        [self pushToLoginViewController];
        return;
    }
    
    // 已登录,请求订阅
    [DWDInformationDataHandler requestSubscribeAddWithCustId:[DWDCustInfo shared].custId
                                                 contentCode:@7
                                                   contentId:expert.custId
                                                     success:^(NSDictionary *dict)
    {
        button.enabled = NO;
        button.backgroundColor = [UIColor whiteColor];
        expert.isSub = YES;
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"hadSubscibe"])
        {
            // 不是第一次订阅
            [DWDProgressHUD showText:@"已订阅" afterDelay:1];
        }
        else
        {
            // 第一次订阅
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"hadSubscibe"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            UIAlertView *alearView = [[UIAlertView alloc] initWithTitle:@"订阅成功" message:@"已自动添加到订阅频道啦~" delegate:self cancelButtonTitle:@"好哒,知道啦~" otherButtonTitles:nil];
            [alearView show];
        }
    } failure:^(NSError *error) {
        [DWDProgressHUD showText:@"订阅失败" afterDelay:1];
    }];
    
}

- (void)pushToLoginViewController
{
    DWDLoginViewController *vc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDLoginViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDLoginViewController class])];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    navi.navigationBarHidden = YES;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:navi animated:YES completion:nil];
}

@end
