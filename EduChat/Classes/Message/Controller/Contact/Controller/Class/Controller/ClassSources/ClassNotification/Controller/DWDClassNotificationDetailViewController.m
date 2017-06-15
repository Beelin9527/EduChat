//
//  DWDClassNotificationDetailViewController.m
//  EduChat
//
//  Created by doublewood on 15/12/10.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassNotificationDetailViewController.h"
#import "DWDClassNotificationAddViewController.h"

#import "DWDNotificationDetailContentCell.h"
#import "DWDNotificationHeaderIocnTableViewCell.h"

#import "DWDRequestServerClassNotification.h"
@interface DWDClassNotificationDetailViewController ()

@property (strong, nonatomic) NSDictionary *dictDataSource;
@end
static NSString *notificationDetailContentCell = @"DWDNotificationDetailContentCell";
static NSString *notificationHeaderIocnTableViewCell = @"DWDNotificationHeaderIocnTableViewCell";
@implementation DWDClassNotificationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"通知";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more_normal"] style:UIBarButtonItemStyleDone target:self action:@selector(moreAction)];

    
    [self setupTableView];
    [self registerCell];
    
    //request
    [self requestData];
}
#pragma mark - view
-(void)setupTableView
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = DWDColorBackgroud;
}
-(void)registerCell
{
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DWDNotificationDetailContentCell class]) bundle:nil] forCellReuseIdentifier:notificationDetailContentCell];
    
     [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DWDNotificationHeaderIocnTableViewCell class]) bundle:nil] forCellReuseIdentifier:notificationHeaderIocnTableViewCell];
}


#pragma mark - Table view data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
         DWDNotificationDetailContentCell *cell = [tableView dequeueReusableCellWithIdentifier:notificationDetailContentCell];
        
        cell.labTitle.text = self.noticeTitle;
        cell.dictDataSource = self.dictDataSource;
        return cell;
        
    }else if (indexPath.section == 1){
         DWDNotificationHeaderIocnTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:notificationHeaderIocnTableViewCell];
        return cell;
    }else if (indexPath.section == 2){
        DWDNotificationHeaderIocnTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:notificationHeaderIocnTableViewCell];
        return cell;
    }
   
   
    
    // Configure the cell...
    
    return nil;
}

#pragma mark - tableView delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        DWDNotificationDetailContentCell *cell = (DWDNotificationDetailContentCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        return  cell.notiDetailContentHight;
    }else if (indexPath.section==1) {
        DWDNotificationHeaderIocnTableViewCell *cell = (DWDNotificationHeaderIocnTableViewCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.cellHight;
    }else if (indexPath.section==2) {
        DWDNotificationHeaderIocnTableViewCell *cell = (DWDNotificationHeaderIocnTableViewCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.cellHight;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
   
    return DWDPadding;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeader = [[UIView alloc]init];
    sectionHeader.backgroundColor = [UIColor clearColor];
    return sectionHeader;
}

#pragma mark - scrollView delegate
//delete UItableview headerview黏性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView)
    {
        CGFloat sectionHeaderHeight = 10;
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
    
}

#pragma mark - action
- (void)moreAction
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action_1 = [UIAlertAction actionWithTitle:@"编辑通知" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
            UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDClassNotificationAddViewController class]) bundle:nil];
            UIViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDClassNotificationAddViewController class])];
            vc.title = @"编辑通知";
            [self.navigationController pushViewController:vc animated:YES];
        
    }];
    
    UIAlertAction *action_2 = [UIAlertAction actionWithTitle:@"删除本通知" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //request delete entity
        [self requestDeleteEntity];
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:action_1];
    [alert addAction:action_2];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];

}

#pragma mark - request
- (void)requestData
{
    __weak DWDClassNotificationDetailViewController *weakSelf = self;
    
    [[DWDRequestServerClassNotification sharedDWDRequestServerClassNotification] requestServerClassGetEntityCustId:@4010000005409 classId:@7010000002006 noticeId:self.noticeId success:^(id responseObject) {
        
        weakSelf.dictDataSource = responseObject;
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}

//request delete entity
- (void)requestDeleteEntity
{
    __weak DWDClassNotificationDetailViewController *weakSelf = self;

    [[DWDRequestServerClassNotification sharedDWDRequestServerClassNotification] requestServerClassDeleteEntityCustId:@4010000005409 classId:@7010000002006 noticeId:@[self.noticeId] success:^(id responseObject) {
        
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSError *error) {
        
        
    }];
    
}
@end
