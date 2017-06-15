//
//  DWDIntNoticeDetailController.m
//  EduChat
//
//  Created by Beelin on 17/1/5.
//  Copyright © 2017年 dwd. All rights reserved.
//

#import "DWDIntNoticeDetailController.h"
#import "DWDPersonDataViewController.h"

#import "DWDIntNoticeDetailCell.h"
#import "DWDIntNoticeReadConditionCell.h"

#import "DWDIntNoticeListModel.h"
#import "DWDIntNoticeDetailModel.h"
#import "DWDIntelligentOfficeDataHandler.h"

#import "DWDImagesScrollView.h"

@interface DWDIntNoticeDetailController ()<DWDIntNoticeDetailCellDelegate, DWDIntNoticeReadConditionCellDelegate>

@property (nonatomic, strong)  DWDIntNoticeReadConditionCell *intNoticeReadConditionCell;
@property (nonatomic, strong) DWDIntNoticeDetailModel *detailModel;

@property (nonatomic, copy) NSArray *dataSource;

@end

@implementation DWDIntNoticeDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //request
    [self requestNoticeDetail];
    
    [self configData];
    [self setupControls];
}

#pragma mark - Config
- (void)configData{
    self.title = @"详情";
}

#pragma mark - Setup UI
- (void)setupControls{
    [self.view addSubview:self.tableView];
}

#pragma mark - Getter
- (DWDIntNoticeReadConditionCell *)intNoticeReadConditionCell{
    if (!_intNoticeReadConditionCell) {
        _intNoticeReadConditionCell = [[DWDIntNoticeReadConditionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        _intNoticeReadConditionCell.delegate = self;
    }
    return _intNoticeReadConditionCell;
}
#pragma mark - TableView Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
         DWDIntNoticeDetailCell *cell = [DWDIntNoticeDetailCell cellWithTableView:tableView];
        cell.model = self.detailModel;
        cell.delegate = self;
        return cell;
    }else if (indexPath.section == 1){
        self.intNoticeReadConditionCell.model = self.detailModel;
        self.intNoticeReadConditionCell.dataSource = self.dataSource;
        return self.intNoticeReadConditionCell;
    }
   
    return nil;
}

#pragma mark - TableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return self.detailModel.cellContentHeight;
    }else if (indexPath.section == 1){
        
        return self.detailModel.cellHeaderHeight == 10 ? 40 : self.detailModel.cellHeaderHeight + 40;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1){
        return 40;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return @"阅读情况";
    }
    return nil;
}

//设置区头颜色
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section{
    UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
    v.backgroundView.backgroundColor = DWDColorBackgroud;
}

#pragma mark - DWDIntNoticeDetailCellDelegate
- (void)intNoticeDetailCell:(DWDIntNoticeDetailCell *)cell clickButton:(UIButton *)sender photos:(NSArray *)photos{
    DWDImagesScrollView *scrollView = [[DWDImagesScrollView alloc] initWithPhotoMetaArray:photos];
    [scrollView presentViewFromImageView:sender.imageView atIndex:sender.tag toContainer:self.view];
}

- (void)intNoticeDetailCell:(DWDIntNoticeDetailCell *)cell didClickOKButtonWithItem:(NSNumber *)item{
    [self requestReplyWithItem:item];
}

- (void)intNoticeDetailCell:(DWDIntNoticeDetailCell *)cell didClickYesOrNoButtonWithItem:(NSNumber *)item{
     [self requestReplyWithItem:item];
}

#pragma mark - DWDIntNoticeReadConditionCellDelegate
- (void)intNoticeReadConditionCell:(DWDIntNoticeReadConditionCell *)cell didClickButtonWithTag:(NSInteger)tag{
    self.dataSource = tag == 0 ? self.detailModel.dataList : self.detailModel.unDataList;
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:1];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
}

- (void)intNoticeReadConditionCell:(DWDIntNoticeReadConditionCell *)cell didClickPhotoHeadWithCustId:(NSNumber *)custId{
    DWDPersonDataViewController *vc = [[DWDPersonDataViewController alloc] init];
    vc.custId = custId;
    [self.navigationController pushViewController:vc animated:YES];

}

#pragma mark - Request
- (void)requestNoticeDetail{
    DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:self.view];
    [DWDIntelligentOfficeDataHandler requestGetNoticeDetailWithCid:[DWDCustInfo shared].custId sid:self.schoolId noticeId:self.model.noticeId success:^(DWDIntNoticeDetailModel *model) {
        [hud hideHud];
        self.detailModel = model;
        self.dataSource = self.detailModel.dataList;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [hud hideHud];
    }];
}

- (void)requestReplyWithItem:(NSNumber *)item{
    [DWDIntelligentOfficeDataHandler requestReplyNoticeWithCid:[DWDCustInfo shared].custId sid:self.schoolId noticeId:self.model.noticeId item:item success:^{
        [self requestNoticeDetail];
    } failure:^(NSError *error) {
        
    }];
}
@end
