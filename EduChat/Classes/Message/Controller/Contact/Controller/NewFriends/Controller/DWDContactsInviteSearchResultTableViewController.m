//
//  DWDContactsInviteSearchResultTableViewController.m
//  EduChat
//
//  Created by KKK on 16/11/14.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDContactsInviteSearchResultTableViewController.h"
#import "DWDContactsInviteCell.h"
#import "DWDContactInviteModel.h"

#import <YYModel.h>

@interface DWDContactsInviteSearchResultTableViewController () <DWDContactsInviteCellDelegate>

@property (nonatomic, strong) NSArray <DWDContactInviteModel *>*resultArray;

@end

@implementation DWDContactsInviteSearchResultTableViewController

static NSString *cellId = @"cellId";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setBackgroundColor:DWDColorBackgroud];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerClass:[DWDContactsInviteCell class] forCellReuseIdentifier:cellId];
}

#pragma mark - Public Method

- (void)reloadResultArray:(NSArray<DWDContactInviteModel *> *)resultArray {
    _resultArray = resultArray;
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _resultArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DWDContactsInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setDataWithModel:_resultArray[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - UIScrollViewDelegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    DWDLog(@"\n%@", NSStringFromCGPoint(scrollView.contentOffset));
//    if (_resultArray.count > 0) {
//
//    }
//}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_controllerDelegate && [_controllerDelegate respondsToSelector:@selector(contactsInviteSearchResultControllerDidScrollTableView:)]) {
        [_controllerDelegate contactsInviteSearchResultControllerDidScrollTableView:self];
    }
}

#pragma mark - DWDContactsInviteCellDelegate
- (void)inviteCell:(DWDContactsInviteCell *)cell didClickInviteButtonWithModel:(DWDContactInviteModel *)model {
    [self requestInvitationWithModel:model];
}

#pragma mark - Private Method
- (void)requestInvitationWithModel:(DWDContactInviteModel *)model {
    WEAKSELF;
    NSDictionary *params = @{
                             @"cid" : [DWDCustInfo shared].custId,
                             @"phoneBook" : [model.mobile yy_modelToJSONObject],
                             };
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在邀请";
    [[DWDWebManager sharedManager] postContactInviteWithParams:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSUInteger index = [_resultArray indexOfObject:model];
        model.invited = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            if (weakSelf.controllerDelegate && [weakSelf.controllerDelegate respondsToSelector:@selector(contactsInviteSearchResultController:didInvited:)]) {
                [weakSelf.controllerDelegate contactsInviteSearchResultController:weakSelf didInvited:model];
            }
            hud.labelText = @"邀请发送成功";
            hud.mode = MBProgressHUDModeText;
            [hud hide:YES afterDelay:1.5f];
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.labelText = @"邀请发送失败";
            hud.mode = MBProgressHUDModeText;
            [hud hide:YES afterDelay:1.5f];
        });
    }];
}

@end
