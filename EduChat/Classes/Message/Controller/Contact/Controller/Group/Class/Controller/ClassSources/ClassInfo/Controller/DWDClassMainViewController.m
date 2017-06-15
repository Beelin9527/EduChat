//
//  DWDClassMainViewController.m
//  EduChat
//
//  Created by Beelin on 16/12/6.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDClassMainViewController.h"

#import "DWDGrowUpViewController.h"
#import "DWDClassSourceClassNotificationViewController.h"
#import "DWDClassSourceHomeWorkViewController.h"
#import "DWDClassSourceLeavePaperViewController.h"
#import "DWDTeacherDetailViewController.h"
#import "DWDPickUpCenterChildTableViewController.h"
#import "DWDClassSettingController.h"
#import "DWDSearchClassInfoViewController.h"
#import "DWDClassIntroduceViewController.h"

#import "DWDClassStudentsListController.h"
#import "DWDClassMembersViewController.h"

#import "DWDIntFunctionItemCell.h"
#import "DWDIntHeaderClassInfoCell.h"

#import "DWDClassModel.h"
#import "DWDIntFunctionItemModel.h"
#import "DWDIntelligenceMenuModel.h"
#import "DWDSchoolModel.h"

#import "DWDIntelligentOfficeDataHandler.h"
#import "DWDRequestClassSetting.h"

#import "DWDIntelligenceMenuDatabaseTool.h"
#import "DWDClassDataBaseTool.h"
#import "DWDRecentChatDatabaseTool.h"

#import "UIActionSheet+camera.h"
@interface DWDClassMainViewController ()<DWDIntFunctionItemCellDelegate,DWDIntHeaderClassInfoCellDelegate,DWDClassIntroduceViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) NSArray *dataSource;

/**
 菜单模型
 目前只为记录所点击菜单的menuCode；
 */
@property (nonatomic, strong) DWDIntelligenceMenuModel *menuModel;

@end

@implementation DWDClassMainViewController

#pragma mark - Lify Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //查询班级管理菜单模块
    _dataSource = [[DWDIntelligenceMenuDatabaseTool sharedIntelligenceDataBase] queryClassManegerMenuWithClassId:self.classModel.classId];
    
    [self createControls];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:DWDColorMain] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBarTintColor:DWDColorMain];
}

#pragma mark - Create
- (void)createControls {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more_normal"] style:UIBarButtonItemStylePlain target:self action:@selector(rightAction)];
    
    self.tableView.frame = CGRectMake(0, 0, DWDScreenW, DWDScreenH);
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];

}


#pragma mark - Event Response
- (void)rightAction{
    // 跳转班级详情界面
    DWDSearchClassInfoViewController *searchInfoVc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDSearchClassInfoViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDSearchClassInfoViewController class])];
    searchInfoVc.classModel = self.classModel;
    searchInfoVc.hideButton = YES;  //隐藏按钮
    [self.navigationController pushViewController:searchInfoVc animated:YES];
}

#pragma mark - Private Method
/**
 跳转菜单功能控制器
 */
- (void)pushFuctionViewContorllerWithMenuCode:(DWDIntelligenceMenuModel *)model{
    //判断code
    UIViewController *functionVC = nil;
    if ([model.menuCode isEqualToString:kDWDIntMenuCodeClassManagementGrowth]) {
        DWDGrowUpViewController *growVc = [[DWDGrowUpViewController alloc] init];
        growVc.myClass = self.classModel;
        functionVC = growVc;
        
    }else if ([model.menuCode isEqualToString:kDWDIntMenuCodeClassManagementNotice]) {
        DWDClassSourceClassNotificationViewController *noteVc = [[DWDClassSourceClassNotificationViewController alloc] init];
        noteVc.myClass = self.classModel;
        functionVC = noteVc;
        
    }else if ([model.menuCode isEqualToString:kDWDIntMenuCodeClassManagementHomework]) {
        DWDClassSourceHomeWorkViewController *homeWorkVc =
        [[UIStoryboard storyboardWithName:NSStringFromClass([DWDClassSourceHomeWorkViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDClassSourceHomeWorkViewController class])];
        homeWorkVc.classId = self.classModel.classId;
        homeWorkVc.classModel = self.classModel;
        functionVC = homeWorkVc;
        
    }else if ([model.menuCode isEqualToString:kDWDIntMenuCodeClassManagementLeave]) {
        
        DWDClassSourceLeavePaperViewController *leaveVc = [[DWDClassSourceLeavePaperViewController alloc] init];
        leaveVc.classId = self.classModel.classId;
        functionVC = leaveVc;
        
    }else if ([model.menuCode isEqualToString:kDWDIntMenuCodeClassManagementTransferCenter]) {
        if ([DWDCustInfo shared].isTeacher) {
            DWDTeacherDetailViewController *vc = [[DWDTeacherDetailViewController alloc] init];
            vc.classId = self.classModel.classId;
            functionVC = vc;
        }else{
            DWDPickUpCenterChildTableViewController *childViewVc = [[DWDPickUpCenterChildTableViewController alloc] init];
            childViewVc.classId = self.classModel.classId;
            functionVC = childViewVc;
        }
        
    }else if ([model.menuCode isEqualToString:kDWDIntMenuCodeClassManagementClassSetting]) {
        DWDClassSettingController *sttingVc = [[DWDClassSettingController alloc] init];
        sttingVc.classModel = self.classModel;
        functionVC = sttingVc;
        
    }else if ([model.menuCode isEqualToString:kDWDIntMenuCodeMemberManagementStudentManagement]) {
        DWDClassStudentsListController *stuListVc = [DWDClassStudentsListController new];
        [stuListVc setHidesBottomBarWhenPushed:YES];
        stuListVc.classId = self.classModel.classId;
        functionVC = stuListVc;
        
    }else if ([model.menuCode isEqualToString:kDWDIntMenuCodeMemberManagementClassMember]) {
        DWDClassMembersViewController *vc = [[DWDClassMembersViewController alloc] init];
        vc.classModel = self.classModel;
        functionVC = vc;
    }
    if (functionVC != nil) {
        functionVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:functionVC animated:YES];
    }
    
}

/**
 alertControlller
 */
- (void)createAlertControllerWithMessage:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:sureAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - TableView Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(self.dataSource.count == 0){
        return 1;
    }
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        DWDIntHeaderClassInfoCell *cell = [DWDIntHeaderClassInfoCell cellWithTableView:tableView];
        cell.headertype = DWDclassMainHeaderType;
        cell.delegate = self;
        cell.classModel = self.classModel;
        return cell;
    }else if (indexPath.section == 1){
        DWDIntFunctionItemCell *itemCell = [DWDIntFunctionItemCell cellWithTableView:tableView headTitle:@"班级管理"];
        itemCell.delegate = self;
        NSArray *arr = self.dataSource[indexPath.section -1];
        itemCell.dataSource = arr.mutableCopy;
        return itemCell;
    }else if (indexPath.section == 2){
        DWDIntFunctionItemCell *itemCell = [DWDIntFunctionItemCell cellWithTableView:tableView headTitle:@"成员管理"];
        itemCell.delegate = self;
        NSArray *arr = self.dataSource[indexPath.section -1];
        itemCell.dataSource = arr.mutableCopy;
        return itemCell;
    }
    return nil;
}

#pragma mark - TableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 426/2.0;
    }
    NSArray *array = self.dataSource[indexPath.section - 1];
    
    return [array.lastObject cellHeight];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
//设置区尾颜色
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(nonnull UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
    v.backgroundView.backgroundColor = DWDColorBackgroud;
}

#pragma mark -  UIImagePickerController Delegate
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
        image =  [UIImage  compressImageWithOldImage:image compressSize: (CGSize){320, 320}];
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
#pragma mark - DWDIntHeaderClassInfoCell Delegate
- (void)intHeaderClassInfoCellClickAvatar:(DWDIntHeaderClassInfoCell *)cell{
    UIActionSheet *cameraActionSheet = [UIActionSheet showCameraActionSheet];
    cameraActionSheet.targer = self;
    
    [cameraActionSheet showInView:self.view];
}

- (void)intHeaderClassInfoCell:(DWDIntHeaderClassInfoCell *)cell clickIntroWithClassModel:(DWDClassModel *)classModel{
    DWDClassIntroduceViewController *vc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDClassIntroduceViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDClassIntroduceViewController class])];
    vc.delegate = self;
    vc.classModel = self.classModel;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - DWDClassIntroduceViewController Delegate
- (void)classIntroduceViewController:(DWDClassIntroduceViewController *)classIntroduceViewController introduce:(NSString *)introduce{
    self.classModel.introduce = introduce;
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - DWDIntFunctionItemCell Delegate
- (void)intFunctionItemCell:(DWDIntFunctionItemCell *)intFunctionItemCell selectItemWithModel:(DWDIntelligenceMenuModel *)model{
    self.menuModel = model;
    
    //判断是否中原生与H5类型
    if([self.menuModel.modeType isEqualToNumber:@0]){
        if ([self.menuModel.isOpen isEqualToNumber:@1]) {
            [self pushFuctionViewContorllerWithMenuCode:self.menuModel];
        }else if ([self.menuModel.isOpen isEqualToNumber:@2]){
            //reqeust
            [self requestGetAlertWithMenuCode:model.menuCode];
        }else if ([self.menuModel.isOpen isEqualToNumber:@6]){
            //reqeust
            [self createAlertControllerWithMessage:@"您还未加入任何班级，快去添加班级吧！"];
        }else if ([self.menuModel.isOpen isEqualToNumber:@7]){
            //我期待，有一天爱会回来。期待更多不作事件
            return;
        }
    }else if ([self.menuModel.modeType isEqualToNumber:@1]){
        
    }
}

#pragma mark - Request Date
- (void)requestGetAlertWithMenuCode:(NSString *)code{
    [DWDIntelligentOfficeDataHandler requestGetAlertWithCid:[DWDCustInfo shared].custId sid:self.classModel.schoolId mncd:code sta:nil targetController:self success:^{
        
    } failure:^(NSError *error) {
        
    }];
}

/** 更新头像 */
- (void)requestClassPhotoKeyWithClassId:(NSNumber *)classId photoKey:(NSString *)photoKey
{
    [[DWDRequestClassSetting sharedDWDRequestClassSetting]
     requestClassSettingGetClassInfoCustId:[DWDCustInfo shared].custId
     classId:classId photoKey:photoKey
     success:^(id responseObject) {
         
         self.classModel.photoKey = photoKey;
         
         dispatch_async(dispatch_get_main_queue(), ^{
             NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
             [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
         });
         
         
         //1. 改 tb_classes 数据库
         [[DWDClassDataBaseTool sharedClassDataBase] updateClassPhotokeyWithClassId:classId photokey:photoKey success:^{
             
             //发通知、刷新班级列表、与会话列表
             [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationClassListReload object:nil];
             
             //2. 修改recentChat 数据库
             [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] updatePhotokeyWithCusId:classId photokey:photoKey success:^{
                 //3. 刷新界面 ( 班级详情, 班级主页 , 接送中心? ...)
                 [[NSNotificationCenter defaultCenter] postNotificationName:kDWDChangeClassPhotoKeyNotification object:@{@"operationId" : classId,@"changePhotoKey" : photoKey}];
             } failure:^{
                 
             }];
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
        hud.labelText = @"正在上传";
    });
    
    NSString *strUUID = DWDUUID;
    [[DWDAliyunManager sharedAliyunManager] uploadImage:image Name:strUUID progressBlock:^(CGFloat progress) {
        
    } success:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            
        });
        
        NSString *urlStr = [[DWDAliyunManager sharedAliyunManager] getDownloadURLStringWithObjectName:strUUID];
        
        //请求更换头像
        [self requestClassPhotoKeyWithClassId:self.classModel.classId photoKey:urlStr];
        
        
    } Failed:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud showText:@"更改失败" afterDelay:DefaultTime];
        });
        
    }];
}
@end
