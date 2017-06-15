//
//  DWDIntOfficeViewController.m
//  EduChat
//
//  Created by Beelin on 16/12/1.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDIntOfficeViewController.h"

//智能通讯录
#import "DWDIntContactController.h"
#import "DWDIntH5ViewController.h"
#import "DWDIntNoticeListController.h"

#import "DWDIntFunctionItemCell.h"
#import "DWDOfficeHeaderInfoTableViewCell.h"

#import "DWDIntelligenceMenuModel.h"
#import "DWDSchoolModel.h"

#import "DWDIntelligentOfficeDataHandler.h"

#import <Masonry.h>

#import "DWDKeyChainTool.h"
#import "DWDIntelligenceMenuDatabaseTool.h"

#import "DWDClassModel.h"
#import "DWDIntH5Model.h"

//通知公告
#import "DWDIntAnnouncementsViewController.h"

#import "DWDIntMessageController.h" //test
@interface DWDIntOfficeViewController ()<DWDIntFunctionItemCellDelegate>

/**
 菜单模型
 目前只为记录所点击菜单的menuCode；
 */
@property (nonatomic, strong) DWDIntelligenceMenuModel *menuModel;

/**
 菜单状态值
 1 启用（正常）2未开通（未开发完成）3未激活（开发完成，学校未开通）4未交费5未续费6未加入任何班级
 */
@property (nonatomic, strong) NSNumber *staval;

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) DWDClassModel *classModel;

@property (nonatomic, strong) NSNumber *classId;

@property (nonatomic, strong) DWDIntH5Model *hModel;

@end

static NSString *officeHeaderInfoTableViewCellID = @"officeHeaderInfoTableViewCellID";
@implementation DWDIntOfficeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createControls];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - Create
- (void)createControls{
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DWDOfficeHeaderInfoTableViewCell class]) bundle:nil] forCellReuseIdentifier:officeHeaderInfoTableViewCellID];
    self.tableView.frame = CGRectMake(0, 0, DWDScreenW, DWDScreenH - DWDTopHight - 40 - DWDToolBarHeight);
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];
}

#pragma mark - Setter
- (void)setSchoolModel:(DWDSchoolModel *)schoolModel{
    _schoolModel = schoolModel;
    
    //获取移动办公菜单
    if (_schoolModel) {
        NSArray *dataSource = [[DWDIntelligenceMenuDatabaseTool sharedIntelligenceDataBase] queryOfficeMenuWittSchoolId:_schoolModel.schoolId];
        self.dataSource = dataSource;
    }else{
        NSArray *dataSource = [[DWDIntelligenceMenuDatabaseTool sharedIntelligenceDataBase] queryOfficeMenuWittSchoolId:@(schoolIdDefault)];
        _schoolModel.schoolId = @(schoolIdDefault);
        self.dataSource = dataSource;
    }

    [self.tableView reloadData];
}

#pragma mark - Getter


#pragma mark - Private Method
/**
 跳转菜单功能控制器
 */
- (void)pushFuctionViewContorllerWithMenuCode:(DWDIntelligenceMenuModel *)model{
    //判断code
    UIViewController *functionVC = nil;
    if ([model.menuCode isEqualToString:kDWDIntMenuCodeSchoolManagementContact]) {
        /** 跳转到'智能通讯录'页面 */
        DWDIntContactController *contactVC = [[DWDIntContactController alloc] init];
        contactVC.schoolId = self.schoolModel.schoolId;
        functionVC = contactVC;
    }else if ([model.menuCode isEqualToString:kDWDIntMenuCodeSchoolManagementNotice]){
        DWDIntNoticeListController *vc = [[DWDIntNoticeListController alloc] init];
        vc.schoolId = self.schoolModel.schoolId;
        functionVC = vc;
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

#pragma mark - TableView Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.dataSource.count == 0){
        return 1;
    }
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        DWDOfficeHeaderInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:officeHeaderInfoTableViewCellID];
        //若为设置头像，加载男女头像有别
        UIImage *defaultImage = [[DWDCustInfo shared].custGender isEqualToString:@"女"] ? DWDDefault_MeGrilImage :DWDDefault_MeBoyImage;
        [cell.avatarImv sd_setImageWithURL:[NSURL URLWithString:[DWDCustInfo shared].custThumbPhotoKey] placeholderImage:defaultImage];
        return cell;
    }else if (indexPath.section == 1){
        DWDIntFunctionItemCell *itemCell = [DWDIntFunctionItemCell cellWithTableView:tableView headTitle:@"移动办公"];
        itemCell.delegate = self;
        NSArray *arr = self.dataSource[indexPath.section -1];
        itemCell.dataSource = arr.mutableCopy;
        return itemCell;
    }else if (indexPath.section == 2){
        DWDIntFunctionItemCell *itemCell = [DWDIntFunctionItemCell cellWithTableView:tableView headTitle:@"成员管理"];
        itemCell.delegate = self;
        NSArray *arr = self.dataSource[indexPath.section -1];
        itemCell.dataSource = arr.mutableCopy;
        return itemCell;
    }
    return nil;
}

#pragma mark - TableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 90;
    }
    NSArray *array = self.dataSource[indexPath.section - 1];
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

#pragma mark - DWDIntFunctionItemCell Delegate
- (void)intFunctionItemCell:(DWDIntFunctionItemCell *)intFunctionItemCell selectItemWithModel:(DWDIntelligenceMenuModel *)model{
    self.menuModel = model;
    
    //判断是否是原生与H5类型
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
            //期待更多不作事件
            //return;
        }
    }else if ([self.menuModel.modeType isEqualToNumber:@1]){
        if ([self.menuModel.isOpen isEqualToNumber:@1]) {
            [self requestClassMenuH5:model.menuCode];
        }else if ([self.menuModel.isOpen isEqualToNumber:@2]){
            //reqeust
            [self requestGetAlertWithMenuCode:model.menuCode];
        }else if ([self.menuModel.isOpen isEqualToNumber:@6]){
            //reqeust
            [self createAlertControllerWithMessage:@"您还未加入任何班级，快去添加班级吧！"];
        }else if ([self.menuModel.isOpen isEqualToNumber:@7]){
            //期待更多不作事件
            return;
        }
    }
}

#pragma mark - Request Date
- (void)requestGetAlertWithMenuCode:(NSString *)code{
    [DWDIntelligentOfficeDataHandler requestGetAlertWithCid:[DWDCustInfo shared].custId sid:self.schoolModel.schoolId ? self.schoolModel.schoolId : @(schoolIdDefault) mncd:code sta:nil targetController:self success:^{
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)requestClassMenuH5:(NSString *)mCode {
    
    DWDIntH5ViewController *html5 = [[DWDIntH5ViewController alloc] init];
    html5.mCode = mCode;
    html5.schoolId = self.schoolModel.schoolId;
    html5.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:html5 animated:YES];
    

}

@end


