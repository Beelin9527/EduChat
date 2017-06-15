//
//  DWDGroupMembersSelectController.m
//  EduChat
//
//  Created by KKK on 16/12/5.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDGroupMembersSelectController.h"

#import "DWDGroupSelectHeaderView.h"
#import "DWDGroupMemberSelectCell.h"

#import "DWDPUCLoadingView.h"

#import "DWDSchoolGroupModel.h"
//群组相关
#import "DWDNoteChatMsg.h"
#import "DWDMessageDatabaseTool.h"

#import <YYModel.h>
#import <Masonry.h>

#import "DWDGroupClient.h"
#import "DWDChatController.h"
#import "DWDGroupEntity.h"
#import "DWDContactsDatabaseTool.h"
#import "DWDContactModel.h"
#import "DWDGroupDataBaseTool.h"

#import <FMDB.h>

#define singleCellHeight 44

@interface DWDGroupMembersSelectController ()<UITableViewDelegate, UITableViewDataSource, DWDGroupSelectHeaderViewDelegate, DWDGroupMemberSelectCellDelegate, DWDPUCLoadingViewDelegate>

@property (nonatomic, weak) UIButton *allSelectGroupButton;

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UIButton *doneButton;

@property (nonatomic, weak) UILabel *tableHeaderDescriptionLabel;

@end

@implementation DWDGroupMembersSelectController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"群发消息(0)人";
    self.view.backgroundColor = DWDColorBackgroud;
    [self createRightNavigationItem];
    [self createTableView];
    [self createBottomView];
    [self getDataWithArray];
}
//
//- (void)dealloc {
//    DWDLog(@"%@:%s",self, __func__);
//}

#pragma mark - initSubViews
//导航栏全选按钮
- (void)createRightNavigationItem {
    UIButton *allSelectGroupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [allSelectGroupButton addTarget:self action:@selector(allSelectGroupButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
//    [allSelectGroupButton setTitle:@"全选" forState:UIControlStateNormal];
    [allSelectGroupButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@" 全选 " attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14], NSForegroundColorAttributeName : [UIColor whiteColor]}] forState:UIControlStateNormal];
    [allSelectGroupButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"全不选" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14], NSForegroundColorAttributeName : [UIColor whiteColor]}] forState:UIControlStateSelected];
    [allSelectGroupButton sizeToFit];
    _allSelectGroupButton = allSelectGroupButton;
    
//    UIBarButtonItem *allSelectGroupButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStyleDone target:self action:@selector(allSelectGroupButtonDidClick)];
    UIBarButtonItem *allSelectGroupButtonItem = [[UIBarButtonItem alloc] initWithCustomView:allSelectGroupButton];
    self.navigationItem.rightBarButtonItem = allSelectGroupButtonItem;
}

- (void)createTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:(CGRect){0, 0, DWDScreenW, DWDScreenH - 64}];
    tableView.userInteractionEnabled = YES;
    tableView.contentInset = UIEdgeInsetsMake(0, 0, 56, 0);
    tableView.backgroundView = nil;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    [tableView registerClass:[DWDGroupSelectHeaderView class] forHeaderFooterViewReuseIdentifier:@"DWDGroupSelectHeaderView"];
    [tableView registerClass:[DWDGroupMemberSelectCell class] forCellReuseIdentifier:@"DWDGroupMemberSelectCell"];
    _tableView = tableView;
    
    // tableHeaderView
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:(CGRect){0, 0, DWDScreenW, 40}];
    tableHeaderView.backgroundColor = [UIColor clearColor];
    
    UILabel *descriptionLabel = [UILabel new];
    descriptionLabel.font = [UIFont systemFontOfSize:14];
    descriptionLabel.textColor = DWDColorContent;
    descriptionLabel.text = @"";
    [tableHeaderView addSubview:descriptionLabel];
    [descriptionLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(0);
    }];
    _tableHeaderDescriptionLabel = descriptionLabel;
    tableView.tableHeaderView = tableHeaderView;
}

// 完成底部页面
- (void)createBottomView {
    UIView *bottomView = [[UIView alloc] initWithFrame:(CGRect){0, _tableView.bounds.size.height, DWDScreenW, 56}];
    bottomView.backgroundColor = [UIColor whiteColor];
    bottomView.layer.shadowColor = [UIColor blackColor].CGColor;
    bottomView.layer.shadowOpacity = 0.14f;
    bottomView.layer.shadowOffset = CGSizeMake(0, -4);
    bottomView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, bottomView.frame.size.width, bottomView.frame.size.height + 2)].CGPath;
    [self.view insertSubview:bottomView aboveSubview:_tableView];
    _bottomView = bottomView;
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"确定"
                                                              attributes:@{NSForegroundColorAttributeName : DWDRGBColor(255, 254, 254),
                                                                           NSFontAttributeName : [UIFont systemFontOfSize:16]}];
    [doneButton addTarget:self action:@selector(doneButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setAttributedTitle:str forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneButton setBackgroundImage:[UIImage imageWithColor:DWDColorMain] forState:UIControlStateNormal];
    [bottomView addSubview:doneButton];
    doneButton.layer.cornerRadius = 40 * 0.5;
    doneButton.layer.masksToBounds = YES;
    doneButton.clipsToBounds = YES;
    [doneButton makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(bottomView);
        make.width.mas_equalTo(DWDScreenW - 60);
        make.height.mas_equalTo(40);
    }];
    
    doneButton.enabled = NO;
    _doneButton = doneButton;
}

#pragma mark - Event Response
- (void)doneButtonClick {
    __block NSMutableArray *saveArray = [NSMutableArray array];
    __block NSMutableArray *selectedArray = [NSMutableArray array];
    [_dataArray enumerateObjectsUsingBlock:^(DWDSchoolGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.groupMembers enumerateObjectsUsingBlock:^(DWDSchoolGroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.checked == YES) {
                [saveArray addObject:obj];
                [selectedArray addObject:obj.custId];
            }
        }];
    }];
    if (selectedArray.count == 0) return;
    DWDLog(@"######################\nselect%@\n######################\n", selectedArray);
    
    //发送创建群组请求
    NSDictionary *params = @{
                             @"custId" : [DWDCustInfo shared].custId,
                             @"groupName" : @"临时群组",
                             @"friendCustId" : selectedArray,
//                             @"friendCustId" : @[@4010000005301],
                             @"duration" : @4,
                             @"isSave" : @NO,
                             };
    WEAKSELF;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在创建群组...";
    [[HttpClient sharedClient] postAddGroupChatWithParams:params success:^(NSURLSessionDataTask *task, id responseObject) {
        DWDGroupEntity *entity = [DWDGroupEntity yy_modelWithJSON:responseObject[@"data"]];
        // 主动插入本地库
        [[DWDGroupDataBaseTool sharedGroupDataBase] insertOneGroup:entity];
        [weakSelf dealWithNoteMsgGroupEntity:entity selctedArray:saveArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil];
            DWDChatController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
            vc.chatType = DWDChatTypeGroup;
            vc.title = entity.groupName;
            vc.toUserId = entity.groupId;
            vc.groupEntity = entity;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.mode = MBProgressHUDModeText;
#ifdef DEBUG
            hud.labelText = [error domain];
#else
            hud.labelText = @"创建失败";
#endif
            [hud hide:YES afterDelay:1.5f];
        });
    }];
   
    
    
    
//    /** 跳转到临时群聊页面 */
//    DWDGroupEntity *group = [[DWDGroupEntity alloc] init];
//    group.groupName = @"xxx";
//    group.isSave = [NSNumber numberWithFloat:0];
//    
//    DWDChatController *chatController = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
//    chatController.toUserId = @4010000005168;
//    chatController.chatType = DWDChatTypeGroup;
//    [self.navigationController pushViewController:chatController animated:YES];
}

- (void)allSelectGroupButtonDidClick:(UIButton *)selectButton {
    [selectButton setSelected:!selectButton.isSelected];
    BOOL isSelected = selectButton.isSelected;
    [_dataArray enumerateObjectsUsingBlock:^(DWDSchoolGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.checked = isSelected;
        [obj.groupMembers enumerateObjectsUsingBlock:^(DWDSchoolGroupMemberModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.checked = isSelected;
        }];
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tableView reloadData];
        [self updateNavigationTitle];
    });
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DWDSchoolGroupModel *model = _dataArray[section];
    if (model.expanded)
        return model.groupMembers.count;
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DWDGroupMemberSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DWDGroupMemberSelectCell"];
    cell.eventDelegate = self;
    DWDSchoolGroupMemberModel *model = [_dataArray[indexPath.section] groupMembers][indexPath.row];
    [cell setCellData:model];
    return cell;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DWDGroupSelectHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DWDGroupSelectHeaderView"];
    view.section = section;
    view.eventDelegate = self;
    [view setHeaderData:_dataArray[section]];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DWDSchoolGroupMemberModel *model = [_dataArray[indexPath.section] groupMembers][indexPath.row];
    model.checked = !model.checked;
    [self reloadRowWithIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DWDSchoolGroupModel *model = _dataArray[indexPath.section];
    if (model.expanded)
        return singleCellHeight;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return singleCellHeight;
}

#pragma mark - DWDGroupMemberSelectCellDelegate
- (void)groupMemberSelectCellDidClickCheckButton:(DWDGroupMemberSelectCell *)cell {
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    if (indexPath != nil) {
        [self ifNeedReloadSectionHeaderViewWithSection:indexPath.section];
    }
}

#pragma mark - DWDGroupSelectHeaderViewDelegate
- (void)groupSelectHeaderView:(DWDGroupSelectHeaderView *)view shouldAllSelectInSection:(NSInteger)section {
    [self reloadRowsInSection:section];
}

- (void)groupSelectHeaderView:(DWDGroupSelectHeaderView *)view shouldChangeExpandStateInSection:(NSInteger)section {
    [self reloadRowsInSection:section];
}
#pragma mark - DWDPUCLoadingViewDelegate
- (void)loadingViewDidClickReloadButton:(DWDPUCLoadingView *)view {
    
}

#pragma mark - Private Method
- (void)getDataWithArray {
    
/**********************************模拟数据开发测试*********************************************/
/**********************************模拟数据开发测试*********************************************/
/**********************************模拟数据开发测试*********************************************/
/**********************************模拟数据开发测试*********************************************/
/**********************************模拟数据开发测试*********************************************/
//    NSMutableArray *groupArray = [NSMutableArray array];
//    for (int g = 0; g < 5; g ++) {
//        DWDSchoolGroupModel *groupModel = [DWDSchoolGroupModel new];
//        groupModel.schoolName = @"学校";
//        groupModel.groupName = [NSString stringWithFormat:@"g:%d", g];
//        
//        NSMutableArray *membersArray = [NSMutableArray array];
//        for (int i = 0; i < 5; i ++) {
//            DWDSchoolGroupMemberModel *memberModel = [DWDSchoolGroupMemberModel new];
//            memberModel.custId = @(g * i);
//            memberModel.memberName = [NSString stringWithFormat:@"测试s:%d-m:%d", g, i];
//            [membersArray addObject:memberModel];
//        }
//        groupModel.groupMembers = membersArray;
//        [groupArray addObject:groupModel];
//    }
//    
//    if (_loadingView) {
//        [_loadingView removeFromSuperview];
//        _loadingView = nil;
//    }
//    
//    DWDPUCLoadingView *loadingView = [[DWDPUCLoadingView alloc] initWithFrame:(CGRect){(DWDScreenW - 310 * 0.5) * 0.5, (self.tableView.bounds.size.height - 271 * 0.5 - 15) * 0.5, 310 * 0.5, 271 * 0.5}];;
//    loadingView.delegate = self;
//    [self.view insertSubview:loadingView aboveSubview:self.tableView];
//    loadingView.layer.zPosition = MAXFLOAT;
//    _loadingView = loadingView;
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        _dataArray = groupArray;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.loadingView removeFromSuperview];
//            self.loadingView = nil;
////            [self.loadingView.descriptionLabel setText:@"暂无分组成员"];
////            [self.loadingView changeToBlankView];
////                [self.loadingView changeToFailedView];
//            _tableHeaderDescriptionLabel.text = @"请选择您要群发消息的同事";
//            [self.tableView reloadData];
//            
//            [UIView animateWithDuration:0.25f animations:^{
//                DWDLog(@"\noriginRect:%@\noffsetRect:%@", NSStringFromCGRect(_bottomView.frame), NSStringFromCGRect(CGRectOffset(_bottomView.frame, 0, -56)));
//                _bottomView.frame = CGRectOffset(_bottomView.frame, 0, -56);
//            }];
//        });
//    });
//    //none
////    [weakSelf.loadingView.descriptionLabel setText:@"暂无分组成员"];
////    [weakSelf.loadingView changeToBlankView];
//    //fail
////    [weakSelf.loadingView changeToFailedView]; 
    
    
/**********************************接口处理数据*********************************************/
/**********************************接口处理数据*********************************************/
/**********************************接口处理数据*********************************************/
/**********************************接口处理数据*********************************************/
/**********************************接口处理数据*********************************************/
    DWDPUCLoadingView *loadingView = [[DWDPUCLoadingView alloc] initWithFrame:(CGRect){(DWDScreenW - 310 * 0.5) * 0.5, (DWDScreenH - 64 - 271 * 0.5 - 15) * 0.5, 310 * 0.5, 271 * 0.5 + 100}];;
    [self.view insertSubview:loadingView aboveSubview:self.tableView];
//    loadingView.layer.zPosition = MAXFLOAT;
    
    NSMutableArray *array = [_dataArray mutableCopy];
    
    __block NSMutableArray<DWDSchoolGroupModel *> *deleteArray = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(DWDSchoolGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.groupMembers.count == 0) {
            [deleteArray addObject:obj];
        }
    }];
    [array removeObjectsInArray:deleteArray];
    _dataArray = array;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (array.count) {
            [loadingView removeFromSuperview];
            _tableHeaderDescriptionLabel.text = @"请选择您要群发消息的同事";
            [_tableView reloadData];
            [UIView animateWithDuration:0.25f animations:^{
                _bottomView.frame = CGRectOffset(_bottomView.frame, 0, -56);
            }];
        } else {
            [loadingView.descriptionLabel setText:@"暂无分组成员"];
            [loadingView changeToBlankView];
            [_tableView reloadData];
        }
    });
}

//在选中/取消选中 cell时候,判断是否需要变化header view
- (void)reloadRowWithIndexPath:(NSIndexPath *)indexPath {
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self ifNeedReloadSectionHeaderViewWithSection:indexPath.section];
}

// 判断是否需要变化header view, 并且更新navigation title
- (void)ifNeedReloadSectionHeaderViewWithSection:(NSInteger)section {
    [self updateNavigationTitle];
    DWDSchoolGroupModel *model = _dataArray[section];
    NSPredicate *sectionPredicate = [NSPredicate predicateWithFormat:@"checked == YES"];
    NSArray *currentSectionSelected = [model.groupMembers filteredArrayUsingPredicate:sectionPredicate];
    if (currentSectionSelected.count == model.groupMembers.count) {
        if (model.checked == NO) {
            model.checked = YES;
            [self reloadSectionHeaderViewWithSection:section];
        }
    } else {
        if (model.checked == YES) {
            model.checked = NO;
            [self reloadSectionHeaderViewWithSection:section];
        }
    }
    [self updateNavigationTitle];
}

// 刷新headerview的状态
- (void)reloadSectionHeaderViewWithSection:(NSInteger)section {
    DWDGroupSelectHeaderView *headerView = (DWDGroupSelectHeaderView *)[_tableView headerViewForSection:section];
    [headerView reloadView];
}

- (void)reloadRowsInSection:(NSInteger)section {
    [_tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
    [self updateNavigationTitle];
}

// 更新navigation title
- (void)updateNavigationTitle {
    NSInteger selectedMember = 0;
    BOOL allselected = YES;
    for (DWDSchoolGroupModel *model in _dataArray) {
        if (model.checked == YES) {
            // 组的check状态是yes的时候, 表示整组都被选择
            selectedMember += model.groupMembers.count;
            continue;
        }
        allselected = NO;
        NSPredicate *sectionPredicate = [NSPredicate predicateWithFormat:@"checked == YES"];
        NSArray *currentSectionSelected = [model.groupMembers filteredArrayUsingPredicate:sectionPredicate];
        selectedMember += currentSectionSelected.count;
    }
    
    // 只要选择了人, 确定按钮就可用
    if (selectedMember > 0) {
        _doneButton.enabled = YES;
    } else {
        _doneButton.enabled = NO;
        // 如果一个人没选 把 全卜选按钮 变成 全选按钮
        if (_allSelectGroupButton.isSelected) {
            [_allSelectGroupButton setSelected:NO];
        }
    }
    
    // 如果全部选择 那把 全选按钮 变成 全卜选按钮
    if (allselected == YES && !_allSelectGroupButton.isSelected) {
        [_allSelectGroupButton setSelected:YES];
    }
    [_allSelectGroupButton sizeToFit];
    
    self.title = [NSString stringWithFormat:@"群发消息(%zd)人", selectedMember];
}

- (id)objectOrNULL:(id)obj {
    if (obj == nil)
        return [NSNull null];
    else
        return obj;
}

#pragma mark - Temp Group Chat
/** 系统消息 私有处理 */
- (void)dealWithNoteMsgGroupEntity:(DWDGroupEntity *)entity selctedArray:(NSArray *)selectedArray
{
    
    //判断组数是否有成员
    if(selectedArray.count)
    {
        //插入消息 “你邀请了xxx加入了群组”
        //获取邀请群成员的昵称
        NSMutableArray *membersNicknameArray = [NSMutableArray arrayWithCapacity:2];
        for (DWDSchoolGroupMemberModel *memberModel in selectedArray) {
            [membersNicknameArray addObject:memberModel.memberName];
        }
        NSArray *array = membersNicknameArray.copy;
        NSString *noteContent = [NSString stringWithFormat:@"你邀请%@加入了群组",[array componentsJoinedByString:@"、"]];
        
        DWDNoteChatMsg *noteChatMsg = [self createNoteMsgWithString:noteContent toUserId:entity.groupId     chatType:DWDChatTypeGroup];
        //5.插入历史消息
        [self saveSystemMessage:noteChatMsg];
    }
    
}


/** 构造 系统消息 谁加入、移除班级 */
- (DWDNoteChatMsg *)createNoteMsgWithString:(NSString *)str toUserId:(NSNumber *)toUserId chatType:(DWDChatType)chatType{
    DWDNoteChatMsg *noteMsg = [[DWDNoteChatMsg alloc] init];
    noteMsg.noteString = str;
    noteMsg.fromUser = [DWDCustInfo shared].custId;
    noteMsg.toUser = toUserId;
    noteMsg.createTime = [NSNumber numberWithLongLong:([NSDate date].timeIntervalSince1970 * 1000)];
    noteMsg.msgType = kDWDMsgTypeNote;
    noteMsg.chatType = chatType;
    return noteMsg;
}

// 存消息模型到本地
- (void)saveSystemMessage:(DWDBaseChatMsg *)msg
{
    [[DWDMessageDatabaseTool sharedMessageDatabaseTool] addMsgToDBWithMsg:msg success:^{
        
        //0. 发通知 ，刷新聊天控制器
        NSDictionary *dict = @{@"msg":msg};
        [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationSystemMessageReload object:nil userInfo:dict];
        
    } failure:^(NSError *error) {
        DWDLog(@"error : %@",error);
    }];
}

@end
