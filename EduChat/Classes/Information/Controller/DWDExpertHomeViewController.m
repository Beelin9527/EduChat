//
//  DWDExpertHomeViewController.m
//  EduChat
//
//  Created by Catskiy on 16/8/10.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDExpertHomeViewController.h"
#import "DWDInfoDetailViewController.h"
#import "DWDLoginViewController.h"
#import "DWDInformationDataHandler.h"
#import "DWDInfoExpertModel.h"
#import "DWDCommendModel.h"
#import "DWDInfoExpArticleCell.h"
#import "DWDInfoTitleCell.h"
#import "DWDUtilityFunc.h"
#import <MJRefresh.h>
#import "UMSocial.h"
#import "KxMenu.h"

#import <SDVersion.h>

@interface DWDExpertHomeViewController () <UMSocialUIDelegate>

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UILabel *nameLbl;
@property (nonatomic, strong) UILabel *tagLbl;
@property (nonatomic, strong) UILabel *signLbl;
@property (nonatomic, strong) UILabel *subsNumLbl;
@property (nonatomic, strong) UILabel *introduceLbl;
@property (nonatomic, strong) UIButton *collectBtn;
@property (nonatomic, strong) UIImageView *headerImgV;
@property (nonatomic, strong) UIImageView *avatarImgV;
@property (nonatomic, strong) UIBarButtonItem *moreBarBtn;
@property (nonatomic, strong) UIBarButtonItem *shareBarBtn;
@property (nonatomic, strong) UIBarButtonItem *colBarBtn;

@property (nonatomic, strong) DWDInfoExpertModel *expert;
@property (nonatomic, assign) NSInteger index;

/**
 *  收藏是否需要回调，此属性是防止用户重新收藏、取消，导致列表出问题，默认NO
 */
@property (nonatomic, getter=isCollectCallBlackFalg, assign) BOOL collectCallBlackFalg;

@end

@implementation DWDExpertHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setNavBar];
    
    [self setSubviews];
    
    [self requestData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.isCollectCallBlackFalg) {
        //collect call back
        self.collectCancleBlock ? self.collectCancleBlock(self.expert.collectId) : nil;
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBar.shadowImage = nil;
}

- (void)setSubviews
{
    // headerView
    _headerView = [[UIView alloc] init];
    _headerView.frame = CGRectMake(0, 0, DWDScreenW, 250.0);
    
    _headerImgV = [[UIImageView alloc] init];
    _headerImgV.frame = CGRectMake(0, 0, DWDScreenW, 250);
    _headerImgV.image = [UIImage imageNamed:@"bg_Introduction"];
    _headerImgV.contentMode = UIViewContentModeScaleAspectFill;
    _headerImgV.layer.masksToBounds = YES;
    [_headerView addSubview:_headerImgV];
    
    UIView *avatarBack = [[UIView alloc] init];
    avatarBack.frame = CGRectMake((DWDScreenW - 105.0) * 0.5, 18.0, 105.0, 105.0);
    avatarBack.backgroundColor = UIColorFromRGBWithAlpha(0xFFFFFF, 0.2);
    avatarBack.layer.masksToBounds = YES;
    avatarBack.layer.cornerRadius = 105.0 * 0.5;
    [_headerView addSubview:avatarBack];
    
    _avatarImgV = [[UIImageView alloc] init];
    _avatarImgV.frame = CGRectMake(avatarBack.x + 2.5, avatarBack.y + 2.5, 100.0, 100.0);
    _avatarImgV.layer.masksToBounds = YES;
    _avatarImgV.layer.cornerRadius = 100.0 * 0.5;
    _avatarImgV.contentMode = UIViewContentModeScaleAspectFill;
    [_headerView addSubview:_avatarImgV];
    
    _nameLbl = [[UILabel alloc] init];
    _nameLbl.frame = CGRectMake(DWDPaddingMax, CGRectGetMaxY(avatarBack.frame) + 13.0, DWDScreenW - 2 * DWDPaddingMax, 19.0);
    _nameLbl.textColor = [UIColor whiteColor];
    _nameLbl.font = [UIFont systemFontOfSize:19.0];
    _nameLbl.textAlignment = NSTextAlignmentCenter;
    [_headerView addSubview:_nameLbl];
    
    _tagLbl = [[UILabel alloc] init];
    _tagLbl.frame = CGRectMake(DWDPaddingMax, CGRectGetMaxY(_nameLbl.frame) + 8.0, DWDScreenW - 2 * DWDPaddingMax, 14.0);
    _tagLbl.textColor = [UIColor whiteColor];
    _tagLbl.font = DWDFontContent;
    _tagLbl.textAlignment = NSTextAlignmentCenter;
    [_headerView addSubview:_tagLbl];
    
    _signLbl = [[UILabel alloc] init];
    _signLbl.frame = CGRectMake(44.0, CGRectGetMaxY(_tagLbl.frame) + 19.0, DWDScreenW - 2 * 44.0, 35.0);
    _signLbl.textAlignment = NSTextAlignmentCenter;
    _signLbl.textColor = [UIColor whiteColor];
    _signLbl.font = DWDFontContent;
    _signLbl.numberOfLines = 2;
    [_headerView addSubview:_signLbl];
    
    _subsNumLbl = [[UILabel alloc] init];
    _subsNumLbl.frame = CGRectMake(DWDScreenW - DWDPaddingMax - 100.0, 17.0, 100.0, 14.0);
    _subsNumLbl.textColor = [UIColor whiteColor];
    _subsNumLbl.font = DWDFontMin;
    _subsNumLbl.textAlignment = NSTextAlignmentRight;
    [_headerView addSubview:_subsNumLbl];
    
    self.tableViewStyle = UITableViewStyleGrouped;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = _headerView;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 75, 0);
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self requestMoreArticle];
    }];
    _index = 2;
    
    _bottomView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    _bottomView.frame = CGRectMake(0, DWDScreenH - 75.0 - DWDTopHight, DWDScreenW, 75.0);
    _bottomView.hidden = YES;
    [self.view addSubview:_bottomView];
    
    UIButton *subsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    subsBtn.frame = CGRectMake(DWDPaddingMax, (75.0 - 50.0) * 0.5, DWDScreenW - 2 * DWDPaddingMax, 50.0);
    subsBtn.backgroundColor = UIColorFromRGBWithAlpha(0xF69100, 1.0);
    [subsBtn setTitle:@"我要订阅" forState:UIControlStateNormal];
    [subsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    subsBtn.titleLabel.font = [UIFont systemFontOfSize:19.0];
    [subsBtn addTarget:self action:@selector(subsBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    subsBtn.layer.cornerRadius = 25.0;
    [_bottomView addSubview:subsBtn];
}

- (void)setNavBar
{
    self.title = @"个人主页";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    collectBtn.frame = CGRectMake(0, 0, 30.0, 30.0);
    collectBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
    [collectBtn setImage:[UIImage imageNamed:@"ic_collect_normal"] forState:UIControlStateNormal];
    [collectBtn setImage:[UIImage imageNamed:@"ic_collect_selected"] forState:UIControlStateSelected];
    [collectBtn addTarget:self action:@selector(collectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    _collectBtn = collectBtn;
    
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    moreBtn.frame = CGRectMake(0, 0, 25.0, 30.0);
    [moreBtn setImage:[UIImage imageNamed:@"ic_more_normal"] forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(moreBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(0, 0, 25.0, 30.0);
    shareBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 2, 0, -2);
    [shareBtn setImage:[UIImage imageNamed:@"ic_share"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _moreBarBtn = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    _colBarBtn = [[UIBarButtonItem alloc] initWithCustomView:collectBtn];
    _shareBarBtn = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];
    
//    self.navigationItem.rightBarButtonItems = @[_shareBarBtn, _colBarBtn];
    self.navigationItem.rightBarButtonItems = @[_colBarBtn];

}

- (UIView *)footerView
{
    if (!_footerView) {
        _footerView = [[UIView alloc] init];
        
        UIImageView *emptyImgV = [[UIImageView alloc] init];
        emptyImgV.w = 170 * DWDScreenW / 375;
        emptyImgV.h = emptyImgV.w * 0.74;
        emptyImgV.x = (DWDScreenW - emptyImgV.w) * 0.5;
        emptyImgV.y = 22;
        emptyImgV.contentMode = UIViewContentModeScaleAspectFit;
        emptyImgV.image = [UIImage imageNamed:@"img_homepage_null"];
        [_footerView addSubview:emptyImgV];
        
        UILabel *emptyLbl1 = [[UILabel alloc] init];
        emptyLbl1.frame = CGRectMake(emptyImgV.x + DWDPadding, CGRectGetMaxY(emptyImgV.frame) + 23, emptyImgV.w - 2 *DWDPadding, 16 * 2 + 8);
        emptyLbl1.font = ([SDVersion deviceVersion] == iPhone4) || ([SDVersion deviceVersion] == iPhone5) ? DWDFontContent : DWDFontBody;
        emptyLbl1.numberOfLines = 2;
        emptyLbl1.textColor = DWDColorSecondary;
        emptyLbl1.textAlignment = NSTextAlignmentCenter;
        emptyLbl1.text = @"精彩专栏马上更新\n敬请期待哟~";
        [_footerView addSubview:emptyLbl1];
        
        _footerView.frame = CGRectMake(0, 0, DWDScreenW, CGRectGetMaxY(emptyLbl1.frame) + 30);
    }
    return _footerView;
}

#pragma mark - 网络请求
// ----- 首页数据 -----
- (void)requestData
{
    [DWDInformationDataHandler requestGetExpertPerHomepageWithCustId:[DWDCustInfo shared].custId expertId:self.expertId cnt:@10
     
    success:^(DWDInfoExpertModel *expert)
    {
        self.expert = expert;
        if (self.expert.articles.count == 0) {
            self.tableView.mj_footer.hidden = YES;
            self.tableView.tableFooterView = self.footerView;
        }
        [self loadData];
    }
    failure:^(NSError *error)
    {
        [DWDProgressHUD showText:error.localizedFailureReason afterDelay:1];
    }];
}
// ----- 更多文章 -----
- (void)requestMoreArticle
{
    [DWDInformationDataHandler requestGetExpertArticleListWithCustId:[DWDCustInfo shared].custId expertId:_expertId idx:@(_index++) cnt:@10
    
    success:^(NSArray *array)
    {
        [_expert.articles addObjectsFromArray:array];
        array.count == 0 ? [self.tableView.mj_footer endRefreshingWithNoMoreData] : [self.tableView.mj_footer endRefreshing];
        [self.tableView reloadData];
    }
    failure:^(NSError *error)
    {
        [self.tableView.mj_footer endRefreshing];
        [DWDProgressHUD showText:error.localizedFailureReason afterDelay:1];
    }];
}
// ----- 友盟分享 -----
- (void)requestSharkWithType:(NSInteger)type
{
    [DWDInformationDataHandler requestSharkSuccessWithCustId:[DWDCustInfo shared].custId contentCode:@7 shareId:_expertId shareType:@(type) objCode:@"a" platform:nil deviceId:nil phoneNum:nil success:^{
        
    } failure:^{
        
    }];
}

#pragma mark - 加载数据

- (void)loadData
{
//    [_headerImgV sd_setImageWithURL:[NSURL URLWithString:_expert.photoKey] placeholderImage:nil];
    
    [_avatarImgV sd_setImageWithURL:[NSURL URLWithString:_expert.photoKey] placeholderImage:DWDDefault_MeBoyImage];
    
    _nameLbl.text = _expert.name;
    
    _tagLbl.text = [_expert.tags firstObject].name;
    
    _subsNumLbl.text = [NSString stringWithFormat:@"%@已订",_expert.subCnt];
    
    _signLbl.text = _expert.sign;
    _signLbl.h = [_expert.sign boundingRectWithfont:_signLbl.font sizeMakeWidth:_signLbl.w].height;
    
    self.introduceLbl.text = _expert.introduce;
    CGSize size = [_introduceLbl.text boundingRectWithfont:DWDFontContent sizeMakeWidth:DWDScreenW - 2 * DWDPaddingMax];
    _introduceLbl.h = size.height;
    
    // 已订阅,显示更多,隐藏底部订阅按钮
    if (_expert.isSub) {
        self.navigationItem.rightBarButtonItems = @[_moreBarBtn, _colBarBtn];
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }else {
        _bottomView.hidden = NO;
    }
    
    // 已收藏,收藏按钮选中
    if (_expert.isCollect) {
        _collectBtn.selected = YES;
    }
    
    [self.tableView reloadData];
}

- (UILabel *)introduceLbl
{
    if (!_introduceLbl) {
        _introduceLbl = [[UILabel alloc] init];
        _introduceLbl.frame = CGRectMake(DWDPaddingMax, 18.0, DWDScreenW - 2 * DWDPaddingMax, 14.0);
        _introduceLbl.textColor = DWDColorSecondary;
        _introduceLbl.font = DWDFontContent;
        _introduceLbl.numberOfLines = 0;
    }
    return _introduceLbl;
}

#pragma mark - ButtonAction

// ********************************************* 收藏 **************************************** //
- (void)collectBtnAction:(UIButton *)sender
{
    // 未登录,弹出登录界面
    if (![DWDCustInfo shared].isLogin)
    {
        [self pushToLoginViewController];
        return;
    }
    if (_collectBtn.selected)
    {
        // 取消收藏
        [DWDInformationDataHandler requestCollectDelWithCustId:[DWDCustInfo shared].custId collectId:@[_expert.collectId]
         
        success:^(NSNumber *collectCnt)
        {
            _collectCallBlackFalg = YES;
            _collectBtn.selected = NO;
            [DWDProgressHUD showText:@"已取消收藏" afterDelay:1.0];
        }
        failure:^(NSError *error)
        {
            [DWDProgressHUD showText:@"取消收藏失败" afterDelay:1.0];
        }];
    }
    else
    {
        // 添加收藏
        [DWDInformationDataHandler requestCollectAddWithCustId:[DWDCustInfo shared].custId contentCode:@7 contentId:_expert.custId
         
        success:^(NSNumber *collectId)
        {
            _collectCallBlackFalg = NO;
            _collectBtn.selected = YES;
            _expert.collectId = collectId;
            [DWDProgressHUD showText:@"收藏成功" afterDelay:1.0];
        }
        failure:^(NSError *error)
        {
            [DWDProgressHUD showText:@"收藏失败" afterDelay:1.0];
        }];
    }

}

// ********************************************* 分享 **************************************** //
- (void)shareBtnAction:(UIButton *)sender
{
    NSURL *rul = [NSURL URLWithString:@"http://educhat.oss-cn-hangzhou.aliyuncs.com/eduinfo21"];
    
    [UMSocialData defaultData].extConfig.qqData.title = @"QQ分享title";
    [UMSocialData defaultData].extConfig.qzoneData.title = @"Qzone分享title";
    [UMSocialData defaultData].extConfig.qqData.url = @"http://baidu.com";
    [UMSocialData defaultData].extConfig.qzoneData.url =   @"http://baidu.com";
    
    [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://weibo.com/fengjieluoyufeng?refer_flag=1001030101_&is_hot=1";
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = @"http://weibo.com/fengjieluoyufeng?refer_flag=1001030101_&is_hot=1";
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:kUMAppkey
                                      shareText:@"链接有毒"
                                     shareImage:[UIImage imageNamed:@"ic_expression_press"]
                                shareToSnsNames:@[UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToQQ,UMShareToQzone]
                                       delegate:self];

}

// ********************************************* 更多 **************************************** //
- (void)moreBtnAction:(UIButton *)sender
{
    // 未登录,弹出登录界面
    if (![DWDCustInfo shared].isLogin) {
        [self pushToLoginViewController];
        return;
    }
    KxMenuItem *addClassItem = [KxMenuItem menuItem:@"取消订阅" image:[UIImage imageNamed:@"ic_Subscribe"] target:self action:@selector(cancelCollect:)];
    
    CGRect fromRect = sender.frame;
    fromRect.origin.y += 20;
    [KxMenu setTitleFont:DWDFontBody];
    [KxMenu showMenuInView:self.view.window fromRect:fromRect menuItems:@[addClassItem]];
}

// ********************************************* 取消订阅 **************************************** //
- (void)cancelCollect:(UIButton *)sender
{
    [DWDInformationDataHandler requestSubscribeDelWithCustId:[DWDCustInfo shared].custId subId:_expert.subId
     
    success:^(NSDictionary *dict)
    {
        _bottomView.hidden = NO;
        _subsNumLbl.text = [NSString stringWithFormat:@"%d已订",[_subsNumLbl.text intValue] - 1];
        self.navigationItem.rightBarButtonItems = @[ _colBarBtn];
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 75, 0);
//        self.subscribeBlock ? self.subscribeBlock(NO) : nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSubscribeState" object:nil];
        DWDProgressHUD *hud = [DWDProgressHUD showText:@"已取消订阅"];
        [hud hide:YES afterDelay:1.0];

    }
    failure:^(NSError *error)
    {
        [DWDProgressHUD showText:@"取消订阅失败" afterDelay:1.0];
    }];
}

// ********************************************* 添加订阅 **************************************** //
- (void)subsBtnAction:(UIButton *)sender
{
    if (![DWDCustInfo shared].isLogin)
    {
        [self pushToLoginViewController];
        return;
    }
    
    [DWDInformationDataHandler requestSubscribeAddWithCustId:[DWDCustInfo shared].custId contentCode:@7 contentId:_expertId
     
    success:^(NSDictionary *dict)
    {
        _bottomView.hidden = YES;
        _expert.subId = dict[@"data"][@"subId"];
        _subsNumLbl.text = [NSString stringWithFormat:@"%d已订",[_subsNumLbl.text intValue] + 1];
        self.navigationItem.rightBarButtonItems = @[_moreBarBtn, _colBarBtn];
        self.tableView.contentInset = UIEdgeInsetsZero;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSubscribeState" object:nil];
                                                         
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"hadSubscibe"]) {
            [DWDProgressHUD showText:@"已订阅" afterDelay:1.0];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"hadSubscibe"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            UIAlertView *alearView = [[UIAlertView alloc] initWithTitle:@"订阅成功"
                                                                message:@"已自动添加到订阅频道啦~"
                                                               delegate:self
                                                      cancelButtonTitle:@"好哒,知道啦~"
                                                      otherButtonTitles:nil];
            [alearView show];
        }

    }
    failure:^(NSError *error)
    {
        [DWDProgressHUD showText:@"订阅失败" afterDelay:1.0];
    }];
}

- (void)pushToLoginViewController
{
    DWDLoginViewController *vc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDLoginViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDLoginViewController class])];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    navi.navigationBarHidden = YES;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:navi animated:YES completion:nil];
}

#pragma mark - UMScoia
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名 wxtimeline微信朋友圈子  wxsession微信好友 qq qzone
        NSInteger sharkType = 0;
        NSString *string = [[response.data allKeys] objectAtIndex:0];
        if ( [string isEqualToString:@"wxsession"]) {
            sharkType = 1;
        }else if ([string isEqualToString:@"wxtimeline"]){
            sharkType = 2;
        }else if ([string isEqualToString:@"qq"]){
            sharkType = 3;
        }else if ([string isEqualToString:@"qzone"]){
            sharkType = 4;
        }else if ([string isEqualToString:@"weibo"]){
            sharkType = 5;
        };
        //request
        [self requestSharkWithType:sharkType];
    }else{
        
    }
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
        return self.expert.articles.count + 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 32.0;
    }else if (indexPath.section == 0) {
        return self.introduceLbl.h + 32.0;
    }else {
        return 50 + 71*DWDScreenW/375.0;
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
            [cell setTitle:@"专家简介" subTitle:@"" image:[UIImage imageNamed:@"ic_about_professor"]];
        }else {
            [cell setTitle:@"TA的栏目" subTitle:@"" image:[UIImage imageNamed:@"ic_column_professor"]];
        }
        return cell;
        
    }else if (indexPath.section == 0) {
        
        static NSString *ID = @"introCell";
        YGCommonCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[YGCommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell.contentView addSubview:self.introduceLbl];
        return cell;
        
    }else {
        
        static NSString *ID = @"titleCell";
        DWDInfoExpArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        if (!cell) {
            cell = [[DWDInfoExpArticleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        }
        DWDArticleModel *model = self.expert.articles[indexPath.row - 1];
        cell.article = model;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        DWDInfoDetailViewController *vc = [[DWDInfoDetailViewController alloc] init];

        DWDArticleModel *article = self.expert.articles[indexPath.row - 1];
        vc.contentLink = article.contentLink;
        vc.contentCode = @8;
        vc.commendId = article.infoId;
        vc.articleModel = article;
//        vc.expertId = self.expertId;
        vc.expArticleCell = [self.tableView cellForRowAtIndexPath:indexPath];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 0.000001 : 10.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.000001;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [DWDUtilityFunc setHeaderViewDropDownEnlargeImageView:_headerImgV withHeaderView:_headerView withImageViewHeight:250.0 withOffsetY:0 withScrollView:scrollView];
}

@end
