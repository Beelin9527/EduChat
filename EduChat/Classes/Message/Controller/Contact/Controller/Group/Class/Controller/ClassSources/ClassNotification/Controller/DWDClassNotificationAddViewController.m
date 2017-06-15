//
//  DWDClassNotificationAddViewController.m
//  EduChat
//
//  Created by Gatlin on 15/12/10.
//  Copyright © 2015年 dwd. All rights reserved.
//

#define kMaxTitleLength 16

#import "DWDClassNotificationAddViewController.h"
//#import "JFImagePickerController.h"
#import "DWDPlaceholderTextView.h"
//#import "DWDMultiSelectImageView.h"
#import "DWDRequestServerClassNotification.h"
#import "DWDAddnotificationSelectGroupTableViewController.h"

#import "KKAlbumsListController.h"
#import "KKImagePreviewController.h"
#import "KKSelectImageView.h"
#import "DWDPhotosHelper.h"

#import "NSString+extend.h"
#import "NSDictionary+dwd_extend.h"

@interface DWDClassNotificationAddViewController ()<UITextViewDelegate, UITextFieldDelegate, KKSelectImageViewDelegate, KKAlbumsListControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tfTitle;
@property (weak, nonatomic) IBOutlet DWDPlaceholderTextView *tvContent;
@property (weak, nonatomic) IBOutlet UILabel *labNotificationType;
@property (strong, nonatomic) NSNumber *type;
@property (weak, nonatomic) IBOutlet UITableViewCell *notificationTypeCell;
@property (weak, nonatomic) IBOutlet UIButton *btnIkonw;


//@property (strong, nonatomic) DWDMultiSelectImageView *multiSelectImageView;
@property (nonatomic, weak) KKSelectImageView *selectImageView;
//@property (strong, nonatomic) NSMutableArray *arrSelectImgs;
@property (nonatomic, strong) NSArray *photosArray;

@property (strong, nonatomic) NSMutableDictionary *dictParams;
@end

@implementation DWDClassNotificationAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tvContent.delegate = self;
    self.tvContent.placeholder = @"请输入通知内容";
    self.tvContent.font = [UIFont systemFontOfSize:16];
    self.tfTitle.font = [UIFont systemFontOfSize:16];
    self.tfTitle.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入通知标题" attributes:@{
                                                                                                            NSFontAttributeName : [UIFont systemFontOfSize:12],
                                                                                                            NSForegroundColorAttributeName : DWDRGBColor(153, 153, 153),
                                                                                                            }];
    [self.tfTitle addTarget:self
                     action:@selector(textFieldDidChange:)
           forControlEvents:UIControlEventEditingChanged];
    //    self.tfTitle.delegate = self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"ic_release_normal"] style:UIBarButtonItemStylePlain target:self action:@selector(commitAction)];
    [self setupTableView];
}

-(void)setupTableView
{
//    DWDMultiSelectImageView *multiSelectImageView = [DWDMultiSelectImageView multiSelectImageView];
//    self.multiSelectImageView = multiSelectImageView;
//    multiSelectImageView.delegate = self;
//    
//    self.tableView.tableFooterView = multiSelectImageView;
    
    KKSelectImageView *imgsView = [[KKSelectImageView alloc] initWithFrame:(CGRect){0, 0, DWDScreenW, 200}];
    //    imgsView.backgroundColor = [UIColor redColor];
    imgsView.eventDelegate = self;
//    [_scrollView addSubview:imgsView];
    self.tableView.tableFooterView = imgsView;
    _selectImageView = imgsView;
    
    _btnIkonw.layer.masksToBounds = YES;
    _btnIkonw.layer.cornerRadius = self.btnIkonw.frame.size.height/2.0f;
}
//
//- (NSMutableArray *)arrSelectImgs
//{
//    if (!_arrSelectImgs) {
//        
//        _arrSelectImgs = [NSMutableArray array];
//    }
//    return _arrSelectImgs;
//}

- (NSMutableDictionary *)dictParams
{
    if (!_dictParams) {
        _dictParams = [NSMutableDictionary dictionaryWithObjects:@[[DWDCustInfo shared].custId,self.myClass.classId] forKeys:@[DWDCustId,@"classId"]];
    }
    return _dictParams;
}
#pragma mark - tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) return 10;
    if (section == 1) return 10;
    if (section == 2) return 10;
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeader = [[UIView alloc]init];
    sectionHeader.backgroundColor = [UIColor clearColor];
    return sectionHeader;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        [self didSelectRowAtChangeNotificatonType];
    } else if (indexPath.section == 3) {
        //发送人员选择
#warning ToDo
        //        DWDAddnotificationSelectGroupTableViewController *vc = [[DWDAddnotificationSelectGroupTableViewController alloc] init];
        //        vc.myClass = self.myClass;
        //        
        //        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - scrollView delegate
//delete UItableview headerview黏性
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (scrollView == self.tableView)
//    {
//        CGFloat sectionHeaderHeight = 10;
//        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
//            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
//            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//        }
//    }

//    [self.view endEditing:YES];
//}

#pragma mark - KKSelectImageViewDelegate
- (void)selectImageView:(KKSelectImageView *)view didClickAddImagesButtonWithMaxCount:(NSUInteger)maxCount {
    [[DWDPrivacyManager shareManger] needPrivacy:DWDPrivacyTypePhotoLibrary withController:self authorized:^{
        KKAlbumsListController *vc = [[KKAlbumsListController alloc] initWithMaxCount:(9 -_photosArray.count)];
        vc.delegate = self;
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
        navi.navigationItem.backBarButtonItem.title = @"所有相册";
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self presentViewController:navi animated:YES completion:nil];
        });
    }];
}

- (void)selectImageViewDidChangedPhotosArray:(NSArray<PHAsset *> *)photosArray {
    _photosArray = photosArray;
}

- (void)selectImageViewFrameChanged:(CGRect)frame {
//    CGRect footerFrame = self.tableView.tableFooterView.frame;
//    footerFrame.size.height = frame.size.height;
//    self.tableView.tableFooterView.frame = footerFrame;
    self.tableView.tableFooterView = _selectImageView;
}

#pragma mark - KKAlbumsListControllerDelegate
- (void)listControllerShouldCancel:(KKAlbumsListController *)listController {
    [listController dismissViewControllerAnimated:YES completion:nil];
}

- (void)listController:(KKAlbumsListController *)listController completeWithPhotosArray:(NSArray<PHAsset *> *)array {
    [listController dismissViewControllerAnimated:YES completion:^{
        if (_selectImageView && [_selectImageView respondsToSelector:@selector(addImagesWithArray:)]) {
            [_selectImageView addImagesWithArray:array];
        }
    }];
}
//
//#pragma mark - JFImagePickerDelegate
//- (void)imagePickerDidFinished:(JFImagePickerController *)picker{
//    
//    [self.arrSelectImgs removeAllObjects];
//    
//    
//    //    for ( ALAsset *asset in picker.assets) {
//    //        UIImage *image = [[JFAssetHelper sharedAssetHelper] getImageFromAsset:asset type:ASSET_PHOTO_FULL_RESOLUTION];
//    //
//    //        [self.arrSelectImgs addObject:image];
//    //    }
//    
//    self.arrSelectImgs = [[picker imagesWithType:ASSET_PHOTO_SCREEN_SIZE] mutableCopy];
//    
//    self.multiSelectImageView.arrImages = [self.arrSelectImgs mutableCopy];
//    self.tableView.tableFooterView = self.multiSelectImageView;
//    [picker dismissViewControllerAnimated:YES completion:nil];
//    //    [JFImagePickerController clear];
//}
//
//- (void)imagePickerDidCancel:(JFImagePickerController *)picker{
//    [picker dismissViewControllerAnimated:YES completion:nil];
//}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    [textView setNeedsDisplay];
}
//
#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    //    if(range.length + range.location > textField.text.length)
    //    {
    //        return NO;
    //    }
    //    
    //    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    //    return newLength <= 25;
    if ([string isEqualToString:@"\n"] || [string isEqualToString:@"\r"]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - action

- (void)textFieldDidChange:(UITextField *)textField {
    NSString *toBeString = textField.text;
    NSString *lang = [textField.textInputMode primaryLanguage];
    if ([lang isEqualToString:@"zh-Hans"]) {// 简体中文输入
        //获取高亮部分
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > kMaxTitleLength) {
                NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:kMaxTitleLength];
                if (rangeIndex.length == 1) {
                    textField.text = [toBeString substringToIndex:kMaxTitleLength];
                }
                else {
                    NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, kMaxTitleLength)];
                    textField.text = [toBeString substringWithRange:rangeRange];
                }
            }
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else {
        if (toBeString.length > kMaxTitleLength) {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:kMaxTitleLength];
            if (rangeIndex.length == 1) {
                textField.text = [toBeString substringToIndex:kMaxTitleLength];
            }
            else {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, kMaxTitleLength)];
                textField.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
}

- (void)didSelectRowAtChangeNotificatonType
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action_1 = [UIAlertAction actionWithTitle:@"单选(确认)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        // add dictParams
        [self.dictParams setObject:@1 forKey:@"type"];
        
        self.labNotificationType.text = @"单选";
        [self.labNotificationType setNeedsDisplay];
        
        //setup notificatonTypeCell
        [self.notificationTypeCell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"我知道了" forState:UIControlStateNormal];
        [btn setBackgroundColor:DWDColorSeparator];
        btn.layer.masksToBounds = YES;
        btn.frame = CGRectMake(DWDScreenW/2.0-150/2.0, 10, 150, 35);
        btn.layer.cornerRadius = btn.frame.size.height/2;
        [self.notificationTypeCell.contentView addSubview:btn]; 
        
        NSIndexSet *set = [[NSIndexSet alloc]initWithIndex:0];
        [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
        NSIndexSet *set2 = [[NSIndexSet alloc]initWithIndex:2];
        [self.tableView reloadSections:set2 withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    UIAlertAction *action_2 = [UIAlertAction actionWithTitle:@"多选(YES/NO)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        // add dictParams
        [self.dictParams setObject:@2 forKey:@"type"];
        
        self.labNotificationType.text = @"多选";
        [self.labNotificationType setNeedsDisplay];
        
        //setup notificatonTypeCell
        [self.notificationTypeCell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        NSArray *arrTitles = @[@"YES",@"NO"];
        for (int i = 0; i < arrTitles.count; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:arrTitles[i] forState:UIControlStateNormal];
            [btn setBackgroundColor:DWDColorSeparator];
            btn.layer.masksToBounds = YES;
            btn.frame = CGRectMake(DWDScreenW/4 + DWDScreenW/2*i-120/2, 10, 120, 35);
            btn.layer.cornerRadius = btn.frame.size.height/2;
            [self.notificationTypeCell.contentView addSubview:btn];
        }
        
        
        NSIndexSet *set = [[NSIndexSet alloc]initWithIndex:0];
        [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
        NSIndexSet *set2 = [[NSIndexSet alloc]initWithIndex:2];
        [self.tableView reloadSections:set2 withRowAnimation:UITableViewRowAnimationNone];
        
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:action_1];
    [alert addAction:action_2];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma  mark - request
- (void)commitAction
{
    NSString *titleString = [self.tfTitle.text trim];
    NSString *contentStr = [self.tvContent.text trim];
    
    if ([contentStr isEqualToString:@""] || [contentStr isEqualToString:@"请输入通知正文"]) {
        
        //        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"通知内容不能为空" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
        //        [alert show];
        
        [DWDProgressHUD showText:@"通知内容不能为空" afterDelay:1.5f];
        return;
    }
    
    if (titleString.length == 0 || [titleString isEqualToString:@""]) {
        [DWDProgressHUD showText:@"通知标题不能为空" afterDelay:1.5f];
        return;
    }
    
    //文案提示
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"通知发布后将无法编辑" message:nil preferredStyle:UIAlertControllerStyleAlert];
    WEAKSELF;
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf uploadRequest];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:action];
    [alertController addAction:cancelAction];
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
}

- (void)uploadRequest {
    
    if (![self.dictParams containsKey:@"type"]) {
        [self.dictParams setObject:@1 forKey:@"type"];
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
    hud.labelText = @"发送中";
    [hud show:YES];
    if (self.originalId) [self.dictParams setObject:self.originalId forKey:@"originalId"];
    
    WEAKSELF;
    [[DWDPhotosHelper defaultHelper] uploadPhotosWithPhotosArray:_photosArray completion:^(NSArray *photoNames, BOOL success) {
        
        if (success) {
            //上传成功
            [weakSelf.dictParams setObject:[weakSelf.tfTitle.text trim] forKey:@"title"];
            [weakSelf.dictParams setObject:[weakSelf.tvContent.text trim] forKey:@"content"];
            [weakSelf.dictParams setObject:photoNames forKey:@"photos"];
//            [[HttpClient sharedClient] postGrowUpRecordWithParams:weakSelf.dictParams success:^(NSURLSessionDataTask *task, id responseObject) {
#warning error with API
            /**
             
             ##################################################################
             #                            warning                             #
             #                            warning                             #
             #                            warning                             #
             #                            warning                             #
             #                            warning                             #
             #                            warning                             #
             #                            warning                             #
             ##################################################################
             
             
             
             上传时写错api,此api写成上传成长记录api"AlbumRestService/addEntity"
             
             已让后端在AlbumRestService/addEntity api中
             判断是否有字段值 type
             如果有字段值type,自动转移到 新增通知api
             
             此方法为无奈之举
             改动 通知 或者 新增成长记录参数时
             切记 切记
             */
            [[DWDRequestServerClassNotification sharedDWDRequestServerClassNotification] requestServerClassAddEntityDictParams:weakSelf.dictParams success:^(id responseObject) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    DWDMarkLog(@"Notification add completed");
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"发布通知成功";
                    [hud hide:YES afterDelay:1.5f];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakSelf.navigationController popViewControllerAnimated:YES];
                    });
                });
                
            } failure:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    hud.mode = MBProgressHUDModeText;
                    hud.labelText = @"发布通知失败";
                    [hud hide:YES afterDelay:1.5f];
                });
            }];
            
        } else {
            //上传失败
            //reason : 上传图片失败
            dispatch_async(dispatch_get_main_queue(), ^{
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"发布通知失败";
                [hud hide:YES afterDelay:1.5f];
            });
        }
    }];
    
    
//    //生成name,发送图片到阿里云,获取图片名字合集
//    NSMutableArray *picUrlArray = [NSMutableArray new];
//    //创建GCD Group 处理完所有请求之后再做下一步动作
//    dispatch_group_t uploadPicGroup = dispatch_group_create();
//    //异步上传
//    //    DWDProgressHUD *hud = [DWDProgressHUD showHUD];
////    if (self.arrSelectImgs.count >= 1 && self.arrSelectImgs.count < 9) {
////        [self.arrSelectImgs removeLastObject];
////    }
//    //    for (UIImage *image in self.arrSelectImgs) {
//    __block BOOL failed = NO;
//    for (UIImage *image in self.arrSelectImgs) {
//        NSString *picName = [NSUUID UUID].UUIDString;
//        
//        dispatch_group_enter(uploadPicGroup);
//        
//        NSString *urlStr = [[DWDAliyunManager sharedAliyunManager] getDownloadURLStringWithObjectName:picName];
//        [picUrlArray addObject:urlStr];
//        [[DWDAliyunManager sharedAliyunManager] uploadImage:image Name:picName progressBlock:^(CGFloat progress) {
//            
//        } success:^{
//            DWDMarkLog(@"uploadPicSucceed");
//            
//            dispatch_group_leave(uploadPicGroup);
//        } Failed:^(NSError *error) {
//            DWDMarkLog(@"uploadPic Failed DWDClassNotificationAddViewController:%@", error);
//            failed = YES;
//            dispatch_group_leave(uploadPicGroup);
//        }];
//    }
//    
//    [self.dictParams setObject:[self.tfTitle.text trim] forKey:@"title"];
//    [self.dictParams setObject:[self.tvContent.text trim] forKey:@"content"];
//    
//    //全部上传完成后发送请求
//    WEAKSELF;
//    dispatch_group_notify(uploadPicGroup, dispatch_get_main_queue(), ^{
//        if (failed == YES) {
//            return;
//        }
//        
//        [weakSelf.dictParams setObject:picUrlArray forKey:@"photos"];
//        
//        [[DWDRequestServerClassNotification sharedDWDRequestServerClassNotification] requestServerClassAddEntityDictParams:weakSelf.dictParams success:^(id responseObject) {
//            [JFImagePickerController clear];
//            DWDMarkLog(@"Notification add completed");
//            hud.mode = MBProgressHUDModeText;
//            hud.labelText = @"发布通知成功";
//            [hud hide:YES];
//            [weakSelf.navigationController popViewControllerAnimated:YES];
//            
//        } failure:^(NSError *error) {
//            hud.mode = MBProgressHUDModeText;
//            hud.labelText = @"发布通知失败";
//            [hud hide:YES];
//        }];
//        
//    });
}

@end


