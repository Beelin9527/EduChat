//
//  DWDGrowUpViewController.m
//  EduChat
//
//  Created by KKK on 16/4/5.
//  Copyright © 2016年 dwd. All rights reserved.
//
#define kBottomFieldComment @"comment"
#define kBottomFieldReply @"reply"

#define kForCustId @"forCustId"
#define kForNickname @"forNickname"


#import "DWDGrowUpViewController.h"
//#import "DWDCommonImagePikerController.h"
#import "DWDPersonDataViewController.h"

//#import "JFImagePickerController.h"
#import "KKAlbumsListController.h"

#import "DWDGrowUpUploadController.h"
//#import "DWDGrowUpRecordUploadRecordController.h"
#import "DWDPhotosHelper.h"

#import "DWDAutoIncreaseTextView.h"
#import "DWDImagesScrollView.h"

#import "DWDGrowUpCell.h"
#import "DWDGrowUpCellLayout.h"
#import "DWDGrowUpModel.h"
#import "DWDClassModel.h"

#import "DWDIntelligentOfficeDataHandler.h"

#import <YYModel.h>
#import <Masonry.h>
#import <MJRefresh.h>
#import <UIImageView+WebCache.h>
#import <SDImageCache.h>
#import <SDWebImageManager.h>



@interface DWDGrowUpViewController () <UITableViewDataSource, UITableViewDelegate, DWDGrowUpCellDelegate, DWDAutoIncreaseTextViewDelegate, UIImagePickerControllerDelegate, KKAlbumsListControllerDelegate, DWDGrowUpUploadControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) DWDAutoIncreaseTextView *autoIncreaseTextView;

@property (nonatomic, weak) UIView *headerViewContainer;
@property (nonatomic, weak) UIView *smallContainer;
@property (nonatomic, weak) UIImageView *backgroundImageView;

@property (nonatomic, strong) NSMutableArray *layoutArray;
@property (nonatomic, strong) DWDGrowUpCellLayout *selectedLayout;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign, getter=isStatusBarHidden) BOOL statusBarHidden;

@property (nonatomic, assign) NSInteger pickerTag;

@property (nonatomic, assign) CGFloat contentOffsetY;
@property (nonatomic , strong) UIImageView *noDataImageView;

// sdwebimage 的下载模式
@property (nonatomic, assign) NSInteger kk_SDWebImageManagerOriginExecutionOrder;
@end
@implementation DWDGrowUpViewController
#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
//#error 清缓存
//    [[SDImageCache sharedImageCache] clearDisk];
//    [[SDImageCache sharedImageCache] clearMemory];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.tableView registerClass:[DWDGrowUpCell class] forCellReuseIdentifier:@"DWDGrowUpCell"];
    
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = self.myClass.className;
    
    /*
     刷新控件
     **/
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadNewDataAndCalculateLayout)];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDataAndCalculateLayout)];
    [self.tableView.mj_header beginRefreshing];
    /*
     顶部headerView
     **/
    [self setUpHeaderView];
    /*
     底部键盘
     */
    [self setUpBottomTextField];
    
    //检测此菜单功能是否点击过,key为menuCode
    NSString *key = [NSString stringWithFormat:@"%@-%@", [DWDCustInfo shared].custId, kDWDIntMenuCodeClassManagementGrowth];
    NSString *obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (!obj) {
        [self requestGetAlertWithMenuCode:kDWDIntMenuCodeClassManagementGrowth];
    }

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
   
        //添加监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //change SDWebImageManagerMode
   _kk_SDWebImageManagerOriginExecutionOrder = [[SDWebImageManager sharedManager] imageDownloader].executionOrder;
    [[[SDWebImageManager sharedManager] imageDownloader] setExecutionOrder:SDWebImageDownloaderLIFOExecutionOrder];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.noDataImageView.center = CGPointMake(self.tableView.center.x, pxToH(480) + pxToW(320));
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:DWDColorMain] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    self.navigationController.navigationBar.hidden = NO;
    self.statusBarHidden = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    //restore SDWebImageManagerMode
    [[[SDWebImageManager sharedManager] imageDownloader] setExecutionOrder:_kk_SDWebImageManagerOriginExecutionOrder];
}

- (BOOL)prefersStatusBarHidden {
    return self.isStatusBarHidden;
}

#pragma mark - Network Request
//下拉刷新
- (void)reloadNewDataAndCalculateLayout {
    _pageIndex = 1;
    
    
    WEAKSELF;
    [[HttpClient sharedClient] getGrowUpRequestWithClassId:self.myClass.classId custId:[DWDCustInfo shared].custId pageIndex:_pageIndex success:^(NSURLSessionDataTask *task, id responseObject) {
        DWDMarkLog(@"获取成功");
        [weakSelf.layoutArray removeAllObjects];
        NSArray *dataArray = [NSArray yy_modelArrayWithClass:[DWDGrowUpModel class] json:responseObject[@"data"][@"photos"]];
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            for (DWDGrowUpModel *model in dataArray) {
                DWDGrowUpCellLayout *layout = [[DWDGrowUpCellLayout alloc] initWithModel:model];
                [weakSelf.layoutArray addObject:layout];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
                [weakSelf.tableView.mj_header endRefreshing];
                if (!dataArray.count) {
                    [weakSelf.tableView addSubview:weakSelf.noDataImageView];
                } else {
                    [weakSelf.noDataImageView removeFromSuperview];
                }
            });
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //        [DWDProgressHUD showText:error.userInfo[@"NSLocalizedFailureReason"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            if ([[HttpClient sharedClient].reachabilityManager isReachable] == NO) {
                hud.labelText = @"无网络";
            } else {
                hud.labelText = error.userInfo[@"NSLocalizedFailureReason"];
            }
            [hud hide:YES afterDelay:1.5f];
            [weakSelf.tableView.mj_header endRefreshing];
            if (!weakSelf.layoutArray.count) {
                [weakSelf.tableView addSubview:weakSelf.noDataImageView];
            }
        });
    }];
}


//上拉加载
- (void)loadMoreDataAndCalculateLayout {
    _pageIndex += 1;
    WEAKSELF;
    [[HttpClient sharedClient] getGrowUpRequestWithClassId:self.myClass.classId custId:[DWDCustInfo shared].custId pageIndex:_pageIndex success:^(NSURLSessionDataTask *task, id responseObject) {
        //          responseObject[@"data"][@"photos"] 结果数组
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            DWDMarkLog(@"获取成功");
            
            NSArray *dataArray = responseObject[@"data"][@"photos"];
            for (int i = 0; i < dataArray.count; i ++) {
                DWDGrowUpCellLayout *layout = [[DWDGrowUpCellLayout alloc] initWithModel:[DWDGrowUpModel yy_modelWithJSON:dataArray[i]]];
                [weakSelf.layoutArray addObject:layout];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
                [weakSelf.tableView.mj_footer endRefreshing];
            });
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        weakSelf.pageIndex -= 1;
        DWDMarkLog(@"获取失败");
        [DWDProgressHUD showText:@"暂无新消息"];
        [weakSelf.tableView.mj_footer endRefreshing];
    }];
}

#pragma mark - Private Method
- (void)setUpBottomTextField {
    DWDAutoIncreaseTextView *textView = [DWDAutoIncreaseTextView new];
    textView.frame = CGRectMake(0, DWDScreenH, DWDScreenW, 50);
    textView.delegate = self;
    _autoIncreaseTextView = textView;
    [self.view addSubview:textView];
}

- (void)setUpHeaderView {
    UIView *container = [[UIView alloc] init];
    
    _headerViewContainer = container;
    UIImageView *backGroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, pxToH(400))];
    backGroundView.contentMode = UIViewContentModeScaleAspectFill;
    UIImage *backgroundImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:[self headerImageName]];
    if (!backgroundImage) {
        backgroundImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[self headerImageName]];
    }
    if (!backgroundImage) {
        backgroundImage = [UIImage imageNamed:@"img_defaultphoto"];
    }
    backGroundView.image = backgroundImage;
    backGroundView.userInteractionEnabled = YES;
    backGroundView.clipsToBounds = YES;
    
    [backGroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroundView:)]];
    
    _backgroundImageView = backGroundView;
    [container addSubview:backGroundView];
    
    
    UIImageView *iconView = [[UIImageView alloc] init];

    [iconView sd_setImageWithURL:[NSURL URLWithString:self.myClass.photoKey] placeholderImage:[UIImage imageNamed:@"MSG_Class_Home_HP"]];
    [backGroundView addSubview:iconView];

    
    UIView *smallContainer = [[UIView alloc] init];
    smallContainer.backgroundColor = [UIColor whiteColor];
    _smallContainer = smallContainer;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSAttributedString *attrTitle = [[NSAttributedString alloc] initWithString:@"说点什么吧.." attributes:
  @{
    NSFontAttributeName : [UIFont systemFontOfSize:14],
    NSForegroundColorAttributeName : DWDColorSecondary,
    }];
    [btn setAttributedTitle:attrTitle forState:UIControlStateNormal];
    [btn.titleLabel setTextAlignment:NSTextAlignmentLeft];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [btn setTitleColor:DWDRGBColor(153, 153, 153) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(addNewGrowUpRecordButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [smallContainer addSubview:btn];
    
    UIButton *photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoBtn setBackgroundImage:[UIImage imageNamed:@"ic_shooting_class_dialogue_pages_normal"] forState:UIControlStateNormal];
    [photoBtn addTarget:self action:@selector(captureAddNewRecordButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [smallContainer addSubview:photoBtn];
    
    [container addSubview:smallContainer];
    
    [iconView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(iconView.superview.bottom).offset(-pxToH(89));
        make.width.equalTo(@(pxToW(120)));
        make.height.equalTo(@(pxToH(120)));
        make.centerX.equalTo(iconView.superview.centerX);
    }];
    
    [smallContainer makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(smallContainer.superview.left);
        make.right.equalTo(smallContainer.superview.right);
        make.top.equalTo(backGroundView.bottom);
        make.height.equalTo(@(pxToH(80)));
    }];
    
    [btn makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(btn.superview.left).offset(pxToW(20));
        make.centerY.equalTo(btn.superview.centerY);
        make.width.equalTo(@(DWDScreenW - pxToW(106)));
    }];
    
    //62 * 56
    [photoBtn makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(photoBtn.superview.right).offset(-pxToW(11));
        make.centerY.equalTo(photoBtn.superview.centerY);
        make.width.mas_equalTo(31);
        make.height.mas_equalTo(28);
    }];
    
    container.h = pxToH(480);
    
//    self.tableView.tableHeaderView = container;
    [self.tableView setTableHeaderView:container];
}

- (void)reloadRowWithIndex:(NSIndexPath *)indexPath {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [(DWDGrowUpCellLayout *)(self.layoutArray[indexPath.row]) layout];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        });
    });
}

- (NSString *)headerImageName {
    return [@"com.dwd-sj.GrowUpRecordBackgroundImageURL" stringByAppendingString:[NSString stringWithFormat:@"_%@_%@", [DWDCustInfo shared].custId, self.myClass.classId]];
}

- (void)pushToUploadControllerWithPhotosArray:(NSArray *)array {
    DWDGrowUpUploadController *vc = [[DWDGrowUpUploadController alloc] initWithPhotosArray:array];
    vc.delegate = self;
    vc.albumId = _myClass.albumId;
    
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Event Response
- (void)tapBackgroundView:(UITapGestureRecognizer *)tap{
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"您需要更换封面背景图片吗?" message:@"请选择:" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[DWDPrivacyManager shareManger] needPrivacy:DWDPrivacyTypePhotoLibrary withController:self authorized:^{
            UIImagePickerController *imagePiker = [[UIImagePickerController alloc] init];
            self.pickerTag = 1;
            imagePiker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            __weak id weakSelf = self;
            imagePiker.delegate = weakSelf;
            [self presentViewController:imagePiker animated:YES completion:nil];
        }];
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"拍一张" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[DWDPrivacyManager shareManger] needPrivacy:DWDPrivacyTypeCamera withController:self authorized:^{
            UIImagePickerController *imagePiker = [[UIImagePickerController alloc] init];
            self.pickerTag = 2;
            imagePiker.sourceType = UIImagePickerControllerSourceTypeCamera;
            __weak id weakSelf = self;
            imagePiker.delegate = weakSelf;
            [self presentViewController:imagePiker animated:YES completion:nil];
        }];
    }];
    
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消"
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        DWDLog(@"取消");
                                                    }];
    
    [alertVc addAction:action1];
    [alertVc addAction:action2];
    [alertVc addAction:action3];
    [self presentViewController:alertVc animated:YES completion:nil];
}

- (void)addNewGrowUpRecordButtonClick:(UIButton *)sender {
    DWDLogFunc;
//    JFImagePickerController *picker = [[JFImagePickerController alloc] initWithRootViewController:self];
//    picker.pickerDelegate = self;
    [[DWDPrivacyManager shareManger] needPrivacy:DWDPrivacyTypePhotoLibrary withController:self authorized:^{
        KKAlbumsListController *vc = [[KKAlbumsListController alloc] initWithMaxCount:9];
        vc.delegate = self;
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
        navi.navigationItem.backBarButtonItem.title = @"所有照片";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self presentViewController:navi animated:YES completion:nil];
        });
    }];
}

- (void)captureAddNewRecordButtonClick:(UIButton *)sender {
    [[DWDPrivacyManager shareManger] needPrivacy:DWDPrivacyTypeCamera withController:self authorized:^{
        UIImagePickerController *vc = [UIImagePickerController new];
        self.pickerTag = 3;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            vc.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            return;
        }
        vc.delegate = self;
        [self presentViewController:vc animated:YES completion:^{
        }];
    }];
}

- (void)keyboardWillShow:(NSNotification *)note{
    CGRect endFrame = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat height = endFrame.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        _autoIncreaseTextView.y = DWDScreenH - height - _autoIncreaseTextView.h;
        [self.tableView setContentOffset:CGPointMake(0, _contentOffsetY - _autoIncreaseTextView.y) animated:YES];
    }];
}

- (void)keyboardWillHide:(NSNotification *)note{
    [UIView animateWithDuration:0.25 animations:^{
        _autoIncreaseTextView.y = DWDScreenH;
    }];
    
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.layoutArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DWDGrowUpCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DWDGrowUpCell"];
    [cell setLayout:_layoutArray[indexPath.row]];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_layoutArray[indexPath.row] totalHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kCellPadding;
}

#pragma mark - UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - DWDBottomTextFieldDelegate
- (void)autoIncreaseTextViewDidEndEditing:(DWDAutoIncreaseTextView *)textView {

//    @property (nonatomic, strong) NSNumber *commentId; //评论id
//    
//    @property (nonatomic, strong) NSNumber *custId; //评论人id √
//    @property (nonatomic, copy) NSString *nickname; //评论人名字 √
//    @property (nonatomic, strong) NSNumber *forCustId; //被回复id
//    @property (nonatomic, copy) NSString *forNickname; //被回复名字
//    
//    @property (nonatomic, copy) NSString *photokey; //回复人photokey
//    @property (nonatomic, copy) NSString *commentTxt; //回复内容
//    @property (nonatomic, copy) NSString *addtime; //回复时间
    DWDGrowUpModelComment *modelComment = [DWDGrowUpModelComment new];
    modelComment.custId = [DWDCustInfo shared].custId;
    modelComment.nickname = [DWDCustInfo shared].custNickname;
    modelComment.commentTxt = textView.textView.text;
    
    //    custId	√	long	点赞人id
    //    albumId	√	long	相册id
    //    recordId	√	long	相册记录id
    //    commentTxt	√	String	评论内容
    //    forCustId √   long    为空时直接评论,有值是回复别人
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[DWDCustInfo shared].custId forKey:@"custId"];
    [params setObject:_selectedLayout.model.record.albumId forKey:@"albumId"];
    [params setObject:_selectedLayout.model.record.logId forKey:@"recordId"];
    [params setObject:textView.textView.text forKey:@"commentTxt"];
    if ([textView.type isEqualToString:kBottomFieldReply]) {
        if ([[textView.userInfo allKeys] containsObject:kForCustId] && [[textView.userInfo allKeys] containsObject:kForNickname]) {
            [params setObject:textView.userInfo[kForCustId] forKey:@"forCustId"];
            modelComment.forCustId = textView.userInfo[kForCustId];
            modelComment.forNickname = textView.userInfo[kForNickname];
        } else {
            return;
        }
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在评论";
    [hud show:YES];
    WEAKSELF;
    [[HttpClient sharedClient] postGrowUpCommentWithParams:params success:^(NSURLSessionDataTask *task, id responseObject) {
        textView.textView.text = nil;
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"评论成功";
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud show:YES];
            [hud hide:YES afterDelay:1.0f];
        });
        
        DWDMarkLog(@"评论成功");
        /*
         模拟插入数据
         */
        NSUInteger index = [weakSelf.layoutArray indexOfObject:weakSelf.selectedLayout];
        if (index != NSNotFound) {
//            NSMutableArray<DWDGrowUpModelComment *> *comments = [[NSMutableArray alloc] initWithArray:weakSelf.selectedLayout.model.comments copyItems:YES];
            NSMutableArray<DWDGrowUpModelComment *> *comments = [[[NSMutableArray alloc] initWithArray:weakSelf.selectedLayout.model.comments] mutableCopy];
            [comments addObject:modelComment];
            weakSelf.selectedLayout.model.comments = comments;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [weakSelf reloadRowWithIndex:indexPath];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDMarkLog(@"评论失败");
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"评论失败";
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud show:YES];
            [hud hide:YES afterDelay:1.0f];
        });
    }];
}

#pragma mark - DWDGrowUpCellDelegate
/**
 *  点击了赞按钮
 */
- (void)growCellDidClickPraise:(DWDGrowUpCell *)cell {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath == nil) return;
    DWDGrowUpCellLayout *layout = _layoutArray[indexPath.row];
    _selectedLayout = layout;
    DWDGrowUpModel *model = layout.model;
    
//    if ([praiseCustId contain:[DWDCustInfo shared].custId]) {
    for (DWDGrowUpModelPraise *praise in model.praises) {
        if ([praise.custId isEqualToNumber:[DWDCustInfo shared].custId]) {
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"已经点过赞啦";
            [hud show:YES];
            [hud hide:YES afterDelay:1.5f];
            return;
        }
    }
    
    WEAKSELF;
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"正在点赞";
    [hud show:YES];
    
    [[HttpClient sharedClient] postGrowUpPraiseWithAlbumId:model.record.albumId custId:[DWDCustInfo shared].custId recordId:model.record.logId success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray<DWDGrowUpModelPraise *> *praises = [[[NSMutableArray alloc] initWithArray:model.praises] mutableCopy];
        DWDGrowUpModelPraise *praise = [DWDGrowUpModelPraise new];
        praise.custId = [DWDCustInfo shared].custId;
        praise.nickname = [DWDCustInfo shared].custNickname;
        if ([model.praises containsObject:praise]) {
            return;
        } else {
            [praises addObject:praise];
        }
        model.praises = praises;
        ((DWDGrowUpCellLayout *)weakSelf.layoutArray[indexPath.row]).model = model;
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud setMode:MBProgressHUDModeText];
            hud.labelText = @"点赞成功";
            [hud hide:YES afterDelay:1.5f];
        });
        [weakSelf reloadRowWithIndex:indexPath];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        DWDMarkLog(@"%@请求失败",);
        DWDMarkLog(@"%s请求失败", __func__);
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud setMode:MBProgressHUDModeText];
            hud.labelText = error.userInfo[@"NSLocalizedFailureReason"];
            [hud hide:YES afterDelay:1.5f];
        });
    }];
}

/**
 *  点击了评论按钮
 */
- (void)growCellDidClickComment:(DWDGrowUpCell *)cell {
    CGRect rect = [cell convertRect:cell.contentView.bounds toView:self.tableView];
    _contentOffsetY = CGRectGetMaxY(rect);
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath == nil) return;
    DWDGrowUpCellLayout *layout = _layoutArray[indexPath.row];
    _selectedLayout = layout;
    _autoIncreaseTextView.textView.placeholderText = nil;
    _autoIncreaseTextView.type = kBottomFieldComment;
    _autoIncreaseTextView.userInfo = nil;
    [_autoIncreaseTextView.textView becomeFirstResponder];
}

/**
 *  点击了label进行回复
 */
- (void)growCell:(DWDGrowUpCell *)cell didClickLabel:(YYLabel *)label replyWithCustId:(NSNumber *)custId nickname:(NSString *)nickname {
    CGRect rect = [label convertRect:label.bounds toView:self.tableView];
    
    _contentOffsetY = CGRectGetMaxY(rect);
//    [self.tableView setContentOffset:CGPointMake(0, CGRectGetMaxY(rect))];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath == nil) return;
    DWDGrowUpCellLayout *layout = _layoutArray[indexPath.row];
    _selectedLayout = layout;
    _autoIncreaseTextView.type = kBottomFieldReply;
    _autoIncreaseTextView.userInfo[kForCustId] = custId;
    _autoIncreaseTextView.userInfo[kForNickname] = nickname;
    _autoIncreaseTextView.textView.placeholderText = [NSString stringWithFormat:@"回复 %@:", nickname];
    [_autoIncreaseTextView.textView becomeFirstResponder];
}

/**
 *  点击了姓名查看详细信息
 */
- (void)growCell:(DWDGrowUpCell *)cell didClickUserToViewDetail:(NSNumber *)custId {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath == nil) return;
    if (custId != [DWDCustInfo shared].custId) {
        DWDPersonDataViewController *vc = [[DWDPersonDataViewController alloc] init];
        vc.custId = custId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

/**
 *  点击了图片
 */
- (void)growCell:(DWDGrowUpCell *)cell didClickImageView:(UIImageView *)imgView withIndex:(NSInteger)index {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath == nil) return;
    DWDGrowUpCellLayout *layout = _layoutArray[indexPath.row];
    
    NSArray *photoArray = [layout.model.photos valueForKeyPath:@"photo"];
    
    DWDImagesScrollView *scrollView = [[DWDImagesScrollView alloc] initWithPhotoMetaArray:photoArray];
    
    [scrollView presentViewFromImageView:imgView atIndex:index toContainer:self.view];
}

/**
 *  点击了内容展开
 */
- (void)growCellDidClickContentExpandButton:(DWDGrowUpCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath == nil) return;
    
    DWDGrowUpCellLayout *layout = self.layoutArray[indexPath.row];
    layout.expandingContent = !layout.isExpandingContent;
    [self reloadRowWithIndex:indexPath];
}

/**
 *  点击了评论展开按钮
 */
- (void)growCellDidClickCommentExpandButton:(DWDGrowUpCell *)cell {
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath == nil) return;

    DWDGrowUpCellLayout *layout = self.layoutArray[indexPath.row];
    layout.expandingComments = !layout.isExpandingComments;
    [self reloadRowWithIndex:indexPath];
}

#pragma mark - DWDGrowUpUploadControllerDelegate
- (void)growUpUploadController:(DWDGrowUpUploadController *)controller didCompleteUploadWithRecord:(DWDGrowUpModel *)model {
    DWDGrowUpCellLayout *layout = [[DWDGrowUpCellLayout alloc] initWithModel:model];
    if (layout) {
        [_layoutArray insertObject:layout atIndex:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_noDataImageView removeFromSuperview];
//            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView reloadData];
        });
    }
}

#pragma mark - KKAlbumsListControllerDelegate
- (void)listControllerShouldCancel:(KKAlbumsListController *)listController {
    
    [listController dismissViewControllerAnimated:YES completion:nil];
}

- (void)listController:(KKAlbumsListController *)listController completeWithPhotosArray:(NSArray<PHAsset *> *)array {
    WEAKSELF;
    [listController dismissViewControllerAnimated:YES completion:^{
        [weakSelf pushToUploadControllerWithPhotosArray:array];
    }];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    if (self.pickerTag == 1) {
        // 更换成长记录封面
        [[SDImageCache sharedImageCache] storeImage:image
                                             forKey:[self headerImageName]
                                             toDisk:YES];
        _backgroundImageView.image = image;
    }else if (self.pickerTag == 2){
        // 成长记录封面拍照获得图片
        [[SDImageCache sharedImageCache] storeImage:image
                                             forKey:[self headerImageName]
                                             toDisk:YES];
        _backgroundImageView.image = image;
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        if (self.pickerTag == 3) {
            //存储图片到图片相册
            WEAKSELF;
            [[DWDPhotosHelper defaultHelper] SaveCaptureImageInfo:info completion:^(PHAsset *asset, BOOL success, NSError *error) {
                //拿到PHAsset
                if (success) {
                    //跳转到上传控制器
                    DWDGrowUpUploadController *vc = [[DWDGrowUpUploadController alloc] initWithPhotosArray:@[asset]];
                    vc.delegate = weakSelf;
                    vc.albumId = weakSelf.myClass.albumId;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.navigationController pushViewController:vc animated:YES];
                    });
                }
            }];
            
        }
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y < 0) {
        self.navigationController.navigationBar.hidden = YES;
        self.statusBarHidden = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    } else {
        self.navigationController.navigationBar.hidden = NO;
        self.statusBarHidden = NO;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    CGFloat alpha;
    if (self.tableView.contentOffset.y > (pxToH(400) - 64)) {
        alpha = 1;
    }else{
        alpha = scrollView.contentOffset.y / (pxToH(400) - 64);
        if (alpha < 0) {
            alpha = 0;
        }
    }
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageWithColor:DWDColorMain] renderAtAphla:alpha completion:nil] forBarMetrics:UIBarMetricsDefault];
    
}

#pragma mark - Setter / Getter
- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] init];
        tableView.frame = self.view.bounds;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.backgroundColor = DWDColorBackgroud;
        [self.view addSubview:tableView];
        _tableView = tableView;
    }
    return _tableView;
}

- (NSMutableArray *)layoutArray {
    if (!_layoutArray) {
        _layoutArray = [NSMutableArray array];
    }
    return _layoutArray;
}

- (UIImageView *)noDataImageView {
    if (!_noDataImageView) {
        _noDataImageView = [[UIImageView alloc] init];
        _noDataImageView.contentMode = UIViewContentModeCenter;
        _noDataImageView.image = [UIImage imageNamed:@"msg_record_no_data"];
    }
    return _noDataImageView;
}



#pragma mark - Request Date
- (void)requestGetAlertWithMenuCode:(NSString *)code{
    [DWDIntelligentOfficeDataHandler requestGetAlertWithCid:[DWDCustInfo shared].custId sid:self.myClass.schoolId mncd:code sta:nil targetController:self success:^{
        
    } failure:^(NSError *error) {
        
    }];
}


@end
