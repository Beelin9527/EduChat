//
//  DWDRemarkNameViewController.m
//  EduChat
//
//  Created by Gatlin on 16/2/4.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDRemarkNameViewController.h"

#import "DWDAccountClient.h"
#import "DWDContactsDatabaseTool.h"
#import "DWDRecentChatDatabaseTool.h"
@interface DWDRemarkNameViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *remarkTfd;

@property (copy, nonatomic) NSString *tempName;
@end

@implementation DWDRemarkNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"备注";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem.enabled = NO;

    
    [self.remarkTfd becomeFirstResponder];
    
    self.tempName = [[DWDPersonDataBiz new] checkoutExistRemarkName:self.friendRemarkName nickname:self.nickname];
    self.remarkTfd.text = self.tempName;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFielDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




#pragma mark - Button Action
- (void)done
{
    [self requestUpdateCustomUserInfoFriendId:self.friendId friendRemarkName:self.remarkTfd.text];
}

#pragma mark - Notification Implementation
- (void)textFielDidChange
{
    NSString *toBeString = self.remarkTfd.text;
    
    //获取高亮部分
    UITextRange *selectedRange = [self.remarkTfd markedTextRange];
    UITextPosition *position = [self.remarkTfd positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position)
    {
        if (toBeString.length > 16)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:16];
            if (rangeIndex.length == 1)
            {
                self.remarkTfd.text = [toBeString substringToIndex:16];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 16)];
                self.remarkTfd.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
    
    if ([self.tempName isEqualToString:self.remarkTfd.text] ) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

#pragma mark - TextFiel Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (![self.tempName isEqualToString:textField.text] || textField.text.length != 0) {
        [self requestUpdateCustomUserInfoFriendId:self.friendId friendRemarkName:textField.text];
    }
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Request
- (void)requestUpdateCustomUserInfoFriendId:(NSNumber *)friendId friendRemarkName:(NSString *)RemarkName
{
    self.remarkTfd.text = [self.remarkTfd.text trim];
    
    __weak typeof(self) weakSelf = self;
    [[DWDAccountClient sharedAccountClient] updateCustomUserInfo:[DWDCustInfo shared].custId friendId: friendId friendRemarkName:RemarkName lookPhoto:nil blackList:nil success:^(NSDictionary *info) {
        
         __strong typeof(self) strongSelf = weakSelf;
        
        //手动更新FMDB对好友的备注
        [[DWDContactsDatabaseTool sharedContactsClient]
         updateFriendRemarkNameMyCustId:[DWDCustInfo shared].custId
         byFriendCustId:friendId remarkName:RemarkName
         success:^{
            
            //更新会话列表中的备注名
            [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool]
             updateRecentChatRemarkNameWithFriendId:strongSelf.friendId
             remarkName:RemarkName Success:^{
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationRecentChatLoad
                                                                     object:nil
                                                                   userInfo:@{@"custId":strongSelf.friendId}];
                 
            } failure:^{
                
            }];
            
        } failure:^{
            
        }];
        
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(remarkNameViewController:doneRemarkName:)]) {
            [strongSelf.delegate remarkNameViewController:strongSelf doneRemarkName:strongSelf.remarkTfd.text];
        }
        //刷新个人信息 通知
         [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationPersonDataReload object:nil];
        
        
        //发通知。 更改聊天Title
        NSDictionary *dict = @{@"title":RemarkName,@"custId":friendId};

        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateChatTitle" object:nil userInfo:dict];
        
        //发通知、让监听的通讯录控制器去刷新FMDB
        [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationContactsGet object:nil];
        

        //GO Home
        [weakSelf.navigationController popViewControllerAnimated:YES];
        
    } failure:^(NSError *error) {
        
    }];
}
@end
