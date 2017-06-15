//
//  DWDInfoRecoViewController.m
//  EduChat
//  推荐
//  Created by Gatlin on 16/8/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDInfoRecoViewController.h"
#import "DWDInfoDetailViewController.h"

#import "DWDBannerView.h"
#import "DWDInformationCell.h"

#import "DWDArticleFrameModel.h"
#import "DWDCommendModel.h"
#import "DWDInfoBannerModel.h"
#import "DWDInformationDataHandler.h"

#import "DWDRefreshGifHeader.h"
#import <MJRefresh/MJRefresh.h>

@interface DWDInfoRecoViewController ()<DWDPageViewDelegate>

@property (strong, nonatomic) DWDBannerView *pageView;
@property (nonatomic, strong) UIView *loadStateView;

@property (nonatomic, strong) NSMutableArray *commendsData;
@property (nonatomic, strong) DWDCommendModel *commendModel;
@property (nonatomic, strong) NSMutableArray *cellFrameModels;

@property (nonatomic, assign) NSInteger index;  //页码


@end

@implementation DWDInfoRecoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* 搜索功能暂时隐藏
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
     initWithTitle:NSLocalizedString(@"Search", nil)
     style:UIBarButtonItemStylePlain
     target:self
     action:@selector(searchBtnClick)];
     */
    
    _index = 1;
    _pageView = [[DWDBannerView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, DWDScreenW/375.0 * 155)];
    _pageView.delegate = self;
    
    self.tableViewStyle = UITableViewStyleGrouped;
     self.tableView.frame = CGRectMake(0, 0, DWDScreenW, DWDScreenH - DWDToolBarHeight - DWDTopHight -  selectViewHeight);
    self.tableView.sectionHeaderHeight = 10.0f;
    self.tableView.tableHeaderView = _pageView;
    self.tableView.showsVerticalScrollIndicator = NO;
    __unsafe_unretained __typeof(self) weakSelf = self;
    
    // header
    DWDRefreshGifHeader *header = [DWDRefreshGifHeader headerWithRefreshingBlock:^{
        [weakSelf requestHomePageInfo];
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
 
    // footer
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        _index += 1;
        [weakSelf requestGetRecoLisWithIndex:_index];
    }];
    
  //request
    [self requestHomePageInfo];
    //加载动画view
    _loadStateView = [self setupStateLoadView];
    [self.view addSubview:_loadStateView];
}

#pragma mark - Getter
- (NSMutableArray *)commendsData
{
    if (!_commendsData) {
        _commendsData = [[NSMutableArray alloc] init];
    }
    return _commendsData;
}
- (NSMutableArray *)cellFrameModels{
    if (!_cellFrameModels) {
        _cellFrameModels = [[NSMutableArray alloc] init];
    }
    return _cellFrameModels;
}
#pragma mark - TableView Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //如果无数据，显示无数据默认页
//    if (self.commendsData.count == 0) {
//        if (self.stateView) {
//             [self.view addSubview:self.stateView];
//        }
//    }
//    else{
//        if ([self.view.subviews containsObject:self.stateView]) {
//            [self.stateView removeFromSuperview];
//            self.stateView = nil;
//        }
//    }
    return self.commendsData.count;
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DWDInformationCell *cell = nil;
    DWDCommendModel *model = self.commendsData[indexPath.row];
    DWDArticleFrameModel *fmodel = self.cellFrameModels[indexPath.row];
    if ([model.contentCode isEqualToNumber:@4]) {
        switch ([model.New.contentType intValue]) {
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
                break;
        }
        
        cell.fmodel = fmodel;
        return cell;
 
    }else if ([model.contentCode isEqualToNumber:@8]){
        switch ([model.article.contentType intValue]) {
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
                break;
        }
        
        cell.fmodel = fmodel;
        return cell;
 
    }else if ([model.contentCode isEqualToNumber:@7]){
        
    }else{
        static NSString *NULLId = @"NULLId";
        UITableViewCell *NULLCel = [tableView dequeueReusableCellWithIdentifier:NULLId];
        if (!NULLCel) {
            NULLCel = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NULLId];
        }
        return NULLCel;
    }
    return nil;
}


#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DWDCommendModel *model = self.commendsData[indexPath.row];
    if ([model.contentCode isEqualToNumber:@4]) {
        DWDInfoDetailViewController *vc = [[DWDInfoDetailViewController alloc] init];
        vc.contentCode = model.contentCode;
        vc.commendId = model.New.infoId;
        vc.contentLink = model.New.contentLink;
        vc.articleModel = model.New;
        vc.articleCell = [self.tableView cellForRowAtIndexPath:indexPath];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([model.contentCode isEqualToNumber:@8]){
        DWDInfoDetailViewController *vc = [[DWDInfoDetailViewController alloc] init];
        vc.contentCode = model.contentCode;
         vc.commendId = model.article.infoId;
        vc.contentLink = model.article.contentLink;
        vc.articleModel = model.article;
        vc.articleCell = [self.tableView cellForRowAtIndexPath:indexPath];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([model.contentCode isEqualToNumber:@7]){
        
    }
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DWDArticleFrameModel *fmodel = self.cellFrameModels[indexPath.row];
    return fmodel.cellHeight;
}


#pragma mark - DWDBannerView Delegate
- (void)bannerViewDidSeleted:(DWDInfoBannerModel *)model
{
   
}

#pragma mark - Request
- (void)requestHomePageInfo
{
   
    [DWDInformationDataHandler requestGetRecoHomePageInfoWithCustId:[DWDCustInfo shared].custId plateCode:@1 cnt:@10 success:^(NSArray *bannersData, NSArray *commendsData, NSArray *cellFrameModels) {
        
        //移除加载view
        if (self.loadStateView) {
            [self.loadStateView removeFromSuperview];
            self.loadStateView = nil;
        }
        
        if ([self.view.subviews containsObject:self.stateView]) {
            [self.stateView removeFromSuperview];
            self.stateView = nil;
        }
        self.index = 1;
        self.pageView.dataSource = bannersData;
        
        [self.commendsData removeAllObjects];
        [self.commendsData addObjectsFromArray:commendsData];
        
        [self.cellFrameModels removeAllObjects];
        [self.cellFrameModels addObjectsFromArray:cellFrameModels];
        

        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
        
        
    } failure:^(NSError *error) {
        
        //移除加载view
        if (self.loadStateView) {
            [self.loadStateView removeFromSuperview];
            self.loadStateView = nil;
        }
        
       [self.tableView.mj_header endRefreshing];
        //数据为空，显示小免崽子图片
        if (!self.stateView) {
            // 小免崽子图片
            self.stateView = [self setupStateViewWithImageName:@"img_loading_fail" describe:@"网络开小差噜" reloadDataBtnEventBlock:^{
                [self requestHomePageInfo];
            }];
            self.stateView.backgroundColor = DWDColorBackgroud;
        }
        [self.view addSubview:self.stateView];
    }];
}

- (void)requestGetRecoLisWithIndex:(NSInteger)index
{
    [DWDInformationDataHandler requestGetRecoListWithCustId:[DWDCustInfo shared].custId plateCode:@1 idx:@(index) cnt:@20 success:^(NSArray *commendsData, NSArray *cellFrameModels, BOOL isHaveData) {
        
        [self.commendsData addObjectsFromArray:commendsData];
        [self.cellFrameModels addObjectsFromArray:cellFrameModels];
        
        if (isHaveData) {
            [self.tableView.mj_footer endRefreshing];
        }else{
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        [self.tableView.mj_footer endRefreshing];
    }];
}
@end
