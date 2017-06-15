//
//  DWDIntParentClassController.m
//  EduChat
//
//  Created by Beelin on 17/1/4.
//  Copyright © 2017年 dwd. All rights reserved.
//

#import "DWDIntParentClassController.h"
#import "DWDChatController.h"

#import "DWDGrowUpViewController.h"
#import "DWDClassSourceClassNotificationViewController.h"
#import "DWDClassSourceHomeWorkViewController.h"
#import "DWDClassSourceLeavePaperViewController.h"
#import "DWDTeacherDetailViewController.h"
#import "DWDPickUpCenterChildTableViewController.h"
#import "DWDClassSettingController.h"
#import "DWDClassIntroduceViewController.h"

#import "DWDIntFunctionItemCell.h"
#import "DWDIntHeaderClassInfoCell.h"

#import "DWDIntClassMenuView.h"
#import "DWDIntTriangleView.h"
#import "DWDIntSchoolItemView.h"
#import "DWDIntClassItemView.h"

#import "DWDSchoolModel.h"
#import "DWDClassModel.h"
#import "DWDIntelligenceMenuModel.h"

#import "DWDIntelligentOfficeDataHandler.h"

#import "DWDSchoolDataBaseTool.h"
#import "DWDClassDataBaseTool.h"
#import "DWDIntelligenceMenuDatabaseTool.h"

#import <YYModel.h>

@interface DWDIntParentClassController ()<DWDIntClassItemViewDelegate,DWDIntClassMenuViewDelegate,DWDIntFunctionItemCellDelegate,DWDIntHeaderClassInfoCellDelegate>
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIButton *iconBtn;
@property (nonatomic, strong) UIButton *titleBtn;
@property (nonatomic, strong) DWDIntTriangleView *triangleView;
@property (nonatomic, strong) DWDIntSchoolItemView *schoolItemView;
@property (nonatomic, strong) UIButton *comeinClassChatBtn; //进入班级聊天按钮
@property (nonatomic, strong) DWDIntClassItemView *intClassItemView;

@property (nonatomic, assign) CGPoint comeinClassChatBtnCenterPoint;

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSArray *menuDataSource;
@property (nonatomic, strong) NSNumber *classId;

@property (nonatomic, strong) DWDSchoolModel *schoolModel;
@property (nonatomic, strong) DWDClassModel *classModel;
/**
 菜单模型
 目前只为记录所点击菜单的menuCode；
 */
@property (nonatomic, strong) DWDIntelligenceMenuModel *menuModel;

@end

@implementation DWDIntParentClassController

- (instancetype)init
{
    self = [super init];
    if (self) {
        //request
        [self requestGetSmartOAMenuLastTimeData];
        
        //observer
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMenu:) name:kDWDNotificationSmartOAMenu object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCalssModel:) name:kDWDNotificationClassManagerClassModel object:nil];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupControls];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setup UI
- (void)setupControls{
    //config
    self.navigationItem.titleView =self.titleView;
    [self setupTitleBtnFrameWithSchoolModel:self.schoolModel];
    
    [self.view addSubview:self.intClassItemView];
    
    self.tableView.frame = CGRectMake(0, 40, DWDScreenW, DWDScreenH - DWDTopHight - DWDToolBarHeight);
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.comeinClassChatBtn];

}

#pragma mark - Setter
- (void)setSchoolModel:(DWDSchoolModel *)schoolModel{
    _schoolModel = schoolModel;
    self.intClassItemView.dataSource = _schoolModel.arrayClassModel;
    
    if (schoolModel.arrayClassModel.count <= 1) {
        self.tableView.frame = CGRectMake(0, 0, DWDScreenW, DWDScreenH - DWDTopHight  - DWDToolBarHeight);
    }else{
        self.tableView.frame = CGRectMake(0, 40, DWDScreenW, DWDScreenH - DWDTopHight - 40 - DWDToolBarHeight);
    }
    
    //查询班级管理菜单模块
    if (_schoolModel) {
        DWDIntClassModel *model = _schoolModel.arrayClassModel[0];
        
        if ([model.classId isEqualToNumber:@0]){
            //空模板学校
            self.menuDataSource =  [[DWDIntelligenceMenuDatabaseTool sharedIntelligenceDataBase] queryClassManegerMenuWithSchoolId:@(schoolIdDefault)];
            //come in chat button hidden
            self.comeinClassChatBtn.hidden = YES;
        } else if ([model.classId isEqualToNumber:@1]) {
            self.menuDataSource = [[DWDIntelligenceMenuDatabaseTool sharedIntelligenceDataBase] queryClassManegerMenuWithClassId:@1];//关于这个classId == 1,这个只能去看数据库才会清楚。当你理解了产品之后，你就会原谅哥为何这么写
            //come in chat button hidden
            self.comeinClassChatBtn.hidden = YES;
        }else{
            self.menuDataSource = [[DWDIntelligenceMenuDatabaseTool sharedIntelligenceDataBase] queryClassManegerMenuWithClassId:_schoolModel.arrayClassModel[0].classId];
            //come in chat button show
            self.comeinClassChatBtn.hidden = NO;
        }
    }
    
    //查询班级信息
    self.classId = [_schoolModel.arrayClassModel firstObject].classId;
    _classModel = [[DWDClassDataBaseTool sharedClassDataBase] getClassInfoWithClassId:self.classId myCustId:[DWDCustInfo shared].custId];
    
    [self.tableView reloadData];
    
}

#pragma mark - Getter
- (UIView *)titleView{
    if (!_titleView) {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
        [_titleView addSubview:self.titleBtn];
        [_titleView addSubview:self.iconBtn];
    }
    return _titleView;
}
- (UIButton *)titleBtn{
    if (!_titleBtn) {
        _titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _titleBtn.titleLabel.font = DWDFontBody;
        _titleBtn.selected = NO;
        [_titleBtn setTitle:@"多维度教育社交" forState:UIControlStateNormal];
        _titleBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [_titleBtn addTarget:self action:@selector(clickTitle:) forControlEvents:UIControlEventTouchDown];
    }
    return _titleBtn;
}
- (UIButton *)iconBtn{
    if (!_iconBtn) {
        _iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _iconBtn.size = CGSizeMake(30, 22);
        _iconBtn.hidden = YES;
        [_iconBtn setImage:[UIImage imageNamed:@"ic_pull_down_office"] forState:UIControlStateNormal];
        [_iconBtn addTarget:self action:@selector(clickTitle:) forControlEvents:UIControlEventTouchDown];
    }
    return _iconBtn;
}

- (DWDIntTriangleView *)triangleView{
    if (!_triangleView) {
        _triangleView = [[DWDIntTriangleView alloc] initWithFrame:CGRectMake(DWDScreenW/2.0 - 5.5,44 - 5, 11, 5)];
    }
    return _triangleView;
}

- (DWDIntClassItemView *)intClassItemView{
    if (!_intClassItemView) {
        _intClassItemView = [[DWDIntClassItemView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, 40)];
        _intClassItemView.delegate = self;
    }
    return _intClassItemView;
}

- (UIButton *)comeinClassChatBtn{
    if (!_comeinClassChatBtn) {
        _comeinClassChatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _comeinClassChatBtn.frame = CGRectMake(DWDScreenW - 92, self.view.h - 40 - 40 - 94.5 - DWDTopHight*2, 94.5, 92);
        _comeinClassChatBtnCenterPoint = _comeinClassChatBtn.center;
        [_comeinClassChatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_comeinClassChatBtn setTitle:@"进入聊天" forState:UIControlStateNormal];
        _comeinClassChatBtn.titleLabel.font = DWDFontBody;
        _comeinClassChatBtn.titleEdgeInsets = UIEdgeInsetsMake(45, 10, 0, 0);
        [_comeinClassChatBtn setBackgroundImage:[UIImage imageNamed:@"img_chat_normal"] forState:UIControlStateNormal];
        [_comeinClassChatBtn setBackgroundImage:[UIImage imageNamed:@"img_chat_press"] forState:UIControlStateHighlighted];
        [_comeinClassChatBtn addTarget:self action:@selector(pushChatVC) forControlEvents:UIControlEventTouchUpInside];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [_comeinClassChatBtn addGestureRecognizer:pan];
    }
    return _comeinClassChatBtn;
}

#pragma mark - Event Response
- (void)clickTitle:(UIButton *)sender{
    sender.selected = !sender.selected;
    //同步两选择按钮状态
    if (self.titleBtn != sender) {
        self.titleBtn.selected = sender.selected;
    }else if (self.iconBtn != sender){
        self.iconBtn.selected = sender.selected;
    }
    
    if (sender.selected) {
        [self.navigationController.navigationBar addSubview:self.triangleView];
        
        self.schoolItemView = [[DWDIntSchoolItemView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, DWDScreenH - DWDTopHight - DWDToolBarHeight)];
        self.schoolItemView.dataSource = self.dataSource;
        //call back
        __weak typeof(self) weakSelf = self;
        [self.schoolItemView setSelectItemBlock:^(DWDSchoolModel *model) {
            //点击当前学校无需刷新
            if(weakSelf.schoolModel == model) return;
            
            weakSelf.schoolModel = model;
            
            [weakSelf.titleBtn setTitle:model.schoolName forState:UIControlStateNormal];
            
            [weakSelf setupTitleBtnFrameWithSchoolModel:model];
        }];
        [self.schoolItemView setRemoveFromSuperViewBlock:^{
            [weakSelf.triangleView removeFromSuperview];
            weakSelf.iconBtn.transform = CGAffineTransformIdentity;
            weakSelf.titleBtn.selected = NO;
            weakSelf.iconBtn.selected = NO;
        }];
        
        self.iconBtn.transform = CGAffineTransformMakeRotation(M_PI);
        [self.view addSubview:self.schoolItemView];
    }else{
        [self.triangleView removeFromSuperview];
        [self.schoolItemView removeFromSuperview];
        self.iconBtn.transform = CGAffineTransformIdentity;
    }
}

- (void)pushChatVC{
    if(!self.classModel.classId) return;
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil];
    DWDChatController *chatVc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
    chatVc.chatType = DWDChatTypeClass;
    chatVc.toUserId = self.classModel.classId;
    chatVc.myClass  = self.classModel;
    chatVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVc animated:YES];
}
- (void)panAction:(UIPanGestureRecognizer *)pan{
    CGPoint point = [pan translationInView:self.view];
    if (pan.state == UIGestureRecognizerStateBegan) {
        
    }else if (pan.state == UIGestureRecognizerStateChanged){
        CGFloat y = self.comeinClassChatBtnCenterPoint.y + point.y;
        if (y > (DWDScreenH - 44 - 64 - 10 - pan.view.bounds.size.height)) {
            y = DWDScreenH - 44 - 64 - 10 - pan.view.bounds.size.height;
        } else {
            if (y < (70)) {
                y = 70;
            }
        }
        pan.view.center = CGPointMake(DWDScreenW - 92 * 0.5, y);
    }else if (pan.state == UIGestureRecognizerStateEnded){
        self.comeinClassChatBtnCenterPoint = pan.view.center;
    }
}



#pragma mark - Private Method
/**
 构造班级管理菜单模型
 */
- (DWDIntelligenceMenuModel *)constructionMenuModel:(NSDictionary *)dict schoolId:(NSNumber *)schoolId classId:(NSNumber *)classId{
    DWDIntelligenceMenuModel *menuModel = [DWDIntelligenceMenuModel yy_modelWithDictionary:dict];
    menuModel.schoolId = schoolId;
    menuModel.classId = classId;
    menuModel.sole = [NSString stringWithFormat:@"%@%@%@",menuModel.schoolId,menuModel.classId,menuModel.menuCode];
    return menuModel;
}

/**
 setup titleBtn frame and icon originX
 */
- (void)setupTitleBtnFrameWithSchoolModel:(DWDSchoolModel *)schoolModel{
    [self.titleBtn setTitle:schoolModel.schoolName forState:UIControlStateNormal];
    
    CGFloat titleW = [schoolModel.schoolName boundingRectWithfont:DWDFontBody].width;
    titleW = MIN(titleW, 200);//取最小值
    self.titleBtn.origin = CGPointMake(_titleView.w/2.0 - titleW/2.0, 0);
    self.titleBtn.size = CGSizeMake(titleW, self.titleView.h);
    
    [self.iconBtn setX: CGRectGetMaxX(self.titleBtn.frame) + 5];
}

/**
 跳转菜单功能控制器
 */
- (void)pushFuctionViewContorllerWithMenuCode:(DWDIntelligenceMenuModel *)model{
    //判断code
    UIViewController *functionVC = nil;
    if ([model.menuCode isEqualToString:kDWDIntMenuCodeClassManagementGrowth]) {
        DWDGrowUpViewController *growVc = [[DWDGrowUpViewController alloc] init];
        growVc.myClass = self.classModel;
        functionVC = growVc;
        
    }else if ([model.menuCode isEqualToString:kDWDIntMenuCodeClassManagementNotice]) {
        DWDClassSourceClassNotificationViewController *noteVc = [[DWDClassSourceClassNotificationViewController alloc] init];
        noteVc.myClass = self.classModel;
        functionVC = noteVc;
        
    }else if ([model.menuCode isEqualToString:kDWDIntMenuCodeClassManagementHomework]) {
        DWDClassSourceHomeWorkViewController *homeWorkVc =
        [[UIStoryboard storyboardWithName:NSStringFromClass([DWDClassSourceHomeWorkViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDClassSourceHomeWorkViewController class])];
        homeWorkVc.classId = self.classModel.classId;
        homeWorkVc.classModel = self.classModel;
        functionVC = homeWorkVc;
        
    }else if ([model.menuCode isEqualToString:kDWDIntMenuCodeClassManagementLeave]) {
        
        DWDClassSourceLeavePaperViewController *leaveVc = [[DWDClassSourceLeavePaperViewController alloc] init];
        leaveVc.classId = self.classModel.classId;
        leaveVc.classModel = self.classModel;
        functionVC = leaveVc;
        
    }else if ([model.menuCode isEqualToString:kDWDIntMenuCodeClassManagementTransferCenter]) {
        if ([DWDCustInfo shared].isTeacher) {
            DWDTeacherDetailViewController *vc = [[DWDTeacherDetailViewController alloc] init];
            vc.classId = self.classModel.classId;
            vc.classModel = self.classModel;
            functionVC = vc;
        }else{
            DWDPickUpCenterChildTableViewController *childViewVc = [[DWDPickUpCenterChildTableViewController alloc] init];
            childViewVc.classId = self.classModel.classId;
            functionVC = childViewVc;
        }
        
    }else if ([model.menuCode isEqualToString:kDWDIntMenuCodeClassManagementClassSetting]) {
        DWDClassSettingController *sttingVc = [[DWDClassSettingController alloc] init];
        sttingVc.classModel = self.classModel;
        functionVC = sttingVc;
        
    }
    if (functionVC != nil) {
        functionVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:functionVC animated:YES];
    }
}

/**
 alertControlller
 */
- (void)createAlertControllerWithMessage:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:sureAction];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Notification Implementation
- (void)updateMenu:(NSNotification *)noti{
    //request
    [self requestGetSmartOAMenuLastTimeData];
}

//更新当前内存classModel
- (void)updateCalssModel:(NSNotification *)noti{
    if (self.classModel) {
        //重新查询班级信息
        self.classId = self.classModel.classId;
        _classModel = [[DWDClassDataBaseTool sharedClassDataBase] getClassInfoWithClassId:self.classId myCustId:[DWDCustInfo shared].custId];
        [self.tableView reloadData];
    }
}

#pragma mark - TableView Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.menuDataSource.count == 0){
        return 1;
    }
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        DWDIntHeaderClassInfoCell *cell = [DWDIntHeaderClassInfoCell cellWithTableView:tableView];
        cell.headertype = DWDClassManagerHeaderType;
        cell.delegate = self;
        cell.classModel = self.classModel;
        return cell;
    }else if (indexPath.section == 1){
        DWDIntFunctionItemCell *itemCell = [DWDIntFunctionItemCell cellWithTableView:tableView headTitle:@"班级管理"];
        itemCell.delegate = self;
        NSArray *arr = self.menuDataSource[indexPath.section -1];
        itemCell.dataSource = arr.mutableCopy;
        return itemCell;
    }
    return nil;
}

#pragma mark - TableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 350/2.0;
    }
    NSArray *array = self.menuDataSource[indexPath.section - 1];
    
    return [array.lastObject cellHeight];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
//设置区尾颜色
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(nonnull UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
    v.backgroundView.backgroundColor = DWDColorBackgroud;
}

#pragma mark - DWDIntHeaderClassInfoCell Delegate
- (void)intHeaderClassInfoCell:(DWDIntHeaderClassInfoCell *)cell clickIntroWithClassModel:(DWDClassModel *)classModel{
    DWDClassIntroduceViewController *vc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDClassIntroduceViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDClassIntroduceViewController class])];
    vc.classModel = self.classModel;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - DWDIntClassItemView Delegate
- (void)intClassItemViewClickMenuButton:(DWDIntClassItemView *)intClassItemView{
    DWDIntClassMenuView *menu = [DWDIntClassMenuView IntClassMenuViewWithFrame:CGRectMake(0, 0, DWDScreenW, DWDScreenH - DWDTopHight - DWDToolBarHeight - 40) dataSource:self.schoolModel.arrayClassModel];
    menu.delegate = self;
    
    [self.view addSubview:menu];
}
- (void)intClassItemView:(DWDIntClassItemView *)intClassItemView selectItem:(DWDIntClassModel *)model{
    if ([self.classId isEqualToNumber: model.classId]) return;
    
    //查询班级管理菜单模块
    self.menuDataSource = [[DWDIntelligenceMenuDatabaseTool sharedIntelligenceDataBase] queryClassManegerMenuWithClassId:model.classId];
    
    //查询班级信息
    self.classId = model.classId;
    _classModel = [[DWDClassDataBaseTool sharedClassDataBase] getClassInfoWithClassId:self.classId myCustId:[DWDCustInfo shared].custId];
    
    [self.tableView reloadData];
    
}

#pragma mark - DWDIntClassMenuView Delegate
- (void)intClassMenuView:(DWDIntClassMenuView *)intClassMenuView selectItem:(DWDIntClassModel *)model{
    if ([self.classId isEqualToNumber: model.classId]) return;
    
    //查询班级管理菜单模块
    self.menuDataSource = [[DWDIntelligenceMenuDatabaseTool sharedIntelligenceDataBase] queryClassManegerMenuWithClassId:model.classId];
    
    //查询班级信息
    self.classId = model.classId;
    _classModel = [[DWDClassDataBaseTool sharedClassDataBase] getClassInfoWithClassId:self.classId myCustId:[DWDCustInfo shared].custId];
    
    //更新intClassItemView 选中按钮
    NSInteger index = [self.schoolModel.arrayClassModel indexOfObject:model];
    [self.intClassItemView updateSelectItemWithIndex:index];
    
    [self.tableView reloadData];
}


#pragma mark - DWDIntFunctionItemCell Delegate
- (void)intFunctionItemCell:(DWDIntFunctionItemCell *)intFunctionItemCell selectItemWithModel:(DWDIntelligenceMenuModel *)model{
    self.menuModel = model;
    
    //判断是否中原生与H5类型
    if([self.menuModel.modeType isEqualToNumber:@0]){
        if ([self.menuModel.isOpen isEqualToNumber:@1]) {
            [self pushFuctionViewContorllerWithMenuCode:self.menuModel];
        }else if ([self.menuModel.isOpen isEqualToNumber:@2]){
            //reqeust
            [self requestGetAlertWithMenuCode:model.menuCode];
        }else if ([self.menuModel.isOpen isEqualToNumber:@6]){
            //reqeust
            [self createAlertControllerWithMessage:@"您还未加入任何班级，快去添加班级吧！"];
        }else if ([self.menuModel.isOpen isEqualToNumber:@7]){
            //我期待，有一天爱会回来。期待更多不作事件
            return;
        }
    }else if ([self.menuModel.modeType isEqualToNumber:@1]){
        if ([self.menuModel.isOpen isEqualToNumber:@1]) {
            
        }else if ([self.menuModel.isOpen isEqualToNumber:@2]){
            //reqeust
            [self requestGetAlertWithMenuCode:model.menuCode];
        }else if ([self.menuModel.isOpen isEqualToNumber:@6]){
            //reqeust
            [self createAlertControllerWithMessage:@"您还未加入任何班级，快去添加班级吧！"];
        }else if ([self.menuModel.isOpen isEqualToNumber:@7]){
            //我期待，有一天爱会回来。期待更多不作事件
            return;
        }
    }
}

#pragma mark - RequestData
/** 获取学校、班级及班级管理菜单 */
- (void)requestGetSmartOAMenuLastTimeData{
    if (![DWDCustInfo shared].custId) return;
    
    NSString *lastUpdateKey = [NSString stringWithFormat:@"%@-%@", @"getSmartOAMenuLastTime", [DWDCustInfo shared].custId];
    
    NSNumber *lastModifyDate =
    [[NSUserDefaults standardUserDefaults] objectForKey:lastUpdateKey];
    NSLog(@"lastModifyDate : %@",lastModifyDate);
    if (!lastModifyDate) lastModifyDate = @(0);
    
    NSDictionary *params = @{@"cid" : [DWDCustInfo shared].custId,
                             @"ts"    : lastModifyDate};
    
    //创建表
    [[DWDSchoolDataBaseTool sharedSchoolDataBase] reCreateTables];
    [[DWDIntelligenceMenuDatabaseTool sharedIntelligenceDataBase] reCreateTables];
    
    [[DWDWebManager sharedManager] getApi:@"plte/getSmartOAMenu" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //初始化容器
        NSMutableArray *schoolModelArray = [NSMutableArray array];
        NSMutableArray *classManeagerModelArray = [NSMutableArray array];
        
        //学校数组
        NSArray *schoolArray = responseObject[@"data"][@"schls"];
        
        //时间戳
        NSNumber *time = responseObject[@"data"][@"ts"];
        
        for (int i = 0; i < schoolArray.count; i ++) {
            //学校
            NSDictionary *schoolDict = schoolArray[i];
            NSNumber *schoolId = schoolDict[@"sid"];
            NSString *schoolName = schoolDict[@"schlNm"];
            
            
            //班级管理菜单数据
            NSArray *classManeagerArray = schoolDict[@"cgmnlist"];
            
            //班级
            NSArray *classArray = schoolDict[@"cglist"];
            if (classArray.count == 0) {//班级为空、虚拟一个数组。目的是继续遍历班级管理菜单
                classArray = @[@{@"cgid" : [NSNull null],
                                 @"cgNm" : [NSNull null]}];
            }
            for (int j = 0; j < classArray.count; j ++) {
                NSDictionary *classDict = classArray[j];
                //构造学校模型
                DWDSchoolModel *schoolModel = [[DWDSchoolModel alloc] init];
                schoolModel.schoolId = schoolId;
                schoolModel.schoolName = schoolName;
                schoolModel.classId = classDict[@"cgid"];
                schoolModel.className = classDict[@"cgNm"];
                
                //加入容器
                [schoolModelArray addObject:schoolModel];
                
                //遍历班级管理菜单
                for (int k = 0; k < classManeagerArray.count; k ++) {
                    NSDictionary *classManeagerDict = classManeagerArray[k];
                    //构造班级管理菜单模型
                    DWDIntelligenceMenuModel *menuModel = [self constructionMenuModel:classManeagerDict schoolId:schoolId classId:schoolModel.classId];
                    [classManeagerModelArray addObject:menuModel];
                }
                
            }
            
        }
        
        //插入学校表
        [[DWDSchoolDataBaseTool sharedSchoolDataBase] insertSchoolTalbeWithArrayModel:schoolModelArray];
        
        //插入班级管理菜单数据
        BOOL success = [[DWDIntelligenceMenuDatabaseTool sharedIntelligenceDataBase] insertIntelligenceMenuDatabaseWithArrayModel:classManeagerModelArray];
        
        //存时间戳
        if (success) {
            [[NSUserDefaults standardUserDefaults] setObject:time forKey:lastUpdateKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //获取数据
            _dataSource =  [[DWDSchoolDataBaseTool sharedSchoolDataBase] querySchoolAndClass];
            if(self.dataSource.count != 0){
                //刷新数据 setSchoolModel方法处理逻辑及reload data
                self.schoolModel = self.dataSource[0];
                
                [self setupTitleBtnFrameWithSchoolModel:self.schoolModel];
                self.titleBtn.userInteractionEnabled = YES;
                self.iconBtn.hidden = NO;
                
                if (self.dataSource.count == 1) {
                    self.titleBtn.userInteractionEnabled = NO;
                    self.iconBtn.hidden = YES;
                }
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];
}

/**
 弹出功能简介
 */
- (void)requestGetAlertWithMenuCode:(NSString *)code{
    [DWDIntelligentOfficeDataHandler requestGetAlertWithCid:[DWDCustInfo shared].custId sid:self.schoolModel.schoolId mncd:code sta:nil targetController:self success:^{
        
    } failure:^(NSError *error) {
        
    }];
}

@end
