//
//  DWDClassSourceClassNotificationViewController.m
//  EduChat
//
//  Created by Superman on 15/11/26.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassSourceClassNotificationViewController.h"
#import "DWDClassNotificationAddViewController.h"
#import "DWDClassNotificationDetailController.h"

#import "DWDClassNotificationCell.h"

#import "DWDRequestServerClassNotification.h"
#import "DWDClassNotificatoinListEntity.h"

#import "DWDIntelligentOfficeDataHandler.h"

#import <MJRefresh.h>

@interface DWDClassSourceClassNotificationViewController() <UINavigationControllerDelegate>
@property (strong, nonatomic) NSArray *arrDataSoure;
@property (nonatomic, weak) UIImageView *blankBackgroundImageView;
@property (nonatomic, assign) NSUInteger currentPage;
@end
@implementation DWDClassSourceClassNotificationViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"通知";
    //区分权限
    if ([DWDCustInfo shared].isTeacher) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BtnPopAdd"] style:UIBarButtonItemStyleDone target:self action:@selector(rightBarBtnClick)];
    }
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestData)];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.mj_header = header;
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    //检测此菜单功能是否点击过,key为menuCode
    NSString *key = [NSString stringWithFormat:@"%@-%@", [DWDCustInfo shared].custId, kDWDIntMenuCodeClassManagementNotice];
    NSString *obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (!obj) {
        [self requestGetAlertWithMenuCode:kDWDIntMenuCodeClassManagementNotice];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)rightBarBtnClick{
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDClassNotificationAddViewController class]) bundle:nil];
    DWDClassNotificationAddViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDClassNotificationAddViewController class])];
    vc.myClass = self.myClass;
    vc.title = @"新增通知";
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.arrDataSoure.count) {
        [self.blankBackgroundImageView removeFromSuperview];
    }
    return self.arrDataSoure.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DWDClassNotificationCell *cell = [DWDClassNotificationCell cellWithTableView:tableView];
    
    DWDClassNotificatoinListEntity *entity = self.arrDataSoure[indexPath.row];
    cell.entity = entity;
    
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DWDClassNotificatoinListEntity *entity = self.arrDataSoure[indexPath.row];
//
//    DWDClassNotificationDetailViewController *vc = [[DWDClassNotificationDetailViewController alloc]init];
//    vc.readed = entity.readed;
//    vc.noticeId = entity.noticeId;
//    vc.noticeTitle = entity.title;
//    vc.type = entity.type;
//    vc.myClass = self.myClass;
    DWDClassNotificationDetailController *vc = [[DWDClassNotificationDetailController alloc] init];
    vc.readed =entity.readed;
    vc.noticeId = entity.noticeId;
    vc.myClass = self.myClass;
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return pxToH(140);
}

#pragma mark - request
- (void)requestData
{
     __weak DWDClassSourceClassNotificationViewController *weakSelf = self;
    
    [[DWDRequestServerClassNotification sharedDWDRequestServerClassNotification]
     requestServerClassGetListCustId:[DWDCustInfo shared].custId//@4010000005409
     classId:self.myClass.classId//@7010000002006
     type:nil
     pageIndex:@1
     pageCount:@25
     success:^(id responseObject) {
         weakSelf.arrDataSoure = responseObject;
         dispatch_async(dispatch_get_main_queue(), ^{
             if ([responseObject count] == 0) {
                 [weakSelf.blankBackgroundImageView setNeedsDisplay];
             }
             weakSelf.currentPage = 1;
             [weakSelf.tableView.mj_header endRefreshing];
             [weakSelf.tableView reloadData];
         });
         
     }                           failure:^(NSError *error) {
         [weakSelf.blankBackgroundImageView setNeedsDisplay];
         [weakSelf.tableView.mj_header endRefreshing];
     }];
}

- (void)loadMoreData {
    if (_currentPage <= 0) {
        _currentPage = 1;
    }
    _currentPage += 1;
    __weak DWDClassSourceClassNotificationViewController *weakSelf = self;
    
    [[DWDRequestServerClassNotification sharedDWDRequestServerClassNotification]
     requestServerClassGetListCustId:[DWDCustInfo shared].custId//@4010000005409
     classId:self.myClass.classId//@7010000002006
     type:nil
     pageIndex:@(_currentPage)
     pageCount:@25
     success:^(id responseObject) {
         NSMutableArray *ar = [NSMutableArray arrayWithArray:weakSelf.arrDataSoure];
         [ar addObjectsFromArray:responseObject];
         weakSelf.arrDataSoure = ar;
         dispatch_async(dispatch_get_main_queue(), ^{
             [weakSelf.tableView.mj_footer endRefreshing];
             [weakSelf.tableView reloadData];
         });
     }                           failure:^(NSError *error) {
         //         [weakSelf.blankBackgroundImageView setNeedsDisplay];
         weakSelf.currentPage -= 1;
         [weakSelf.tableView.mj_footer endRefreshing];
     }];
}

#pragma mark - Setter / Getter

- (UIImageView *)blankBackgroundImageView {
    if (!_blankBackgroundImageView) {
        UIImageView *blankBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"msg_notice_no_data"]];
        
        blankBackgroundImageView.frame = CGRectMake(DWDScreenW * 0.5 - pxToW(316) * 0.5, pxToH(330), pxToW(316), pxToH(377));
        [self.view addSubview:blankBackgroundImageView];
        _blankBackgroundImageView = blankBackgroundImageView;
    }
    return _blankBackgroundImageView;
}

#pragma mark - Request Data
- (void)requestGetAlertWithMenuCode:(NSString *)code{
    [DWDIntelligentOfficeDataHandler requestGetAlertWithCid:[DWDCustInfo shared].custId sid:self.myClass.schoolId mncd:code sta:nil targetController:self success:^{
        
    } failure:^(NSError *error) {
        
    }];
}
@end
