//
//  DWDIntContactController.m
//  EduChat
//
//  Created by KKK on 16/12/13.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDIntContactController.h"
// 群发消息控制器
#import "DWDGroupMembersSelectController.h"
// 聊天控制器
#import "DWDChatController.h"
// 个人讯息控制器
#import "DWDPersonDataViewController.h"

// tableview的cell
#import "DWDIntContactGroupMemberCell.h"
// header view
#import "DWDIntClassItemView.h"
#import "DWDIntClassMenuView.h"
//loading view
#import "DWDPUCLoadingView.h"

// 成员的model
#import "DWDSchoolGroupModel.h"
// header属性的model
#import "DWDSchoolModel.h"
// 通讯录model
#import "DWDTempContactModel.h"

// 通讯录数据库工具
#import "DWDContactsDatabaseTool.h"

@import Contacts;
#import <AddressBook/AddressBook.h>
#import <YYModel.h>
#import <SDVersion.h>

@interface DWDIntContactController () <UITableViewDataSource, UITableViewDelegate, DWDIntContactGroupMemberCellDelegate,DWDIntClassItemViewDelegate,DWDIntClassMenuViewDelegate, DWDPUCLoadingViewDelegate>

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, weak) DWDIntClassItemView *headerView;
@property (nonatomic, weak) DWDIntClassMenuView *headerExpandView;

@property (nonatomic, weak) DWDPUCLoadingView *loadingView;

@property (nonatomic, strong) NSArray <DWDSchoolGroupModel *>*originGroupsArray;
@property (nonatomic, strong) NSArray <DWDSchoolGroupModel *>*groupsArray;
@property (nonatomic, strong) NSArray <DWDIntClassModel *>*groupListArray;

@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, assign) BOOL requestSucceed;

@end

@implementation DWDIntContactController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"智能通讯录";
    self.view.backgroundColor = DWDColorBackgroud;
    _requestSucceed = NO;
    // Do any additional setup after loading the view.
    [self initTableView];
    [self initRightBarButtonItem];
    [self requestGroups];
}

#pragma mark - Init SubViews;
- (void)initTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:(CGRect){0, 40 + 10, DWDScreenW, DWDScreenH - 64 - 40 - 10}];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.estimatedRowHeight = 100;
    [tableView registerClass:[DWDIntContactGroupMemberCell class] forCellReuseIdentifier:@"DWDIntContactGroupMemberCell"];
    [self.view addSubview:tableView];
    _tableView = tableView;
}

- (void)initRightBarButtonItem {
    UIBarButtonItem *groupSelectItem = [[UIBarButtonItem alloc] initWithTitle:@"群发消息" style:UIBarButtonItemStylePlain target:self action:@selector(groupSelectButtonDidClick)];
    self.navigationItem.rightBarButtonItem = groupSelectItem;
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

- (void)initHeaderViewWithGroupArray:(NSArray *)groupArray {
    NSMutableArray *groupListArray = [NSMutableArray array];
    for (DWDSchoolGroupModel *model in groupArray) {
        DWDIntClassModel *classModel = [DWDIntClassModel new];
        classModel.className = model.groupName;
        [groupListArray addObject:classModel];
    }
    _groupListArray = groupListArray;
    
    if (!_headerView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            DWDIntClassItemView *headerView = [[DWDIntClassItemView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, 40)];
            headerView.delegate = self;
            headerView.dataSource = _groupListArray;
            [self.view addSubview:headerView];
            _headerView = headerView;
        });
    }
}

#pragma mark - Event Response
- (void)groupSelectButtonDidClick {
    DWDGroupMembersSelectController *groupVC = [DWDGroupMembersSelectController new];
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:_originGroupsArray.count];
    [_originGroupsArray enumerateObjectsUsingBlock:^(DWDSchoolGroupModel * _Nonnull schoolGroup, NSUInteger idx, BOOL * _Nonnull stop) {
//        @property (nonatomic, strong) NSNumber *schoolID; //学校ID
//        @property (nonatomic, copy) NSString *schoolName; //学校名字
//        @property (nonatomic, strong) NSNumber *groupID; //群组ID
//        @property (nonatomic, copy) NSString *groupName; //群组名字
//        @property (nonatomic, strong) NSNumber *serialNumber; //群组序列号, 用于排序(?
//        @property (nonatomic, strong) NSArray<DWDSchoolGroupMemberModel *> *groupMembers; //成员数组
        DWDSchoolGroupModel *schoolModel = [[DWDSchoolGroupModel alloc] init];
        schoolModel.schoolID = schoolGroup.schoolID;
        schoolModel.schoolName = schoolGroup.schoolName;
        schoolModel.groupID = schoolGroup.groupID;
        schoolModel.groupName = schoolGroup.groupName;
        schoolModel.serialNumber = schoolGroup.serialNumber;
        NSMutableArray *memberArray = [NSMutableArray arrayWithCapacity:schoolModel.groupMembers.count];
        [schoolGroup.groupMembers enumerateObjectsUsingBlock:^(DWDSchoolGroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            @property (nonatomic, strong) NSNumber *custId; //成员的custId
//            @property (nonatomic, copy) NSString *memberName; //成员的姓名
//            @property (nonatomic, copy) NSString *telPhone; //成员的电话
//            @property (nonatomic, copy) NSString *photoKey; //成员的头像
//            @property (nonatomic, assign) BOOL isFriend; //成员是否是好友
//            @property (nonatomic, copy) NSString *characterName;//角色名称(其实是身份
            DWDSchoolGroupMemberModel *memberModel = [[DWDSchoolGroupMemberModel alloc] init];
            memberModel.custId = obj.custId;
            memberModel.memberName = obj.memberName;
            memberModel.telPhone = obj.telPhone;
            memberModel.photoKey = obj.photoKey;
            memberModel.isFriend = obj.isFriend;
            memberModel.characterName = obj.characterName;
            [memberArray addObject:memberModel];
        }];
        schoolModel.groupMembers = memberArray;
        [dataArray addObject:schoolModel];
    }];
    
    groupVC.dataArray = dataArray;
    [groupVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:groupVC animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_requestSucceed)
        if (_groupsArray.count)
            return [[_groupsArray[_selectedIndex] groupMembers] count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DWDIntContactGroupMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DWDIntContactGroupMemberCell"];
    cell.eventDelegate = self;
    DWDSchoolGroupMemberModel *model = [_groupsArray[_selectedIndex] groupMembers][indexPath.row];
    [cell layoutWithModel:model];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    DWDSchoolGroupMemberModel *model = [_groupsArray[_selectedIndex] groupMembers][indexPath.row];
    dispatch_async(dispatch_get_main_queue(), ^{
        DWDPersonDataViewController *personController = [[DWDPersonDataViewController alloc] init];
        personController.custId = model.custId;
        // 根据好友关系判断进入控制器后按钮显示
        if ([[DWDContactsDatabaseTool sharedContactsClient] getRelationWithFriendCustId:model.custId]) {
            personController.personType = DWDPersonTypeIsFriend;
        } else {
            personController.personType = DWDPersonTypeIsStrangerAdd;
        }
        personController.showPhoneNumber = YES;
        [self.navigationController pushViewController:personController animated:YES];
    });
}

#pragma mark - DWDIntClassItemViewDelegate
- (void)intClassItemViewClickMenuButton:(DWDIntClassItemView *)intClassItemView{
    dispatch_async(dispatch_get_main_queue(), ^{
    DWDIntClassMenuView *menu = [DWDIntClassMenuView IntClassMenuViewWithFrame:CGRectMake(0, 0, DWDScreenW, DWDScreenH - DWDTopHight) dataSource:_groupListArray];
    menu.delegate = self;
        [self.view addSubview:menu];
    });
}
- (void)intClassItemView:(DWDIntClassItemView *)intClassItemView selectItem:(DWDIntClassModel *)model{
    //查询班级管理菜单模块
    DWDIntClassModel *classModel = (DWDIntClassModel*)model;
    self.selectedIndex = [self.groupListArray indexOfObject:classModel];
    [self.tableView reloadData];
    
}

#pragma mark - DWDIntClassMenuViewDelegate
- (void)intClassMenuView:(DWDIntClassMenuView *)intClassMenuView selectItem:(DWDIntClassModel *)model{
    self.selectedIndex = [self.groupListArray indexOfObject:model];
    
    //更新intClassItemView 选中按钮
    [self.headerView updateSelectItemWithIndex: self.selectedIndex];
    
    [self.tableView reloadData];
}

#pragma mark - DWDIntContactGroupMemberCellDelegate
// 临时聊天
- (void)memberCellDidClickMessageButton:(DWDIntContactGroupMemberCell *)cell {
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    DWDSchoolGroupMemberModel *model = [_groupsArray[_selectedIndex] groupMembers][indexPath.row];
    [self pushToTempChatWithModel:model];
}

// 打电话
- (void)memberCellDidClickPhoneCallButton:(DWDIntContactGroupMemberCell *)cell {
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    DWDSchoolGroupMemberModel *model = [_groupsArray[_selectedIndex] groupMembers][indexPath.row];
    [self presentAlertControllerWithModel:model];
}

#pragma mark - PUCLoadingViewDelegate
// 获取失败
- (void)loadingViewDidClickReloadButton:(DWDPUCLoadingView *)view {
    [self requestGroups];
}

#pragma mark - Private Method
// 请求全部组&成员
- (void)requestGroups {
    NSDictionary *para = @{
                           @"sid" : [self objectOrNULL:_schoolId],
                           @"cid" : [self objectOrNULL:[DWDCustInfo shared].custId],
//                           @"sid" : @2010000063157,
//                           @"cid" : @4010000005168,
                           @"pgIdx" : @0,
                           @"pgCnt" : @0,
                           };
    
        if (_loadingView) {
            [_loadingView removeFromSuperview];
            _loadingView = nil;
        }
    DWDPUCLoadingView *loadingView = [[DWDPUCLoadingView alloc] initWithFrame:(CGRect){(DWDScreenW - 310 * 0.5) * 0.5, (DWDScreenH - 64 - 271 * 0.5 - 15) * 0.5, 310 * 0.5, 271 * 0.5 + 100}];;
    [loadingView.blankImgView setImage:[UIImage imageNamed:@"img_addresslist_default"]];
    loadingView.blankImgView.frame = (CGRect){(310 * 0.5 - 350 * 0.5) * 0.5, 0, 350 * 0.5, 228 * 0.5};
    loadingView.delegate = self;
    [self.view insertSubview:loadingView aboveSubview:self.tableView];
    _loadingView = loadingView;
    
    WEAKSELF;
    [[DWDWebManager sharedManager] getSchoolGroupMembersWithParams:para success:^(NSURLSessionDataTask *task, id responseObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 设置原版数组
            weakSelf.requestSucceed = YES;
            weakSelf.selectedIndex = 0;
            NSMutableArray<DWDSchoolGroupModel *> *originArray = [[NSArray yy_modelArrayWithClass:[DWDSchoolGroupModel class] json:responseObject[@"data"]] mutableCopy];
            weakSelf.originGroupsArray = [originArray copy];
            // 设置显示数组
            if (originArray.count) {
                DWDSchoolGroupModel *model = [[DWDSchoolGroupModel alloc] init];
                model.groupName = @"全校";
                NSMutableArray <DWDSchoolGroupMemberModel *>*allMembers = [NSMutableArray array];
                [originArray enumerateObjectsUsingBlock:^(DWDSchoolGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [allMembers addObjectsFromArray:obj.groupMembers];
                }];
                model.groupMembers = allMembers;
                [originArray insertObject:model atIndex:0];
            }
            weakSelf.groupsArray = [originArray copy];
            // 设置header view数组
            
            
            // 刷新页面
            dispatch_async(dispatch_get_main_queue(), ^{
                if (originArray.count) {
                    [weakSelf initHeaderViewWithGroupArray:originArray];
                    [loadingView removeFromSuperview];
                    [weakSelf.navigationItem.rightBarButtonItem setEnabled:YES];
                } else {
                    [loadingView.descriptionLabel setText:@"暂无通讯录列表"];
                    [loadingView changeToBlankView];
                }
                [weakSelf.tableView reloadData];
            });
        });
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        weakSelf.requestSucceed = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [loadingView changeToFailedView];
            [weakSelf.tableView reloadData];
        });
    }];
}

- (void)presentAlertControllerWithModel:(DWDSchoolGroupMemberModel *)model {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    // 呼叫用户
    UIAlertAction *phoneCallAction = [UIAlertAction actionWithTitle:@"呼叫用户" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self phoneCallWithPhoneNumber:model.telPhone];
    }];
    [alertController addAction:phoneCallAction];
    
    // 添加至手机通讯录
    UIAlertAction *contactSaveAction = [UIAlertAction actionWithTitle:@"添加至手机通讯录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self saveToContactsWithModel:model];
    }];
    [alertController addAction:contactSaveAction];
    
    // 添加多维度好友
    UIAlertAction *friendAddAction = [UIAlertAction actionWithTitle:@"添加多维度好友" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            DWDPersonDataViewController *personController = [[DWDPersonDataViewController alloc] init];
            personController.custId = model.custId;
            // 根据好友关系判断进入控制器后按钮显示
            if ([[DWDContactsDatabaseTool sharedContactsClient] getRelationWithFriendCustId:model.custId]) {
                personController.personType = DWDPersonTypeIsFriend;
            } else {
                personController.personType = DWDPersonTypeIsStrangerAdd;
            }
            personController.showPhoneNumber = YES;
            [self.navigationController pushViewController:personController animated:YES];
        });
    }];
    [alertController addAction:friendAddAction];
    
    // 取消按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cancelAction];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)phoneCallWithPhoneNumber:(NSString *)phoneNumber {
    if (phoneNumber.length == 0 && phoneNumber == nil) return;
    
    NSString *formatPhoneNumber = [NSString stringWithFormat:@"tel:%@", phoneNumber];
//    NSString *formatPhoneNumber = @"tel:13181513123";
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:formatPhoneNumber]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:formatPhoneNumber]];
    }
}

// 点击了保存到通讯录
- (void)saveToContactsWithModel:(DWDSchoolGroupMemberModel *)model {
    if (!model.memberName || model.memberName.length == 0) return;
    if (!model.telPhone || model.telPhone.length == 0) return;
    
    [[DWDPrivacyManager shareManger] needPrivacy:DWDPrivacyTypeContacts withController:self authorized:^{
        BOOL succeed = [self contactAuthorizedToSave:model];
        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            if (succeed) {
                hud.labelText = @"保存到通讯录成功";
                [hud hide:YES afterDelay:1.5f];
            } else {
                hud.labelText = @"保存到通讯录失败";
                [hud hide:YES afterDelay:1.5f];
            }
        });
    }];
}

// 权限认证通过 可以保存 保存成功返回YES 保存通讯录
- (BOOL)contactAuthorizedToSave:(DWDSchoolGroupMemberModel *)model {
    NSString *name = model.memberName;
    NSString *phoneNumber = model.telPhone;
    // 根据系统版本选择框架
    if (iOSVersionLessThan(@"9.0")) {
        CFErrorRef error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreate();
        
        ABRecordRef newPerson = ABPersonCreate();
        
        //add name
        ABRecordSetValue(newPerson, kABPersonFirstNameProperty, (__bridge CFTypeRef)((id)name), &error);
        if (error) {
            DWDLog(@"nameError:%@", (__bridge NSError *)error);
            return NO;
        }
        //add phone numbers
        //in fact only one phone numbers
        ABMutableMultiValueRef mutiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(mutiPhone, (__bridge CFTypeRef)((id)phoneNumber), kABPersonPhoneMainLabel, NULL);
        ABRecordSetValue(newPerson, kABPersonPhoneProperty, mutiPhone, &error);
        if (error) {
            DWDLog(@"numberError:%@", (__bridge NSError *)error);
            return NO;
        }
        ABAddressBookAddRecord(addressBook, newPerson, &error);
        if (error) {
            DWDLog(@"saveError:%@", (__bridge NSError *)error);
            return NO;
        }
        ABAddressBookSave(addressBook, &error);
        if (error) {
            DWDLog(@"saveError:%@", (__bridge NSError *)error);
            return NO;
        } else {
            return YES;
        }
    } else {
        CNContactStore *store = [[CNContactStore alloc] init];
        //new person
        CNMutableContact *contact = [[CNMutableContact alloc] init];
        contact.familyName = name;
        CNLabeledValue *phoneNumberValue = [CNLabeledValue labeledValueWithLabel:CNLabelHome value:[CNPhoneNumber phoneNumberWithStringValue:phoneNumber]];
        contact.phoneNumbers = @[phoneNumberValue];
        
        //save request
        CNSaveRequest *request = [[CNSaveRequest alloc] init];
        [request addContact:contact toContainerWithIdentifier:nil];
        
        NSError *saveError = [[NSError alloc] init];
        if (![store executeSaveRequest:request error:&saveError]) {
            DWDLog(@"contact save error : %@", saveError);
            return NO;
        } else
            return YES;
    }
}

// 推到临时聊天
- (void)pushToTempChatWithModel:(DWDSchoolGroupMemberModel *)model {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在创建临时聊天";
    if (model.isFriend == NO) {
        NSDictionary *params = @{
                                 @"custId" : [self objectOrNULL:[DWDCustInfo shared].custId],
                                 @"friendCustId" : model.custId,
                                 //                             @"friendCustId" : @4010000005301,
                                 };
        WEAKSELF;
        // 发送请求
        [[HttpClient sharedClient] postAddTempFriendChatWithParams:params success:^(NSURLSessionDataTask *task, id responseObject) {
            // 插入到通讯录(replace into)
            [[DWDContactsDatabaseTool sharedContactsClient] addTempContact:[DWDTempContactModel yy_modelWithJSON:responseObject[@"data"]]];
            // push to chat controller
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:YES];
                [weakSelf pushToChatControllerWithModel:model];
            });
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.labelText = @"临时聊天创建失败";
                hud.mode = MBProgressHUDModeText;
                [hud hide:YES afterDelay:1.5f];
            });
            DWDLog(@"error:%@", error);
        }];
    } else {
        // 如果显示是好友,但是查通讯录确实不是好友
        if (![[DWDContactsDatabaseTool sharedContactsClient] getRelationWithFriendCustId:model.custId]) {
            // 更新通讯录
            // 成功失败都返回
            [[DWDContactsDatabaseTool sharedContactsClient] updateContactsByCustemId:[DWDCustInfo shared].custId success:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hide:YES];
                    [self pushToChatControllerWithModel:model];
                });
            } failure:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    hud.labelText = @"临时聊天创建失败";
                    hud.mode = MBProgressHUDModeText;
                    [hud hide:YES afterDelay:1.5f];
                    [self pushToChatControllerWithModel:model];
                });
            }];
        } else {
            // 是好友 直接走
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hide:YES];
                [self pushToChatControllerWithModel:model];
            });
        }
    }
    
}

- (id)objectOrNULL:(id)obj {
    if (obj == nil)
        return [NSNull null];
    else
        return obj;
}

#pragma mark - Temp Single Chat
- (void)pushToChatControllerWithModel:(DWDSchoolGroupMemberModel *)model {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil];
    DWDChatController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
    vc.chatType = DWDChatTypeFace;
//    if ([[DWDContactsDatabaseTool sharedContactsClient] getRelationWithFriendCustId:model.custId]) {
//        // 是好友
//    } else {
//        // 不是好友
//    }
    vc.title = model.memberName;
    vc.toUserId = model.custId;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
