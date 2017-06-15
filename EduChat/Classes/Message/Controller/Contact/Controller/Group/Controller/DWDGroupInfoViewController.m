//
//  DWDGroupInfoViewController.m
//  EduChat
//
//  Created by Gatlin on 15/12/21.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDGroupInfoViewController.h"
#import "DWDContactSelectViewController.h"
#import "DWDNavViewController.h"
#import "DWDGroupNameSetupViewController.h"
#import "DWDQRViewController.h"
#import "DWDPersonDataViewController.h"
#import "DWDGroupMyNicknameViewController.h"
#import "DWDMessageViewController.h"

#import "DWDGroupInfoModel.h"
#import "DWDContactModel.h"
#import "DWDGroupEntity.h"
#import "DWDGroupInfoSectionItemModel.h"
#import "DWDNoteChatMsg.h"

#import "DWDContactsDatabaseTool.h"
#import "DWDRecentChatDatabaseTool.h"
#import "DWDMessageDatabaseTool.h"
#import "DWDGroupDataBaseTool.h"

#import "DWDGroupInfoCell.h"
#import "DWDHeaderImgSortControl.h"


#import "DWDGroupClient.h"

#import "UIActionSheet+camera.h"

#import <YYModel/YYModel.h>

@interface DWDGroupInfoViewController ()<DWDHeaderImgSortControlDelegate,DWDContactSelectViewControllerDelegate,DWDGroupNameSetupViewControllerDelegate,DWDGroupMyNicknameViewControllerDelegate, UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) NSMutableArray *arrItems;
@property (strong, nonatomic) NSMutableArray *contactsArray;
@property (strong, nonatomic) NSMutableArray *arrSelectFlag;//标记所有CustId 存储对象是CustID
@property (strong, nonatomic) NSDictionary *dictGroupInfo;
@property (strong, nonatomic) UIView *footView; //底部View 删除按钮

@property (nonatomic, strong) DWDHeaderImgSortControl *headerImgSortControl;
@end

@implementation DWDGroupInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Groups", nil);
    
    self.tableViewStyle = UITableViewStyleGrouped;
    [self.view addSubview:self.tableView];
    //添加通知
    [self observerNotification];
    
    [self requestData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupTableView];
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //移除通知
    
#warning Gatlin bug 暂时隐藏些功能
    /*
    //是否更新设置
     DWDGroupInfoModel *isTopModel_Now = _arrItems[2][0];
    DWDGroupInfoModel *isCloseModel_Now = _arrItems[2][1];
    DWDGroupInfoModel *isSaveModel_Now = _arrItems[2][2];
      DWDGroupInfoModel *isShowNickModel_Now = _arrItems[3][1];
    
    
    if (isTopModel_Now.isOpen  != [self.dictGroupInfo[@"isTop"] boolValue]
        || isCloseModel_Now.isOpen != [self.dictGroupInfo[@"isClose"] boolValue]
        || isSaveModel_Now.isOpen != [self.dictGroupInfo[@"isSave"] boolValue]
        || isShowNickModel_Now.isOpen != [self.dictGroupInfo[@"isShowNick"] boolValue] ) {
        
        //上传服务器
        [[DWDRequestGroup sharedRequestGroup] getGroupRestUpdateGroupWithGroupId:self.groupModel.groupId
                                                                  custId:[DWDCustInfo shared].custId
                                                                   isTop:[NSNumber numberWithInt:isTopModel_Now.isOpen]
                                                                 isClose:[NSNumber numberWithInt:isCloseModel_Now.isOpen]
                                                                  isSave:[NSNumber numberWithInt:isSaveModel_Now.isOpen]
                                                              isShowNick:[NSNumber numberWithInt:isShowNickModel_Now.isOpen]
                                                                 success:^(id responseObject) {
                                                                     
                                                                 } failure:^(NSError *error) {
                                                                     
                                                                 }];
    }
     */
    if (_arrItems.count == 0) return;
    
    DWDGroupInfoModel *isShowNickModel_Now = _arrItems[2][1];
    
    if (isShowNickModel_Now.isOpen != [self.groupModel.isShowNick boolValue] ) {
       
        //上传服务器
        [[DWDGroupClient sharedRequestGroup]
         getGroupRestUpdateGroupWithGroupId:self.groupModel.groupId
         custId:[DWDCustInfo shared].custId
         isTop:[NSNumber numberWithInt:0]
         isClose:[NSNumber numberWithInt:0]
         isSave:[NSNumber numberWithInt:0]
         isShowNick:[NSNumber numberWithInt:isShowNickModel_Now.isOpen]
         success:^(id responseObject) {
             
             
             //更新本地库 班级列表 中的isShowNick 字段
             [[DWDGroupDataBaseTool sharedGroupDataBase]
              updateGroupInfoWithMyCustId:[DWDCustInfo shared].custId
              groupId:self.groupModel.groupId
              isShowNick:[NSNumber numberWithInt:isShowNickModel_Now.isOpen]];
             
             //发送通知 给聊天界面 是否显示好友昵称
             NSDictionary *dict = @{@"isShowNick" : [NSNumber numberWithBool:isShowNickModel_Now.isOpen]};
             [[NSNotificationCenter defaultCenter]
              postNotificationName:@"showNickNotification"
              object:@"chatShowNick" userInfo:dict];
             
         }
         failure:^(NSError *error) {
                                                                             
                                                                         }];
    }
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Setup
- (void)setupTableView
{
    [self.tableView registerClass:[DWDGroupInfoCell class] forCellReuseIdentifier:NSStringFromClass([DWDGroupInfoCell class])];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];

}


#pragma mark - Getter
-(NSMutableArray *)arrItems
{
    if (!_arrItems) {
        _arrItems = [NSMutableArray array];
        
    }
       return _arrItems;
}

-(NSMutableArray *)contactsArray
{
    if (!_contactsArray) {
        _contactsArray = [NSMutableArray array];
        
    }
    return _contactsArray;
}

- (NSMutableArray *)arrSelectFlag
{
    if (!_arrSelectFlag) {
        _arrSelectFlag = [NSMutableArray array];
    }
    return _arrSelectFlag;

}

/** footView */
- (UIView *)footView
{
    if (!_footView) {
        //footView  退出删除按钮
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, -100, DWDScreenW, 100)];
       
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.backgroundColor = [UIColor redColor];
        
        if ([self.groupModel.isMian isEqualToNumber:@1]) {
            [deleteBtn setTitle:@"删除并退出" forState:UIControlStateNormal];
        }else{
            [deleteBtn setTitle:@"退出" forState:UIControlStateNormal];
        }
        
        deleteBtn.frame = CGRectMake(30,20 , DWDScreenW - 60, 40);
        deleteBtn.layer.masksToBounds = YES;
        deleteBtn.layer.cornerRadius = 20;
        [deleteBtn addTarget:self action:@selector(getoutGroup) forControlEvents:UIControlEventTouchUpInside];
        [footView addSubview:deleteBtn];
        
         _footView = footView;
    }
    return _footView;
}

#pragma mark - Button Action
/** 退出该群 */
- (void)getoutGroup
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[self.groupModel.isMian isEqualToNumber:@1] ? @"是否确定解散该群组" : @"是否确定退出该群组" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //request delect group
        [self requestGetoutGroup];

    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction:cancleAction];
    [alert addAction:sureAction];
    
    [self presentViewController:alert animated:YES completion:nil];

    }

#pragma mark - Private Method
/** 调用相机 */
- (void)showCamera
{
    UIActionSheet *cameraActionSheet = [UIActionSheet showCameraActionSheet];
    cameraActionSheet.targer = self;
    
    [cameraActionSheet showInView:self.view];
}

/** 更改本地库群组人数 */
- (void)changeMenberCount:(NSNumber *)menberCount
{
    [[DWDGroupDataBaseTool sharedGroupDataBase]
    updateGroupInfoWithMyCustId:[DWDCustInfo shared].custId
    groupId:self.groupModel.groupId
     menberCount:menberCount];
    
    DWDGroupInfoModel *model = self.arrItems[1][3];
    model.detailTitle = [menberCount stringValue];;
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

#pragma mark - Notification Observer
- (void)observerNotification
{
    //监听 实时更新 群主更新群名称
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(updateGroupName:)
     name:kDWDChangeGroupNicknameNotification
     object:nil];

}
#pragma mark - Notification Method
/** 更改 实时更新 群主更改群名称 */
- (void)updateGroupName:(NSNotification *)noti
{
    NSDictionary *dict = noti.userInfo;
    
    //判断是否为 需要更新的id
    if([dict[@"operationId"] isEqual:self.groupModel.groupId])
    {
        DWDGroupInfoModel *model = self.arrItems[1][1];
        model.detailTitle = dict[@"changeNickname"];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

        
    }
    
}
#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.arrItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSArray * arrRow = self.arrItems[section];
    return arrRow.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DWDGroupInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDGroupInfoCell class])];
    
    DWDGroupInfoModel *model = self.arrItems[indexPath.section][indexPath.row];
    cell.groupInfoModel = model;
    
    if(indexPath.section==0&&indexPath.row==0){
        UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
        headerCell.selectionStyle = UITableViewCellSelectionStyleNone;
        DWDHeaderImgSortControl *headerImgSortControl = [[DWDHeaderImgSortControl alloc]init];
        _headerImgSortControl = headerImgSortControl;
        headerImgSortControl.delegate = self;
        headerImgSortControl.layouType = [self.groupModel.isMian isEqualToNumber:@1] ? DWDNeedBothType : DWDNeedOnlyAddButtonType;
        
        if (self.contactsArray.count == 1) {
            headerImgSortControl.layouType = DWDNeedOnlyAddButtonType;
        }
        headerImgSortControl.arrItems = self.contactsArray;
        headerImgSortControl.frame = CGRectMake(0, 0, DWDScreenW, headerImgSortControl.hight);
        [headerCell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [headerCell.contentView addSubview:headerImgSortControl];
        return  headerCell;
    }
    return cell;
}

#pragma mark - TableView Delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   if (indexPath.section==0 && indexPath.row == 0){
        return self.headerImgSortControl.hight;
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        return 90;
    }
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v = [[UIView alloc]init];
    v.backgroundColor = [UIColor clearColor];
    return v;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        [self showCamera];
        
    }
    if (indexPath.section==1 && indexPath.row == 1)
    {
        DWDGroupNameSetupViewController *vc = [[DWDGroupNameSetupViewController alloc]initWithNibName:NSStringFromClass([DWDGroupNameSetupViewController class]) bundle:nil];
        vc.groupModel = self.groupModel;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    else if(indexPath.section == 1 && indexPath.row == 2)
    {//二维码
        
       //获取群组头像
        UIImageView *QRImv = [[UIImageView alloc] init];
        [QRImv sd_setImageWithURL:[NSURL URLWithString:self.groupModel.photoKey] placeholderImage:DWDDefault_GroupImage];
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDQRViewController class]) bundle:nil];
        DWDQRViewController *qrVC = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDQRViewController class])];
        qrVC.info = [self.groupModel.groupId stringValue];
        qrVC.image = QRImv.image;
        qrVC.nickname = self.groupModel.groupName;
        qrVC.type = DWDQRTypeGroup;
        [self.navigationController pushViewController:qrVC animated:YES];
        
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Group" bundle:nil];
        DWDGroupMyNicknameViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDGroupMyNicknameViewController class])];
        vc.groupModel = self.groupModel;
        vc.delegate = self;
          [self.navigationController pushViewController:vc animated:YES];
    }
}



#pragma mark - UIImagePickerController Delegate
//当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
        
        //压缩图片
        image =  [UIImage  compressImageWithOldImage:image compressSize:self.view.size];
        //上传到阿里云
        [self requestUploadWithAliyun:image];
        
        //关闭相册界面
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

/** 取消相机 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DWDHeaderImgSortControl delegate
- (void)headerImgSortControl:(DWDHeaderImgSortControl *)headerImgSortControl DidGroupMemberWithCust:(NSNumber *)custId
{
    DWDPersonDataViewController *vc = [[DWDPersonDataViewController alloc] init];
    vc.custId = custId;
     vc.sourceType = DWDSourceTypeGroup;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)headerImgSortControlDidSelectAddButton:(DWDHeaderImgSortControl *)headerImgSortControl
{
    DWDContactSelectViewController *vc = [[DWDContactSelectViewController alloc]init];
    vc.delegate = self;
    vc.type = DWDSelectContactTypeAddEntity;
   
    //从本地库获取联系人，若已添加的需要排除
    vc.dataSource =  [[DWDContactsDatabaseTool sharedContactsClient] getGroupedContacts:[DWDCustInfo shared].custId exclude:self.arrSelectFlag];

    
    DWDNavViewController *naviVC = [[DWDNavViewController alloc]initWithRootViewController:vc];
    [self.navigationController presentViewController:naviVC animated:YES completion:nil];

}
-(void)headerImgSortControlDidSelectDeleteButton:(DWDHeaderImgSortControl *)headerImgSortControl
{
    if (self.arrSelectFlag.count == 1) {//alone self  don't delete
        return;
    }
    
    DWDContactSelectViewController *vc = [[DWDContactSelectViewController alloc]init];
    vc.delegate = self;
    vc.type = DWDSelectContactTypeDeleteEntity;
  
    //对于该群组成员进行删除，需要排除自己
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:self.contactsArray.count];
    [tempArray addObjectsFromArray:self.contactsArray];
    for (DWDContactModel *model in self.contactsArray) {
        if ([model.custId isEqualToNumber:[DWDCustInfo shared].custId]) {
            [tempArray removeObject:model];
            break;
        }
    }
    vc.dataSource = tempArray;
    
    DWDNavViewController *naviVC = [[DWDNavViewController alloc]initWithRootViewController:vc];
    [self.navigationController presentViewController:naviVC animated:YES completion:nil];
    
}

#pragma mark - DWDGroupNameSetupViewController Delegate
- (void)groupNameSetupViewController:(DWDGroupNameSetupViewController *)groupNameSetupViewController groupName:(NSString *)groupName
{
    DWDGroupInfoModel *model = self.arrItems[1][1];
    model.detailTitle = groupName;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - DWDGroupMyNicknameViewController Delegate
- (void)groupMyNicknameViewController:(DWDGroupMyNicknameViewController *)groupMyNicknameViewController myGroupNickname:(NSString *)myGroupNickname
{
    DWDGroupInfoModel *model = self.arrItems[2][0];
    model.detailTitle = myGroupNickname;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
 
}
#pragma mark - DWDContactSelectViewController delegate

- (void)contactSelectViewControllerDidSelectContactsForIds:(NSArray *)contactsIds selectContactType:(DWDSelectContactType)type
{
    if (type == DWDSelectContactTypeAddEntity) {
        //request
        [self requestAddEntityFriendCustId:contactsIds];
    }else if (type == DWDSelectContactTypeDeleteEntity){
        //request
        [self requestDeleteEntityFriendCustId:contactsIds];
    }
   
}



#pragma mark - requse
-(void)requestData
{
    DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:self.view];
    
    __weak DWDGroupInfoViewController *weakSelf = self;
    //获取群成员列表信息
    [[DWDGroupClient sharedRequestGroup] getGroupRestGetListGroupId:self.groupModel.groupId success:^(id responseObject) {
        
        [hud hideHud];
       
        [weakSelf.contactsArray removeAllObjects];//清空
        for (NSDictionary *dic in responseObject) {
            DWDContactModel *entity = [DWDContactModel yy_modelWithDictionary:dic];
            [weakSelf.contactsArray addObject:entity];
            [weakSelf.arrSelectFlag addObject:entity.custId];
        }
       
        //数据模型
        DWDGroupInfoSectionItemModel *model = [[DWDGroupInfoSectionItemModel alloc]init];
        model.groupModel = self.groupModel;
        _arrItems =  [model.arrSectionItem mutableCopy];
        
        
        //直接更新本地库群组成员人数
        [self changeMenberCount:@(self.contactsArray.count)];
        
        //显示footView
        weakSelf.tableView.tableFooterView = self.footView;
        [weakSelf.tableView reloadData];

/*
        [[DWDGroupClient sharedRequestGroup] getGroupRestgetGroupGroupId:self.groupModel.groupId custId:[DWDCustInfo shared].custId success:^(id responseObject) {
            
            [hud hide:YES];
            
            weakSelf.dictGroupInfo = responseObject;
            
            //数据模型
            DWDGroupInfoSectionItemModel *model = [[DWDGroupInfoSectionItemModel alloc]init];
            model.dictModle = weakSelf.dictGroupInfo;
            _arrItems =  [model.arrSectionItem copy];
            
            //发通知。刷新群组列表
            [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationGroupListReload  object:nil];
            
            //显示footView
            weakSelf.tableView.tableFooterView = self.footView;
            [weakSelf.tableView reloadData];
            
        } failure:^(NSError *error) {
            
            hud.labelText = error.debugDescription;
            [hud hide:YES afterDelay:1.5];
            
        }];
        
        */
        
        
    } failure:^(NSError *error) {
        [hud showText:@"未查寻到数据"];
    }];
    
}

/** 添加群成员 */
- (void)requestAddEntityFriendCustId:(NSArray *)friendCustId
{
    [[DWDGroupClient sharedRequestGroup]
     requestAddEntityGroupId:self.groupModel.groupId
     custId:[DWDCustInfo shared].custId
     friendCustId:friendCustId
     success:^(id responseObject) {
       
        //1.从本地库获取联系人，并加入数组contactsArray
        NSArray *tempContactArray = [[DWDContactsDatabaseTool sharedContactsClient] getGroupedContacts:[DWDCustInfo shared].custId ByIds:friendCustId];
        [self.contactsArray addObjectsFromArray:tempContactArray];
        
        //2.更改本地库群组人数
        [self changeMenberCount:@(self.contactsArray.count)];
        
        //3.发通知。刷新群组列表
        [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationGroupListReload  object:nil];
       
        //4.标记已选择数组CustId
        [self.arrSelectFlag addObjectsFromArray:friendCustId];
        
        //刷新当前TableView
        [self.tableView reloadData];

        
        //5.临时数组。存储添加成员的nickname
        NSMutableArray *tempNicknameArray = [NSMutableArray array];
        for (DWDContactModel *model in tempContactArray) {
            [tempNicknameArray addObject:model.nickname];
        }
        
        //6.构造模型
        NSString *lastContent = [NSString stringWithFormat:@"你邀请%@加入了群组",[tempNicknameArray componentsJoinedByString:@"、"]];
        DWDNoteChatMsg *noteChatMsg = [self createNoteMsgWithString:lastContent toUserId:self.groupModel.groupId chatType:DWDChatTypeGroup];
        
        //7.保存历史消息
        [self saveSystemMessage:noteChatMsg];
        
        //8.更新本地库会话表
        [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] insertNewDataToRecentChatListWithMsg:noteChatMsg FriendCusId:self.groupModel.groupId myCusId:[DWDCustInfo shared].custId success:^{
            //9. 发送通知、是否刷新 会话列表
            [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNeedRecentChatLoad object:nil userInfo:@{@"isNeedLoadData":@(YES)}];
        } failure:^{
            
        }];

        
    }
     failure:^(NSError *error) {
        
    }];
}

/** 删除群成员 */
- (void)requestDeleteEntityFriendCustId:(NSArray *)friendCustId
{
    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    [[DWDGroupClient sharedRequestGroup]
     requestDeleteEntityGroupId:self.groupModel.groupId
     custId:[DWDCustInfo shared].custId
     friendCustId:friendCustId
     success:^(id responseObject) {
        
        [hud showText:@"删除成功"];
       
        //1.临时数组。存储被删除成员的nickname
        NSMutableArray *tempNicknameArray = [NSMutableArray array];

        //2.对内存中数组进行减员操作
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        temp = self.contactsArray.mutableCopy;
        for (NSNumber *custId in friendCustId) {
            for (DWDContactModel *entity in self.contactsArray) {
                if ([entity.custId isEqualToNumber:custId]) {
                    [tempNicknameArray addObject:entity.nickname];
                    [temp removeObject:entity];
                }
            }
        }
        self.contactsArray = temp.mutableCopy;
        
        //3.更改本地库群组人数
        [self changeMenberCount:@(self.contactsArray.count)];
        
        //4.发通知。刷新群组列表
        [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationGroupListReload  object:nil];
        
        
        //5.标记已选择数组CustId
        [self.arrSelectFlag removeObjectsInArray:friendCustId];

        //刷新TableView
        [self.tableView reloadData];
       
        //6.构造模型
        NSString *lastContent = [NSString stringWithFormat:@"你将%@移出了群组",[tempNicknameArray componentsJoinedByString:@"、"]];
        DWDNoteChatMsg *noteChatMsg = [self createNoteMsgWithString:lastContent toUserId:self.groupModel.groupId chatType:DWDChatTypeGroup];
        
         //7.保存历史消息
         [self saveSystemMessage:noteChatMsg];
        
        //8.更新本地库会话表
        [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] insertNewDataToRecentChatListWithMsg:noteChatMsg FriendCusId:self.groupModel.groupId myCusId:[DWDCustInfo shared].custId success:^{
            //9. 发送通知、是否刷新 会话列表
            [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNeedRecentChatLoad object:nil userInfo:@{@"isNeedLoadData":@(YES)}];
        } failure:^{
            
        }];
        
    }
     failure:^(NSError *error) {
        [hud showText:@"删除失败"];
    }];
}


/** 退出该群 */
- (void)requestGetoutGroup
{
    __weak typeof(self) weakSelf = self;
    
     DWDProgressHUD *hud = [DWDProgressHUD showHUD];
    NSArray *array = @[[DWDCustInfo shared].custId];//需要转为数组
    
    [[DWDGroupClient sharedRequestGroup]
     requestDeleteEntityGroupId:self.groupModel.groupId
     custId:[DWDCustInfo shared].custId
     friendCustId:array
     success:^(id responseObject) {
        
         __strong typeof(self) strongSelf = weakSelf;
        
          [hud showText:@"退出成功"];
        //1.从本地库删除该群组
        [[DWDGroupDataBaseTool sharedGroupDataBase] deleteGroupWithMyCustId:[DWDCustInfo shared].custId gorupId:self.groupModel.groupId];
        
//        //2.发通知。刷新群组列表
//        [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationGroupListReload object:nil];
        
        
        
        //3.删除会话列表
        [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] deleteRecentChatWithFriendId:strongSelf.groupModel.groupId success:^{
            
            //4.发送通知、是否刷新 会话列表
            [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNeedRecentChatLoad object:nil userInfo:@{@"isNeedLoadData":@(YES)}];

            

            //4.清空历史聊天记录
            [[DWDMessageDatabaseTool sharedMessageDatabaseTool] deleteMessageTableWithFriendId:self.groupModel.groupId
                                                                                      chatType:DWDChatTypeGroup
                                                                                       success:^{
                                                                                       }
                                                                                       failure:^(NSError *error) {
                                                                                       }];
      
              [self.navigationController popToRootViewControllerAnimated:YES];
      
            
        } failure:^{
            
        }];
       
         

        
    }
     failure:^(NSError *error) {
         [hud showText:@"退出失败"];
    }];

}


/** 更改头像 */
- (void)requestGroupIconWithPhotoKey:(NSString *)photoKey
{
    [[DWDGroupClient sharedRequestGroup]
     getGroupRestUpdateGroupWithGroupId:self.groupModel.groupId
     photoKey:photoKey
     success:^(id responseObject)
    {
        
        //1.更新当前UI群组头像
        DWDGroupInfoModel *model = self.arrItems[1][0];
        model.imgName = photoKey;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        //2. 改 tb_groups 数据库 群头像
        [[DWDGroupDataBaseTool sharedGroupDataBase]
         updateGroupPhotokeyWithGroupId:self.groupModel.groupId
         photokey:photoKey
         success:^{
             
            //3. 修改recentChat 数据库
            [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool]
             updatePhotokeyWithCusId:self.groupModel.groupId
             photokey:photoKey
             success:^{
                 
                //4. 刷新界面
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:kDWDChangeGroupPhotoKeyNotification
                 object:@{@"operationId" : self.groupModel.groupId,@"changePhotoKey" : photoKey}];
            } failure:^{
                
            }];
             
             //5.修改内存头像
             self.groupModel.photoKey = photoKey;
            
        } failure:^{
            
        }];

    } failure:^(NSError *error) {
        
        
    }];
}
/** 上传头像到阿里 **/
- (void)requestUploadWithAliyun:(UIImage *)image
{
    __block DWDProgressHUD *hud;
    dispatch_async(dispatch_get_main_queue(), ^{
        hud = [DWDProgressHUD showHUD];
        hud.labelText = nil;
    });
    
    NSString *strUUID = DWDUUID;
    [[DWDAliyunManager sharedAliyunManager] uploadImage:image Name:strUUID progressBlock:^(CGFloat progress) {
        
    } success:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            
        });
        
        NSString *urlStr = [[DWDAliyunManager sharedAliyunManager] getDownloadURLStringWithObjectName:strUUID];
        
        [self requestGroupIconWithPhotoKey:urlStr];
        
    } Failed:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud showText:@"更改失败" afterDelay:DefaultTime];
        });
        
    }];
}
@end
