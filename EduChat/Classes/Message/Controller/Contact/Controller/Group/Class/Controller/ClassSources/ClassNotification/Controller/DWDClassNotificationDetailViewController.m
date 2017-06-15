//
//  DWDClassNotificationDetailViewController.m
//  EduChat
//
//  Created by Mantis on 15/12/10.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassNotificationDetailViewController.h"
#import "DWDClassNotificationAddViewController.h"

#import "DWDNotificationDetailContentCell.h"
#import "DWDNotificationHeaderIocnTableViewCell.h"
#import "DWDClassNotificatoinListEntity.h"
#import "DWDRequestServerClassNotification.h"

#import "DWDImagesScrollView.h"

#import <YYModel.h>

@interface DWDClassNotificationDetailViewController ()<DWDNotificationDetailContentCellDelegate>

@property (strong, nonatomic) NSDictionary *dictDataSource;
@end
static NSString *notificationDetailContentCell = @"DWDNotificationDetailContentCell";
static NSString *notificationHeaderIocnTableViewCell = @"DWDNotificationHeaderIocnTableViewCell";
static NSString *notificationHeaderIocnReadedTableViewCell = @"DWDNotificationHeaderIocnReadedTableViewCell";
@implementation DWDClassNotificationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"通知";
    
    if ([DWDCustInfo shared].isTeacher) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more_normal"] style:UIBarButtonItemStyleDone target:self action:@selector(moreAction)];
    }
   
    
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
    
     [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DWDNotificationHeaderIocnTableViewCell class]) bundle:nil] forCellReuseIdentifier:notificationHeaderIocnReadedTableViewCell];
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
        cell.delegate = self;
        
        cell.labTitle.text = self.noticeTitle;
        cell.readed = self.readed;
        cell.classId = self.myClass.classId;
        cell.noticeId = self.noticeId;
        cell.dictDataSource = self.dictDataSource;
        return cell;
    }else if (indexPath.section == 1){
        DWDNotificationHeaderIocnTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:notificationHeaderIocnReadedTableViewCell];
        
        //        type
        //        通知类型
        //        1-知道了
        //        2-YES/NO
        NSString *typeStr;
        if ([self.type isEqual:@1]) {
            typeStr = @"readeds";
        } else {
            typeStr = @"joins";
        }
        NSArray *replyAr = self.dictDataSource[@"replys"][typeStr];
        cell.type = self.type;
        cell.userArray = replyAr;
        return cell;
    }else if (indexPath.section == 2){
        DWDNotificationHeaderIocnTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:notificationHeaderIocnTableViewCell];
        NSString *typeStr;
        if ([self.type isEqual:@1]) {
            typeStr = @"unreads";
        } else {
            typeStr = @"unjoins";
        }
        NSArray *replyAr = self.dictDataSource[@"replys"][typeStr];
        cell.type = self.type;
        cell.userArray = replyAr;
        return cell;
    }
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

#pragma mark - DWDNotificationDetailContentCellDelegate
-       (void)cell:(DWDNotificationDetailContentCell *)cell
 didClickImageView:(UIImageView *)imageView
           AtIndex:(NSInteger)index {
    
    NSMutableArray *photoArray = [NSMutableArray array];
    for (NSDictionary *dict in self.dictDataSource[@"notice"][@"photos"]) {
        [photoArray addObject:[DWDPhotoMetaModel yy_modelWithDictionary:dict[@"photo"]]];
    }

    DWDImagesScrollView *scrollView = [[DWDImagesScrollView alloc] initWithPhotoMetaArray:photoArray];
    
    [scrollView presentViewFromImageView:imageView atIndex:index toContainer:self.view];
}

- (void)cell:(DWDNotificationDetailContentCell *)cell shouldReloadDataWithDataSource:(NSDictionary *)datasource {
    self.dictDataSource = datasource;
    self.readed = @1;
    [self.tableView reloadData];
}

#pragma mark - action
- (void)moreAction
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
//    UIAlertAction *action_1 = [UIAlertAction actionWithTitle:@"编辑通知" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        
//            UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDClassNotificationAddViewController class]) bundle:nil];
//            UIViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDClassNotificationAddViewController class])];
//            vc.title = @"编辑通知";
//            [self.navigationController pushViewController:vc animated:YES];
//        
//    }];
    
    UIAlertAction *action_2 = [UIAlertAction actionWithTitle:@"删除本通知" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //request delete entity
        [self requestDeleteEntity];
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
//    [alert addAction:action_1];
    [alert addAction:action_2];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];

}

#pragma mark - request
- (void)requestData
{
    __weak DWDClassNotificationDetailViewController *weakSelf = self;
    
    [[DWDRequestServerClassNotification sharedDWDRequestServerClassNotification] requestServerClassGetEntityCustId:[DWDCustInfo shared].custId classId:self.myClass.classId noticeId:self.noticeId success:^(id responseObject) {
        
        weakSelf.dictDataSource = responseObject;
        [weakSelf.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
}

//request delete entity
- (void)requestDeleteEntity
{
    __weak DWDClassNotificationDetailViewController *weakSelf = self;

    [[DWDRequestServerClassNotification sharedDWDRequestServerClassNotification] requestServerClassDeleteEntityCustId:[DWDCustInfo shared].custId classId:self.myClass.classId noticeId:@[self.noticeId] success:^(id responseObject) {
        
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSError *error) {
        
        
    }];
    
}
@end
