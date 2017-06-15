//
//  DWDMeDetailViewController.m
//  EduChat
//
//  Created by Superman on 15/11/16.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDMeDetailViewController.h"
#import "DWDFixSignatureViewController.h"
#import "DWDAddressListViewController.h"
#import "DWDEduchatAccountSetupViewController.h"
#import "DWDCurrentDistrictViewController.h"
#import "DWDMyClassListViewController.h"
#import "DWDQRViewController.h"
#import "DWDMyChildListViewController.h"

#import "DWDCustInfoClient.h"

#import "UIActionSheet+camera.h"
#import <UIImageView+WebCache.h>
#import "DWDAliyunManager.h"
#import "DWDImagesScrollView.h"
@interface DWDMeDetailViewController ()<UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgHeader;
@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UILabel *labPhoneNum;
@property (weak, nonatomic) IBOutlet UILabel *labId;
@property (weak, nonatomic) IBOutlet UILabel *labEduchatAccount;
@property (weak, nonatomic) IBOutlet UILabel *labMyChildName;
@property (weak, nonatomic) IBOutlet UILabel *mySchoolOrchildLab;  //我的孩子或老师标签

@property (weak, nonatomic) IBOutlet UILabel *labGender;
@property (weak, nonatomic) IBOutlet UILabel *labSignature;
@property (weak, nonatomic) IBOutlet UILabel *labArea;

@property (weak, nonatomic) IBOutlet UITableViewCell *educhatAccountCell;   //多维度Cell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *eduAccountLabelRight; //请设置多维度号的约束右

@end

@implementation DWDMeDetailViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"信息";
    
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 10)];

    //若为设置头像，加载男女头像有别
    UIImage *defaultImage = [[DWDCustInfo shared].custGender isEqualToString:@"女"] ? DWDDefault_MeGrilImage :DWDDefault_MeBoyImage;
    [self.imgHeader sd_setImageWithURL:[NSURL URLWithString:[DWDCustInfo shared].custThumbPhotoKey] placeholderImage:defaultImage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChange)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:nil];
}
- (void)viewWillAppear:(BOOL)animated{
    [self loadData];
    [self setupTableViewCell];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private Method
- (void)loadData{
    /** 手机号 中间四位字符设置为*号 **/
    self.labPhoneNum.text = [DWDCustInfo shared].custMobile;
    if (self.labPhoneNum.text && ![self.labPhoneNum.text isEqualToString:@""]) {
        NSMutableString *string = [self.labPhoneNum.text copy];
       self.labPhoneNum.text = [string stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }
    
    self.tfName.text = [DWDCustInfo shared].custNickname;

    self.labEduchatAccount.text = [DWDCustInfo shared].custEduchatAccount;
    
    self.labGender.text = [DWDCustInfo shared].custGender;
    
    NSString *strIdentity = [[DWDCustInfo shared].custIdentity isEqual: @4]?@"老师":@"家长";
    self.labId.text = [NSString stringWithFormat:@"%@",strIdentity];
    
    self.labSignature.text = [DWDCustInfo shared].custSignature;
   
    self.labArea.text = [DWDCustInfo shared].custRegionName;
}


#pragma mark - Setup TableViewCell
/** 此方法是设置一些在XIB上无法进行设置的事件 **/
- (void)setupTableViewCell
{
    //设置多维度号Cell
    if (self.labEduchatAccount.text) {
        self.educhatAccountCell.accessoryType = UITableViewCellAccessoryNone;
        self.educhatAccountCell.userInteractionEnabled = NO;
        self.eduAccountLabelRight.constant = 15;
    }else{
        self.labEduchatAccount.text = @"请设置多维度号";
        self.educhatAccountCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.eduAccountLabelRight.constant = 0;
        self.labEduchatAccount.textColor = DWDColorSecondary;
    }
    
    //设置个性签名Cell
    if (self.labSignature.text) {
        self.labSignature.text = [DWDCustInfo shared].custSignature;
        self.labSignature.textColor = DWDColorBody;
    }else{
        self.labSignature.text = @"未填写";
        self.labSignature.textColor = DWDColorSecondary;
    }

    //区分权限
    if([DWDCustInfo shared].isTeacher){
        self.mySchoolOrchildLab.text = @"我的学校/班级";
        self.labMyChildName.text = @"";
    }else{
        self.mySchoolOrchildLab.text = @"我的孩子";
         self.labMyChildName.text = [DWDCustInfo shared].custMyChildName;
    }
}


#pragma mark - Gesture Recognizer
/** 查看图片 **/
- (IBAction)lookHeaderImageAction:(UITapGestureRecognizer *)sender {
    if ([DWDCustInfo shared].photoMetaModel.photoKey.length > 0 ) {
        DWDImagesScrollView *scrollView = [[DWDImagesScrollView alloc] initWithPhotoMetaArray:@[[DWDCustInfo shared].photoMetaModel]];
        [scrollView presentViewFromImageView:self.imgHeader atIndex:0 toContainer:self.view];
    }else{
          [self didSelectRowAtHeadImgAction];
    }
}



#pragma mark - <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
    
    if (indexPath.section == 0) {
        
        switch (indexPath.row) {
            case 0:{
                
                [self didSelectRowAtHeadImgAction];
                
            }break;
                
            case 3:{
                
                [self didSelectRowAtQRAction];
            }break;
            case 4:{
                
                [self didSelectRowAtEduchatAccountAction];
                
            }break;
            case 6:{
                
                //区分权限
                if ([DWDCustInfo shared].isTeacher) {
                    [self didSelectRowAtLookMyClass];
                }else{
                    [self didSelectRowAtMyChildsList];
                    
                }
                
            }break;
                
            default:
                break;
        }

    }else if (indexPath.section == 1){
        switch (indexPath.row) {
            case 0:{
                
                [self didSelectRowAtGenderAction];
            }break;
            case 1:{
                
                [self didSelectRowAtArea];
            }break;
            case 2:{
                
                [self didSelectRowAtSignaturnAction];

            }break;
            default:
                break;
        }
    }
}

#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.tfName endEditing:YES];
}

#pragma mark - textField delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.tfName.text = textField.text;
    [textField resignFirstResponder];
    
   
    return  YES;
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    if (textField.text.length + string.length - range.length > 16)
//    {
//        if (range.length)
//        {
//            textField.text = [textField.text substringToIndex:16];
//        }
//        
//        return NO;
//    }
//    else return YES;
//}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text isEqualToString:[DWDCustInfo shared].custNickname] ) return;

    //request
    [self requestUpdateWithNickname:textField.text];
}

#pragma mark - Notification implementation
- (void)textFieldDidChange
{
    NSString *toBeString = self.tfName.text;
    
    //获取高亮部分
    UITextRange *selectedRange = [self.tfName markedTextRange];
    UITextPosition *position = [self.tfName positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position)
    {
        if (toBeString.length > 16)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:16];
            if (rangeIndex.length == 1)
            {
                self.tfName.text = [toBeString substringToIndex:16];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, 16)];
                self.tfName.text = [toBeString substringWithRange:rangeRange];
            }
        }
        
    }
}


#pragma mark - didSelectRow action
// change headImg
- (void)didSelectRowAtHeadImgAction
{
    UIActionSheet *cameraActionSheet = [UIActionSheet showCameraActionSheet];
    cameraActionSheet.targer = self;
    
    [cameraActionSheet showInView:self.view];
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

/** 二维码 */
- (void)didSelectRowAtQRAction
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDQRViewController class]) bundle:nil];
    DWDQRViewController *qrVC = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDQRViewController class])];
    qrVC.info = [[DWDCustInfo shared].custId stringValue];
    qrVC.image = self.imgHeader.image;
    qrVC.nickname = [DWDCustInfo shared].custNickname;
    qrVC.type = DWDQRTypePerson;
    [self.navigationController pushViewController:qrVC animated:YES];
}
// change gender
- (void)didSelectRowAtGenderAction
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action_1 = [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        self.labGender.text = @"男";
        
        //requst
        [self requestUpdateWithGender:@1];
        
        
    }];
    
    UIAlertAction *action_2 = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        self.labGender.text = @"女";
        
        //requst
        [self requestUpdateWithGender:@2];
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:action_1];
    [alert addAction:action_2];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

//change area
- (void)didSelectRowAtArea
{
    DWDCurrentDistrictViewController *vc = [[DWDCurrentDistrictViewController alloc]init];
    vc.type = DWDSelfClassPropertyTypeSelectCityForChangeMeArea;
    vc.destinationVc = self;
    [self.navigationController pushViewController:vc animated:YES];
}

//look my class list
- (void)didSelectRowAtLookMyClass
{
    DWDMyClassListViewController *vc = [[DWDMyClassListViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];

}

// change signaturn
- (void)didSelectRowAtSignaturnAction
{
    DWDFixSignatureViewController *vc = [[DWDFixSignatureViewController alloc]initWithNibName:NSStringFromClass([DWDFixSignatureViewController class]) bundle:nil];
    vc.StrSignature = self.labSignature.text;
    [self.navigationController pushViewController:vc animated:YES];
    
}

// push AddressList
- (void)didSelectRowAtAddressListAction
{
    DWDAddressListViewController *vc = [[DWDAddressListViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

// push educhatAccount viewController
- (void)didSelectRowAtEduchatAccountAction
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:NSStringFromClass([DWDEduchatAccountSetupViewController class]) bundle:nil];
    DWDEduchatAccountSetupViewController *vc = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([DWDEduchatAccountSetupViewController class])];
    
    [self.navigationController pushViewController:vc animated:YES];
   
}

//parent client child list
- (void)didSelectRowAtMyChildsList
{
    DWDMyChildListViewController *vc = [[DWDMyChildListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - requsetServer
/** 上传头像到阿里去 **/
- (void)requestUploadWithAliyun:(UIImage *)image
{
    __block DWDProgressHUD *hud;
   dispatch_async(dispatch_get_main_queue(), ^{
          hud = [DWDProgressHUD showHUD];
       hud.labelText = nil;
   });
 
    NSString *strUUID = DWDUUID;
//    NSString *strUUID = [[DWDCustInfo shared].custId stringValue];
    [[DWDAliyunManager sharedAliyunManager] uploadImage:image Name:strUUID progressBlock:^(CGFloat progress) {
        
    } success:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            
        });
        
        NSString *urlStr = [[DWDAliyunManager sharedAliyunManager] getDownloadURLStringWithObjectName:strUUID];

        //request commit server
        [self requestUpdateWithPhotoKey:urlStr];
        
        
    } Failed:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
           [hud showText:@"更改失败" afterDelay:DefaultTime];            
        });
        
    }];
}

/** 修改昵称 */
- (void)requestUpdateWithNickname:(NSString *)nickname
{
    //校验昵称是否设置为空字符
    if ([nickname isBlank]) {
        [DWDProgressHUD showText:@"昵称不能为空"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tfName becomeFirstResponder];
        });
        return;
    }
   
    //去掉前后空格
    nickname = [nickname trim];
    
    //request
    [[DWDCustInfoClient sharedCustInfoClient]
    requestUpdateWithNickname:nickname
     success:^(id responseObject)
     {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];
}
/** 修改性别 */
- (void)requestUpdateWithGender:(NSNumber *)gender
{
    //request
    [[DWDCustInfoClient sharedCustInfoClient]
     requestUpdateWithGender:gender
     success:^(id responseObject)
     {
         //若为设置头像，加载男女头像有别
         UIImage *defaultImage = [[DWDCustInfo shared].custGender isEqualToString:@"女"] ? DWDDefault_MeGrilImage :DWDDefault_MeBoyImage;
         [self.imgHeader sd_setImageWithURL:[NSURL URLWithString:[DWDCustInfo shared].custThumbPhotoKey] placeholderImage:defaultImage];

         
         NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:1];
         if (![DWDCustInfo shared].custThumbPhotoKey) {
             
             NSIndexPath *indexPathIcon = [NSIndexPath indexPathForRow:0 inSection:0];
             [indexPaths addObject:indexPathIcon];
         }
         
         NSIndexPath *indexPathGender = [NSIndexPath indexPathForRow:0 inSection:1];
         [indexPaths addObject:indexPathGender];
         
         [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
     }];
    
}

/** 修改头像 */
- (void)requestUpdateWithPhotoKey:(NSString *)photoKey
{
    //request
    [[DWDCustInfoClient sharedCustInfoClient]
     requestUpdateWithPhotoKey:photoKey
     success:^(id responseObject)
     {
         //若为设置头像，加载男女头像有别
         UIImage *defaultImage = [[DWDCustInfo shared].custGender isEqualToString:@"女"] ? DWDDefault_MeGrilImage :DWDDefault_MeBoyImage;
         [self.imgHeader sd_setImageWithURL:[NSURL URLWithString:[DWDCustInfo shared].custThumbPhotoKey] placeholderImage:defaultImage];
         
         NSIndexPath *indexPathIcon = [NSIndexPath indexPathForRow:0 inSection:0];
         [self.tableView reloadRowsAtIndexPaths:@[indexPathIcon] withRowAnimation:UITableViewRowAnimationNone];
     }];
}

@end
