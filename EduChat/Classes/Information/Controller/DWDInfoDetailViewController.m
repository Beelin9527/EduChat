//
//  DWDInfoDetailViewController.m
//  DWDSj
//
//  Created by apple  on 15/10/30.
//  Copyright © 2015年 dwd. All rights reserved.
//


#import "DWDInfoDetailViewController.h"
#import "DWDLoginViewController.h"
#import "DWDExpertHomeViewController.h"

#import "DWDDetailToolCell.h"
#import "DWDInformationCommentCell.h"
#import "DWDCommentToolView.h"
#import "DWDInformationCell.h"
#import "DWDInfoExpArticleCell.h"

#import "DWDInformationDataHandler.h"
#import "DWDInfomationCommentModel.h"
#import "DWDCommendModel.h"
#import "DWDWebPageModel.h"

#import <WebKit/WebKit.h>
#import "UMSocial.h"
#import <MJRefresh/MJRefresh.h>
@interface DWDInfoDetailViewController ()<WKNavigationDelegate,WKScriptMessageHandler,DWDInformationCommentCellDelegate,  UMSocialUIDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) DWDCommentToolView *commentToolView;
@property (nonatomic, assign) CGFloat lastOffset;
@property (nonatomic, getter=isLoadWebData,assign) BOOL loadWebData;
@property (nonatomic, getter=isClearWebView,assign) BOOL clearWebView;  //标识
@property (nonatomic, assign) NSInteger index;  //页码

@property (nonatomic, strong) NSMutableArray *commentsDataSource;
//@property (nonatomic, strong) DWDVisitStat *visitStatDataSource;

@property (nonatomic, strong) DWDWebPageModel *webPageModel;

@property (nonatomic, strong) UIButton *collectBtn;
@property (nonatomic, strong) UIButton *shareBtn;
/**
 *  收藏是否需要回调，此属性是防止用户重新收藏、取消，导致列表出问题，默认NO
 */
@property (nonatomic, getter=isCollectCallBlackFalg, assign) BOOL collectCallBlackFalg;
@end


@implementation DWDInfoDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"详情";
    self.view.backgroundColor = DWDColorBackgroud;
    
   //默认设置清除webview 标识
    _clearWebView = YES;

  [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_contentLink]]];
    
    _collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _collectBtn.frame = CGRectMake(0, 0, 40.0, 30.0);
    _collectBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    [_collectBtn setImage:[UIImage imageNamed:@"ic_collect_normal"] forState:UIControlStateNormal];
    [_collectBtn setImage:[UIImage imageNamed:@"ic_collect_selected"] forState:UIControlStateSelected];
    [_collectBtn addTarget:self action:@selector(collectAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _shareBtn = shareBtn;
    shareBtn.frame = CGRectMake(0, 0, 30.0, 30.0);
    shareBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 2, 0, -2);
    [shareBtn setImage:[UIImage imageNamed:@"ic_share"] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *colBarBtn = [[UIBarButtonItem alloc] initWithCustomView:_collectBtn];
    UIBarButtonItem *shareBarBtn = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];
    
    self.navigationItem.rightBarButtonItems = @[shareBarBtn, colBarBtn];
    
    [self requestWebPage];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.commentToolView.hidden = NO;
    _clearWebView = YES;
}


- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    [self.commentToolView endEditing:YES];
    self.commentToolView.hidden = YES;
    
    if (self.isCollectCallBlackFalg) {
        //collect call back
        self.collectCancleBlock ? self.collectCancleBlock(self.webPageModel.collectId) : nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.isClearWebView) {
         [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
    }
   
}
- (void)dealloc
{
    
    [self.commentToolView removeFromSuperview];
}

- (void)setupControl
{
    self.tableViewStyle = UITableViewStyleGrouped;
     self.tableView.frame = CGRectMake(0, 0, DWDScreenW, DWDScreenH - DWDTopHight);
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[DWDInformationCommentCell class] forCellReuseIdentifier:@"commentCell"];
    
    self.commentToolView.praiseSta = [self.webPageModel.visitStat.praiseSta boolValue];
    [self.view addSubview:self.commentToolView];
    
    __weak typeof(self) weakSelf = self;
    self.commentToolView.praiseActionBlock = ^(UIButton *praiseBtn){
        //request parise
        if ([weakSelf.webPageModel.visitStat.praiseSta boolValue]) {
            [weakSelf requestPraiseDel:praiseBtn];
        }else{
            if (![DWDCustInfo shared].custId) {
                [weakSelf gotoLogin];
                return;
            }
            [weakSelf requestPraiseAdd:praiseBtn];
        }
    };
    
    self.commentToolView.beginEnditingActionBlock = ^{
        if (![DWDCustInfo shared].custId) {
            //go login
            [weakSelf gotoLogin];
        }
    };
    self.commentToolView.sendTextActionBlock = ^(NSString *content, DWDInfomationCommentModel *commentModel){
        //request comment add
        [weakSelf requestCommentAddWithTextView:content commentModel:commentModel];
    };
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf.tableView.mj_footer beginRefreshing];
        _index += 1;
        [self requestLoadCommentDataWithIndex:_index];
    }];
}

#pragma mark - Getter
- (WKWebView *)webView
{
    if (!_webView) {
        
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        [config.userContentController addScriptMessageHandler:self name:@"intoExpertDetail"];
        config.allowsInlineMediaPlayback = YES;
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
        _webView.scrollView.scrollEnabled = NO;
        _webView.scrollView.bounces = NO;
        _webView.navigationDelegate = self;
       
    }
    return _webView;
}

- (DWDCommentToolView *)commentToolView
{
    if (!_commentToolView) {
        _commentToolView = [[DWDCommentToolView alloc] initWithFrame:CGRectMake(0, DWDScreenH - DWDTopHight - 50, DWDScreenW, 300)];
//         _commentToolView = [[DWDCommentToolView alloc] initWithFrame:CGRectMake(0, DWDScreenH - DWDTopHight - 50, DWDScreenW, 50)];
    }
    return _commentToolView;
}

- (NSMutableArray *)commentsDataSource
{
    if (!_commentsDataSource) {
        _commentsDataSource = [NSMutableArray arrayWithCapacity:10];
    }
    return _commentsDataSource;
}
#pragma mark - Event Response
- (void)collectAction:(UIButton *)sender
{
    if (![DWDCustInfo shared].custId) {
        [self gotoLogin];
        return;
    }
   //reqeust
    [self requestCollect];
}
- (void)shareAction
{
    if (![DWDCustInfo shared].custId) {
        //go login
        [self gotoLogin];
        return;
    }
    
    
    self.shareBtn.selected = YES;
    UIImage *shareImgDefult = [UIImage imageNamed:@"img_logo"];
    UIImage *shareImg;
    if (_webPageModel.topic.length > 0) {
        shareImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_webPageModel.topic]]];
    }
    
    [UMSocialData defaultData].extConfig.qqData.title = _webPageModel.title;
    [UMSocialData defaultData].extConfig.qqData.url = _webPageModel.shareLink;
    
    [UMSocialData defaultData].extConfig.qzoneData.title = _webPageModel.title;
    [UMSocialData defaultData].extConfig.qzoneData.url = _webPageModel.shareLink;
    
    [UMSocialData defaultData].extConfig.wechatSessionData.title = _webPageModel.title;
    [UMSocialData defaultData].extConfig.wechatSessionData.url = _webPageModel.shareLink;
    
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = _webPageModel.title;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = _webPageModel.shareLink;
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:kUMAppkey
                                      shareText:_webPageModel.summary
                                     shareImage:shareImg ? shareImg : shareImgDefult
                                shareToSnsNames:@[UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,UMShareToQzone]
                                       delegate:self];
  
     [self commentToolViewWithHidden:YES];
}

#pragma mark - Private Method
/** 评论框动画 */
- (void)commentToolViewWithHidden:(BOOL)bol
{
    if (bol) {
        if (self.commentToolView.y != DWDScreenH) {
            [UIView animateWithDuration:0.25 animations:^{
                self.commentToolView.y = DWDScreenH - DWDTopHight;
            }];
        }
        
    }else{
        if (self.commentToolView.y != DWDScreenH - 50) {
            [UIView animateWithDuration:0.25 animations:^{
                self.commentToolView.y = DWDScreenH - DWDTopHight -50;
            }];
        }
    }
}

/** 点赞动画 */
- (CAKeyframeAnimation *)buttonAnimation
{
    CAKeyframeAnimation *animation0 = [CAKeyframeAnimation animation];
    animation0.keyPath = @"transform.scale";
    animation0.values = @[@0.6f, @1.0f, @1.2f, @1.0f, @0.8f, @1.0f];
    animation0.duration = 0.25f;
    animation0.repeatCount = 0;
    animation0.removedOnCompletion = YES;
    
    return animation0;
}

- (void)gotoLogin
{
    _clearWebView = NO;
    DWDLoginViewController *vc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDLoginViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDLoginViewController class])];
    
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    navi.navigationBarHidden = YES;
   
    [self presentViewController:navi animated:YES completion:nil];
    
}

#pragma mark - WKNavigationDelegate 
- (void)webView:(WKWebView*)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    [webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id  height, NSError * _Nullable error) {
        DWDLog(@"%zd", [height integerValue]);
        
        //标识已加载
        _loadWebData = YES;
        [self setupControl];
        
        self.webView.frame = CGRectMake(0, 0, DWDScreenW, [height floatValue]);
        self.tableView.tableHeaderView = self.webView;
        [self.tableView reloadData];
        
        //计算关于滚动多少像素弹出评论框
        _lastOffset = 0.0f;
        if((self.tableView.contentSize.height - self.tableView.tableHeaderView.h) >= self.tableView.h){
            self.lastOffset = self.tableView.tableHeaderView.h;
        }else{
            self.lastOffset = self.tableView.tableHeaderView.h - self.tableView.h;
        }
    }];
  }

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    //message.name  js发送的方法名称 跳转专家详情
    if([message.name  isEqualToString:@"intoExpertDetail"])
    {
         _clearWebView = NO;//标识
        if (self.expertId) {
            DWDExpertHomeViewController *vc = [[DWDExpertHomeViewController alloc] init];
            vc.expertId = self.expertId;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}
#pragma mark - TableView Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }else if(section == 1){
        return self.commentsDataSource.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
          DWDDetailToolCell *cell = [DWDDetailToolCell initDetailToolCellWithTableView:tableView];
        cell.visitStat = self.webPageModel.visitStat;
        return cell;
    }else if(indexPath.section == 1){
        
        DWDInformationCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
        
        cell.delegate = self;
        [cell layout:self.commentsDataSource[indexPath.row]];
        return cell;
    }
 
    return nil;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   
    if (![DWDCustInfo shared].custId) {
        [self gotoLogin];
        return;
    }
    
    DWDInfomationCommentModel *model = self.commentsDataSource[indexPath.row];
    
    [self.commentToolView.textView resignFirstResponder];
    if ([model.custId isEqualToNumber:[DWDCustInfo shared].custId]) {
        [self commentToolViewWithHidden:YES];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"是否删除评论" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self requestCommentDelWithCommentId:model.commentId];
        }];
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
           [self commentToolViewWithHidden:NO];
        }];
        [alert addAction:sureAction];
        [alert addAction:cancleAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        [self commentToolViewWithHidden:NO];
        self.commentToolView.textView.placeholderText = [NSString stringWithFormat:@"回复 %@",model.nickname];
        self.commentToolView.commentModel = model;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 81;
    }else{
        DWDInfomationCommentModel *model = self.commentsDataSource[indexPath.row];
        return [model cellHeight];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.001;
    }
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, 10)];
        view.backgroundColor = DWDColorBackgroud;
        return view;
    }
    return nil;
}

#pragma mark - Scroller Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y <= 0) {
        [self commentToolViewWithHidden:NO];
    }else if (scrollView.contentOffset.y < self.lastOffset) {
         [self commentToolViewWithHidden:NO];
    }else if (scrollView.contentOffset.y > self.lastOffset ){
        [self commentToolViewWithHidden:YES];
        [self.commentToolView endEditing:YES];
    }
    self.lastOffset = scrollView.contentOffset.y;
    
    [self.commentToolView.textView resignFirstResponder];
    self.commentToolView.commentModel = nil;
    self.commentToolView.textView.text = nil;
   self.commentToolView.textView.placeholderText = @"写评论，交流下...";
}


- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
     [self commentToolViewWithHidden:NO];
}

#pragma mark - UMScoia Delegate
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

#pragma mark - Request
- (void)requestWebPage
{
    [DWDInformationDataHandler requestWebPageWithCustId:[DWDCustInfo shared].custId contentCode:self.contentCode contentId:self.commendId success:^(DWDWebPageModel *model) {
        self.webPageModel = model;
        self.articleModel.visitStat.readSta = @1;
//        self.articleCell ? self.articleCell.articleModel = self.articleModel : nil;
        self.expArticleCell ? self.expArticleCell.article = self.articleModel : nil;
        // 已收藏
        if ([self.webPageModel.visitStat.collectSta intValue] == 1) {
            self.collectBtn.selected = YES;
        }
        
    } failure:^(NSError *error) {
        
    }];
}
- (void)requestPraiseAdd:(UIButton *)sender
{
    //animation
    [sender.layer addAnimation:[self buttonAnimation] forKey:nil];
    [sender setSelected:YES];
    
    [DWDInformationDataHandler requestPraiseAddWithCustId:[DWDCustInfo shared].custId contentCode:self.contentCode contentId:self.commendId success:^(NSNumber *praiseCnt) {
        
        self.webPageModel.visitStat.praiseSta = @1;
        self.webPageModel.visitStat.praiseCnt = praiseCnt;
        
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(NSError *error) {
        [sender.layer addAnimation:[self buttonAnimation] forKey:nil];
        [sender setSelected:NO];
    }];
}

- (void)requestPraiseDel:(UIButton *)sender
{
     //animation
    [sender.layer addAnimation:[self buttonAnimation] forKey:nil];
    [sender setSelected:NO ];
    
    [DWDInformationDataHandler requestPraiseDelWithCustId:[DWDCustInfo shared].custId contentCode:self.contentCode contentId:self.commendId success:^(NSNumber *praiseCnt) {
     
        self.webPageModel.visitStat.praiseSta = @0;
        self.webPageModel.visitStat.praiseCnt = praiseCnt;
        
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
        [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(NSError *error) {
        [sender.layer addAnimation:[self buttonAnimation] forKey:nil];
        [sender setSelected:YES];
    }];
 
}

// 收藏
- (void)requestCollect
{
    if (_collectBtn.selected) {
        
        // 取消收藏
        [DWDInformationDataHandler requestCollectDelWithCustId:[DWDCustInfo shared].custId collectId:@[self.webPageModel.collectId] success:^(NSNumber *collectCnt) {
            _collectCallBlackFalg = YES;
            _collectBtn.selected = NO;
            [DWDProgressHUD showText:@"已取消收藏" afterDelay:1.0];
            
        } failure:^(NSError *error) {
            [DWDProgressHUD showText:@"取消收藏失败" afterDelay:1.0];
        }];
    }else{
        
        // 添加收藏
        [DWDInformationDataHandler requestCollectAddWithCustId:[DWDCustInfo shared].custId contentCode:self.contentCode contentId:self.commendId success:^(NSNumber *collectId) {
            _collectCallBlackFalg = NO;
            _collectBtn.selected = YES;
            self.webPageModel.collectId = collectId;
            [DWDProgressHUD showText:@"已收藏" afterDelay:1.0];
        } failure:^(NSError *error) {
            [DWDProgressHUD showText:@"收藏失败" afterDelay:1.0];
        }];
    }
}

- (void)requestLoadCommentDataWithIndex:(NSInteger)index
{
    [DWDInformationDataHandler requestCommentListithCustId:[DWDCustInfo shared].custId contentCode:self.contentCode contentId:self.commendId  idx:@(index) cnt:nil success:^(NSArray *dataSource, BOOL isHaveData) {
        if (index == 1) {
            [self.commentsDataSource removeAllObjects];
        }
        [self.commentsDataSource addObjectsFromArray:dataSource];
        if (self.isLoadWebData) {
            if (isHaveData) {
                [self.tableView.mj_footer endRefreshing];
            }else{
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.tableView reloadData];
        }
        
    } failure:^(NSError *error) {
       [DWDProgressHUD showText:error.localizedFailureReason];
    }];
}
- (void)requestCommentAddWithTextView:(NSString *)content commentModel:(DWDInfomationCommentModel *)commentModel
{
   DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:self.view];
    [DWDInformationDataHandler requestCommentAddWithCustId:[DWDCustInfo shared].custId contentCode:self.contentCode contentId:self.commendId commentTxt:content forCustId:commentModel.custId forCommentId:commentModel.commentId success:^(NSNumber *commentCnt) {
        [hud showText:@"评论成功"];
        self.commentToolView.content = nil;
        self.webPageModel.visitStat.commentCnt = commentCnt;
        
        //reload comment Data
        self.index = 1;
        [self requestLoadCommentDataWithIndex:self.index];
  
    } failure:^(NSError *error) {
        [hud showText:error.localizedFailureReason];
    }];
}
- (void)requestCommentDelWithCommentId:(NSNumber *)commentId
{
    DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:self.view];
    [DWDInformationDataHandler requestCommentDelWithCustId:[DWDCustInfo shared].custId  contentCode:self.contentCode contentId:self.commendId commentId:commentId success:
     ^(NSNumber *commentCnt) {
         [hud showText:@"删除成功"];
         self.webPageModel.visitStat.commentCnt = commentCnt;
         
         //reload comment Data
         self.index = 1;
         [self requestLoadCommentDataWithIndex:self.index];
     } failure:^(NSError *error) {
         [hud showText:error.localizedFailureReason];
     }];
}
- (void)requestSharkWithType:(NSInteger)type
{
    [DWDInformationDataHandler requestSharkSuccessWithCustId:[DWDCustInfo shared].custId contentCode:self.contentCode shareId:self.commendId shareType:@(type) objCode:nil platform:nil deviceId:nil phoneNum:nil success:^{
     
    } failure:^{
    
    }];
}
@end
