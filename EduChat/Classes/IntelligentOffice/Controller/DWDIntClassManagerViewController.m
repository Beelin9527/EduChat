//
//  DWDIntClassManagerViewController.m
//  EduChat
//
//  Created by Beelin on 16/12/1.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDIntClassManagerViewController.h"

#import "DWDChatController.h"

#import "DWDGrowUpViewController.h"
#import "DWDClassSourceClassNotificationViewController.h"
#import "DWDClassSourceHomeWorkViewController.h"
#import "DWDClassSourceLeavePaperViewController.h"
#import "DWDTeacherDetailViewController.h"
#import "DWDPickUpCenterChildTableViewController.h"
#import "DWDClassSettingController.h"
#import "DWDClassIntroduceViewController.h"

#import "DWDClassStudentsListController.h"
#import "DWDClassMembersViewController.h"

#import "DWDIntFunctionItemCell.h"
#import "DWDIntHeaderClassInfoCell.h"
#import "DWDIntClassMenuView.h"

#import "DWDSchoolModel.h"
#import "DWDClassModel.h"
#import "DWDIntelligenceMenuModel.h"

#import "DWDIntelligentOfficeDataHandler.h"
#import "DWDRequestClassSetting.h"
#import "DWDClassMemberClient.h"

#import "DWDIntelligenceMenuDatabaseTool.h"
#import "DWDClassDataBaseTool.h"
#import "DWDRecentChatDatabaseTool.h"

#import "UIActionSheet+camera.h"
#import <Masonry.h>


@interface DWDIntClassManagerViewController ()<DWDIntClassItemViewDelegate,DWDIntClassMenuViewDelegate,DWDIntFunctionItemCellDelegate,DWDIntHeaderClassInfoCellDelegate,DWDClassIntroduceViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UIButton *comeinClassChatBtn; //进入班级聊天按钮

@property (nonatomic, strong) NSNumber *classId;
@property (nonatomic, strong) DWDClassModel *classModel;

@property (nonatomic, assign) CGPoint comeinClassChatBtnCenterPoint;

@property (nonatomic, strong) NSArray *dataSource;

/** 
 菜单模型
 目前只为记录所点击菜单的menuCode；
 */
@property (nonatomic, strong) DWDIntelligenceMenuModel *menuModel;

@end


@implementation DWDIntClassManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createControls];
    
    //observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCalssModel:) name:kDWDNotificationClassManagerClassModel object:nil];
    
}

#pragma mark - Create
- (void)createControls{
    [self.view addSubview:self.intClassItemView];
    
    self.tableView.frame = CGRectMake(0, 40, DWDScreenW, DWDScreenH - DWDTopHight - 40 - 40 - DWDToolBarHeight);
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.comeinClassChatBtn];
}

#pragma mark - Setter
- (void)setSchoolModel:(DWDSchoolModel *)schoolModel{
    _schoolModel = schoolModel;
    self.intClassItemView.dataSource = _schoolModel.arrayClassModel;
    
    if (schoolModel.arrayClassModel.count <= 1) {
         self.tableView.frame = CGRectMake(0, 0, DWDScreenW, DWDScreenH - DWDTopHight  - 40 - DWDToolBarHeight);
    }else{
        self.tableView.frame = CGRectMake(0, 40, DWDScreenW, DWDScreenH - DWDTopHight - 40 - 40 - DWDToolBarHeight);
    }
    
    //查询班级管理菜单模块
    if (_schoolModel) {
            DWDIntClassModel *model = _schoolModel.arrayClassModel[0];
        
            if ([model.classId isEqualToNumber:@0]){
                //空模板学校
                self.dataSource =  [[DWDIntelligenceMenuDatabaseTool sharedIntelligenceDataBase] queryClassManegerMenuWithSchoolId:@(schoolIdDefault)];
                //come in chat button hidden
                self.comeinClassChatBtn.hidden = YES;
            } else if ([model.classId isEqualToNumber:@1]) {
                self.dataSource = [[DWDIntelligenceMenuDatabaseTool sharedIntelligenceDataBase] queryClassManegerMenuWithClassId:@1];//关于这个classId == 1,这个只能去看数据库才会清楚。当你理解了产品之后，你就会原谅哥为何这么写
                //come in chat button hidden
                self.comeinClassChatBtn.hidden = YES;
            }else{
                self.dataSource = [[DWDIntelligenceMenuDatabaseTool sharedIntelligenceDataBase] queryClassManegerMenuWithClassId:_schoolModel.arrayClassModel[0].classId];
                //come in chat button show
                self.comeinClassChatBtn.hidden = NO;
            }
    }
    
    //查询班级信息
    self.classId = [_schoolModel.arrayClassModel firstObject].classId;
    _classModel = [[DWDClassDataBaseTool sharedClassDataBase] getClassInfoWithClassId:self.classId myCustId:[DWDCustInfo shared].custId];
    
    [self.tableView reloadData];

}

#pragma mark - Getter
- (DWDIntClassItemView *)intClassItemView{
    if (!_intClassItemView) {
        _intClassItemView = [[DWDIntClassItemView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, 40)];
        _intClassItemView.delegate = self;
        }
    return _intClassItemView;
}

- (UIButton *)comeinClassChatBtn{
    if (!_comeinClassChatBtn) {
        _comeinClassChatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _comeinClassChatBtn.frame = CGRectMake(DWDScreenW - 92, self.view.h - 40 - 40 - 94.5 - DWDTopHight*2, 94.5, 92);
        _comeinClassChatBtnCenterPoint = _comeinClassChatBtn.center;
            [_comeinClassChatBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_comeinClassChatBtn setTitle:@"进入聊天" forState:UIControlStateNormal];
            _comeinClassChatBtn.titleLabel.font = DWDFontBody;
            _comeinClassChatBtn.titleEdgeInsets = UIEdgeInsetsMake(45, 10, 0, 0);
            [_comeinClassChatBtn setBackgroundImage:[UIImage imageNamed:@"img_chat_normal"] forState:UIControlStateNormal];
            [_comeinClassChatBtn setBackgroundImage:[UIImage imageNamed:@"img_chat_press"] forState:UIControlStateHighlighted];
            [_comeinClassChatBtn addTarget:self action:@selector(pushChatVC) forControlEvents:UIControlEventTouchUpInside];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [_comeinClassChatBtn addGestureRecognizer:pan];
    }
    return _comeinClassChatBtn;
}


#pragma mark - Event Response
- (void)pushChatVC{
    if(!self.classModel.classId) return;
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDChatController class]) bundle:nil];
    DWDChatController *chatVc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDChatController class])];
    chatVc.chatType = DWDChatTypeClass;
    chatVc.toUserId = self.classModel.classId;
    chatVc.myClass  = self.classModel;
    chatVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatVc animated:YES];
}
- (void)panAction:(UIPanGestureRecognizer *)pan{
    CGPoint point = [pan translationInView:self.view];
    if (pan.state == UIGestureRecognizerStateBegan) {
        
    }else if (pan.state == UIGestureRecognizerStateChanged){
        CGFloat y = self.comeinClassChatBtnCenterPoint.y + point.y;
        if (y > (DWDScreenH - 44 - 64 - 10 - pan.view.bounds.size.height)) {
            y = DWDScreenH - 44 - 64 - 10 - pan.view.bounds.size.height;
        } else {
            if (y < (70)) {
                y = 70;
            }
        }
        pan.view.center = CGPointMake(DWDScreenW - 92 * 0.5, y);
    }else if (pan.state == UIGestureRecognizerStateEnded){
        self.comeinClassChatBtnCenterPoint = pan.view.center;
    }
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
        leaveVc.classModel = self.classModel;
        functionVC = leaveVc;
        
    }else if ([model.menuCode isEqualToString:kDWDIntMenuCodeClassManagementTransferCenter]) {
        if ([DWDCustInfo shared].isTeacher) {
            DWDTeacherDetailViewController *vc = [[DWDTeacherDetailViewController alloc] init];
            vc.classId = self.classModel.classId;
            vc.classModel = self.classModel;
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
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:sureAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Notification Implementation
//更新当前内存classModel
- (void)updateCalssModel:(NSNotification *)noti{
    if (self.classModel) {
        //重新查询班级信息
        self.classId = self.classModel.classId;
        _classModel = [[DWDClassDataBaseTool sharedClassDataBase] getClassInfoWithClassId:self.classId myCustId:[DWDCustInfo shared].custId];
        [self.tableView reloadData];
    }
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
        cell.headertype = DWDClassManagerHeaderType;
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
        return 350/2.0;
    }
    NSArray *array = self.dataSource[indexPath.section - 1];
    
    return [array.lastObject cellHeight];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 2) return 0;
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


#pragma mark - DWDIntClassItemView Delegate
- (void)intClassItemViewClickMenuButton:(DWDIntClassItemView *)intClassItemView{
    DWDIntClassMenuView *menu = [DWDIntClassMenuView IntClassMenuViewWithFrame:CGRectMake(0, 0, DWDScreenW, DWDScreenH - DWDTopHight - DWDToolBarHeight - 40) dataSource:self.schoolModel.arrayClassModel];
    menu.delegate = self;
    
    [self.view addSubview:menu];
}
- (void)intClassItemView:(DWDIntClassItemView *)intClassItemView selectItem:(DWDIntClassModel *)model{
    if ([self.classId isEqualToNumber: model.classId]) return;
    
    //查询班级管理菜单模块
    self.dataSource = [[DWDIntelligenceMenuDatabaseTool sharedIntelligenceDataBase] queryClassManegerMenuWithClassId:model.classId];
    
    //查询班级信息
    self.classId = model.classId;
    _classModel = [[DWDClassDataBaseTool sharedClassDataBase] getClassInfoWithClassId:self.classId myCustId:[DWDCustInfo shared].custId];
    
    [self.tableView reloadData];
    
}

#pragma mark - DWDIntClassMenuView Delegate
- (void)intClassMenuView:(DWDIntClassMenuView *)intClassMenuView selectItem:(DWDIntClassModel *)model{
    if ([self.classId isEqualToNumber: model.classId]) return;

    //查询班级管理菜单模块
    self.dataSource = [[DWDIntelligenceMenuDatabaseTool sharedIntelligenceDataBase] queryClassManegerMenuWithClassId:model.classId];
    
    //查询班级信息
    self.classId = model.classId;
    _classModel = [[DWDClassDataBaseTool sharedClassDataBase] getClassInfoWithClassId:self.classId myCustId:[DWDCustInfo shared].custId];
    
    //更新intClassItemView 选中按钮
    NSInteger index = [self.schoolModel.arrayClassModel indexOfObject:model];
    [self.intClassItemView updateSelectItemWithIndex:index];
    
    [self.tableView reloadData];
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
        if ([self.menuModel.isOpen isEqualToNumber:@1]) {
            
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
    }
}

#pragma mark - Request Data
- (void)requestGetAlertWithMenuCode:(NSString *)code{
    [DWDIntelligentOfficeDataHandler requestGetAlertWithCid:[DWDCustInfo shared].custId sid:self.schoolModel.schoolId mncd:code sta:nil targetController:self success:^{
        
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
