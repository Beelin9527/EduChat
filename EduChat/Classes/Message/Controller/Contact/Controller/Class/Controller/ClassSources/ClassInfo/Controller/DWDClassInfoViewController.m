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

#import "DWDClassInfoTopView.h"
#import "DWDClassInfoMidView.h"
#import "DWDClassInfoBottomView.h"

#import "DWDMyClassModel.h"

#import "NSString+Extension.h"
#import "DWDClassInfoMidViewButton.h"
#import "UIImage+Utils.h"
#import <Masonry/Masonry.h>

@interface DWDClassInfoViewController () <DWDContactSelectViewControllerDelegate>
@property (nonatomic , weak) DWDClassInfoTopView *topView;
@property (nonatomic , weak) DWDClassInfoMidView *midView;
@property (nonatomic , weak) DWDClassInfoBottomView *bottomView;
@property (nonatomic , strong) NSArray *titles;

@end

@implementation DWDClassInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.title = [NSString stringWithFormat:@"%@的班级主页",_myClass.gradeId];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more_normal"] style:UIBarButtonItemStyleDone target:self action:@selector(rightBarBtnClick)];
    
    
    [self setUpMySubviews];

    
}

- (void)rightBarBtnClick{
    DWDLogFunc;
    // 跳转班级详情界面
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

- (void)setUpMySubviews{
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    backgroundView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backgroundView];
    
    DWDClassInfoTopView *topView = [[DWDClassInfoTopView alloc] init];
    DWDClassInfoMidView *midView = [[DWDClassInfoMidView alloc] init];
    DWDClassInfoBottomView *bottomView = [[DWDClassInfoBottomView alloc] init];
    topView.backgroundColor = DWDRandomColor;
    
    _topView = topView;
    _midView = midView;
    _bottomView = bottomView;
    
    [backgroundView addSubview:topView];
    [backgroundView addSubview:midView];
    [backgroundView addSubview:bottomView];
    
    [topView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView.superview.top);
        make.left.equalTo(topView.superview.left);
        make.right.equalTo(topView.superview.right);
        make.height.equalTo(@(pxToH(560)));
    }];
    
    [midView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView.bottom);
        make.left.equalTo(midView.superview.left);
        make.right.equalTo(midView.superview.right);
        make.height.equalTo(@(pxToH(376)));
    }];

    [bottomView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(midView.bottom).offset(pxToH(20));
        make.left.equalTo(bottomView.superview.left);
        make.right.equalTo(bottomView.superview.right);
        make.height.equalTo(@(pxToH(270)));
    }];
    
    [self setUpTopViewSubviews];
    [self setUpMidViewSubviews];
    [self setUpBottomView];
    
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
}

- (void)setUpTopViewSubviews{
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"AvatarOther"];
    [_topView addSubview:imageView];
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:0.5];
    [_topView addSubview:view];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"宣言:每天都是一个起点,每天都有一点进步哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈";
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
    
}

- (void)setUpMidViewSubviews{
    NSArray *titles = @[@"成长记录",@"通知",@"作业",@"成绩查询",@"假条",@"我的分组",@"班级设置",@"期待更多"];
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
        
        NSString *imageName = [NSString stringWithFormat:@"classMidViewBtnNol%d",i];
        NSString *imagePreName = [NSString stringWithFormat:@"classMidViewBtnPre%d",i];
        if (i == titles.count - 1) {
            [btn setTitleColor:DWDRGBColor(221, 221, 221) forState:UIControlStateNormal];
        }else{
            [btn setTitleColor:DWDRGBColor(102, 102, 102) forState:UIControlStateNormal];
        }
        
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:imagePreName] forState:UIControlStateHighlighted];
        
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)btnClick:(UIButton *)btn{
    if ([btn.titleLabel.text isEqualToString:@"通知"]) {
        DWDClassSourceClassNotificationViewController *noteVc = [[DWDClassSourceClassNotificationViewController alloc] init];
        [self.navigationController pushViewController:noteVc animated:YES];
    }else if ([btn.titleLabel.text isEqualToString:@"假条"]){
        DWDClassSourceLeavePaperViewController *leaveVc = [[DWDClassSourceLeavePaperViewController alloc] init];
        [self.navigationController pushViewController:leaveVc animated:YES];
    }else if ([btn.titleLabel.text isEqualToString:@"成长记录"]){
        DWDClassSourceGrowupRecordViewController *growVc = [[DWDClassSourceGrowupRecordViewController alloc] init];
        growVc.myClass = self.myClass;
        [self.navigationController pushViewController:growVc animated:YES];
    }else if ([btn.titleLabel.text isEqualToString:@"成绩查询"]){
        DWDClassSourceCheckScoreViewController *checkScoreVc = [[DWDClassSourceCheckScoreViewController alloc] init];
        [self.navigationController pushViewController:checkScoreVc animated:YES];
    }else if ([btn.titleLabel.text isEqualToString:@"作业"]){
        DWDClassSourceHomeWorkViewController *homeWorkVc = 
        [[UIStoryboard storyboardWithName:NSStringFromClass([DWDClassSourceHomeWorkViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDClassSourceHomeWorkViewController class])];
        homeWorkVc.classId = self.myClass.gradeId;
        [self.navigationController pushViewController:homeWorkVc animated:YES];
    }else if ([btn.titleLabel.text isEqualToString:@"我的分组"]){
        DWDClassInnerGroupViewController *vc = [[DWDClassInnerGroupViewController alloc] init];
        vc.classId = self.myClass.gradeId;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([btn.titleLabel.text isEqualToString:@"班级设置"]){
        
        DWDClassSettingController *sttingVc = [[DWDClassSettingController alloc] init];
        [self.navigationController pushViewController:sttingVc animated:YES];
    }
}

- (void)setUpBottomView{
    UILabel * nameLabel = [[UILabel alloc] init];
    nameLabel.text = @"班级成员";
    nameLabel.font = DWDFontContent;
    nameLabel.textColor = DWDRGBColor(102, 102, 102);
    CGSize realSize = [nameLabel.text realSizeWithfont:DWDFontBody];
    nameLabel.frame = CGRectMake(pxToW(20), pxToH(25), realSize.width, realSize.height);
    [_bottomView addSubview:nameLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(DWDScreenW - (pxToW(53)), pxToH(20), pxToW(44), pxToH(44))];
    imageView.image = [UIImage imageNamed:@"ic_clickable_normal@2x"];
    [_bottomView addSubview:imageView];
    
    UILabel *countLabel = [[UILabel alloc] init];
    countLabel.text = @"20人";
    countLabel.font = DWDFontContent;
    countLabel.textColor = DWDRGBColor(153, 153, 153);
    CGSize countLabelRealSize = [countLabel.text realSizeWithfont:DWDFontBody];
    countLabel.frame = CGRectMake(DWDScreenW - (pxToW(53)) - countLabelRealSize.width, pxToH(20), countLabelRealSize.width, countLabelRealSize.height);
    [_bottomView addSubview:countLabel];
    
    CGFloat btnX = 0;
    CGFloat btnY = 0;
    CGFloat btnW = pxToW(80);
    CGFloat btnH = pxToH(80);
    int totleBottomColumn = 7.0;
    CGFloat btnmarginH = pxToW(25);
    CGFloat btnmarginV = pxToH(20);
    
    for (NSUInteger i = 0; i < 14; i ++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnW, btnH)];
        btn.tag = i;
        if (i == 12) {
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_add_image_group_detail_normal"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_add_image_group_detail_press"] forState:UIControlStateHighlighted];
        }else if (i == 13){
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_delete_image_group_detail_normal"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"btn_delete_image_group_detail_press"] forState:UIControlStateHighlighted];
        }else{
            [btn setBackgroundImage:[UIImage imageNamed:@"AvatarOther"] forState:UIControlStateNormal];
        }
        
        NSUInteger row = i / totleBottomColumn;
        NSUInteger col = i % totleBottomColumn;
        
        btnX = (pxToW(20)) + col * (btnW + btnmarginH);
        btnY = (pxToH(40)) + realSize.height + row * (btnH + btnmarginV);
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        [btn addTarget:self action:@selector(bottomViewBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:btn];
    }
}

- (void)bottomViewBtnClick:(UIButton *)btn{
    DWDLogFunc;
    if (btn.tag == 12 || btn.tag == 13) {
        // 弹出通讯录控制器
        DWDContactSelectViewController *vc = [[DWDContactSelectViewController alloc]init];
        vc.delegate = self;
        vc.type = DWDSelectContactTypeCreate;
        DWDNavViewController *naviVC = [[DWDNavViewController alloc]initWithRootViewController:vc];
        [self.navigationController presentViewController:naviVC animated:YES completion:nil];
    }
}

#pragma mark - <DWDContactSelectViewController>
- (void)contactSelectViewControllerDidSelectContactsForCreate:(NSArray *)contacts{
    DWDLog(@"FFFFFFFFFFFFFFFF%@",contacts);
}
@end
