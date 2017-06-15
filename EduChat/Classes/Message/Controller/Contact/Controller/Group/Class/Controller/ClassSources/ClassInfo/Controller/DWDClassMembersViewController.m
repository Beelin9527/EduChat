//
//  DWDClassMembersViewController.m
//  EduChat
//
//  Created by Gatlin on 16/5/4.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDClassMembersViewController.h"
#import "DWDContactSelectViewController.h"
#import "DWDNavViewController.h"
#import "DWDPersonDataViewController.h"

#import "DWDHeaderImgSortControl.h"

#import "DWDClassMemberClient.h"

#import "DWDClassDataBaseTool.h"
#import "DWDMessageDatabaseTool.h"
#import "DWDRecentChatDatabaseTool.h"
#import "DWDClassModel.h"
#import "DWDClassMember.h"

#import "DWDNoteChatMsg.h"
@interface DWDClassMembersViewController ()<DWDHeaderImgSortControlDelegate,DWDContactSelectViewControllerDelegate>
@property (strong, nonatomic) NSArray *membersArray;
@property (strong, nonatomic) DWDHeaderImgSortControl *headerImgSortControl;
@end

@implementation DWDClassMembersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"班群成员";
   
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //reqeust
    [self requedtClassMemberGetListWithClassId:self.classModel.classId];
    
}

#pragma mark - Getter
- (NSArray *)membersArray
{
    if (!_membersArray) {
        _membersArray = [[DWDClassDataBaseTool sharedClassDataBase]
                         getClassMemberWithClassId:self.classModel.classId
                         myCustId:[DWDCustInfo shared].custId];
    }
    return _membersArray;
}
- (DWDHeaderImgSortControl *)headerImgSortControl
{
    if (!_headerImgSortControl) {
        _headerImgSortControl = [[DWDHeaderImgSortControl alloc] init];
        _headerImgSortControl.delegate = self;
    }
    return _headerImgSortControl;
}


#pragma mark - Private Method
/** 更改本地库群组人数 */
- (void)changeMenberCount:(NSNumber *)menberCount
{
    [[DWDClassDataBaseTool sharedClassDataBase]
     updateClassInfoWithMemberCount:menberCount
     classId:self.classModel.classId];
    
    self.classModel.memberNum = menberCount;
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

#pragma mark - Table view data source
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
    
    self.headerImgSortControl.layouType = [DWDCustInfo shared].isTeacher ? DWDNeedOnlyDeleteButtonType : DWDNotNeedType;
    self.headerImgSortControl.arrItems = self.membersArray;
    self.headerImgSortControl.frame = CGRectMake(0, 0, DWDScreenW, self.headerImgSortControl.hight);
   
    [cell.contentView addSubview:self.headerImgSortControl];
    return cell;
}

#pragma mark - TableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.headerImgSortControl.hight;
}

#pragma mark - DWDHeaderImgSortControl Delegate
- (void)headerImgSortControl:(DWDHeaderImgSortControl *)headerImgSortControl DidGroupMemberWithCust:(NSNumber *)custId
{
    DWDPersonDataViewController *vc = [[DWDPersonDataViewController alloc] init];
    vc.custId = custId;
    vc.sourceType = DWDSourceTypeClass;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)headerImgSortControlDidSelectDeleteButton:(DWDHeaderImgSortControl *)headerImgSortControl
{
    DWDContactSelectViewController *vc = [[DWDContactSelectViewController alloc] init];
    vc.delegate = self;
    vc.type = DWDSelectContactTypeDeleteEntity;
    
    //获取非自己、非班级创建者的成员 进行删除操作
    vc.dataSource = [[DWDClassDataBaseTool sharedClassDataBase] getClassMemberIsNotMianWithClassId:self.classModel.classId myCustId:[DWDCustInfo shared].custId];
    
    DWDNavViewController *naviVC = [[DWDNavViewController alloc]initWithRootViewController:vc];
    [self.navigationController presentViewController:naviVC animated:YES completion:nil];
}

#pragma mark - DWDContactSelectViewController Delegate
- (void)contactSelectViewControllerDidSelectContactsForIds:(NSArray *)contactsIds selectContactType:(DWDSelectContactType)type
{
    if (type == DWDSelectContactTypeDeleteEntity) {
        
        NSDictionary *params = @{@"custId" : [DWDCustInfo shared].custId,
                                 @"classId" : self.classModel.classId,
                                 @"friendCustId" : contactsIds};
       
        DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:self.view];
        hud.labelText = @"正在删除";
        [[HttpClient sharedClient] postApi:@"ClassMemberRestService/deleteEntity" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
            
            [hud hide:YES];
 
            //0.从本地库获取array nickname
            NSArray *nicknameArray = [[DWDClassDataBaseTool sharedClassDataBase] getClassMemberNicknameWithClassId:self.classModel.classId memberArray:contactsIds];
            //1.删除班级成员本地库
           [[DWDClassDataBaseTool sharedClassDataBase] deleteClassMemberWithClassId:self.classModel.classId membersId:contactsIds success:^{
               
               //2.重新获取本地库班级成员
               self.membersArray =  [[DWDClassDataBaseTool sharedClassDataBase] getClassMemberWithClassId:self.classModel.classId myCustId:[DWDCustInfo shared].custId];
               
               //4.构造模型 你将xx移除了班级
               NSString *sysContent = [NSString stringWithFormat:@"你将%@移除了班级",[nicknameArray componentsJoinedByString:@"、"]];
              DWDNoteChatMsg *noteChatMsg = [self createNoteMsgWithString:sysContent toUserId:self.classModel.classId chatType:DWDChatTypeClass];
               //5.插入历史消息
               [self saveSystemMessage:noteChatMsg];
               
               //8.更新本地库会话表
               [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] insertNewDataToRecentChatListWithMsg:noteChatMsg FriendCusId:self.classModel.classId myCusId:[DWDCustInfo shared].custId success:^{
                   //发送通知、是否刷新 会话列表
                   [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNeedRecentChatLoad object:nil userInfo:@{@"isNeedLoadData":@(YES)}];
               } failure:^{
                   
               }];
               
               //6.更新班级人数
               [self changeMenberCount:@(self.membersArray.count)];
               
               //7.实现代理
               if (self.delegate && [self.delegate respondsToSelector:@selector(classMembersViewControllerNeedReload:)]) {
                   [self.delegate classMembersViewControllerNeedReload:self];
               }
               //3.刷新列表
               [self.tableView reloadData];
               
           } failure:^{
              
               //本地库删除失败 直接请求网络更新
               [self requedtClassMemberGetListWithClassId:self.classModel.classId];
           }];
            
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
//            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            hud.labelText = @"删除班级成员失败";
//            [hud show:YES];
            [hud hide:YES afterDelay:1.0];
        }];
    
    }
}

#pragma mark Request
- (void)requedtClassMemberGetListWithClassId:(NSNumber *)classId
{
    __weak typeof(self) weakSelf = self;
    [[DWDClassMemberClient sharedClassMemberClient]
     requestClassMemberGetListWithClassId:self.classModel.classId
     success:^(id responseObject) {
         
         __strong typeof(self) strongSelf = weakSelf;
         
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             self.membersArray =  [[DWDClassDataBaseTool sharedClassDataBase] getClassMemberWithClassId:strongSelf.classModel.classId myCustId:[DWDCustInfo shared].custId];
             
             //设置班级成员VIEW
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
             });
         });
         
     } failure:^(NSError *error) {
         
     }];
}
@end
