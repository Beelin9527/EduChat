//
//  DWDClassInfoViewController.m
//  EduChat
//
//  Created by Superman on 15/11/19.
//  Copyright © 2015年 dwd. All rights reserved.
//  班级主页控制器

// all
#define totleColumn 4

#import "DWDClassInfoViewController.h"
#import "DWDClassSourceClassNotificationViewController.h"
#import "DWDClassSourceLeavePaperViewController.h"
#import "DWDClassSourceGrowupRecordViewController.h"
#import "DWDClassSourceCheckScoreViewController.h"
#import "DWDClassSourceHomeWorkViewController.h"
#import "DWDClassSettingController.h"
#import "DWDClassInnerGroupViewController.h"
#import "DWDContactSelectViewController.h"
#import "DWDNavViewController.h"
#import "DWDPersonDataViewController.h"
#import "DWDTeacherDetailViewController.h"
#import "DWDSearchClassInfoViewController.h"
#import "DWDGrowUpViewController.h"
#import "DWDClassMembersViewController.h"
#import "DWDWebViewController.h"
#import "DWDChatController.h"

#import "DWDPickUpCenterChildTableViewController.h"

#import "DWDClassIntroduceViewController.h"


#import "DWDClassInfoTopView.h"
#import "DWDClassInfoMidView.h"
#import "DWDClassInfoBottomView.h"

#import "DWDClassModel.h"
#import "DWDClassMember.h"
#import "DWDClassDataBaseTool.h"

#import "DWDContactsDatabaseTool.h"
#import "DWDRecentChatDatabaseTool.h"
#import "DWDPickUpCenterDatabaseTool.h"

#import "DWDClassMemberClient.h"
#import "DWDRequestClassSetting.h"

#import "DWDClassInfoMidViewButton.h"
#import "UIImage+Utils.h"
#import <Masonry/Masonry.h>
#import <UIButton+WebCache.h>
#import <UIImageView+WebCache.h>
#import <YYModel.h>
#import "DWDClassDataHandler.h"
#import "DWDClassFuncModel.h"

@interface DWDClassInfoViewController () <DWDContactSelectViewControllerDelegate,DWDClassIntroduceViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, DWDClassMembersViewControllerDelegate, UIScrollViewDelegate,UIActionSheetDelegate>
@property (nonatomic , weak) DWDClassInfoTopView *topView;
@property (nonatomic , weak) DWDClassInfoMidView *midView;
@property (nonatomic , weak) DWDClassInfoBottomView *bottomView;

@property (strong, nonatomic) UIImageView *classPhoto;                      //班级头像

@property (nonatomic , strong) NSArray *titles;
@property (nonatomic , strong) NSArray *members;
@property (nonatomic , strong) NSMutableArray *membersIds;
@property (nonatomic , strong) NSMutableArray *deleteBottomViewBtnArray;
@property (nonatomic , strong) NSMutableArray *classFuncItems;              // 班级功能选项

@property (nonatomic , weak) UIButton *countBtn;
@property (nonatomic , assign) NSUInteger buttonCount;

@property (nonatomic , strong) NSMutableArray *btns;
@property (nonatomic , assign) CGSize nameLabelRealSize;
@property (nonatomic , strong) UIScrollView *scrollView;

@end

@implementation DWDClassInfoViewController

- (NSMutableArray *)deleteBottomViewBtnArray{
    if (!_deleteBottomViewBtnArray) {
        _deleteBottomViewBtnArray = [NSMutableArray array];
    }
    return _deleteBottomViewBtnArray;
}

- (NSMutableArray *)btns{
    if (!_btns) {
        _btns = [NSMutableArray array];
    }
    return _btns;
}

- (NSMutableArray *)membersIds{
    if (!_membersIds) {
        _membersIds = [NSMutableArray array];
    }
    return _membersIds;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.title = [NSString stringWithFormat:@"%@",self.myClass.className];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more_normal"] style:UIBarButtonItemStyleDone target:self action:@selector(rightBarBtnClick)];
    
    [self setUpMySubviews];
    
    //判断是否需要显示进入班级图标
    if (self.typeShow == DWDClassTypeShowComeInChat) {
        [self createComeIn];
    }
    
    //request
//  班级成员 家长暂时隐藏
    if ([DWDCustInfo shared].isTeacher) {
        [self requedtClassMemberGetListWithClassId:self.myClass.classId];
    }
    [self requestClassFunctionItem];
}




- (void)rightBarBtnClick{
    
    // 跳转班级详情界面
    DWDSearchClassInfoViewController *searchInfoVc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDSearchClassInfoViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDSearchClassInfoViewController class])];
    searchInfoVc.classModel = self.myClass;
    searchInfoVc.hideButton = YES;  //隐藏按钮
    [self.navigationController pushViewController:searchInfoVc animated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:DWDColorMain] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBarTintColor:DWDColorMain];
    [self.navigationController.navigationBar setShadowImage:nil];
}

#pragma mark - subviews

- (void)setUpMySubviews{
    
//    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
//    backgroundView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:backgroundView];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.frame = CGRectMake(0, 0, DWDScreenW, DWDScreenH);
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.contentSize = CGSizeMake(DWDScreenW, DWDScreenH);
    _scrollView.scrollEnabled = YES;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    
    DWDClassInfoTopView *topView = [[DWDClassInfoTopView alloc] init];
    DWDClassInfoMidView *midView = [[DWDClassInfoMidView alloc] init];
    
    _topView = topView;
    _midView = midView;
    [_scrollView addSubview:topView];
    [_scrollView addSubview:midView];
    _topView.frame = CGRectMake(0, 0, DWDScreenW, pxToH(560));
    _midView.frame = CGRectMake(0, _topView.h, DWDScreenW, pxToH(376));
    
//    [backgroundView addSubview:topView];
//    [backgroundView addSubview:midView];

//    [topView makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(topView.superview.top);
//        make.left.equalTo(topView.superview.left);
//        make.right.equalTo(topView.superview.right);
//        make.height.equalTo(@(pxToH(560)));
//    }];
    
//    [midView makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(topView.bottom);
//        make.left.equalTo(midView.superview.left);
//        make.right.equalTo(midView.superview.right);
//        make.height.equalTo(@(pxToH(376)));
//    }];

    [self setUpTopViewSubviews];
//    [self setUpMidViewSubviews];
    
    //   班级成员 老师显示 家长暂时隐藏
    if ([DWDCustInfo shared].isTeacher) {
        DWDClassInfoBottomView *bottomView = [[DWDClassInfoBottomView alloc] init];
        _bottomView = bottomView;
//        [backgroundView addSubview:bottomView];
        [_scrollView addSubview:bottomView];
        
        _bottomView.frame = CGRectMake(0, midView.y + midView.h + 20, DWDScreenW, pxToH(240));
//        [bottomView makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(midView.bottom).offset(pxToH(20));
//            make.left.equalTo(bottomView.superview.left);
//            make.right.equalTo(bottomView.superview.right);
//            make.bottom.equalTo(bottomView.superview.bottom).offset(-pxToH(20));
//        }];
        
        [self setUpBottomView];
    }
    
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
}

- (void)setUpTopViewSubviews{
    
    UIImageView *imageView = [[UIImageView alloc] init];
    self.classPhoto = imageView;
    imageView.userInteractionEnabled = YES;
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.myClass.photoKey] placeholderImage:[UIImage imageNamed:@"MSG_Class_Home_HP" ]];
    [_topView addSubview:imageView];
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithWhite:0 alpha:.1];
    [_topView addSubview:view];
    
    UILabel *label = [[UILabel alloc] init];
    if ([self.myClass.introduce isEqualToString:@""] || !self.myClass.introduce) {
        label.text = @"该班级还未有班级介绍哦!";
    }else{
       label.text = self.myClass.introduce;
    }
    
    label.font = DWDFontContent;
    label.textColor = DWDRGBColor(254, 254, 254);
    [view addSubview:label];
    
    UIImageView *imageview1 = [[UIImageView alloc] init];
    imageview1.image = [UIImage imageNamed:@"ic_declaration"];
    [view addSubview:imageview1];
    
    [imageView makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.centerX);
        make.bottom.equalTo(view.top).offset(-pxToH(102));
        make.width.equalTo(@(pxToW(160)));
        make.height.equalTo(@(pxToH(160)));
    }];
    
    [view makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view.superview.left);
        make.right.equalTo(view.superview.right);
        make.bottom.equalTo(view.superview.bottom);
        make.height.equalTo(@(pxToH(88)));
    }];
    
    [imageview1 makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageview1.superview.left).offset(pxToW(13));
        make.centerY.equalTo(imageview1.superview.centerY);
        make.width.equalTo(@(pxToW(44)));
        make.height.equalTo(@(pxToH(44)));
    }];
    
    [label makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageview1.right).offset(pxToW(14));
        make.right.equalTo(label.superview.right).offset(-pxToW(10));
        make.centerY.equalTo(imageview1.centerY);
    }];
    
    
    //加手势在这个头像上， 只有老师才有权限修改
    if([DWDCustInfo shared].isTeacher){
        
        UITapGestureRecognizer *gesturePhoto = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPhoto)];
        [imageView addGestureRecognizer:gesturePhoto];
    }
   //加手势在这个宣言View上
    UITapGestureRecognizer *gestureIntroduce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showIntroduceVC)];
    [view addGestureRecognizer:gestureIntroduce];
}

/** 添加进入班级图标 */
- (void)createComeIn{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:({
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitle:@"进入聊天" forState:UIControlStateNormal];
        btn.titleLabel.font = DWDFontBody;
        btn.titleEdgeInsets = UIEdgeInsetsMake(45, 10, 0, 0);
        [btn setBackgroundImage:[UIImage imageNamed:@"img_chat_normal"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"img_chat_press"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(pushChatVC) forControlEvents:UIControlEventTouchUpInside];
        btn;
    })];
    
    //masory
    [btn makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view).mas_offset(-37);
    }];
}

#pragma mark - Gesture Method
- (void)showIntroduceVC
{
    DWDClassIntroduceViewController *vc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDClassIntroduceViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDClassIntroduceViewController class])];
    vc.delegate = self;
    vc.classModel = self.myClass;
    [self.navigationController pushViewController:vc animated:YES];
}

/** 调用相机相册 */
- (void)showPhoto
{
    //在这里呼出下方菜单按钮项
    UIActionSheet *myActionSheet = [[UIActionSheet alloc]
                                    initWithTitle:nil
                                    delegate:self
                                    cancelButtonTitle:@"取消"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles: @"打开照相机", @"从手机相册获取",nil];
    
    [myActionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    //呼出的菜单按钮点击后的响应
    if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        DWDLog(@"取消");
    }
    
    switch (buttonIndex)
    {
        case 0:  //打开照相机拍照
        {
            [[DWDPrivacyManager shareManger] needPrivacy:DWDPrivacyTypeCamera withController:self authorized:^{
                [self takePhoto];
            }];
            break;
        }
            
        case 1:  //打开本地相册
        {
            [[DWDPrivacyManager shareManger] needPrivacy:DWDPrivacyTypePhotoLibrary withController:self authorized:^{
                [self LocalPhoto];
            }];
            break;
        }
    }
}

//开始拍照
-(void)takePhoto
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        
        [self presentViewController:picker animated:YES completion:nil];
        
    }else
    {
        DWDLog(@"模拟其中无法打开照相机,请在真机中使用");
    }
}

//打开本地相册
-(void)LocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    
    [self presentViewController:picker animated:YES completion:nil];
}

//当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
        
        //压缩图片
        image =  [UIImage  compressImageWithOldImage:image compressSize:self.view.size];
        //上传到阿里云
        [self requestUploadWithAliyun:image];
        
        //关闭相册界面
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    DWDLog(@"您取消了选择图片");
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - function item

- (void)setUpMidViewSubviews{
    
    // 动态加载功能
    CGFloat btnX = 0;
    CGFloat btnY = 0;
    CGFloat btnW = pxToW(187);
    CGFloat btnH = pxToH(187);
    
    for (int i = 0; i < self.classFuncItems.count; i++) {
        
        DWDClassFuncModel *func = self.classFuncItems[i];
        
        DWDClassInfoMidViewButton *btn = [[DWDClassInfoMidViewButton alloc] init];
        [_midView addSubview:btn];
        btn.tag = 999 + i;
        
        NSUInteger row = i / totleColumn;
        NSUInteger col = i % totleColumn;
        
        btnX =  col * btnW ;
        btnY =  row * btnH ;
        
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        [btn setTitle:func.plteNm forState:UIControlStateNormal];
        btn.titleLabel.font = DWDFontContent;
        
        
        //解决功能图标问题
        
        if ([func.plteCd intValue] == 999) {            // 网络图标
            [btn sd_setImageWithURL:[NSURL URLWithString:func.ico] forState:UIControlStateNormal];
            
        }else {                                         // 本地图标
            NSString *imageName;
            NSString *imagePreName;
            imageName = [NSString stringWithFormat:@"classMidViewBtnNol%@",func.plteCd];
            imagePreName = [NSString stringWithFormat:@"classMidViewBtnPre%@",func.plteCd];
            [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:imagePreName] forState:UIControlStateHighlighted];
        }
        
        
        if (i == self.classFuncItems.count - 1) {
            [btn setTitleColor:DWDRGBColor(221, 221, 221) forState:UIControlStateNormal];
            btn.enabled = NO;
        }else{
            [btn setTitleColor:DWDRGBColor(102, 102, 102) forState:UIControlStateNormal];
        }
        
        [btn addTarget:self action:@selector(funcBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.midView.h = btnH * ((self.classFuncItems.count - 1)/totleColumn + 1);;
    if (_bottomView) {
        _bottomView.frame = CGRectMake(0, self.midView.y + self.midView.h + 20, DWDScreenW, pxToH(300));
    }
    self.scrollView.contentSize = CGSizeMake(DWDScreenW, self.topView.h + self.midView.h + self.bottomView.h + 20);

    
    //区分权限 家长没有我的分组
    /*NSArray *titles = [NSArray array];
    if ([DWDCustInfo shared].isTeacher) {
         titles = @[@"成长记录",@"通知",@"作业",@"假条",@"接送中心",@"班级设置",@"期待更多"]; // 成绩查询、我的分组 暂时隐藏
    }else{
         titles = @[@"成长记录",@"通知",@"作业",@"假条",@"接送中心",@"班级设置",@"期待更多"]; // 成绩查询暂时隐藏
    }
   
    _titles = titles;
    
    CGFloat btnX = 0;
    CGFloat btnY = 0;
    CGFloat btnW = pxToW(187);
    CGFloat btnH = pxToH(187);
    
    for (int i = 0; i < titles.count; i++) {
        
        DWDClassInfoMidViewButton *btn = [[DWDClassInfoMidViewButton alloc] init];
        
        [_midView addSubview:btn];
        
        NSUInteger row = i / totleColumn;
        NSUInteger col = i % totleColumn;
        
        btnX =  col * btnW ;
        btnY =  row * btnH ;
        
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        btn.titleLabel.font = DWDFontContent;
        
        
        //解决功能图标问题
        NSString *imageName;
        NSString *imagePreName;
        if([DWDCustInfo shared].isTeacher){
//            imageName = [NSString stringWithFormat:@"classMidViewBtnNol%d",i];
//            imagePreName = [NSString stringWithFormat:@"classMidViewBtnPre%d",i];
            if (i < 5) {
                imageName = [NSString stringWithFormat:@"classMidViewBtnNol%d",i];
                imagePreName = [NSString stringWithFormat:@"classMidViewBtnPre%d",i];
            }else{
                imageName = [NSString stringWithFormat:@"classMidViewBtnNol%d",i+1];
                imagePreName = [NSString stringWithFormat:@"classMidViewBtnPre%d",i+1];
            }

        }else{
            if (i < 5) {
                imageName = [NSString stringWithFormat:@"classMidViewBtnNol%d",i];
                imagePreName = [NSString stringWithFormat:@"classMidViewBtnPre%d",i];
            }else{
                imageName = [NSString stringWithFormat:@"classMidViewBtnNol%d",i+1];
                imagePreName = [NSString stringWithFormat:@"classMidViewBtnPre%d",i+1];
            }
            
        }
        
        if (i == titles.count - 1) {
            [btn setTitleColor:DWDRGBColor(221, 221, 221) forState:UIControlStateNormal];
        }else{
            [btn setTitleColor:DWDRGBColor(102, 102, 102) forState:UIControlStateNormal];
        }
        
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:imagePreName] forState:UIControlStateHighlighted];
        
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }*/
}

- (void)funcBtnClick:(UIButton *)sender
{
    NSInteger index = sender.tag - 999;
    DWDClassFuncModel *func = self.classFuncItems[index];
    
    switch ([func.plteCd intValue]) {
        case DWDClassFunctionGroupRecord:     // 成长记录
        {
            DWDGrowUpViewController *growVc = [DWDGrowUpViewController new];
            growVc.myClass = self.myClass;
            [self.navigationController pushViewController:growVc animated:YES];
        }
            break;
        case DWDClassFunctionNotification:    // 通知
        {
            DWDClassSourceClassNotificationViewController *noteVc = [[DWDClassSourceClassNotificationViewController alloc] init];
            noteVc.myClass = self.myClass;
            [self.navigationController pushViewController:noteVc animated:YES];
        }
            break;
        case DWDClassFunctionHomeWork:        // 作业
        {
            DWDClassSourceHomeWorkViewController *homeWorkVc =
            [[UIStoryboard storyboardWithName:NSStringFromClass([DWDClassSourceHomeWorkViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDClassSourceHomeWorkViewController class])];
            homeWorkVc.classId = self.myClass.classId;
            homeWorkVc.classModel = self.myClass;
            [self.navigationController pushViewController:homeWorkVc animated:YES];
        }
            break;
        case DWDClassFunctionLeavePaper:      // 假条
        {
            DWDClassSourceLeavePaperViewController *leaveVc = [[DWDClassSourceLeavePaperViewController alloc] init];
            leaveVc.classId = self.myClass.classId;
            [self.navigationController pushViewController:leaveVc animated:YES];
        }
            break;
        case DWDClassFunctionPickupCenter:    // 接送中心
        {
            if ([DWDCustInfo shared].isTeacher) {
                DWDTeacherDetailViewController *vc = [[DWDTeacherDetailViewController alloc] init];
                vc.classId = self.myClass.classId;
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                DWDPickUpCenterChildTableViewController *childViewVc = [[DWDPickUpCenterChildTableViewController alloc] init];
                childViewVc.classId = self.myClass.classId;
                [self.navigationController pushViewController:childViewVc animated:YES];
            }
        }
            break;
        case DWDClassFunctionInnerGroup:      // 分组
        {
            DWDClassInnerGroupViewController *vc = [[DWDClassInnerGroupViewController alloc] init];
            vc.classId = self.myClass.classId;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case DWDClassFunctionSetting:         // 设置
        {
            DWDClassSettingController *sttingVc = [[DWDClassSettingController alloc] init];
            sttingVc.classModel = self.myClass;
            [self.navigationController pushViewController:sttingVc animated:YES];
        }
            break;
        case DWDClassFunctionOther:           // 第三方
        {
            DWDWebViewController *webVC = [[DWDWebViewController alloc] init];
            webVC.urlStr = func.url;
            [self.navigationController pushViewController:webVC animated:YES];
        }
            break;
        default:
            break;
    }
}

/*- (void)btnClick:(UIButton *)btn{
    if ([btn.titleLabel.text isEqualToString:@"通知"]) {
        DWDClassSourceClassNotificationViewController *noteVc = [[DWDClassSourceClassNotificationViewController alloc] init];
        noteVc.myClass = self.myClass;
        [self.navigationController pushViewController:noteVc animated:YES];
    }else if ([btn.titleLabel.text isEqualToString:@"假条"]){
        DWDClassSourceLeavePaperViewController *leaveVc = [[DWDClassSourceLeavePaperViewController alloc] init];
        leaveVc.classId = self.myClass.classId;
        [self.navigationController pushViewController:leaveVc animated:YES];
    }else if ([btn.titleLabel.text isEqualToString:@"成长记录"]){
#warning  GrowUp Reborn
        DWDGrowUpViewController *growVc = [DWDGrowUpViewController new];
        growVc.myClass = self.myClass;
        [self.navigationController pushViewController:growVc animated:YES];
    }else if ([btn.titleLabel.text isEqualToString:@"成绩查询"]){
        DWDClassSourceCheckScoreViewController *checkScoreVc = [[DWDClassSourceCheckScoreViewController alloc] init];
        [self.navigationController pushViewController:checkScoreVc animated:YES];
    }else if ([btn.titleLabel.text isEqualToString:@"作业"]){
        DWDClassSourceHomeWorkViewController *homeWorkVc = 
        [[UIStoryboard storyboardWithName:NSStringFromClass([DWDClassSourceHomeWorkViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDClassSourceHomeWorkViewController class])];
        homeWorkVc.classId = self.myClass.classId;
        homeWorkVc.classModel = self.myClass;
        [self.navigationController pushViewController:homeWorkVc animated:YES];
    }else if ([btn.titleLabel.text isEqualToString:@"接送中心"]) {
        if ([DWDCustInfo shared].isTeacher) {
            DWDTeacherDetailViewController *vc = [[DWDTeacherDetailViewController alloc] init];
            vc.classId = self.myClass.classId;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            DWDPickUpCenterChildTableViewController *childViewVc = [[DWDPickUpCenterChildTableViewController alloc] init];
            childViewVc.classId = self.myClass.classId;
            [self.navigationController pushViewController:childViewVc animated:YES];
        }
        
    }else if ([btn.titleLabel.text isEqualToString:@"我的分组"]){
        DWDClassInnerGroupViewController *vc = [[DWDClassInnerGroupViewController alloc] init];
        vc.classId = self.myClass.classId;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([btn.titleLabel.text isEqualToString:@"班级设置"]){
        
        DWDClassSettingController *sttingVc = [[DWDClassSettingController alloc] init];
        sttingVc.classModel = self.myClass;
        [self.navigationController pushViewController:sttingVc animated:YES];
    }
}*/

- (void)setUpBottomView{
    UILabel * nameLabel = [[UILabel alloc] init];
    nameLabel.text = @"班群成员";
    nameLabel.font = DWDFontContent;
    nameLabel.textColor = DWDRGBColor(102, 102, 102);
    CGSize realSize = [nameLabel.text realSizeWithfont:DWDFontBody];
    _nameLabelRealSize = realSize;
    nameLabel.frame = CGRectMake(pxToW(20), pxToH(25), realSize.width, realSize.height);
    [_bottomView addSubview:nameLabel];
    
    // 箭头
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(DWDScreenW - (pxToW(53)), pxToH(20), pxToW(44), pxToH(44))];
    imageView.image = [UIImage imageNamed:@"ic_clickable_normal"];
    [_bottomView addSubview:imageView];
    
    // 人数
    UIButton *countBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _countBtn = countBtn;
    
    /* 产品说人数隐藏，请别要删掉这段代码，因为哪天产品说人数要显示
    //本地库获取班级总人数，确保数据准确
    [[DWDClassDataBaseTool sharedClassDataBase] getClassMemberCountWithClassId:self.myClass.classId success:^(NSUInteger memberCount) {
        
        [countBtn setTitle:[NSString stringWithFormat:@"%lu人",memberCount] forState:UIControlStateNormal];
    } failure:^{
        
    }];
    countBtn.titleLabel.font = DWDFontContent;
    [countBtn setTitleColor:DWDRGBColor(153, 153, 153) forState:UIControlStateNormal];
     */
    countBtn.frame = CGRectMake(DWDScreenW - 80, pxToH(12), 80, 30);
    [countBtn addTarget:self action:@selector(pushClassMembersViewController) forControlEvents:UIControlEventTouchDown];
    [_bottomView addSubview:countBtn];
    
    CGFloat btnX = 0;
    CGFloat btnY = 0;
    CGFloat btnW = pxToW(80);
    CGFloat btnH = pxToH(80);
    int totleBottomColumn = 7.0;
    CGFloat btnmarginH = pxToW(25);
    CGFloat btnmarginV = pxToH(20);
    

    NSUInteger count = self.members.count;
    if (count >= 14) {
        count = 14;
    }
    for (NSUInteger i = 0; i < count; i ++) {
        DWDClassMember *member;
        member = self.members[i];
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnW, btnH)];
        btn.tag = i;
        
        [btn sd_setBackgroundImageWithURL:[NSURL URLWithString:member.photoKey] forState:UIControlStateNormal placeholderImage:DWDDefault_MeBoyImage];
        
        NSUInteger row = i / totleBottomColumn;
        NSUInteger col = i % totleBottomColumn;
        
        btnX = (pxToW(20)) + col * (btnW + btnmarginH);
        btnY = (pxToH(40)) + realSize.height + row * (btnH + btnmarginV);
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        [btn addTarget:self action:@selector(bottomViewBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:btn];
        [self.btns addObject:btn];
        _buttonCount++;
    }
}


- (void)bottomViewBtnClick:(UIButton *)btn{
    if ([DWDCustInfo shared].isTeacher) {
        NSInteger count = 0;
        if (self.members.count > 14) {
            count = 14;
        }else{
            count = self.members.count;
        }
    }
    
    DWDClassMember *member = self.members[btn.tag];
    DWDPersonDataViewController *vc = [[DWDPersonDataViewController alloc] init];
    if ([self.myClass.isMian isEqualToNumber:@1]) {
        vc.needShowSetGag = YES;
        vc.classId = self.myClass.classId;
    }
    vc.custId = member.custId;
    vc.sourceType = DWDSourceTypeClass;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Button Action
- (void)pushClassMembersViewController
{
    DWDClassMembersViewController *vc = [[DWDClassMembersViewController alloc] init];
    vc.classModel = self.myClass;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushChatVC{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil];
    DWDChatController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
    vc.chatType = DWDChatTypeClass;
    vc.myClass = self.myClass;
    vc.toUserId = self.myClass.classId;
    
    vc.lastVCisClassInfoVC = YES;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - DWDClassMembersViewController Delegate
/** 更新成员 与人数 */
- (void)classMembersViewControllerNeedReload:(DWDClassMembersViewController *)classMembersViewController
{
    [self.membersIds removeAllObjects];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.members =  [[DWDClassDataBaseTool sharedClassDataBase] getClassMemberNoMoreThanFourTeenWithClassId:self.myClass.classId myCustId:[DWDCustInfo shared].custId];
        
        for (DWDClassMember *member in self.members) {
            [self.membersIds addObject: member.custId];
        }
        //设置班级成员VIEW
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_midView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [self setUpMidViewSubviews];
            
            [_bottomView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [self setUpBottomView];
        });
    });
 
}


#pragma mark - DWDClassIntroduceViewController Delegate
- (void)classIntroduceViewController:(DWDClassIntroduceViewController *)classIntroduceViewController introduce:(NSString *)introduce
{
    self.myClass.introduce = introduce;
    [_topView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setUpTopViewSubviews];
}


#pragma mark - <DWDContactSelectViewController>
// 删除班级成员
- (void)contactSelectViewControllerDidSelectContactsForIds:(NSArray *)contactsIds selectContactType:(DWDSelectContactType)type
{
    if (type == DWDSelectContactTypeDeleteEntity) {
        NSDictionary *params = @{@"custId" : [DWDCustInfo shared].custId,
                                 @"classId" : self.myClass.classId,
                                 @"friendCustId" : contactsIds};
        WEAKSELF;
        [[HttpClient sharedClient] postApi:@"ClassMemberRestService/deleteEntity" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
            [weakSelf requedtClassMemberGetListWithClassId:self.myClass.classId];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            hud.labelText = @"删除班级成员失败";
            [hud show:YES];
            [hud hide:YES afterDelay:1.0];
            DWDLog(@"error : %@",error);
        }];

    }
}



#pragma mark Request
- (void)requedtClassMemberGetListWithClassId:(NSNumber *)classId
{
    __weak typeof(self) weakSelf = self;
    [[DWDClassMemberClient sharedClassMemberClient]
     requestClassMemberGetListWithClassId:self.myClass.classId
     success:^(id responseObject) {
         
         __strong typeof(self) strongSelf = weakSelf;
         
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             strongSelf.members =  [[DWDClassDataBaseTool sharedClassDataBase] getClassMemberNoMoreThanFourTeenWithClassId:strongSelf.myClass.classId myCustId:[DWDCustInfo shared].custId];
             
             for (DWDClassMember *member in strongSelf.members) {
                 [strongSelf.membersIds addObject: member.custId];
             }
             //设置班级成员VIEW
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_bottomView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                 [self setUpBottomView];
             });
         });
         
     } failure:^(NSError *error) {
         [DWDProgressHUD showText:@"加载成员失败" afterDelay:1.0f];
     }];

}

// request class function item
- (void)requestClassFunctionItem
{
//    [DWDClassDataHandler getClassFunctionItemListWithCustId:[DWDCustInfo shared].custId classId:@1 success:^(NSMutableArray *data) {
//        
//        self.classFuncItems = [NSMutableArray arrayWithArray:data];
//    } failure:^(NSError *error) {
//        
//    }];
    
#warning 模拟数据,对接口时与服务端协调各种功能对应的"plteCd"值,将"plteCd"与枚举对应,注意原生功能的icon是以"classMidViewBtnNol拼plteCd"作为图片名
    // 服务端未完成,暂时写死,功能"5"为分组,第三方功能为"999"
    self.classFuncItems = [NSMutableArray arrayWithCapacity:0];
    NSArray *titles = @[@"成长记录",@"通知",@"作业",@"假条",@"接送中心",@"班级设置"];
    NSArray *plteCds = @[@0, @1, @2, @3, @4, @6];
    for (int i = 0; i < titles.count; i ++) {
        
        DWDClassFuncModel *func = [[DWDClassFuncModel alloc] init];
        func.plteNm = titles[i];
        func.plteCd = plteCds[i];
        func.ico = @"http://pic2.cxtuku.com/00/07/42/b801acd21d50.jpg";
        func.url = @"https://www.baidu.com";
        [self.classFuncItems addObject:func];
    }
    
    DWDClassFuncModel *lastItem = [[DWDClassFuncModel alloc] init];
    lastItem.plteNm = @"期待更多";
    lastItem.plteCd = @7;
    [self.classFuncItems addObject:lastItem];
    
    [self setUpMidViewSubviews];
    
}

/** 更新头像 */
- (void)requestClassPhotoKeyWithClassId:(NSNumber *)classId photoKey:(NSString *)photoKey
{
    [[DWDRequestClassSetting sharedDWDRequestClassSetting]
     requestClassSettingGetClassInfoCustId:[DWDCustInfo shared].custId
     classId:classId photoKey:photoKey
     success:^(id responseObject) {
      
         self.myClass.photoKey = photoKey;
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [_topView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
             [self setUpTopViewSubviews];
             
         });
         
      
         //1. 改 tb_classes 数据库
         [[DWDClassDataBaseTool sharedClassDataBase] updateClassPhotokeyWithClassId:classId photokey:photoKey success:^{
             
             //发通知、刷新班级列表、与会话列表
             [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationClassListReload object:nil];
             
             //2. 修改recentChat 数据库
             [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] updatePhotokeyWithCusId:classId photokey:photoKey success:^{
                 //3. 刷新界面 ( 班级详情, 班级主页 , 接送中心? ...)
                 [[NSNotificationCenter defaultCenter] postNotificationName:kDWDChangeClassPhotoKeyNotification object:@{@"operationId" : classId,@"changePhotoKey" : photoKey}];
             } failure:^{
                 
             }];
         } failure:^{
             
         }];
         
    } failure:^(NSError *error) {
        
    }];
}
/** 上传头像到阿里 **/
- (void)requestUploadWithAliyun:(UIImage *)image
{
    __block DWDProgressHUD *hud;
    dispatch_async(dispatch_get_main_queue(), ^{
        hud = [DWDProgressHUD showHUD];
        hud.labelText = @"正在上传";
    });
    
    NSString *strUUID = DWDUUID;
    [[DWDAliyunManager sharedAliyunManager] uploadImage:image Name:strUUID progressBlock:^(CGFloat progress) {
        
    } success:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            
        });
        
        NSString *urlStr = [[DWDAliyunManager sharedAliyunManager] getDownloadURLStringWithObjectName:strUUID];
        
        //请求更换头像
        [self requestClassPhotoKeyWithClassId:self.myClass.classId photoKey:urlStr];
       
        
    } Failed:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud showText:@"更改失败" afterDelay:DefaultTime];
        });
        
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y < 0) {
        self.navigationController.navigationBar.hidden = YES;
    } else {
        self.navigationController.navigationBar.hidden = NO;
    }
    
    CGFloat alpha;
    if (self.scrollView.contentOffset.y > (pxToH(400) - 64)) {
        alpha = 1;
    }else{
        alpha = scrollView.contentOffset.y / (pxToH(400) - 64);
        if (alpha < 0) {
            alpha = 0;
        }
    }
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageWithColor:DWDColorMain] renderAtAphla:alpha completion:nil] forBarMetrics:UIBarMetricsDefault];
    
}
@end
