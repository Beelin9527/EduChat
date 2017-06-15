//
//  DWDGroupNameSetupViewController.m
//  EduChat
//
//  Created by Gatlin on 15/12/22.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDGroupNameSetupViewController.h"
#import "DWDGroupClient.h"

#import "DWDGroupDataBaseTool.h"
#import "DWDRecentChatDatabaseTool.h"
#import "DWDMessageDatabaseTool.h"

#import "DWDGroupEntity.h"

#import "DWDNoteChatMsg.h"

@interface DWDGroupNameSetupViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *tfSetupName;
@end

@implementation DWDGroupNameSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"群组名称";
    
    self.tfSetupName.text = self.groupModel.groupName;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(requestDataAction)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFielDidChange) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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


#pragma mark - Notification Implementation
- (void)textFielDidChange
{
    NSString *toBeString = self.tfSetupName.text;
    
    //获取高亮部分
    UITextRange *selectedRange = [self.tfSetupName markedTextRange];
    UITextPosition *position = [self.tfSetupName positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position)
    {
        if (toBeString.length > 16)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:16];
            if (rangeIndex.length == 1)
            {
                self.tfSetupName.text = [toBeString substringToIndex:16];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 16)];
                self.tfSetupName.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
    
    if ([self.groupModel.groupName isEqualToString:self.tfSetupName.text] || self.tfSetupName.text.length <= 0 ) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

#pragma mark - TextFiel Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![self.groupModel.groupName isEqualToString:textField.text] || textField.text.length != 0) {
        [self requestDataAction];
    }
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Request
-(void)requestDataAction
{
    if ([self.tfSetupName.text isBlank]) {
        [DWDProgressHUD showText:@"群组名称不能为空"];
        return;
    }
    self.tfSetupName.text = [self.tfSetupName.text trim];
    
    //请求
    [[DWDGroupClient sharedRequestGroup]
     getGroupRestUpdateGroupWithGroupId:self.groupModel.groupId
     groupName:self.tfSetupName.text
     groupNickName:nil
     success:^(id responseObject) {
        
        //更新对就本地库群组名称
        [[DWDGroupDataBaseTool sharedGroupDataBase]
         updateGroupInfoWithMyCustId:[DWDCustInfo shared].custId
         groupId:self.groupModel.groupId
         groupName:self.tfSetupName.text];
        
         self.groupModel.groupName = self.tfSetupName.text;
        
        //发通知。 更改聊天Title
         NSDictionary *dict = @{@"title":self.tfSetupName.text,@"custId":self.groupModel.groupId};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateChatTitle" object:nil userInfo:dict];
        
         //6.构造模型
         NSString *lastContent = [NSString stringWithFormat:@"你将群组名称更改为\"%@\"",self.tfSetupName.text];
         DWDNoteChatMsg *noteChatMsg = [self createNoteMsgWithString:lastContent toUserId:self.groupModel.groupId chatType:DWDChatTypeGroup];
         
         //7.保存历史消息
         [self saveSystemMessage:noteChatMsg];
         
         //更新会话列表 群组名
         [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool]
          updateRecentChatNicknameWithFriendId:self.groupModel.groupId
          nickname:self.tfSetupName.text Success:^{
              
          } failure:^{
              
          }];
         
         //8.更新本地库会话表 消息
         [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool]
          insertNewDataToRecentChatListWithMsg:noteChatMsg
          FriendCusId:self.groupModel.groupId
          myCusId:[DWDCustInfo shared].custId
          success:^
         {
             //9. 发通知 刷新会话列表
             [[NSNotificationCenter defaultCenter]
              postNotificationName:kDWDNotificationRecentChatLoad
              object:nil
              userInfo:@{@"custId": self.groupModel.groupId}];
         } failure:^{
         }];

        if (self.delegate && [self.delegate respondsToSelector:@selector(groupNameSetupViewController:groupName:)]) {
            [self.delegate groupNameSetupViewController:self groupName:self.tfSetupName.text];
            //返回
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } failure:^(NSError *error) {
    }];
}
@end
