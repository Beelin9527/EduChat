//
//  DWDClassGagViewController.m
//  EduChat
//
//  Created by Beelin on 16/11/15.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDClassGagViewController.h"
#import "DWDNavViewController.h"
#import "DWDPersonDataViewController.h"
#import "DWDClassGagSelectViewController.h"

#import "DWDHeaderImgSortControl.h"

#import "DWDClassMemberClient.h"

#import "DWDClassDataBaseTool.h"//test
#import "DWDClassModel.h" //test

@interface DWDClassGagViewController ()<DWDHeaderImgSortControlDelegate,DWDContactSelectViewControllerDelegate>
@property (strong, nonatomic) NSArray *dataSource;
@property (nonatomic, strong) NSArray *shutupMembersIDArray;
@property (strong, nonatomic) DWDHeaderImgSortControl *headerImgSortControl;
@end

@implementation DWDClassGagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"禁言名单";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //request
    [self requestGetShutupMemberData];
}

#pragma mark - Getter
//- (NSArray *)membersArray
//{
//    if (!_dataSource) {
//        _dataSource = [NSMutableArray array];
//    }
//    return _dataSource;
//}

- (DWDHeaderImgSortControl *)headerImgSortControl
{
    if (!_headerImgSortControl) {
        _headerImgSortControl = [[DWDHeaderImgSortControl alloc] init];
        _headerImgSortControl.delegate = self;
    }
    return _headerImgSortControl;
}

#pragma mark - TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (self.headerImgSortControl) {
        [self.headerImgSortControl.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    self.headerImgSortControl.layouType = self.dataSource.count ? DWDNeedBothType : DWDNeedOnlyAddButtonType;
    self.headerImgSortControl.arrItems = self.dataSource;
    self.headerImgSortControl.frame = CGRectMake(0, 0, DWDScreenW, self.headerImgSortControl.hight);
    
    [cell.contentView addSubview:self.headerImgSortControl];
    return cell;
}

#pragma mark - TableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.headerImgSortControl.hight;
}

#pragma mark - DWDHeaderImgSortControl Delegate
- (void)headerImgSortControl:(DWDHeaderImgSortControl *)headerImgSortControl DidGroupMemberWithCust:(NSNumber *)custId{
    DWDPersonDataViewController *vc = [[DWDPersonDataViewController alloc] init];
    vc.custId = custId;
    vc.sourceType = DWDSourceTypeClass;
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)headerImgSortControlDidSelectAddButton:(DWDHeaderImgSortControl*)headerImgSortControl{
    DWDClassGagSelectViewController *vc = [[DWDClassGagSelectViewController alloc] init];
    vc.delegate = self;
    vc.type = DWDSelectContactTypeAddEntity;
    
    //获取未禁言的成员 进行添加操作
    vc.dataSource = [[DWDClassDataBaseTool sharedClassDataBase] getClassMemberWithExcludeByMembersId:self.shutupMembersIDArray ClassId:self.classModel.classId myCustId:[DWDCustInfo shared].custId];
    DWDNavViewController *naviVC = [[DWDNavViewController alloc]initWithRootViewController:vc];
    [self.navigationController presentViewController:naviVC animated:YES completion:nil];
}
- (void)headerImgSortControlDidSelectDeleteButton:(DWDHeaderImgSortControl *)headerImgSortControl{
    DWDClassGagSelectViewController *vc = [[DWDClassGagSelectViewController alloc] init];
    vc.delegate = self;
    vc.type = DWDSelectContactTypeDeleteEntity;
    
    //获取禁言的成员 进行删除操作
    vc.dataSource = self.dataSource;
    DWDNavViewController *naviVC = [[DWDNavViewController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:naviVC animated:YES completion:nil];
}

#pragma mark - DWDContactSelectViewController Delegate
- (void)contactSelectViewControllerDidSelectContactsForIds:(NSArray *)contactsIds selectContactType:(DWDSelectContactType)type{
    if (type == DWDSelectContactTypeAddEntity) {
        [self requestSetShutupWithClassMembers:contactsIds];
    }else if (type == DWDSelectContactTypeDeleteEntity){
        [self requestCancelShutupWithClassMembers:contactsIds];
    }
}

#pragma mark - Request
/** 获取禁言成员数据 */
- (void)requestGetShutupMemberData{
    DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:self.view];
    
    NSDictionary *dict = @{@"cid":[DWDCustInfo shared].custId,
                           @"tid":self.classModel.classId};
    [[DWDWebManager sharedManager] getApi:@"groupshutup/getShutupList" params:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        [hud hideHud];
        _shutupMembersIDArray = responseObject[@"data"];
        
        //获取本地库成员信息
       _dataSource = [[DWDClassDataBaseTool sharedClassDataBase] getClassMemberWithByMembersId:self.shutupMembersIDArray ClassId:self.classModel.classId myCustId:[DWDCustInfo shared].custId includeMian:NO];
        
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [hud showText:error.localizedFailureReason];
    }];
}

/** 添加禁言成员 */
- (void)requestSetShutupWithClassMembers:(NSArray *)classMembers{
    NSDictionary *dict = @{@"cid":[DWDCustInfo shared].custId,
                           @"tid":self.classModel.classId,
                           @"cids":classMembers};
    [[DWDWebManager sharedManager] postApi:@"groupshutup/setShutup" params:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        [self requestGetShutupMemberData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

/** 删除禁言成员 */
- (void)requestCancelShutupWithClassMembers:(NSArray *)classMembers{
    NSDictionary *dict = @{@"cid":[DWDCustInfo shared].custId,
                           @"tid":self.classModel.classId,
                           @"cids":classMembers};
    [[DWDWebManager sharedManager] postApi:@"groupshutup/cancelShutup" params:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        [self requestGetShutupMemberData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}


@end
