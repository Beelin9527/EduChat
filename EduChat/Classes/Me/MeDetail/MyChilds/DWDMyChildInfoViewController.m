//
//  DWDMyChildInfoViewController.m
//  EduChat
//
//  Created by Gatlin on 16/3/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDMyChildInfoViewController.h"
#import "DWDMyChildFixChildNameViewController.h"

#import "OOStretchTableHeaderView.h"

#import "DWDMyChildClient.h"

#import "DWDMyChildInfoModel.h"
#import "DWDMyChildListEntity.h"


#import <YYModel/YYModel.h>

@interface DWDMyChildInfoViewController ()< UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (weak, nonatomic) IBOutlet UIImageView *avatarImv;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *genderBtn;
@property (weak, nonatomic) IBOutlet UILabel *identifyLab;


@property (strong, nonatomic) OOStretchTableHeaderView *StretchHeaderView;

@property (strong, nonatomic) NSArray *schollsArray;
@property (strong, nonatomic) DWDMyChildInfoModel *myChildInfoModel;
@end

@implementation DWDMyChildInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    [self requestDataWithChildCustId:self.childCustId];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
    //加载数据
    [self updateData];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:DWDColorMain] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBarTintColor:DWDColorMain];
    [self.navigationController.navigationBar setShadowImage:nil];
}

/** 刷新布局。关键 */
- (void)viewDidLayoutSubviews
{
    [self.StretchHeaderView resizeView];
}

#pragma mark - Setup
- (void)setup
{
    //自宝义控件 、拉伸图片
    _StretchHeaderView = [OOStretchTableHeaderView stretchHeaderForTableView:self.tableView withView:self.headerView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.bottomView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
}


#pragma mark - Private Methods
- (void)updateData
{
    self.title = self.myChildInfoModel.childName;
    [self.avatarImv sd_setImageWithURL:[NSURL URLWithString:self.myChildInfoModel.childPhotoKey] placeholderImage:[self.myChildInfoModel.gender isEqual: @2] ? DWDDefault_MeGrilImage : DWDDefault_MeBoyImage];
    [self.genderBtn setTitle:[self.myChildInfoModel.gender isEqualToNumber: @2] ? @"女" : @"男"
                    forState:UIControlStateNormal];

    switch ([self.myChildInfoModel.type intValue]) {
        case 21:
            self.identifyLab.text = @"爸爸";
            break;
        case 22:
            self.identifyLab.text = @"妈妈";
            break;
        case 23:
            self.identifyLab.text = @"爷爷";
            break;
        case 24:
            self.identifyLab.text = @"奶奶";
            break;
        case 25:
            self.identifyLab.text = @"外公";
            break;
        case 26:
            self.identifyLab.text = @"外婆";
            break;
            
        default:
            break;
    }
}

- (void)showSelectPhoto
{
    
    //在这里呼出下方菜单按钮项
    UIActionSheet *myActionSheet = [[UIActionSheet alloc]
                                    initWithTitle:nil
                                    delegate:self
                                    cancelButtonTitle:@"取消"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles: @"打开照相机", @"从手机相册获取",nil];
    
    [myActionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    //呼出的菜单按钮点击后的响应
    if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        DWDLog(@"取消");
    }
    
    switch (buttonIndex)
    {
        case 0:  //打开照相机拍照
            [self takePhoto];
            break;
            
        case 1:  //打开本地相册
            [self LocalPhoto];
            break;
    }
}

//开始拍照
-(void)takePhoto
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        
        [self presentViewController:picker animated:YES completion:nil];
        
    }else
    {
        DWDLog(@"模拟其中无法打开照相机,请在真机中使用");
    }
}

//打开本地相册
-(void)LocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    
    [self presentViewController:picker animated:YES completion:nil];
}

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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    DWDLog(@"您取消了选择图片");
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Button Action
- (IBAction)updateGenderAction:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *selectManAction = [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
         DWDProgressHUD *hud = [DWDProgressHUD showHUD];
        [self requestUpdateDataWithChildName:nil childGender:@(1) childPhotoKey:nil hud:hud];
    }];
    
    UIAlertAction *selectWomanAction = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        DWDProgressHUD *hud = [DWDProgressHUD showHUD];
        [self requestUpdateDataWithChildName:nil childGender:@(2) childPhotoKey:nil hud:hud];
    }];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:selectManAction];
    [alertController addAction:selectWomanAction];
     [alertController addAction:cancleAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Gesture
- (IBAction)updateAvatar:(UITapGestureRecognizer *)sender
{
    [self showSelectPhoto];
}



#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.schollsArray.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    
    DWDMyChildSchoolsModel *schoolsModel = self.schollsArray[section - 1];
    return schoolsModel.classInfo.count + 1;
  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"childInfoCell" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"姓名";
            cell.detailTextLabel.text = self.myChildInfoModel.childName;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }else if (indexPath.row == 1){
            cell.textLabel.text = @"多维度号";
            cell.detailTextLabel.text = self.myChildInfoModel.childEduAcct;
        }
    }else{
        
        //多个学校 与 多个班级 
        DWDMyChildSchoolsModel *schoolsModel = self.schollsArray[indexPath.section - 1];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"学校";
            cell.detailTextLabel.text = schoolsModel.schoolName;
        }else{
            DWDMyChildClassInfoModel *classInfoModel = schoolsModel.classInfo[indexPath.row - 1];
            cell.textLabel.text = [NSString stringWithFormat:@"班级%ld",indexPath.row];
            cell.detailTextLabel.text = classInfoModel.className;
        }
        
    }
    return cell;

}
#pragma mark - TableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) return 30;
    return 10;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) return @"Ta的学校/班级";

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        DWDMyChildFixChildNameViewController *vc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDMyChildFixChildNameViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDMyChildFixChildNameViewController class])];
        vc.myChildInfoModel = self.myChildInfoModel;
        vc.myChildListEntity = self.myChildListEntity;
        [self.navigationController pushViewController:vc animated:YES];

    }
}


#pragma mark - Scorller Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.StretchHeaderView scrollViewDidScroll:scrollView];
    
    if (self.tableView.contentOffset.y > (pxToH(300) - 64)) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:DWDColorMain] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:nil];
    }else if (self.tableView.contentOffset.y >= 0 && self.tableView.contentOffset.y <= (pxToH(300) - 64)){
        
        float alp = self.tableView.contentOffset.y / (pxToH(300) - 64);
       
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:90/255.0 green:136/255.0 blue:231/255.0 alpha:alp]] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    }else{
        [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];

    }
}

#pragma mark - Request
- (void)requestDataWithChildCustId:(NSNumber *)childCustId
{
    DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:self.view];
    
    __weak typeof(self) weakSelf = self;
    [[DWDMyChildClient sharedMyChildClient]
     requestGetMyChildInfoWithCustId:[DWDCustInfo shared].custId
     childCustId:childCustId
     success:^(id responseObject) {
         
         [hud hideHud];
         __strong typeof(self) strongSelf = weakSelf;
        strongSelf.myChildInfoModel = [DWDMyChildInfoModel yy_modelWithDictionary:responseObject[@"childInfo"]];
        
        NSMutableArray *schoolsMArray = [NSMutableArray arrayWithCapacity:[responseObject[@"schools"] count]];
        
         NSMutableArray *classInfoMArray = [NSMutableArray arrayWithCapacity:1];
        
        //遍历逻辑，看不懂。请结合后台返回数据看
        for (NSDictionary *dict in responseObject[@"schools"]) {
           DWDMyChildSchoolsModel *schoolModel = [DWDMyChildSchoolsModel yy_modelWithDictionary:dict];
            
            
            for (NSDictionary *dictClassInfo in schoolModel.classInfo) {
                DWDMyChildClassInfoModel *classInfoModel = [DWDMyChildClassInfoModel yy_modelWithDictionary:dictClassInfo];
                [classInfoMArray addObject:classInfoModel];
            }
            
            schoolModel.classInfo = classInfoMArray.mutableCopy;
            [schoolsMArray addObject:schoolModel];
            
            //清空下班级数组，非常有必要
             [classInfoMArray removeAllObjects];

        }
        
        self.schollsArray = schoolsMArray;
        [strongSelf updateData];
        [strongSelf.tableView reloadData];
        
    } failure:^(NSError *error) {
        [hud showText:@"加载失败"];
    }];
}

/** 更改信息 */
- (void)requestUpdateDataWithChildName:(NSString *)childName childGender:(NSNumber *)childGender childPhotoKey:(NSString *)childPhotoKey hud:(DWDProgressHUD *)hud
{
    __weak typeof(self) weakSelf = self;
    
    [[DWDMyChildClient sharedMyChildClient]
     requestUpdateMyChildInfoWithCustId:[DWDCustInfo shared].custId
     childCustId:self.childCustId
     childName:childName
     childGender:childGender
     childPhotoKey:childPhotoKey
     success:^(id responseObject) {
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [hud hide:YES];
             
         });
         
          __strong typeof(self) strongSelf = weakSelf;
         
         if (childGender) {
             strongSelf.myChildInfoModel.gender = childGender;
         }
         if (childPhotoKey) {
             self.myChildInfoModel.childPhotoKey = childPhotoKey;
             self.myChildListEntity.childPhotoKey = childPhotoKey;
         }
         //若为设置头像，加载男女头像有别
         UIImage *defaultImage = [strongSelf.myChildInfoModel.gender isEqual:@2] ? DWDDefault_MeGrilImage :DWDDefault_MeBoyImage;
         [strongSelf.avatarImv sd_setImageWithURL:[NSURL URLWithString:childPhotoKey] placeholderImage:defaultImage];
         
         
          [strongSelf updateData];
         [strongSelf.tableView reloadData];

        
    } failure:^(NSError *error) {
        
        [hud showText:@"更改失败"];
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
    
    __weak typeof(self) weakSelf = self;
    [[DWDAliyunManager sharedAliyunManager] uploadImage:image Name:strUUID progressBlock:^(CGFloat progress) {
        
    } success:^{
        
         __strong typeof(self) strongSelf = weakSelf;
       
        
        NSString *urlStr = [[DWDAliyunManager sharedAliyunManager] getDownloadURLStringWithObjectName:strUUID];
        

        [strongSelf requestUpdateDataWithChildName:nil childGender:nil childPhotoKey:urlStr hud:hud];

    } Failed:^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud showText:@"更改失败" afterDelay:DefaultTime];
        });
        
    }];
}


@end

