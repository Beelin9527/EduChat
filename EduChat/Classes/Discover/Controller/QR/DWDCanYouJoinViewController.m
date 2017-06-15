//
//  DWDCanYouJoinViewController.m
//  EduChat
//
//  Created by Gatlin on 16/2/17.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDCanYouJoinViewController.h"
#import "DWDGroupClient.h"
#import "DWDChatController.h"
#import "DWDClassVerifyController.h"

#import "DWDClassInfoModel.h"
#import "DWDGroupEntity.h"

#import "DWDContactsDatabaseTool.h"
#import "DWDGroupDataBaseTool.h"
@interface DWDCanYouJoinViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imv;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLable;
@property (weak, nonatomic) IBOutlet UILabel *groupCountLable;
@property (weak, nonatomic) IBOutlet UIButton *btn;

@end

@implementation DWDCanYouJoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"详情";
    
    if(self.type == DWDSacnResultTypeApply){
        [_btn setTitle:@"申请加入群组" forState:UIControlStateNormal];
    }else{
        [_btn setTitle:@"进入群组" forState:UIControlStateNormal];
    }
    self.btn.layer.masksToBounds = YES;
    self.btn.layer.cornerRadius = self.btn.h/2;
    
    [_imv sd_setImageWithURL:[NSURL URLWithString:self.dictDataSource[@"photoKey"]] placeholderImage:DWDDefault_GroupImage];
    _groupNameLable.text = [NSString stringWithFormat:@"%@", self.dictDataSource[@"groupName"]];
    _groupCountLable.text = [NSString stringWithFormat:@"(共%@人)",self.dictDataSource[@"memberNum"] ? self.dictDataSource[@"memberNum"] : self.dictDataSource[@"memberCount"]];
    
}

#pragma mark - Button Action
- (IBAction)joinAction:(UIButton *)sender
{
    if(self.type == DWDSacnResultTypeApply){
        [self requestJoinGroupWithGroupId:self.dictDataSource[@"groupId"] myCustId:[DWDCustInfo shared].custId];
    }else{//进入班级聊天
        DWDChatController *chatController = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
        chatController.chatType = DWDChatTypeGroup;
        chatController.title = self.dictDataSource[@"groupName"];
        chatController.toUserId = self.dictDataSource[@"groupId"];
        chatController.groupEntity = [[DWDGroupDataBaseTool sharedGroupDataBase] getGroupInfoWithMyCustId:[DWDCustInfo shared].custId groupId:self.dictDataSource[@"groupId"]];
        [self.navigationController pushViewController:chatController animated:YES];
        
    }
}

#pragma mark Request
/** 加入群组 */
- (void)requestJoinGroupWithGroupId:(NSNumber *)groupId myCustId:(NSNumber *)myCustId
{
    [[DWDGroupClient sharedRequestGroup]
     requestAddEntityGroupId:groupId
     custId:myCustId
     friendCustId:@[myCustId]
     success:^(id responseObject) {
    
         [[DWDContactsDatabaseTool sharedContactsClient] updateContactsByCustemId:[DWDCustInfo shared].custId success:^{
             
            //获取本地库群组信息
            DWDGroupEntity *groupModel = [[DWDGroupDataBaseTool sharedGroupDataBase] getGroupInfoWithMyCustId:[DWDCustInfo shared].custId groupId:groupId];
             
            dispatch_async(dispatch_get_main_queue(), ^{
                
                DWDChatController *chatController = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
                
                chatController.chatType = DWDChatTypeGroup;
                chatController.title = self.dictDataSource[@"groupName"];
                chatController.toUserId = groupId;
                chatController.groupEntity = groupModel;
                [self.navigationController pushViewController:chatController animated:YES];
            });
           
             
         } failure:^(NSError *error) {
           
             //更新失败，自己手动往本地插入群组
             DWDGroupEntity *model = [[DWDGroupEntity alloc] init];
             model.groupId = responseObject[@"groupId"];
             model.groupName = responseObject[@"groupName"];
             model.isMian = responseObject[@"isMian"];
             model.isShowNick = responseObject[@"isShowNick"];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 DWDChatController *chatController = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
                 
                 chatController.chatType = DWDChatTypeGroup;
                 chatController.title = self.dictDataSource[@"groupName"];
                 chatController.toUserId = groupId;
                 chatController.groupEntity = model;
                 [self.navigationController pushViewController:chatController animated:YES];
             });

         }];

         
    } failure:^(NSError *error) {
        
    }];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 n:@"groupId"] forKey:@"groupId"];
 [contact setObject:[rs stringForColumn:@"groupName"] forKey:@"groupName"];
 [contact setObject:[rs stringForColumn:@"photoKey"] forKey:@"photoKey"];
 [contact setObject:[rs stringForColumn:@"memberCount"] forKey:@"memberCount"];
*/

@end
