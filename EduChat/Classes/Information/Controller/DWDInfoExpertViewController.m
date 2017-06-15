//
//  DWDInfoExpertViewController.m
//  EduChat
//  专家
//  Created by Catskiy on 16/8/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDInfoExpertViewController.h"
#import "DWDInfoExpertListViewController.h"
#import "DWDExpertHomeViewController.h"
#import "DWDInfoDetailViewController.h"

#import "DWDBannerView.h"
#import "DWDInfoExpertChart.h"
#import "DWDInfoTitleCell.h"
#import "DWDInformationCell.h"
#import "DWDInformationDataHandler.h"
#import "DWDInfoBannerModel.h"
#import "DWDCommendModel.h"
#import "DWDArticleFrameModel.h"
#import "DWDArticleModel.h"
#import "DWDRefreshGifHeader.h"
#import "UIImage+Utils.h"

@interface DWDInfoExpertViewController () <DWDPageViewDelegate>

@property (nonatomic, strong) DWDInfoExpertChart *expertchart;
@property (nonatomic, strong) DWDBannerView *scroHeader;
@property (nonatomic, strong) NSMutableArray *headerDataArray;
@property (nonatomic, strong) NSMutableArray *hotDataArray;
@property (nonatomic, strong) NSMutableArray *expDataArray;
@property (nonatomic, strong) UIView *loadStateView;

@end

@implementation DWDInfoExpertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setSubviews];
    
    [self getData];
}

- (void)setSubviews
{
    _scroHeader = [[DWDBannerView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW,DWDScreenW/375.0 * 155)];
    self.scroHeader.delegate = self;
    self.tableViewStyle = UITableViewStylePlain;
    self.tableView.frame = CGRectMake(0, 0, DWDScreenW, DWDScreenH - DWDToolBarHeight - DWDTopHight - selectViewHeight);
    self.tableView.tableHeaderView = self.scroHeader;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];
    
    DWDRefreshGifHeader *header = [DWDRefreshGifHeader headerWithRefreshingBlock:^{
        [self getData];
    }];
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:64];
    for (int i = 1; i < 8; i ++ ) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"img_loading_%d",i]];
        [images addObject:image];
    }
    [header setImages:images duration:0.5 forState:MJRefreshStateIdle];
    [header setImages:images duration:0.5 forState:MJRefreshStatePulling];
    [header setImages:images duration:0.5 forState:MJRefreshStateRefreshing];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    
    //加载动画view
    _loadStateView = [self setupStateLoadView];
    _loadStateView.backgroundColor = DWDColorBackgroud;
    [self.view addSubview:_loadStateView];

}

- (void)getData
{
    [DWDInformationDataHandler requestGetExpertHomePageWithCustId:[DWDCustInfo shared].custId
                                                        plateCode:@3
                                                              cnt:@10
    success:^(NSArray *banners, NSArray *experts, NSArray *hotArts) {
        
        //移除加载view
        if (self.loadStateView) {
            [self.loadStateView removeFromSuperview];
            self.loadStateView = nil;
        }
        
        if ([self.view.subviews containsObject:self.stateView]) {
            [self.stateView removeFromSuperview];
            self.stateView = nil;
        }
        self.headerDataArray = [NSMutableArray arrayWithArray:banners];
        self.expDataArray = [NSMutableArray arrayWithArray:experts];
        self.hotDataArray = [NSMutableArray arrayWithArray:hotArts];
        self.scroHeader.dataSource = self.headerDataArray;
        self.expertchart.experts = self.expDataArray;
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];

        //移除加载view
        if (self.loadStateView) {
            [self.loadStateView removeFromSuperview];
            self.loadStateView = nil;
        }
        
        if (!self.stateView) {
            //数据为空，显示小免崽子图片
            self.stateView = [self setupStateViewWithImageName:@"img_loading_fail" describe:@"网络开小差噜" reloadDataBtnEventBlock:^{
                [self getData];
            }];
            self.stateView.backgroundColor = DWDColorBackgroud;
        }
        [self.view addSubview:self.stateView];
    }];
}

- (DWDInfoExpertChart *)expertchart
{
    if (!_expertchart) {
        WEAKSELF;
        _expertchart = [[DWDInfoExpertChart alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, [DWDInfoExpertChart getExpertChartHeight])];
        [_expertchart setBlock:^(NSInteger index) {
            DWDExpertHomeViewController *expertHomeVC = [[DWDExpertHomeViewController alloc] init];
            expertHomeVC.expertId = [weakSelf.expDataArray[index] custId];
            expertHomeVC.hidesBottomBarWhenPushed = YES;
            [weakSelf.navigationController pushViewController:expertHomeVC animated:YES];
        }];
    }
    return _expertchart;
}

#pragma mark - TableViewDelegate && TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }else {
        return self.hotDataArray.count + 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 32.0;
    }else {
        if (indexPath.section == 0) {
            return [DWDInfoExpertChart getExpertChartHeight];
        }else {
            DWDArticleFrameModel *model = self.hotDataArray[indexPath.row - 1];
            return model.cellHeight;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        static NSString *ID = @"titleCell";
        DWDInfoTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[DWDInfoTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        if (indexPath.section == 0) {
            WEAKSELF;
            [cell setTitle:@"订阅排行榜" subTitle:@"更多" image:[UIImage imageNamed:@"ic_top_information"]];
            [cell setMoreBlock:^{
                DWDInfoExpertListViewController *expertListVC = [[DWDInfoExpertListViewController alloc] init];
                expertListVC.hidesBottomBarWhenPushed = YES;
                [weakSelf.navigationController pushViewController:expertListVC animated:YES];
            }];
        }else {
            [cell setTitle:@"热门" subTitle:@"" image:[UIImage imageNamed:@"ic_hot_information"]];
        }
        
        return cell;
        
    }else if (indexPath.section == 0) {
        
        static NSString *ID = @"expertCell";
        YGCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[YGCommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        [cell addSubview:self.expertchart];
        return cell;

    }else {
        
        DWDInformationCell *cell = nil;
        DWDArticleFrameModel *model = self.hotDataArray[indexPath.row - 1];
        switch ([model.articleModel.contentType integerValue]) {
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
        cell.fmodel = model;;
        return cell;

    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row != 0)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        DWDInfoDetailViewController *vc = [[DWDInfoDetailViewController alloc] init];
        DWDArticleFrameModel *model = self.hotDataArray[indexPath.row - 1];
        vc.contentCode = @8;
        vc.commendId = model.articleModel.infoId;
        vc.contentLink = model.articleModel.contentLink;
        vc.articleModel = model.articleModel;
        vc.expertId = model.articleModel.auth.custId;
        vc.articleCell = [self.tableView cellForRowAtIndexPath:indexPath];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.000001;
}
//设置区头颜色
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
    v.backgroundView.backgroundColor = DWDColorBackgroud;
}

#pragma mark - scrollView delegate
//delete UItableview headerview黏性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView)
    {
        CGFloat sectionHeaderHeight = 10;
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
    
    [self.view endEditing:YES];
}

#pragma mark - DWDBannerView Delegate
- (void)bannerViewDidSeleted:(DWDInfoBannerModel *)model
{
    DWDLogFunc;
}

@end
