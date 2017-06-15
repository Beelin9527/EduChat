//
//  DWDClassSourceClassNotificationViewController.m
//  EduChat
//
//  Created by Superman on 15/11/26.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassSourceClassNotificationViewController.h"
#import "DWDClassNotificationDetailViewController.h"
#import "DWDClassNotificationAddViewController.h"

#import "DWDClassNotificationCell.h"

#import "DWDRequestServerClassNotification.h"
#import "DWDClassNotificatoinListEntity.h"

@interface DWDClassSourceClassNotificationViewController()
@property (strong, nonatomic) NSArray *arrDataSoure;
@end
@implementation DWDClassSourceClassNotificationViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"通知";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BtnPopAdd"] style:UIBarButtonItemStyleDone target:self action:@selector(rightBarBtnClick)];
    
    self.tableView.tableFooterView = [[UIView alloc]init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //request
    [self requestData];
}

- (void)rightBarBtnClick{
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDClassNotificationAddViewController class]) bundle:nil];
    DWDClassNotificationAddViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDClassNotificationAddViewController class])];
    vc.title = @"新增通知";
    [self.navigationController pushViewController:vc animated:YES];

}


#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
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
    
    DWDClassNotificationDetailViewController *vc = [[DWDClassNotificationDetailViewController alloc]init];
    vc.noticeId = entity.noticeId;
    vc.noticeTitle = entity.title;
    [self.navigationController pushViewController:vc animated:YES];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return pxToH(140);
}

#pragma mark - request
- (void)requestData
{
     __weak DWDClassSourceClassNotificationViewController *weakSelf = self;
    
    [[DWDRequestServerClassNotification sharedDWDRequestServerClassNotification] requestServerClassGetListCustId:@4010000005409 classId:@7010000002006 type:nil pageIndex:@1 pageCount:@25 success:^(id responseObject) {
        
        weakSelf.arrDataSoure = responseObject;
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}
@end
