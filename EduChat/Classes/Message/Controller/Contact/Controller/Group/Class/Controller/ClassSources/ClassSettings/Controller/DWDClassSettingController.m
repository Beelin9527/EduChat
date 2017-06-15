//
//  DWDClassSettingController.m
//  EduChat
//
//  Created by Gatlin on 15/12/31.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassSettingController.h"
#import "DWDClassChangeClassNameViewController.h"
#import "DWDQRViewController.h"
#import "DWDClassGagViewController.h"

#import "DWDRequestClassSetting.h"
#import "DWDGroupInfoModel.h"
#import "DWDClassSettingSectiomItemsModle.h"
#import "DWDClassModel.h"

#import "DWDGroupInfoCell.h"

#import "DWDClassDataBaseTool.h"
#import "DWDRecentChatDatabaseTool.h"
#import "DWDMessageDatabaseTool.h"
#import "DWDSchoolDataBaseTool.h"
#import "DWDIntelligenceMenuDatabaseTool.h"

#import "DWDClassMemberClient.h"

#import <YYModel/YYModel.h>

@interface DWDClassSettingController ()<DWDClassChangeClassNameViewControllerDelegate>
@property (strong, nonatomic) NSMutableArray *arrItems;
@property (strong, nonatomic) NSMutableArray *arrGroupCusts;

@property (strong, nonatomic) UIView *footView; //底部View 删除按钮
//@property (strong, nonatomic) DWDClassInfoEntity *entity;
@end

@implementation DWDClassSettingController


- (void)viewDidLoad {
    
    [super viewDidLoad];

    self.title = @"班级设置";
   
    self.tableViewStyle = UITableViewStyleGrouped;
    self.tableView.tableFooterView = self.footView;
    
    [self.tableView registerClass:[DWDGroupInfoCell class] forCellReuseIdentifier:NSStringFromClass([DWDGroupInfoCell class])];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    
    //request member
    if([self.classModel.isManager isEqualToNumber:@1]){
        [self requedtClassMemberGetListWithClassId:self.classModel.classId];
    }
    
    //一开始我是拒绝的。但没办法，要去除内存classModel,拿最新classModel
    _classModel = [[DWDClassDataBaseTool sharedClassDataBase] getClassInfoWithClassId:self.classModel.classId myCustId:[DWDCustInfo shared].custId];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    //是否更新设置
//    DWDGroupInfoModel *isTopModel_Now = _arrItems[1][0];
//    DWDLog(@"==== %d",isTopModel_Now.isOpen);
//    DWDGroupInfoModel *isCloseModel_Now = _arrItems[1][1];
  
//    DWDGroupInfoModel *isShowNickModel_Now = _arrItems[1][1];
 
   
    
//    if (isTopModel_Now.isOpen  != [self.dictDataSource[@"isTop"] boolValue]
//        || isCloseModel_Now.isOpen != [self.dictDataSource[@"isClose"] boolValue]
//        || isShowNickModel_Now.isOpen != [self.dictDataSource[@"isShowNick"] boolValue] ) {
//        
//        //上传服务器
//        [[DWDRequestClassSetting sharedDWDRequestClassSetting] requestClassSettingGetClassInfoCustId:@4010000005410 classId:@8010000001047 isTop:[NSNumber numberWithInt:isTopModel_Now.isOpen] isClose:[NSNumber numberWithInt:isCloseModel_Now.isOpen] isShowNick:[NSNumber numberWithInt:isShowNickModel_Now.isOpen] success:^(id responseObject) {
//            
//        } failure:^(NSError *error) {
//            
//        }];
//
//    }
    
    
}
-(NSMutableArray *)arrItems
{
    if (!_arrItems) {
        
        _arrItems = [NSMutableArray array];
        
    }
    DWDClassSettingSectiomItemsModle *item = [[DWDClassSettingSectiomItemsModle alloc]init];
    item.classModel = self.classModel;
    _arrItems = [item.arrSectionItem mutableCopy];

    return _arrItems;
}
-(NSMutableArray *)arrGroupCusts
{
    if (!_arrGroupCusts) {
        _arrGroupCusts = [NSMutableArray array];
        
    }
    return _arrGroupCusts;
}


/** footView */
- (UIView *)footView
{
    if (!_footView) {
        //footView  退出删除按钮
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, -100, DWDScreenW, 60)];
        
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteBtn.backgroundColor = [UIColor redColor];
        
        if ([self.classModel.isMian boolValue]) {
            [deleteBtn setTitle:@"解散班级" forState:UIControlStateNormal];
        }else{
            [deleteBtn setTitle:@"退出班级" forState:UIControlStateNormal];
        }
        
        deleteBtn.frame = CGRectMake(30,20 , DWDScreenW - 60, 40);
        deleteBtn.layer.masksToBounds = YES;
        deleteBtn.layer.cornerRadius = 20;
        [deleteBtn addTarget:self action:@selector(getoutClass) forControlEvents:UIControlEventTouchUpInside];
        [footView addSubview:deleteBtn];
        
        _footView = footView;
    }
    return _footView;
}


#pragma mark - Button Action
- (void)getoutClass
{
    NSString *alertString = nil;
    if ([self.classModel.isMian boolValue]) {
        alertString = @"班级里的所有记录、照片都将失去噢，您确定要解散吗？";
    }else if ([DWDCustInfo shared].isTeacher){
        alertString = @"班级里的所有记录、照片都将失去噢，您确定要退出吗?";
    }else if (![DWDCustInfo shared].isTeacher){
       alertString = @"班级里的所有记录都将失去噢，您确定要退出吗?";
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:alertString preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //request delect class
        [self requestGetout];
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alert addAction:cancleAction];
    [alert addAction:sureAction];
    
    [self presentViewController:alert animated:YES completion:nil];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 
    return self.arrItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray * arrRow = self.arrItems[section];
    return arrRow.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DWDGroupInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDGroupInfoCell class])];
    DWDGroupInfoModel *model = _arrItems[indexPath.section][indexPath.row];
    cell.groupInfoModel = model;
    
    __weak typeof(self) weakSelf = self;
    [cell setClickShowNicknameButton:^(NSNumber *state) {
        //request update show nickname
        [weakSelf requestUpdateNicknamestateWithState:state];
    }];
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 1)
    {
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDQRViewController class]) bundle:nil];
        DWDQRViewController *qrVC = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDQRViewController class])];
        qrVC.info = [self.classModel.classId stringValue];

        //获取班级头像
        UIImageView *QRImv = [[UIImageView alloc] init];
        [QRImv sd_setImageWithURL:[NSURL URLWithString:self.classModel.photoKey] placeholderImage:DWDDefault_GradeImage];
        qrVC.image = QRImv.image;
        
        qrVC.nickname = self.classModel.className;
        qrVC.type = DWDQRTypeClass;
        [self.navigationController pushViewController:qrVC animated:YES];
        
    }
    else if (indexPath.section == 1 && indexPath.row ==0)
    {
        DWDClassChangeClassNameViewController *vc = [[UIStoryboard storyboardWithName:@"DWDClassChangeClassNameViewController" bundle:nil] instantiateViewControllerWithIdentifier:@"DWDClassChangeClassNameViewController"];
        vc.classModel = self.classModel;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }else if(indexPath.section == 2 && indexPath.row ==0){
        DWDClassGagViewController *vc = [[DWDClassGagViewController alloc] init];
        vc.classModel = self.classModel;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

#pragma mark - DWDClassChangeClassNameViewController Delegate
- (void)classChangeMyNicknameViewController:(DWDClassChangeClassNameViewController *)selfViewController doneRemarkName:(NSString *)doneRemarkName
{
    self.classModel.nickname = doneRemarkName;

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - request
- (void)requestGetout
{

    NSDictionary *params = @{@"custId" : [DWDCustInfo shared].custId,
                             @"classId" : self.classModel.classId,
                             @"friendCustId" : @[[DWDCustInfo shared].custId]};
  
    DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:self.view];
    [[HttpClient sharedClient] postApi:@"ClassMemberRestService/deleteEntity" params:params success:^(NSURLSessionDataTask *task, id responseObject) {
     
        [hud hide:YES];
        
        //1.删除本地库 班级
        [[DWDClassDataBaseTool sharedClassDataBase] deleteClassId:self.classModel.classId success:^{
           
            // 发通知 刷新班级列表
            [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationClassListReload object:nil];
        } failure:^{
            
            //失败、发通知、直接调接口更新
            [[NSNotificationCenter defaultCenter] postNotificationName:DWDNotificationContactUpdate object:nil];
        }];
        
        //2.删除会话列表
        [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] deleteRecentChatWithFriendId:self.classModel.classId success:^{
            //发送通知、是否刷新 会话列表
            [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNeedRecentChatLoad object:nil userInfo:@{@"isNeedLoadData":@(YES)}];

            
            [self.navigationController popToRootViewControllerAnimated:YES];
            //3. 删除会话历史聊天记录
            [[DWDMessageDatabaseTool sharedMessageDatabaseTool] deleteMessageTableWithFriendId:self.classModel.classId
                                                                                      chatType:DWDChatTypeClass
                                                                                       success:^{
                                                                                       }
                                                                                       failure:^(NSError *error) {
                                                                                       }];
            
            //4.删除学校表与智能菜单表
            [[DWDSchoolDataBaseTool sharedSchoolDataBase] deleteClassWithClassId:self.classModel.classId success:^{
                [[DWDIntelligenceMenuDatabaseTool sharedIntelligenceDataBase] deleteClassMenuWithClassId:self.classModel.classId success:^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationSmartOAMenu object:nil userInfo:nil];
                }];
            }];
            
        } failure:^{
            
        }];
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if([self.classModel.isMian isEqualToNumber:@1]) {
            [hud showText:@"解散失败"];
        }else{
            [hud showText:@"退出失败"];
        }

    }];

}


/** 更新nickname状态 */
- (void)requestUpdateNicknamestateWithState:(NSNumber *)state{
    [[DWDRequestClassSetting sharedDWDRequestClassSetting] requestClassSettingGetClassInfoCustId:[DWDCustInfo shared].custId classId:self.classModel.classId isTop:nil isClose:nil isShowNick:state success:^(id responseObject) {

        //更新本地库 班级列表 中的isShowNick 字段
        [[DWDClassDataBaseTool sharedClassDataBase] updateClassInfoWithisShowNick:state classId:self.classModel.classId myCustId:[DWDCustInfo shared].custId];
        self.classModel.isShowNick = state;
        
        //发送通知 给聊天界面 是否显示好友昵称
        NSDictionary *dict = @{@"isShowNick" : state};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showNickNotification" object:@"chatShowNick" userInfo:dict];
        
    } failure:^(NSError *error) {
        
    }];
}

//更新班级成员、获取最新成员人数
- (void)requedtClassMemberGetListWithClassId:(NSNumber *)classId{
    [[DWDClassMemberClient sharedClassMemberClient]
     requestClassMemberGetListWithClassId:self.classModel.classId
     success:^(id responseObject) {
         //获取班级成员总人数,替换当前内存数据
         [[DWDClassDataBaseTool sharedClassDataBase] getClassMemberCountWithClassId:classId success:^(NSUInteger memberCount) {
             self.classModel.memberNum = @(memberCount);
             //reload row
             NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:0];
             [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        } failure:^{
         }];

     } failure:^(NSError *error) {
     }];
}
@end
