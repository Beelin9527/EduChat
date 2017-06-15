//
//  DWDIntelligentOfficeViewController.m
//  EduChat
//
//  Created by Beelin on 16/12/1.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDIntelligentOfficeViewController.h"
#import "DWDIntClassManagerViewController.h"
#import "DWDIntOfficeViewController.h"

#import "DWDIntSegmentedButton.h"
#import "DWDIntSchoolItemView.h"
#import "DWDIntTriangleView.h"

#import "DWDSchoolDataBaseTool.h"
#import "DWDIntelligenceMenuDatabaseTool.h"
#import "DWDSchoolModel.h"

#import <YYModel.h>
@interface DWDIntelligentOfficeViewController ()<DWDIntSegmentedButtonDelegate>
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIButton *iconBtn;
@property (nonatomic, strong) UIButton *titleBtn;
@property (nonatomic, strong) DWDIntTriangleView *triangleView;

@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) DWDIntClassManagerViewController *claManVC;
@property (nonatomic, strong) DWDIntOfficeViewController *officeVC;

@property (nonatomic, strong) DWDIntSegmentedButton *seg;
@property (nonatomic, strong) DWDIntSchoolItemView *schoolItemView;

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) DWDSchoolModel *schoolModel;
@end

@implementation DWDIntelligentOfficeViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        //request
        [self requestGetSmartOAMenuLastTimeData];
       
        //observer
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMenu:) name:kDWDNotificationSmartOAMenu object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataSource =  [[DWDSchoolDataBaseTool sharedSchoolDataBase] querySchoolAndClass];
    if(self.dataSource.count != 0){
        _schoolModel = self.dataSource[0];
    }else{
        _schoolModel = nil;
    }
    
    [self createControls];
    
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
#pragma mark - Create
- (void)createControls{
   
    //config
    self.navigationItem.titleView =self.titleView;
    [self setupTitleBtnFrameWithSchoolModel:self.schoolModel];

    [self.view addSubview:self.seg];
    [self.view addSubview:self.mainScrollView];
    
    [self addChildViewController:self.claManVC];
    self.claManVC.schoolModel = self.schoolModel;
    [self.mainScrollView addSubview:self.claManVC.view];
    
    [self addChildViewController:self.officeVC];
    self.officeVC.schoolModel= self.schoolModel;
    [self.mainScrollView addSubview:self.officeVC.view];
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


- (UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, DWDScreenW, DWDScreenH - DWDTopHight - 40)];
        _mainScrollView.pagingEnabled = YES;
        _mainScrollView.showsVerticalScrollIndicator = NO;
        _mainScrollView.showsHorizontalScrollIndicator = NO;
        _mainScrollView.bounces = NO;
        _mainScrollView.delegate = self;
        _mainScrollView.contentSize = CGSizeMake(DWDScreenW * 2, _mainScrollView.h);
    }
    return _mainScrollView;
}
- (DWDIntClassManagerViewController *)claManVC{
    if (!_claManVC) {
        _claManVC =  [[DWDIntClassManagerViewController alloc] init];
        _claManVC.view.frame = CGRectMake(0, 0, DWDScreenW, DWDScreenH - DWDTopHight - 40);
    }
    return _claManVC;
}
- (DWDIntOfficeViewController *)officeVC{
    if (!_officeVC) {
        _officeVC =  [[DWDIntOfficeViewController alloc] init];
        _officeVC.view.frame = CGRectMake(DWDScreenW, 0, DWDScreenW, DWDScreenH - DWDTopHight - 40);
    }
    return _officeVC;
}

- (DWDIntSegmentedButton *)seg{
    if (!_seg) {
        _seg = [DWDIntSegmentedButton segmentedControlWithFrame:CGRectMake(0, 0, DWDScreenW, 40) Titles:@[@"班级管理",@"移动办公"] index:0];
        _seg.delegate = self;
    }
    return _seg;
}

- (DWDIntTriangleView *)triangleView{
    if (!_triangleView) {
        _triangleView = [[DWDIntTriangleView alloc] initWithFrame:CGRectMake(DWDScreenW/2.0 - 5.5,44 - 5, 11, 5)];
    }
    return _triangleView;
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
            weakSelf.claManVC.schoolModel = weakSelf.schoolModel;
            weakSelf.officeVC.schoolModel= weakSelf.schoolModel;
            
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


#pragma mark - Notification Implementation
- (void)updateMenu:(NSNotification *)noti{
    //request
    [self requestGetSmartOAMenuLastTimeData];
}

#pragma mark  - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger itemTag = scrollView.contentOffset.x / DWDScreenW;
    [self.seg setupSelectButtonIndex:itemTag];
}
#pragma mark - DWDSegmentedControl Delegate
- (void)segmentedControlIndexButtonView:(DWDIntSegmentedButton *)indexButtonView lickBtnAtTag:(NSInteger)tag{
    if (tag == 0) {
        [self.mainScrollView setContentOffset:CGPointMake(0, 0)  animated:YES];
    }else{
        [self.mainScrollView setContentOffset:CGPointMake(DWDScreenW, 0)  animated:YES];
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
    
    NSDictionary *params = @{@"cid" : [DWDCustInfo shared].custId,// @4010000005168
                             @"ts"    : lastModifyDate};
    
    //创建表
    [[DWDSchoolDataBaseTool sharedSchoolDataBase] reCreateTables];
    [[DWDIntelligenceMenuDatabaseTool sharedIntelligenceDataBase] reCreateTables];
    
    //初始化容器
    NSMutableArray *schoolModelArray = [NSMutableArray array];
    NSMutableArray *classManeagerModelArray = [NSMutableArray array];
    NSMutableArray *officeModelArray = [NSMutableArray array];
    
    [[DWDWebManager sharedManager] getApi:@"plte/getSmartOAMenu" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
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
            
            //移动办公菜单
            NSArray *officeArray = schoolDict[@"mbmnlist"];
            for (int o = 0; o < officeArray.count; o ++) {
                NSDictionary *officeDict = officeArray[o];
                DWDIntelligenceMenuModel *menuModel = [self constructionMenuModel:officeDict schoolId:schoolId classId:nil];
                [officeModelArray addObject:menuModel];
            }
        }
        
        //插入学校表
        [[DWDSchoolDataBaseTool sharedSchoolDataBase] insertSchoolTalbeWithArrayModel:schoolModelArray];
        
        //插入班级管理菜单数据
        BOOL success = [[DWDIntelligenceMenuDatabaseTool sharedIntelligenceDataBase] insertIntelligenceMenuDatabaseWithArrayModel:classManeagerModelArray];
        //插入移动办公菜单数据
        success = [[DWDIntelligenceMenuDatabaseTool sharedIntelligenceDataBase] insertIntelligenceMenuDatabaseWithArrayModel:officeModelArray];
        //存时间戳
        if (success) {
            [[NSUserDefaults standardUserDefaults] setObject:time forKey:lastUpdateKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //获取数据
            _dataSource =  [[DWDSchoolDataBaseTool sharedSchoolDataBase] querySchoolAndClass];
            if(self.dataSource.count != 0){
                //刷新数据
                _schoolModel = self.dataSource[0];
                
                [self setupTitleBtnFrameWithSchoolModel:self.schoolModel];
                self.titleBtn.userInteractionEnabled = YES;
                self.iconBtn.hidden = NO;
                
                self.claManVC.schoolModel = self.schoolModel;
                self.officeVC.schoolModel= self.schoolModel;
                
                if (self.dataSource.count == 1) {
                    self.titleBtn.userInteractionEnabled = NO;
                    self.iconBtn.hidden = YES;
                }
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];
}


@end
