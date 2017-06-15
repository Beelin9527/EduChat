//
//  DWDGroupListViewController.m
//  EduChat
//
//  Created by Gatlin on 15/12/11.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDGroupAddViewController.h"
#import "DWDContactSelectViewController.h"
#import "DWDNavViewController.h"
#import "DWDChatController.h"

#import "DWDHeaderImgSortControl.h"

#import "DWDGroupCustEntity.h"
#import "DWDContactModel.h"
#import "DWDContactsDatabaseTool.h"
#import "DWDMessageDatabaseTool.h"
#import "DWDGroupDataBaseTool.h"
#import "DWDNoteChatMsg.h"

#import "DWDGroupClient.h"

#import <MBProgressHUD/MBProgressHUD.h>
@interface DWDGroupAddViewController ()<DWDHeaderImgSortControlDelegate,DWDContactSelectViewControllerDelegate,UITextFieldDelegate>
@property (strong, nonatomic) NSString *setupTimeStr;
@property (weak, nonatomic) UITextField *tfGroupName;
@property (strong, nonatomic)  NSNumber *duration;

@property (strong, nonatomic) NSArray *contactsArray;//联系人array
@property (strong, nonatomic) NSMutableArray *selectedCustIdFlagArray;//标记已选人 存储对象是CustID

@property (strong, nonatomic) DWDHeaderImgSortControl *headerImgSortControl;
@end

@implementation DWDGroupAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加群组";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(sureAction)];
    
    
    //默认为永久  4
    self.duration = @4;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
    
   self.tableViewStyle = UITableViewStyleGrouped;
    [self.view addSubview:self.tableView];
}


#pragma mark - Getter
- (NSMutableArray *)selectedCustIdFlagArray
{
    if (!_selectedCustIdFlagArray) {
        _selectedCustIdFlagArray = [NSMutableArray array];
    }
    return _selectedCustIdFlagArray;
}


#pragma mark - Button Action
- (void)showSheet
{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"一日" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.setupTimeStr  = @"一日";
        self.duration = @1;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"一周" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       self.setupTimeStr  = @"一周";
        self.duration = @2;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"一月" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.setupTimeStr  = @"一月";
        self.duration = @3;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }]; UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"永久" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.setupTimeStr  = @"永久";
        self.duration = @4;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
    UIAlertAction *action5 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertVc addAction:action1];
    [alertVc addAction:action2];
    [alertVc addAction:action3];
    [alertVc addAction:action4];
    [alertVc addAction:action5];
    [self presentViewController:alertVc animated:YES completion:nil];

}

#pragma mark - Notification Implememtation
- (void)textFieldDidChange
{
    NSString *toBeString = self.tfGroupName.text;
    
    //获取高亮部分
    UITextRange *selectedRange = [self.tfGroupName markedTextRange];
    UITextPosition *position = [self.tfGroupName positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position)
    {
        if (toBeString.length > 16)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:16];
            if (rangeIndex.length == 1)
            {
                self.tfGroupName.text = [toBeString substringToIndex:16];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 16)];
                self.tfGroupName.text = [toBeString substringWithRange:rangeRange];
            }
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

/** 系统消息 私有处理 */
- (void)dealWithNoteMsgByGroupId:(NSNumber *)groupId
{
    
    //判断组数是否有成员
    if(self.selectedCustIdFlagArray.count)
    {
        //插入消息 “你邀请了xxx加入了群组”
        //获取邀请群成员的昵称
        NSMutableArray *membersNicknameArray = [NSMutableArray arrayWithCapacity:2];
        for (DWDContactModel *contactModel in self.contactsArray) {
            [membersNicknameArray addObject:contactModel.nickname];
        }
        NSArray *array = membersNicknameArray.copy;
        NSString *noteContent = [NSString stringWithFormat:@"你邀请%@加入了群组",[array componentsJoinedByString:@"、"]];
        
        DWDNoteChatMsg *noteChatMsg = [self createNoteMsgWithString:noteContent toUserId:groupId chatType:DWDChatTypeGroup];
        //5.插入历史消息
        [self saveSystemMessage:noteChatMsg];
    }

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section==0) {
        return 2;
    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        static NSString *groupNameID = @"groupNameID";
        UITableViewCell *groupNameCell = [tableView dequeueReusableCellWithIdentifier:groupNameID];
        
        if (!groupNameCell) {
            groupNameCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:groupNameID];
            groupNameCell.selectionStyle = UITableViewCellSelectionStyleNone;
            groupNameCell.textLabel.text = @"群组名称";
            groupNameCell.textLabel.textColor = DWDColorContent;
            groupNameCell.textLabel.font = DWDFontBody;
            
            //设置textField
            UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(100, 7, DWDScreenW * 0.7, 30)];
            self.tfGroupName = textField;
            textField.delegate = self;
            textField.placeholder = @"请输入群组名";
            [groupNameCell.contentView addSubview:textField];
        }
        return groupNameCell;
    }else if (indexPath.section == 0 && indexPath.row == 1){
        static NSString *setupTimeID = @"setupTimeID";
        UITableViewCell *setupTimeCell = [tableView dequeueReusableCellWithIdentifier:setupTimeID];
        
        if (!setupTimeCell) {
            setupTimeCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:setupTimeID];
            setupTimeCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            setupTimeCell.textLabel.text = @"持续时间";
             setupTimeCell.textLabel.textColor = DWDColorContent;
            setupTimeCell.textLabel.font = DWDFontBody;
            
        }
        setupTimeCell.detailTextLabel.text = self.setupTimeStr ? self.setupTimeStr : @"永久";
        setupTimeCell.detailTextLabel.font = DWDFontBody;
        return setupTimeCell;

    }else if (indexPath.section==1){
        static NSString *headerImgID = @"headerImgID";
        UITableViewCell *headerImgCell = [tableView dequeueReusableCellWithIdentifier:headerImgID];
       
        if (!headerImgCell) {
            headerImgCell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headerImgID];
            headerImgCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        self.headerImgSortControl = [[DWDHeaderImgSortControl alloc]init];
        self.headerImgSortControl.layouType = DWDNeedOnlyAddButtonType;
        self.headerImgSortControl.delegate = self;
        self.headerImgSortControl.arrItems = self.contactsArray;
        self.headerImgSortControl.frame = CGRectMake(0, 0, DWDScreenW, self.headerImgSortControl.hight);
        
        [headerImgCell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [headerImgCell.contentView addSubview:self.headerImgSortControl];
        return headerImgCell;
        
    }
    
    return nil;
}
#pragma mark - TableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        return  self. headerImgSortControl.hight;
    }
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0&&indexPath.row==1) {
        [self showSheet];
    }
}

#pragma mark - DWDHeaderImgSortControl delegate
-(void)headerImgSortControlDidSelectAddButton:(DWDHeaderImgSortControl *)headerImgSortControl
{
    DWDContactSelectViewController *vc = [[DWDContactSelectViewController alloc]init];
    vc.delegate = self;
    vc.type = DWDSelectContactTypeAddEntity;
    
    //从本地库获取联系人，若已添加的需要排除
    vc.dataSource =  [[DWDContactsDatabaseTool sharedContactsClient] getGroupedContacts:[DWDCustInfo shared].custId exclude:self.selectedCustIdFlagArray];
    
    DWDNavViewController *naviVC = [[DWDNavViewController alloc]initWithRootViewController:vc];
    [self.navigationController presentViewController:naviVC animated:YES completion:nil];

}
-(void)headerImgSortControlDidSelectDeleteButton:(DWDHeaderImgSortControl *)headerImgSortControl
{
    if (self.selectedCustIdFlagArray.count == 0) {
        return;
    }
    
    DWDContactSelectViewController *vc = [[DWDContactSelectViewController alloc]init];
    vc.delegate = self;
    vc.type = DWDSelectContactTypeDeleteEntity;
  
    //从本地库获取已添加联系人
    vc.dataSource = [[DWDContactsDatabaseTool sharedContactsClient] getGroupedContacts:[DWDCustInfo shared].custId ByIds:self.selectedCustIdFlagArray];
    
    DWDNavViewController *naviVC = [[DWDNavViewController alloc]initWithRootViewController:vc];
    [self.navigationController presentViewController:naviVC animated:YES completion:nil];

}

#pragma mark - DWDContactSelectViewController delegate
- (void)contactSelectViewControllerDidSelectContactsForIds:(NSArray *)contactsIds selectContactType:(DWDSelectContactType)type
{
    if (type == DWDSelectContactTypeAddEntity) {
        [self.selectedCustIdFlagArray addObjectsFromArray:contactsIds];
    }else if (type == DWDSelectContactTypeDeleteEntity){
        [self.selectedCustIdFlagArray removeObjectsInArray:contactsIds];
    }
    
    //从本地库获取联系人
    self.contactsArray = [[DWDContactsDatabaseTool sharedContactsClient] getGroupedContacts:[DWDCustInfo shared].custId ByIds:self.selectedCustIdFlagArray];
    
    [self.tableView reloadData];
}


#pragma mark request
-(void)sureAction
{
    
    if (self.contactsArray.count == 0) {
        [DWDProgressHUD showText:@"请添加联系人"];
        return;
    }
    
    if ([self.tfGroupName.text isEqualToString:@""]) {
        [DWDProgressHUD showText:@"请输入群组名称"];
        return;
    }
    
    if ([self.tfGroupName.text isBlank]) {
        [DWDProgressHUD showText:@"群组名称不能为空"];
        return;
    }
    self.tfGroupName.text = [self.tfGroupName.text trim];
    
    __weak DWDGroupAddViewController *weakSelf = self;
    
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    [[DWDGroupClient sharedRequestGroup]
     getGroupRestAddGroup:self.tfGroupName.text
     duration:self.duration
     friendCustId:self.selectedCustIdFlagArray
     success:^(id responseObject) {
         
         DWDGroupEntity *entity = [[DWDGroupEntity alloc] init];
         entity.groupId = responseObject[@"groupId"];
         entity.groupName = responseObject[@"groupName"];
         entity.isMian = responseObject[@"isMian"];
         entity.isShowNick = responseObject[@"isShowNick"];
         entity.memberCount = @(self.selectedCustIdFlagArray.count + 1);
         
         //刷新数据库 
         [[DWDContactsDatabaseTool sharedContactsClient] updateContactsByCustemId:[DWDCustInfo shared].custId success:^{
             
             [hud hide:YES];
             
             //构造系统消息模型
             [self dealWithNoteMsgByGroupId:entity.groupId];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil];
                 DWDChatController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
                 vc.chatType = DWDChatTypeGroup;
                 vc.toUserId = responseObject[@"groupId"];
                 vc.groupEntity = entity;
                 [weakSelf.navigationController pushViewController:vc animated:YES];
             });
             
         } failure:^(NSError *error) {
             [hud hide:YES];
 
             // 主动插入本地库
             [[DWDGroupDataBaseTool sharedGroupDataBase]
              insertOneGroup:entity];
             
             //构造系统消息模型
             [self dealWithNoteMsgByGroupId:entity.groupId];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil];
                 DWDChatController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
                 vc.chatType = DWDChatTypeGroup;
                 vc.toUserId = responseObject[@"groupId"];
                 vc.groupEntity = entity;
                 [weakSelf.navigationController pushViewController:vc animated:YES];
             });

         }];
         
         
         
    } failure:^(NSError *error) {
        
        [hud showText:@"创建失败"];
    }];
    
}

@end
