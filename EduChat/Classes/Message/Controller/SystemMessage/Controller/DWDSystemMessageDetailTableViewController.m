//
//  DWDSystemMessageDetailTableViewController.m
//  EduChat
//
//  Created by apple on 3/1/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import "DWDSystemMessageDetailTableViewController.h"
#import "DWDChatController.h"

#import "DWDContactsDatabaseTool.h"
#import "DWDRecentChatDatabaseTool.h"
#import "DWDMessageDatabaseTool.h"

#import "DWDSystemMessageDetailModel.h"
#import "DWDDetailSystemMessagePhotoCell.h"
#import "DWDDetailSystemMessageVerifyCell.h"
#import "DWDDetailSystemMessageInfoCell.h"
#import "DWDUserInfoModel.h"

#import "DWDClassModel.h"
#import "DWDClassDataBaseTool.h"

#import "DWDNoteChatMsg.h"

#import "DWDClassDataBaseTool.h"
#import "DWDMessageDatabaseTool.h"
#import "DWDRecentChatDatabaseTool.h"

@interface DWDSystemMessageDetailTableViewController () <DWDDetailSystemMessageVerifyCellDelegate>
@property (nonatomic, strong) DWDUserInfoModel *userModel;
@property (nonatomic, strong) UIView *buttonView;

@end

@implementation DWDSystemMessageDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"验证申请";
    self.tableView.estimatedRowHeight = 200;
    [self.tableView registerClass:[DWDDetailSystemMessagePhotoCell class] forCellReuseIdentifier:@"PhotoCell"];
    [self.tableView registerClass:[DWDDetailSystemMessageVerifyCell class] forCellReuseIdentifier:@"VerifyCell"];
    [self.tableView registerClass:[DWDDetailSystemMessageInfoCell class] forCellReuseIdentifier:@"InfoCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = DWDRGBColor(245, 245, 245);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] clearBadgeCountWithFriendId:@1000 myCusId:[DWDCustInfo shared].custId success:^{
    } failure:^{
    }];
    
    [DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool].currentOperationFriendId = @1000;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] clearBadgeCountWithFriendId:@1000 myCusId:[DWDCustInfo shared].custId success:^{
    } failure:^{
    }];
    [DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool].currentOperationFriendId = nil;
}

#pragma mark - Table view data source
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, pxToH(20))];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return self.buttonView;
    } else {
        return nil;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0) {
//        return pxToH(160);
//    }
//    else if (indexPath.section == 1) {
//        return pxToH(160);
//    } else {
//        return pxToH(397);
//    }
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        DWDDetailSystemMessagePhotoCell *photoView = [tableView dequeueReusableCellWithIdentifier:@"PhotoCell"];
        photoView.name = self.data.nickName;
        photoView.photoKey = self.data.photoKey;
        photoView.status = [self getUserStatus];
        
        if (self.userModel.gender == 1) {
            photoView.gender = @"男";
        } else {
            photoView.gender = @"女";
        }
        photoView.selectionStyle = UITableViewCellSelectionStyleNone;
        return photoView;
    } else if (indexPath.section == 1) {
        DWDDetailSystemMessageVerifyCell *verifyView = [tableView dequeueReusableCellWithIdentifier:@"VerifyCell"];
        verifyView.delegate = self;
//        verifyView.name = self.data.nickName;
        verifyView.verifyInfo = self.data.verifyInfo;
//        verifyView.verifyId = self.data.
        verifyView.selectionStyle = UITableViewCellSelectionStyleNone;
        return verifyView;
    } else {
        DWDDetailSystemMessageInfoCell *infoView = [tableView dequeueReusableCellWithIdentifier:@"InfoCell"];
        infoView.address = self.userModel.address;
        infoView.signature = self.userModel.signature;
        infoView.verifySource = self.data.className;
        infoView.selectionStyle = UITableViewCellSelectionStyleNone;
        return infoView;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return pxToH(20);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return pxToH(240);
    } else {
        return 0;
    }
}

#pragma mark - UITableViewDelegate

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView)
    {
        CGFloat sectionHeaderHeight = pxToH(20);
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
}

#pragma mark - Private Method
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

#pragma mark - Setter / Getter
- (NSString *)getUserStatus {
    NSString *status = @"";
    switch ([self.userModel.custType intValue]) {
        case 1:
            status = @"机构";
            break;
        case 2:
            status = @"学校";
            break;
        case 3:
            status = @"培训机构";
            break;
        case 4:
            status = @"教师";
            break;
        case 5:
            status = @"学生";
            break;
        case 6:
            status = @"家长";
            break;
        case 7:
            status = @"班级";
            break;
        case 8:
            status = @"群组";
            break;
        case 9:
            status = @"管理员";
            break;
        default:
            status = @"用户";
            break;
    }
    return status;
}





- (void)setData:(DWDSystemMessageDetailModel *)data {
    _data = data;
    
    //获取好友信息
    WEAKSELF;
    [[HttpClient sharedClient] getUserInfo:data.custId success:^(NSURLSessionDataTask *task, id responseObject) {
        
//        @property (nonatomic, copy) NSString *gender;
//        @property (nonatomic, copy) NSString *status;
//        @property (nonatomic, copy) NSString *address;
//        @property (nonatomic, copy) NSString *signature;
        DWDUserInfoModel *userModel = [[DWDUserInfoModel alloc] init];
        userModel.gender = [responseObject[@"data"][@"gender"] intValue];
        userModel.address = responseObject[@"data"][@"regionName"];
        userModel.signature = responseObject[@"data"][@"signature"];
        userModel.custType = responseObject[@"data"][@"custType"];
        weakSelf.userModel = userModel;
        
        DWDMarkLog(@"getUserInfoEx success");
        [weakSelf.tableView reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [DWDProgressHUD showText:@"获取失败"];
    }];
    
}

- (UIView *)buttonView {
    if (!_buttonView) {
        UIView *view = [UIView new];
        CGRect frame = CGRectMake(0, 0, DWDScreenW, pxToH(20));
        view.frame = frame;
        view.backgroundColor = [UIColor clearColor];
        
        frame = CGRectZero;
        frame.origin.y = pxToH(40);
        frame.size.height = pxToH(80);
        CGFloat width = pxToW(600);
        frame.origin.x = (DWDScreenW - width) / 2.0;
        frame.size.width = width;
        
        //正常按钮
        UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [confirmButton setBackgroundColor:DWDRGBColor(90, 136, 230)];
        [confirmButton.layer setCornerRadius:(pxToH(80) * 0.5)];
        [confirmButton setTitleColor:DWDRGBColor(254, 254, 254) forState:UIControlStateNormal];
        confirmButton.layer.masksToBounds = YES;
        confirmButton.frame = frame;
        //拒绝按钮
        UIButton *refuseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [refuseButton setBackgroundColor:[UIColor whiteColor]];
        [refuseButton.layer setCornerRadius:(pxToH(80) * 0.5)];
        [refuseButton setTitleColor:DWDRGBColor(1, 1, 1) forState:UIControlStateNormal];
        refuseButton.layer.masksToBounds = YES;
        if ([self.data.verifyState intValue] == 0) { //两个按钮
            frame.origin.y += pxToH(120);
            refuseButton.frame = frame;
            NSString *confirmString = @"通过验证";
            [confirmButton setTitle:confirmString forState:UIControlStateNormal];
            [confirmButton addTarget:self action:@selector(confirmButtonClick) forControlEvents:UIControlEventTouchUpInside];
            
            NSString *refuseString = @"我要拒绝";
            [refuseButton setTitle:refuseString forState:UIControlStateNormal];
            [refuseButton addTarget:self action:@selector(refuseButtonClick) forControlEvents:UIControlEventTouchUpInside];
            
            [view addSubview:confirmButton];
            [view addSubview:refuseButton];
        }
        else {
            NSString *stateString;
            if ([self.data.verifyState intValue] == 1) { //通过
                //进入班级
                stateString = @"进入班级";
                [confirmButton setTitle:stateString forState:UIControlStateNormal];
                [confirmButton addTarget:self action:@selector(goClassButtonClick) forControlEvents:UIControlEventTouchUpInside];
                [view addSubview:confirmButton];
                
            } else { //拒绝
                
                refuseButton.frame = frame;
                stateString = @"已拒绝";
                [refuseButton setTitle:stateString forState:UIControlStateNormal];
                refuseButton.userInteractionEnabled = NO;
                [view addSubview:refuseButton];
            }
        }
        
        
        _buttonView = view;
    }
    return _buttonView;
}

//custId	√	long	用户id
//memberCustId	√	long	班级成员id
//classId	√	long	班级Id
//state	√	int	验证状态
//0-待验证
//1-通过
//2-已拒绝

- (void)confirmButtonClick {
    DWDMarkLog(@"%s", __func__);
    NSDictionary *dic = @{@"custId":[DWDCustInfo shared].custId,
                          @"memberCustId":self.data.custId,
                          @"classId":self.data.classId,
                          @"memberChildId":self.data.memberChildId,
                          @"state":@1};
    
    WEAKSELF;
    [[HttpClient sharedClient] postUpdateClassVerifyState:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        
        //1.构造模型
        NSString *lastContent = [NSString stringWithFormat:@"%@加入了班级",self.data.nickName];
        
        DWDNoteChatMsg *noteChatMsg = [self createNoteMsgWithString:lastContent toUserId:self.data.classId chatType:DWDChatTypeClass];
        
        //2.保存历史消息
        [self saveSystemMessage:noteChatMsg];
        
        //3.更新本地库会话表
        [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] insertNewDataToRecentChatListWithMsg:noteChatMsg FriendCusId:self.data.classId myCusId:[DWDCustInfo shared].custId success:^{
            //发送通知、是否刷新 会话列表
            [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNeedRecentChatLoad object:nil userInfo:@{@"isNeedLoadData":@(YES)}];
        } failure:^{
            
        }];
//        DWDClassModel *classModel = [[DWDClassDataBaseTool sharedClassDataBase] getClassInfoWithClassId:self.data.classId myCustId:[DWDCustInfo shared].custId];
//        NSInteger memberCount = [classModel.memberNum integerValue] + 1;
//        //3.更新班级人数。加一
//        [[DWDClassDataBaseTool sharedClassDataBase] updateClassInfoWithMemberCount:@(memberCount) classId:self.data.classId];
        
        //3.发通知 刷新班级列表
//        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationClassListReload object:nil];
        // 改变上个页面状态 通过验证
        if (_eventDelegate && [_eventDelegate respondsToSelector:@selector(systemMessageDetailController:didChangeVerifyState:)]) {
            [_eventDelegate systemMessageDetailController:self didChangeVerifyState:@1];
        }
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
        DWDMarkLog(@"postUpdateClassVerifyState YES");
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDMarkLog(@"postError:%@", error);
        [weakSelf.navigationController popViewControllerAnimated:YES];
        DWDMarkLog(@"postUpdateClassVerifyState NO");
    }];
    
    
}

- (void)refuseButtonClick {
    DWDMarkLog(@"%s", __func__);
    NSDictionary *dic = @{@"custId":[DWDCustInfo shared].custId,
                          @"memberCustId":self.data.custId,
                          @"classId":self.data.classId,
                          @"state":@2};
    WEAKSELF;
    [[HttpClient sharedClient] postUpdateClassVerifyState:dic success:^(NSURLSessionDataTask *task, id responseObject) {
        // 改变上个页面状态 拒绝
        if (_eventDelegate && [_eventDelegate respondsToSelector:@selector(systemMessageDetailController:didChangeVerifyState:)]) {
            [_eventDelegate systemMessageDetailController:self didChangeVerifyState:@2];
        }
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDMarkLog(@"postError:%@", error);
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)goClassButtonClick {
    DWDClassModel *model = [[DWDClassDataBaseTool sharedClassDataBase] getClassInfoWithClassId:_data.classId myCustId:[DWDCustInfo shared].custId];
//    DWDChatController *vc = [DWDChatController];
//    chatController.myClass = model;
    if ([model.isExist isEqualToNumber:@0]) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"您已不在该班级";
        [hud show:YES];
        [hud hide:YES afterDelay:1.5f];
        return;
    }
     DWDChatController *chatController = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
    chatController.chatType = DWDChatTypeClass;
    chatController.toUserId = _data.classId;
    chatController.myClass = model;
    [self.navigationController pushViewController:chatController animated:YES];
}

#pragma mark - DWDDetailSystemMessageVerifyCellDelegate
- (void)verifyCell:(DWDDetailSystemMessageVerifyCell *)cell clickReplyToShowAlertController:(UIAlertController *)controller {
    [self.navigationController presentViewController:controller animated:YES completion:^{
    }];
}

- (void)verifyCell:(DWDDetailSystemMessageVerifyCell *)cell clickComfirmButtonToSendText:(NSString *)text {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在发送";
    NSDictionary *dict = @{
                           @"custId" : [DWDCustInfo shared].custId,
                           @"verifyId" : self.data.verifyId,
                           @"verifyInfo" : text,
                           };
    [[HttpClient sharedClient] postClassVerifyReplyVerifyInfoWithParams:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.labelText = @"发送失败";
            [hud hide:YES afterDelay:1.5f];
        });
    }];
}


@end
