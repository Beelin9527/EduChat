//
//  DWDInfoSubscribeViewController.m
//  EduChat
//  订阅
//  Created by Catskiy on 16/8/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDInfoSubscribeViewController.h"
#import "DWDExpertHomeViewController.h"
#import "DWDInfoExpertListViewController.h"
#import "DWDInfoDetailViewController.h"
#import "DWDLoginViewController.h"

#import "DWDExpertListCell.h"
#import "DWDInfoTitleCell.h"
#import "DWDInfoSubsExpertCell.h"
#import "DWDInformationCell.h"
#import "DWDSubscribeListCell.h"

#import <MJRefresh.h>
#import "DWDRefreshGifHeader.h"
#import "DWDInformationDataHandler.h"

@interface DWDInfoSubscribeViewController () <DWDInfoExpertCellDelegate>

@property (nonatomic, strong) NSMutableArray *recomData;     // 推荐
@property (nonatomic, strong) NSMutableArray *updateData;    // 更新
@property (nonatomic, strong) NSMutableArray *subscData;     // 订阅
@property (nonatomic, strong) UIView *emptyView;             // 空提示
@property (nonatomic, strong) UIView *loadStateView;
@property (nonatomic, assign) NSInteger subCnt;
@property (nonatomic, assign) BOOL *empty;

@end

@implementation DWDInfoSubscribeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getData) name:@"updateSubscribeState" object:nil];
    
    [self setSubviews];
    
    [self getData];
}

- (void)setSubviews
{
    self.tableView.frame = CGRectMake(0, 0, DWDScreenW, DWDScreenH - DWDTopHight - DWDToolBarHeight - selectViewHeight);
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];
    
    DWDRefreshGifHeader *header = [DWDRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(getData)];
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:8];
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
    [self.view addSubview:_loadStateView];
}

- (void)getData
{
    [DWDInformationDataHandler requestGetSubscribeHomepageWithCustId:[DWDCustInfo shared].custId plateCode:@4 cnt:@10
    success:^(NSArray *subsArray, NSArray *lastArray, NSArray *comArray, NSNumber *subExpCnt) {
        
        //移除加载view
        if (self.loadStateView) {
            [self.loadStateView removeFromSuperview];
            self.loadStateView = nil;
        }
        
        if ([self.view.subviews containsObject:self.stateView]) {
            [self.stateView removeFromSuperview];
            self.stateView = nil;
        }
        self.subscData = [NSMutableArray arrayWithArray:subsArray];
        self.updateData = [NSMutableArray arrayWithArray:lastArray];
        self.recomData = [NSMutableArray arrayWithArray:comArray];
        self.subCnt = [subExpCnt integerValue];
        if (self.subscData.count == 0) {
            self.tableView.tableHeaderView = self.emptyView;
        }else {
            [self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, 10.0)]];
        }
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
            // 小免崽子图片
            self.stateView = [self setupStateViewWithImageName:@"img_loading_fail" describe:@"网络开小差噜" reloadDataBtnEventBlock:^{
                [self getData];
            }];
            self.stateView.backgroundColor = DWDColorBackgroud;
        }
        [self.view addSubview:self.stateView];
    }];
}

- (void)getArticleData
{
    [DWDInformationDataHandler requestGetSubscribeHomepageWithCustId:[DWDCustInfo shared].custId plateCode:@4 cnt:@10
     
     success:^(NSArray *subsArray, NSArray *lastArray, NSArray *comArray, NSNumber *subExpCnt) {
         
         self.updateData = [NSMutableArray arrayWithArray:lastArray];
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
         [self.tableView reloadData];
     } failure:^(NSError *error) {
       
     }];
}

- (NSMutableArray *)subscData
{
    if (!_subscData) {
        _subscData = [NSMutableArray arrayWithCapacity:64];
    }
    return _subscData;
}

- (NSMutableArray *)updateData
{
    if (!_updateData) {
        _updateData = [NSMutableArray arrayWithCapacity:64];
    }
    return _updateData;
}

- (NSMutableArray *)recomData
{
    if (!_recomData) {
        _recomData = [NSMutableArray arrayWithCapacity:64];
    }
    return _recomData;
}

- (UIView *)emptyView
{
    if (!_emptyView) {
        _emptyView = [[UIView alloc] init];
        _emptyView.frame = CGRectMake(0, 0, DWDScreenW, 164.0);
        _emptyView.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageV = [[UIImageView alloc] init];
        imageV.frame = CGRectMake((DWDScreenW - 145.0) * 0.5, 21.0, 145.0, 100.0);
        imageV.image = [UIImage imageNamed:@"img_subscription_empty"];
        [_emptyView addSubview:imageV];
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(DWDPaddingMax, CGRectGetMaxY(imageV.frame) + 8.0, DWDScreenW - 2 * DWDPaddingMax, 12.0);
        label.font = DWDFontMin;
        label.textColor = DWDColorSecondary;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"有点冷清,快点订阅吧~";
        [_emptyView addSubview:label];
    }
    return _emptyView;
}

#pragma mark - TableViewDelegate && TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number;
    if (section == 0) {
        number = self.subscData.count == 0 ? 0 : 2;
    }else if (section == 1) {
        number = self.updateData.count == 0 ? 0 : self.updateData.count;
    }else {
        number = self.recomData.count == 0 ? 0 : self.recomData.count + 1;
    }
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 32;
        }
        return [DWDInfoSubsExpertCell getHeight];
    }else if (indexPath.section == 1) {
        DWDArticleModel *model = self.updateData[indexPath.row];
        return model.height;
    }else {
        if (indexPath.row == 0) {
            return 32;
        }
        return ExpertCellHeight;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.row == 0 && indexPath.section != 1) { // 标题 //2016.11.08 beelin 改，不要问我如何要这样写，我也只是过来改这位仁史的代码，看懂了，才这样下手。你慢慢捊捊
        
        static NSString *ID = @"titleCell";
        DWDInfoTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[DWDInfoTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        if (indexPath.section == 0) {
            [cell setTitle:[NSString stringWithFormat:@"已订阅(%ld)",self.subCnt] subTitle:@"查看全部" image:[UIImage imageNamed:@"ic_Subscribe_information"]];
            [cell setMoreBlock:^{
                DWDInfoExpertListViewController *vc = [[DWDInfoExpertListViewController alloc] init];
                vc.type = ExpertListTypeSubsc;
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }];
        }else  if (indexPath.section == 2){
            [cell setTitle:@"推荐订阅" subTitle:@"" image:[UIImage imageNamed:@"ic_recommend_information"]];
        }
        if (self.subCnt <= 4) {
            [cell hideSubTitle:YES];
        }else {
            [cell hideSubTitle:NO];
        }
        return cell;
    }else if (indexPath.section == 0) { // 已订阅
        
        WEAKSELF;
        static NSString *ID = @"Cell";
        DWDInfoSubsExpertCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[DWDInfoSubsExpertCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        //进专家主页
        [cell setSubsExpertCellBlock:^(NSNumber *expertId) {
            DWDExpertHomeViewController *expHomeVC = [[DWDExpertHomeViewController alloc] init];
            expHomeVC.expertId = expertId;
            expHomeVC.hidesBottomBarWhenPushed = YES;
            [weakSelf.navigationController pushViewController:expHomeVC animated:YES];
        }];
        cell.experts = self.subscData;
        return cell;

    }else if (indexPath.section == 1) { // 最近更新
        DWDArticleModel *model = self.updateData[indexPath.row];
        switch ([model.contentType integerValue]) {
            case 1:
            {
                DWDSubscribeListArticleCell *cell1 = [DWDSubscribeListArticleCell cellWithTableView:tableView];
                cell1.articleModel = model;
                __weak typeof(self) weakSelf = self;;
                [cell1 setComeInExpertInfoBlock:^(DWDArticleModel *model) {
                    DWDExpertHomeViewController *expHomeVC = [[DWDExpertHomeViewController alloc] init];
                    expHomeVC.expertId = model.auth.custId;
                    expHomeVC.hidesBottomBarWhenPushed = YES;
                    [weakSelf.navigationController pushViewController:expHomeVC animated:YES];
                }];
                return cell1;
            }
                break;
            case 2:
            {
                DWDSubscribeListPhotoCell *cell1 = [DWDSubscribeListPhotoCell cellWithTableView:tableView];
                cell1.articleModel = model;
                __weak typeof(self) weakSelf = self;;
                [cell1 setComeInExpertInfoBlock:^(DWDArticleModel *model) {
                    DWDExpertHomeViewController *expHomeVC = [[DWDExpertHomeViewController alloc] init];
                    expHomeVC.expertId = model.auth.custId;
                    expHomeVC.hidesBottomBarWhenPushed = YES;
                    [weakSelf.navigationController pushViewController:expHomeVC animated:YES];
                }];

                return cell1;
            }
                break;
            case 3:
            {
                DWDSubscribeListVideoCell *cell1 = [DWDSubscribeListVideoCell cellWithTableView:tableView];
                cell1.articleModel = model;
                __weak typeof(self) weakSelf = self;;
                [cell1 setComeInExpertInfoBlock:^(DWDArticleModel *model) {
                    DWDExpertHomeViewController *expHomeVC = [[DWDExpertHomeViewController alloc] init];
                    expHomeVC.expertId = model.auth.custId;
                    expHomeVC.hidesBottomBarWhenPushed = YES;
                    [weakSelf.navigationController pushViewController:expHomeVC animated:YES];
                }];

                return cell1;
            }
                break;
            case 4:
            {
                DWDSubscribeListArticleCell *cell1 = [DWDSubscribeListArticleCell cellWithTableView:tableView];
                cell1.articleModel = model;
                __weak typeof(self) weakSelf = self;;
                [cell1 setComeInExpertInfoBlock:^(DWDArticleModel *model) {
                    DWDExpertHomeViewController *expHomeVC = [[DWDExpertHomeViewController alloc] init];
                    expHomeVC.expertId = model.auth.custId;
                    expHomeVC.hidesBottomBarWhenPushed = YES;
                    [weakSelf.navigationController pushViewController:expHomeVC animated:YES];
                }];

                return cell1;

            }
                break;
                
            default:
                return nil;
                break;
        }
    }else {                             // 推荐订阅
        
        static NSString *ID = @"expertListCell";
        DWDExpertListCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[DWDExpertListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        cell.delegate = self;
        cell.model = self.recomData[indexPath.row - 1];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1 )      // 文章详情
    {
        DWDInfoDetailViewController *detailVC = [[DWDInfoDetailViewController alloc] init];
        DWDArticleModel *article = self.updateData[indexPath.row];
        detailVC.contentCode = @8;
        detailVC.commendId = article.infoId;
        detailVC.contentLink = article.contentLink;
        detailVC.articleModel = article;
        detailVC.expertId = article.auth.custId;
        detailVC.articleCell = [self.tableView cellForRowAtIndexPath:indexPath];
        detailVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    else if (indexPath.section == 2 && indexPath.row != 0) // 专家首页
    {
        DWDExpertHomeViewController *expertHomeVC = [[DWDExpertHomeViewController alloc] init];
        DWDInfoExpertModel *expert = self.recomData[indexPath.row - 1];
        expertHomeVC.expertId = expert.custId;
        expertHomeVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:expertHomeVC animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.000001;
    }else if (section == 1) {
        return self.updateData.count == 0 ? 0.000001 :5.0;
    }else {
        return self.subscData.count == 0 && self.updateData.count == 0 ? 0.000001 : 5.0;
    }
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
        CGFloat sectionHeaderHeight = 5;
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
    
    [self.view endEditing:YES];
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
    [DWDInformationDataHandler requestSubscribeAddWithCustId:[DWDCustInfo shared].custId contentCode:@7 contentId:expert.custId success:^(NSDictionary *dict) {
        _subCnt ++;
        if (self.subscData.count == 0)
        {
            [self.tableView beginUpdates];
            [self.tableView setTableHeaderView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, 10.0)]];
            [self.tableView endUpdates];
            [self.subscData addObject:expert];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }
        else
        {
            [self.subscData insertObject:expert atIndex:0];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }
       
        NSUInteger index = [self.recomData indexOfObject:expert];
        DWDLog(@"============================%ld",index);
        if (index >= self.recomData.count) {
            return ;
        }
        [self.recomData removeObjectAtIndex:index];
        if (self.recomData.count == 0)
        {
            [self.tableView reloadData];
            return ;
        }
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index + 1 inSection:2]] withRowAnimation:UITableViewRowAnimationLeft];
        
        // 订阅成功提示
        [self showSubscribeAleart];
        // 请求刷新专家最近文章
        [self getArticleData];
    } failure:^(NSError *error) {
        [DWDProgressHUD showText:@"订阅失败" afterDelay:1];
    }];
}

// 跳转登录界面
- (void)pushToLoginViewController
{
    DWDLoginViewController *vc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDLoginViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDLoginViewController class])];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    navi.navigationBarHidden = YES;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:navi animated:YES completion:nil];
}

// 订阅成功提示
- (void)showSubscribeAleart
{
    // 不是第一次订阅
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"hadSubscibe"])
    {
        [DWDProgressHUD showText:@"已订阅" afterDelay:1];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"hadSubscibe"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        UIAlertView *alearView = [[UIAlertView alloc] initWithTitle:@"订阅成功" message:@"已自动添加到订阅频道啦~" delegate:self cancelButtonTitle:@"好哒,知道啦~" otherButtonTitles:nil];
        [alearView show];
    }
}

@end
