//
//  DWDClassSetGagViewController.m
//  EduChat
//
//  Created by Beelin on 16/11/18.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDClassSetGagViewController.h"

@interface DWDClassSetGagViewController ()
@property (nonatomic, strong) UISwitch *swi;
@end

@implementation DWDClassSetGagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"用户设置";
    
    self.tableViewStyle = UITableViewStyleGrouped;
    [self.view addSubview:self.tableView];
    
    //request
    [self requestCheckShutupStateWithClassMember:self.custId];
}

#pragma mark - Getter
- (UISwitch *)swi{
    if(!_swi){
        _swi = [[UISwitch alloc] init];
        [_swi addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _swi;
}

#pragma Event Response
- (void)switchAction:(UISwitch *)sender{
    if (sender.isOn) {
        [self requestSetShutupWithClassMembers:@[self.custId]];
    }else{
        [self requestCancelShutupWithClassMembers:@[self.custId]];
    }
}

#pragma mark - TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.textLabel.text = @"禁言设置";
        cell.accessoryView = self.swi;
    }
    return cell;
}

#pragma mark - TableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

#pragma mark - Request
/** 添加禁言成员 */
- (void)requestSetShutupWithClassMembers:(NSArray *)classMembers{
    NSDictionary *dict = @{@"cid":[DWDCustInfo shared].custId,
                           @"tid":self.classId,
                           @"cids":classMembers};
    DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:self.view];
    [[DWDWebManager sharedManager] postApi:@"groupshutup/setShutup" params:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        [hud hideHud];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [hud showText:error.localizedFailureReason];
    }];
}

/** 删除禁言成员 */
- (void)requestCancelShutupWithClassMembers:(NSArray *)classMembers{
    NSDictionary *dict = @{@"cid":[DWDCustInfo shared].custId,
                           @"tid":self.classId,
                           @"cids":classMembers};
    DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:self.view];
    [[DWDWebManager sharedManager] postApi:@"groupshutup/cancelShutup" params:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        [hud hideHud];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [hud showText:error.localizedFailureReason];
    }];
}

/** 查看班级成员禁言状态 */
- (void)requestCheckShutupStateWithClassMember:(NSNumber *)classMember{
    NSDictionary *dict = @{@"cid":[DWDCustInfo shared].custId,
                           @"tid":self.classId,
                           @"pid":classMember};
    DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:self.view];
    [[DWDWebManager sharedManager] getApi:@"groupshutup/checkShutup" params:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        [hud hideHud];
        if ([responseObject[@"data"] isEqualToString:@"1"]) {
            [self.swi setOn:YES animated:YES];
        }else{
            [self.swi setOn:NO animated:YES];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [hud showText:error.localizedFailureReason];
    }];
}
@end
