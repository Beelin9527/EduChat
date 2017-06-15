//
//  DWDInfoNewsViewController.m
//  EduChat
//  新闻政策
//  Created by Gatlin on 16/8/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDInfoNewsViewController.h"
#import "DWDInfoDetailViewController.h"

#import "DWDInformationCell.h"

#import "DWDInformationDataHandler.h"
#import "DWDArticleModel.h"
#import "DWDArticleFrameModel.h"
#import "DWDRefreshGifHeader.h"

@interface DWDInfoNewsViewController ()
@property (nonatomic, strong) UIView *loadStateView;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) NSInteger index;  //页码
@end

@implementation DWDInfoNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.frame = CGRectMake(0, 0, DWDScreenW, DWDScreenH - DWDToolBarHeight - DWDTopHight -  selectViewHeight);
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        _index ++;
        [self requestGetNewList];
    }];
    
    DWDRefreshGifHeader *header = [DWDRefreshGifHeader headerWithRefreshingBlock:^{
        _index = 1;
        [self requestGetNewList];
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

   //request
    _index = 1;
    [self requestGetNewList];
    
    //加载动画view
    _loadStateView = [self setupStateLoadView];
    [self.view addSubview:_loadStateView];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
#pragma mark - TableView Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //如果无数据，显示无数据默认页
//    if (self.dataSource.count == 0) {
//        if (self.stateView) {
//            [self.view addSubview:self.stateView];
//        }
//    }
//    else{
//        if ([self.view.subviews containsObject:self.stateView]) {
//            [self.stateView removeFromSuperview];
//            self.stateView = nil;
//        }
//    }
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DWDInformationCell *cell = nil;
    DWDArticleFrameModel *fmodel = self.dataSource[indexPath.row];
    switch ([fmodel.articleModel.contentType integerValue]) {
        case 1:
        {
            cell = [[DWDArticleCell alloc] initArticleCellWithTableView:tableView];
        }
            break;
        case 2:
        {
            cell = [[DWDPhotoCell alloc] initPhotoCellWithTableView:tableView];
        }
            break;
        case 3:
        {
            cell = [[DWDVideoCell alloc] initVideoCellWithTableView:tableView];
        }
            break;
        case 4:
        {
            cell = [[DWDArticleCell alloc] initArticleCellWithTableView:tableView];
        }
            break;
            
        default:
        {
            return nil;
        }
            break;
    }
    
    cell.fmodel = fmodel;
    return cell;
}


#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DWDArticleFrameModel *model = self.dataSource[indexPath.row];
    
    DWDInfoDetailViewController *vc = [[DWDInfoDetailViewController alloc] init];
    vc.contentCode = @4;
    vc.commendId = model.articleModel.infoId;
    vc.contentLink = model.articleModel.contentLink;
    vc.articleModel = model.articleModel;
    vc.articleCell = [self.tableView cellForRowAtIndexPath:indexPath];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DWDArticleFrameModel *fmodel = self.dataSource[indexPath.row];
    return fmodel.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.000001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.000001;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource  = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataSource;
}

#pragma mark - Request
- (void)requestGetNewList
{
    [DWDInformationDataHandler requestGetNewListWithCustId:[DWDCustInfo shared].custId plateCode:@2 idx:@(_index) cnt:@10 success:^(NSArray *newDataSource,BOOL isHaveData) {
        
        //移除加载view
        if (self.loadStateView) {
            [self.loadStateView removeFromSuperview];
            self.loadStateView = nil;
        }
        
        if ([self.view.subviews containsObject:self.stateView]) {
            [self.stateView removeFromSuperview];
            self.stateView = nil;
        }
        if (_index == 1) {
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:newDataSource];

            [self.tableView.mj_header endRefreshing];
            [self.tableView reloadData];
        }else{
            if (isHaveData) {
                [self.tableView.mj_footer endRefreshing];
            }else{
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.dataSource addObjectsFromArray:newDataSource];
            [self.tableView reloadData];

        }
        
    } failure:^(NSError *error) {
        
        //移除加载view
        if (self.loadStateView) {
            [self.loadStateView removeFromSuperview];
            self.loadStateView = nil;
        }
        
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        //数据为空，显示小免崽子图片
        if (!self.stateView) {
            // 小免崽子图片
            self.stateView = [self setupStateViewWithImageName:@"img_loading_fail" describe:@"网络开小差噜" reloadDataBtnEventBlock:^{
                [self requestGetNewList];
            }];
            self.stateView.backgroundColor = DWDColorBackgroud;
        }
        [self.view addSubview:self.stateView];
         
    }];
}
@end
