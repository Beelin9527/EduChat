//
//  DWDClassSourceGrowupRecordViewController.m
//  EduChat
//
//  Created by Superman on 15/11/26.
//  Copyright © 2015年 dwd. All rights reserved.
//

#define kTextFieldTypeReplyComment @"replyComment"
#define kTextFieldTypeAddComment @"addComment"

#import "DWDClassSourceGrowupRecordViewController.h"
#import "DWDClassSourceGrowupRecordCell.h"
#import "DWDClassSourcePersonalRecordViewController.h"
#import "DWDClassMemberViewController.h"
#import "DWDCommonImagePikerController.h"
#import "DWDGrowUpRecordUploadRecordController.h"
#import "DWDClassGrowUpRecordCommentsListControllerTableViewController.h"
#import "DWDPersonDataViewController.h"
#import "DWDGrowUpDetailContentController.h"

#import "DWDClassGrowUpCell.h"
#import "DWDBottomTextField.h"
#import "DWDFaceView.h"

#import "DWDClassModel.h"
#import "DWDGrowUpRecordModel.h"
#import "DWDPhotoInfoModel.h"
#import "DWDGrowUpRecordFrame.h"
#import "DWDGrowUpRecordCommentList.h"

#import "DWDMenuController.h"
#import "DWDGrowUpRecordCell.h"

#import "UIImage+Utils.h"
#import <Masonry.h>
#import <MJRefresh.h>
#import <YYModel.h>
#import "JFImagePickerController.h"

@interface DWDClassSourceGrowupRecordViewController() <UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate,DWDBottomTextFieldDelegate, JFImagePickerDelegate , DWDClassGrowUpCellExtendBtnClickDelegate , DWDGrowUpRecordUploadRecordControllerDelegate, DWDGrowUpRecordCellDelegate>
@property (nonatomic , strong) NSMutableArray *records;
@property (nonatomic , weak) UIView *headerViewContainer;
@property (nonatomic , weak) UIView *smallContainer;
@property (nonatomic , weak) UITableView *tableView;
@property (nonatomic , weak) DWDBottomTextField *bottomTextField;


@property (nonatomic , weak) UIImageView *backgroundImageView;


@property (nonatomic , assign) BOOL haveNewMessage;

@property (nonatomic , strong) NSMutableArray *arrSelectImgs;

@property (nonatomic , assign) long long albumID;   // 当前这条动态的相册ID

@property (nonatomic , strong) UIImageView *noDataimageView;

@end

@implementation DWDClassSourceGrowupRecordViewController

- (UIImageView *)noDataimageView{
    if (!_noDataimageView) {
        _noDataimageView = [[UIImageView alloc] initWithFrame:CGRectMake((DWDScreenW - pxToW(450))*0.5, DWDScreenH - pxToH(370) - pxToH(378), pxToW(500), pxToH(378))];
        _noDataimageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.tableView addSubview:_noDataimageView];
    }
    return _noDataimageView;
}
//
//- (void)setHaveNewMessage:(BOOL)haveNewMessage{
//    _haveNewMessage = haveNewMessage;
//    if (haveNewMessage == YES) {
//        [_messageBtn updateConstraints:^(MASConstraintMaker *make) {
//            make.height.equalTo(@0);
//        }];
//        [_messageBtn setTitle:nil forState:UIControlStateNormal];
//        [self.tableView.tableHeaderView setH:pxToH(509)];
//        [_smallContainer updateConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_messageBtn.bottom).offset(pxToH(32));
//        }];
//    }else{
//        [_messageBtn updateConstraints:^(MASConstraintMaker *make) {
//            make.height.equalTo(@(pxToH(64)));
//        }];
//        [_messageBtn setTitle:@"您有1条新消息" forState:UIControlStateNormal];
//        [self.tableView.tableHeaderView setH:pxToH(573)];
//        [_smallContainer updateConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_messageBtn.bottom);
//        }];
//    }
//}

// 获取班级记录
- (void)refreshing{
    DWDLogFunc;
    NSDictionary *params = @{@"custId" : [DWDCustInfo shared].custId,
                             @"classId" : self.myClass.classId,
                             };
    [[HttpClient sharedClient] getApi:@"AlbumRestService/getClassAlbumRecords" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *array = responseObject[@"data"][@"photos"];
        if (array.count <= self.records.count) {
            self.haveNewMessage = YES;
            return ;
        }else{
            self.haveNewMessage = NO;
        }
        
        for (int i = 0; i < array.count; i++) {
            DWDGrowUpRecordModel *growUpModel = [DWDGrowUpRecordModel yy_modelWithJSON:array[i]];
            growUpModel.expandButtonOn = NO;
            growUpModel.expandBody = NO;
            DWDGrowUpRecordFrame *growFrame = [[DWDGrowUpRecordFrame alloc] init];
            growFrame.growupModel = growUpModel;
            [self.records addObject:growFrame];
        }
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDLog(@"error:%@",error);
    }];
    [self.tableView.mj_header endRefreshing];
}

- (NSMutableArray *)arrSelectImgs{
    if (!_arrSelectImgs) {
        _arrSelectImgs = [NSMutableArray array];
    }
    return _arrSelectImgs;
}

- (NSMutableArray *)records{
    if (!_records) {
        _records = [NSMutableArray array];
    }
    return _records;
}



- (void)viewDidLoad{
    [super viewDidLoad];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, DWDScreenH) style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = DWDColorBackgroud;
    
    _tableView = tableView;
    [self.view addSubview:tableView];
    [self.tableView registerClass:[DWDGrowUpRecordCell class] forCellReuseIdentifier:@"DWDGrowUpRecordCell"];
    self.tableView.estimatedRowHeight = 400;
    
    // 底部输入框
    DWDBottomTextField *bottomTextField = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DWDBottomTextField class]) owner:nil options:nil] lastObject];
    bottomTextField.frame = CGRectMake(0, DWDScreenH, DWDScreenW, 50);
    bottomTextField.delegate = self;
    _bottomTextField = bottomTextField;
    [self.view addSubview:bottomTextField];
   
    
//    self.tableView.tableHeaderView.backgroundColor = DWDRandomColor;
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = [NSString stringWithFormat:@"%@",_myClass.className];
    
    UIBarButtonItem *barBtnright = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more_press"] style:UIBarButtonItemStyleDone target:self action:@selector(rightBarBtnClick)];
//    UIBarButtonItem *barBtnleft = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_clss_member_class_albums"] style:UIBarButtonItemStyleDone target:self action:@selector(leftBarBtnClick)];
    self.navigationItem.rightBarButtonItems = @[barBtnright];
    
    [self setUpTableHeaderView];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshing)];
    
    // 手动加载数据
    self.haveNewMessage = YES;
    [self getRecordData:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zanClickNotification:) name:@"DWDMenuButtonzanClickNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentClickNotification:) name:@"DWDMenuButtoncommentClickNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableViewNotification) name:@"GrowUpTableViewReloadData" object:nil];
}

- (void)zanClickNotification:(NSNotification *)notification{
    DWDLogFunc;
    NSDictionary *userInfo = [notification userInfo];
    DWDGrowUpRecordModel *growupModel = userInfo[@"growupModel"];
    
    
//    DWDGrowUpRecordModel *frameModel = bottomTextField.recordModel;
//    NSDictionary *params = @{@"custId" : [DWDCustInfo shared].custId,
//                             @"albumId" : frameModel.record.albumId,  // 当前这条动态的相册ID
//                             @"recordId" : frameModel.record.logId,
//                             @"commentTxt": bottomTextField.Field.text};
    
    NSDictionary *params = @{@"custId" : [DWDCustInfo shared].custId,
                             @"albumId" : growupModel.record.albumId,
                             @"recordId" : growupModel.record.logId};
    [[HttpClient sharedClient] postApi:@"AlbumRestService/addPraise" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
//        DWDLog(@"%@~~~~~~~",responseObject[@"data"]);
        //  把自己的名字传给cell  刷新tableview
        // 应该修改模型,并且上传服务器
        [self getRecordData:growupModel];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDLog(@"error:%@",error);
    }];

}

- (void)commentClickNotification:(NSNotification *)notification{
    DWDLogFunc;
    // 弹出键盘做动画
    [_bottomTextField.Field becomeFirstResponder];
    NSDictionary *userInfo = [notification userInfo];
    DWDGrowUpRecordModel *growupModel = userInfo[@"growupModel"];
    _bottomTextField.recordModel = growupModel;
}

- (void)keyboardWillShow:(NSNotification *)note{
    DWDLog(@"%@",note);
    CGRect endFrame = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat height = endFrame.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        _bottomTextField.y = DWDScreenH - height - _bottomTextField.h;
    }];
}

- (void)reloadTableViewNotification {
    [self.tableView reloadData];
}

- (void)keyboardWillHide:(NSNotification *)note{
    DWDLog(@"%@",note);
    [UIView animateWithDuration:0.25 animations:^{
        _bottomTextField.y = DWDScreenH;
    }];
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:DWDColorMain] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)tapBackgroundView:(UITapGestureRecognizer *)tap{
    DWDLogFunc;
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"您需要更换封面背景图片吗?" message:@"请选择:" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        DWDCommonImagePikerController *imagePiker = [[DWDCommonImagePikerController alloc] init];
        imagePiker.tag = 1;
        imagePiker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        __weak id weakSelf = self;
        imagePiker.delegate = weakSelf;
        [self presentViewController:imagePiker animated:YES completion:nil];
        
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"拍一张" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        DWDCommonImagePikerController *imagePiker = [[DWDCommonImagePikerController alloc] init];
        imagePiker.tag = 2;
        imagePiker.sourceType = UIImagePickerControllerSourceTypeCamera;
        __weak id weakSelf = self;
        imagePiker.delegate = weakSelf;
        [self presentViewController:imagePiker animated:YES completion:nil];
        
    }];
    
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        DWDLog(@"取消");
    }];
    
    [alertVc addAction:action1];
    [alertVc addAction:action2];
    [alertVc addAction:action3];
    [self presentViewController:alertVc animated:YES completion:nil];
}

- (void)setUpTableHeaderView{
    
    UIView *container = [[UIView alloc] init];
    
    _headerViewContainer = container;
    UIImageView *backGroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, pxToH(400))];
    backGroundView.image = [UIImage imageNamed:@"img_defaultphoto"];
    backGroundView.userInteractionEnabled = YES;
    backGroundView.contentMode = UIViewContentModeScaleAspectFill;
    backGroundView.clipsToBounds = YES;
    
    [backGroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroundView:)]];
    
    _backgroundImageView = backGroundView;
    [container addSubview:backGroundView];
    
    
    UIImageView *iconView = [[UIImageView alloc] init];
    [iconView sd_setImageWithURL:[NSURL URLWithString:self.myClass.photoKey] placeholderImage:[UIImage imageNamed:@"MSG_Class_Home_HP"]];
    [backGroundView addSubview:iconView];
    
    
//    UIImage *image = [UIImage imageNamed:@"bg_new_messages_record"];
//    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.5, image.size.width * 0.5, image.size.height * 0.5, image.size.width * 0.5) resizingMode:UIImageResizingModeStretch];
//    [messageBtn setBackgroundImage:image forState:UIControlStateNormal];
    
//    messageBtn.layer.cornerRadius = 5;
//    [container addSubview:messageBtn];
    
    UIView *smallContainer = [[UIView alloc] init];
    smallContainer.backgroundColor = [UIColor whiteColor];
    _smallContainer = smallContainer;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"说点什么吧.." forState:UIControlStateNormal];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 220);
    [btn setTitleColor:DWDRGBColor(153, 153, 153) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [smallContainer addSubview:btn];
    
    UIButton *photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [photoBtn setBackgroundImage:[UIImage imageNamed:@"ic_shooting_class_dialogue_pages_normal"] forState:UIControlStateNormal];
    [photoBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [smallContainer addSubview:photoBtn];
    
    [container addSubview:smallContainer];
    
    [iconView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(iconView.superview.bottom).offset(-pxToH(89));
        make.width.equalTo(@(pxToW(120)));
        make.height.equalTo(@(pxToH(120)));
        make.centerX.equalTo(iconView.superview.centerX);
    }];
    
//    [messageBtn makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(backGroundView.bottom).offset(pxToH(20));
//        make.centerX.equalTo(iconView.centerX);
//        make.width.equalTo(@(pxToW(300)));
//        make.height.equalTo(@(pxToH(64)));
//    }];
    
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
    
    [photoBtn makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(photoBtn.superview.right).offset(-pxToW(11));
        make.centerY.equalTo(photoBtn.superview.centerY);
        make.width.equalTo(@(pxToW(75)));
        make.height.equalTo(@(pxToH(75)));
    }];
    
    container.h = pxToH(480);
    
    self.tableView.tableHeaderView = container;
}

- (void)getNewComment{
    
    self.haveNewMessage = YES;
    DWDClassGrowUpRecordCommentsListControllerTableViewController *commentListVc = [[DWDClassGrowUpRecordCommentsListControllerTableViewController alloc] init];
    
    DWDGrowUpRecordFrame *frameModel = [self.records firstObject];
    
    NSDictionary *params = @{@"custId" : [DWDCustInfo shared].custId,
                             @"albumId" : frameModel.growupModel.record.albumId,  // 当前这条动态的相册ID
                             @"recordId" : frameModel.growupModel.record.logId};
    [[HttpClient sharedClient] getApi:@"AlbumRestService/getCommentList" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray *comments = responseObject[@"data"][@"comments"];
        NSMutableArray *commentListArray = [NSMutableArray array];
        for (int i = 0; i < comments.count; i++) {
            DWDGrowUpRecordCommentList *commentList = [DWDGrowUpRecordCommentList yy_modelWithJSON:comments[i]];
            [commentListArray addObject:commentList];
        }
        
        commentListVc.commentList = commentListArray;
        [self.navigationController pushViewController:commentListVc animated:YES];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDLog(@"error:%@",error);
    }];
}

- (void)btnClick:(UIButton *)btn{
    DWDLogFunc;
    // 跳上传图片,需要.h声明 上传的接口需要封装

    JFImagePickerController *picker = [[JFImagePickerController alloc] initWithRootViewController:self];
    picker.pickerDelegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}



- (void)rightBarBtnClick{
    DWDLogFunc;
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"消息列表" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        DWDLog(@"消息列表");
        DWDClassGrowUpRecordCommentsListControllerTableViewController *commentListVc = [[DWDClassGrowUpRecordCommentsListControllerTableViewController alloc] init];
        
        DWDGrowUpRecordFrame *frameModel = [self.records firstObject];
        if (frameModel == nil) {
            [DWDProgressHUD showText:@"暂无新消息" afterDelay:1.0];
            return ;
        }
        NSDictionary *params = @{@"custId" : [DWDCustInfo shared].custId,
                                 @"albumId" : frameModel.growupModel.record.albumId,  // 当前这条动态的相册ID
                                 @"recordId" : frameModel.growupModel.record.logId};
        [[HttpClient sharedClient] getApi:@"AlbumRestService/getCommentList" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
            
            NSArray *comments = responseObject[@"data"][@"comments"];
            NSMutableArray *commentListArray = [NSMutableArray array];
            for (int i = 0; i < comments.count; i++) {
                DWDGrowUpRecordCommentList *commentList = [DWDGrowUpRecordCommentList yy_modelWithJSON:comments[i]];
                [commentListArray addObject:commentList];
            }
            
            commentListVc.commentList = commentListArray;
            [self.navigationController pushViewController:commentListVc animated:YES];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DWDLog(@"error:%@",error);
        }];
        
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        DWDLog(@"取消");
    }];
    
    [alertVc addAction:action1];
    [alertVc addAction:action2];
    [self presentViewController:alertVc animated:YES completion:nil];
}

- (void)leftBarBtnClick{
    DWDClassMemberViewController *memberVc = [[DWDClassMemberViewController alloc] init];
    memberVc.myClass = self.myClass;
#warning 没有接口😄
    [self.navigationController pushViewController:memberVc animated:YES];
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.records.count == 0) {
        self.noDataimageView.hidden = NO;
        [self.noDataimageView setImage:[UIImage imageNamed:@"msg_record_no_data"]];
    }else{
        self.noDataimageView.hidden = YES;
    }
    return self.records.count;
}

- (DWDGrowUpRecordCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//- (DWDClassGrowUpCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

//    DWDLog(@"%zd",self.records.count);
//    DWDClassGrowUpCell *cell = [DWDClassGrowUpCell cellWithTableView:tableView];
//    cell.extendBtnDelegate = self;
//    cell.cellIndexPath = indexPath;
    DWDGrowUpRecordFrame *Framemodel = self.records[indexPath.row];
    Framemodel.growupModel.indexPath = indexPath;
//    DWDLog(@"%zd",Framemodel.growupModel.comments.count);
//    
//    cell.growUpRecordFrame = Framemodel;
//   
//    return cell;
    
    DWDGrowUpRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DWDGrowUpRecordCell"];
    cell.delegate = self;
    
    cell.dataModel = Framemodel.growupModel;
    
    return cell;
}

#pragma mark - <DWDClassGrowUpCellExtendBtnClickDelegate>
- (void)extendBtnClickWithIndex:(NSIndexPath *)index{
    
//    [self.tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView setNeedsDisplay];
    [self.tableView reloadData];
}

- (void)tableViewCell:(DWDClassGrowUpCell *)cell ClickUserNamePushToUserInfo:(NSNumber *)custId {
    if (custId != [DWDCustInfo shared].custId) {
        DWDPersonDataViewController *vc = [[DWDPersonDataViewController alloc] init];
        vc.custId = custId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - <UIImagePickerControllerDelegate>
- (void)imagePickerController:(DWDCommonImagePikerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    if (picker.tag == 1) {
        // 更换成长记录封面
        _backgroundImageView.image = image;
    }else if (picker.tag == 2){
        // 成长记录封面拍照获得图片
        _backgroundImageView.image = image;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#import <JFImagePicker/JFAssetHelper.h>

#pragma makr - <JFImagePickerDelegate>
- (void)imagePickerDidFinished:(JFImagePickerController *)picker{
    
    [self.arrSelectImgs removeAllObjects];
    
//    __weak DWDClassSourceGrowupRecordViewController *weakSelf = self;
    
    for ( ALAsset *asset in picker.assets) {
        
        // ASSET_PHOTO_ASPECT_THUMBNAIL(挤压高清)  ASSET_PHOTO_THUMBNAIL(等比模糊缩略)  ASSET_PHOTO_FULL_RESOLUTION  ASSET_PHOTO_SCREEN_SIZE
        
        UIImage *image = [[JFAssetHelper sharedAssetHelper] getImageFromAsset:asset type:ASSET_PHOTO_SCREEN_SIZE];

        [self.arrSelectImgs addObject:image];
    }
    
    [picker dismissViewControllerAnimated:NO completion:^{
        // 传图片数组到下一个控制器中
        DWDGrowUpRecordUploadRecordController *uploadVc = [[UIStoryboard storyboardWithName:@"DWDGrowUpRecordUploadRecordController" bundle:nil] instantiateViewControllerWithIdentifier:@"DWDGrowUpRecordUploadRecordController"];
        uploadVc.rightBarBtnDelegate = self;
        uploadVc.myClassAlbumId = [self.myClass.albumId longLongValue];
        uploadVc.arrSelectImgs = self.arrSelectImgs;

        [self.navigationController pushViewController:uploadVc animated:YES];
    }];
    
}

#pragma mark - <DWDGrowUpRecordUploadRecordControllerDelegate>
- (void)DWDGrowUpRecordUploadRecordControllerRightBarBtnClickWithImages:(NSArray *)imageUrls
                                                                   text:(NSString *)text
                                                                albumId:(NSNumber *)albumId{
    // 上传成功 , 获得images数组 和 最新发布的动态
    
    DWDGrowUpRecordFrame *growupF = [[DWDGrowUpRecordFrame alloc] init];
    
    DWDGrowUpRecordModel *growupRecord = [[DWDGrowUpRecordModel alloc] init];
    DWDGrowUpAuthor *author = [[DWDGrowUpAuthor alloc] init];
    author.addtime = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    author.photokey = [DWDCustInfo shared].custThumbPhotoKey;
    author.name = [DWDCustInfo shared].custNickname;
    
    DWDGrowUpRecord *record = [[DWDGrowUpRecord alloc] init];
    record.albumId = albumId;
    record.content = text;
    
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < imageUrls.count; i++) {
        DWDPhotoInfoModel *photoModel = [[DWDPhotoInfoModel alloc] init];
        photoModel.photokey = imageUrls[i];
        [arr addObject:photoModel];
    }
    growupRecord.photos = arr;
    growupRecord.record = record;
    growupRecord.author = author;
    growupF.growupModel = growupRecord;
    
    [self.records insertObject:growupF atIndex:0];
    [self.tableView reloadData];
}

- (void)imagePickerDidCancel:(JFImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <UITableViewDelegate>

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    DWDGrowUpRecordFrame *frameModel = self.records[indexPath.row];
//
//    return frameModel.cellHeight;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return pxToH(20);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - DWDGrowUpRecordCellDelegate

- (void)recordCell:(DWDGrowUpRecordCell *)cell didClickCommentViewWithCustId:(NSNumber *)custId {

    if (custId != [DWDCustInfo shared].custId) {
        DWDPersonDataViewController *vc = [[DWDPersonDataViewController alloc] init];
        vc.custId = custId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)recordCell:(DWDGrowUpRecordCell *)cell didClickCommentViewContentLabelWithCustId:(NSNumber *)custId {
    [_bottomTextField.Field becomeFirstResponder];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    DWDGrowUpRecordModel *model = ((DWDGrowUpRecordFrame *)self.records[indexPath.row]).growupModel;
    _bottomTextField.recordModel = model;
    _bottomTextField.recordModel.forCustId = custId;
    _bottomTextField.type = kTextFieldTypeReplyComment;
}

- (void)recordCell:(DWDGrowUpRecordCell *)cell didClickContentLabelWithContent:(NSString *)contentString {
    DWDGrowUpDetailContentController *vc = [DWDGrowUpDetailContentController new];
    vc.detailContentString = contentString;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.tableView.contentOffset.y > (pxToH(400) - 64)) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:DWDColorMain] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:nil];
    }else{
        [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    }
}

- (void)getRecordData:(DWDGrowUpRecordModel *)recordModel{
//    NSDictionary *params = @{@"custId" : @5010000003026,
//                             @"classId" : @7010000002006,
//                             };
    NSDictionary *params = @{@"custId" : [DWDCustInfo shared].custId,
                             @"classId" : self.myClass.classId,
                             };
    [[HttpClient sharedClient] getApi:@"AlbumRestService/getClassAlbumRecords" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *array = responseObject[@"data"][@"photos"];
        
        [self.records removeAllObjects];
        for (int i = 0; i < array.count; i++) {
            DWDGrowUpRecordModel *growUpModel = [DWDGrowUpRecordModel yy_modelWithJSON:array[i]];
            DWDGrowUpRecordFrame *growFrame = [[DWDGrowUpRecordFrame alloc] init];
            if (i == recordModel.indexPath.row) {
                growUpModel.expandButtonOn = recordModel.expandButtonOn;
                growUpModel.expandBody = recordModel.expandBody;
            }
            growFrame.growupModel = growUpModel;
            [self.records addObject:growFrame];
            
        }
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDLog(@"error:%@",error);
    }];
}



#pragma mark - <DWDBottomTextFieldDelegate>

//- (void)bottomTextFieldDidClickEmotionButton:(DWDBottomTextField *)bottomTextField {
//    bottomTextField.Field.inputView = [DWDFaceView]
//}

- (void)bottomTextFieldDidEndEditing:(DWDBottomTextField *)bottomTextField {
    //    custId	√	long	点赞人id
    //    albumId	√	long	相册id
    //    recordId	√	long	相册记录id
    //    commentTxt	√	String	评论内容
    DWDGrowUpRecordModel *frameModel = bottomTextField.recordModel;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:[DWDCustInfo shared].custId forKey:@"custId"];
    [params setObject:frameModel.record.albumId forKey:@"albumId"];
    [params setObject:frameModel.record.logId forKey:@"recordId"];
    [params setObject:bottomTextField.Field.text forKey:@"commentTxt"];
    if ([bottomTextField.type isEqualToString:kTextFieldTypeReplyComment]) {
        [params setObject:frameModel.forCustId forKey:@"forCustId"];
    }
    
    [[HttpClient sharedClient] postGrowUpCommentWithParams:params success:^(NSURLSessionDataTask *task, id responseObject) {
        bottomTextField.Field.text = nil;

        
        [self getRecordData:frameModel];
        
        DWDMarkLog(@"评论发送成功");
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDMarkLog(@"评论发送失败");
    }];
    
}

@end
