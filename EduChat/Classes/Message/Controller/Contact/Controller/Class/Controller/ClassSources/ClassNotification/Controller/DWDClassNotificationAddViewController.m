//
//  DWDClassNotificationAddViewController.m
//  EduChat
//
//  Created by Bharal on 15/12/10.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDClassNotificationAddViewController.h"
#import "JFImagePickerController.h"

#import "DWDMultiSelectImageView.h"

#import "DWDRequestServerClassNotification.h"
@interface DWDClassNotificationAddViewController ()<JFImagePickerDelegate,DWDMultiSelectImageViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tfTitle;
@property (weak, nonatomic) IBOutlet UITextView *tvContent;
@property (weak, nonatomic) IBOutlet UILabel *labNotificationType;
@property (strong, nonatomic) NSNumber *type;
@property (weak, nonatomic) IBOutlet UITableViewCell *notificationTypeCell;
@property (weak, nonatomic) IBOutlet UIButton *btnIkonw;


@property (strong, nonatomic) DWDMultiSelectImageView *multiSelectImageView;
@property (strong, nonatomic) NSMutableArray *arrSelectImgs;

@property (strong, nonatomic) NSMutableDictionary *dictParams;
@end

@implementation DWDClassNotificationAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(commitAction)];
    [self setupTableView];
}

-(void)setupTableView
{
    DWDMultiSelectImageView *multiSelectImageView = [DWDMultiSelectImageView multiSelectImageView];
    self.multiSelectImageView = multiSelectImageView;
    multiSelectImageView.delegate = self;
    
    self.tableView.tableFooterView = multiSelectImageView;
      
    _btnIkonw.layer.masksToBounds = YES;
    _btnIkonw.layer.cornerRadius = self.btnIkonw.frame.size.height/2;
}

- (NSMutableArray *)arrSelectImgs
{
    if (!_arrSelectImgs) {
        
        _arrSelectImgs = [NSMutableArray array];
    }
    return _arrSelectImgs;
}

- (NSMutableDictionary *)dictParams
{
    if (!_dictParams) {
        _dictParams = [NSMutableDictionary dictionaryWithObjects:@[@4010000005409,@7010000002006] forKeys:@[DWDCustId,@"classId"]];
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
    if (indexPath.section == 0) {
        
        [self didSelectRowAtChangeNotificatonType];
    }
}

#pragma mark - scrollView delegate
//delete UItableview headerview黏性
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView)
    {
        CGFloat sectionHeaderHeight = 10;
        if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
    
    [self.view endEditing:YES];
}

#pragma mark - DWDMultiSelectImageView delegate
- (void)multiSelectImageViewDidSelectAddButton:(DWDMultiSelectImageView *)multiSelectImageView
{
    JFImagePickerController *picker = [[JFImagePickerController alloc] initWithRootViewController:nil];
    picker.pickerDelegate = self;
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma makr - JFImagePickerDelegate
- (void)imagePickerDidFinished:(JFImagePickerController *)picker{
    
    [self.arrSelectImgs removeAllObjects];
    
    __weak DWDClassNotificationAddViewController *weakSelf = self;
    
    for ( ALAsset *asset in picker.assets) {
        
        [[JFImageManager sharedManager] thumbWithAsset:asset resultHandler:^(UIImage *result) {
        
            [weakSelf.arrSelectImgs addObject:result];
        }];

    }
    
    self.multiSelectImageView.arrImages = self.arrSelectImgs;
    DWDLog(@"----%lu",(unsigned long)self.arrSelectImgs.count);
     self.tableView.tableFooterView = self.multiSelectImageView;
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerDidCancel:(JFImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}




#pragma mark - action

- (void)didSelectRowAtChangeNotificatonType
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action_1 = [UIAlertAction actionWithTitle:@"模式一" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        // add dictParams
        [self.dictParams setObject:@1 forKey:@"type"];
        
        self.labNotificationType.text = @"模式一";
        
        //setup notificatonTypeCell
        [self.notificationTypeCell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"我知道了" forState:UIControlStateNormal];
        [btn setBackgroundColor:DWDColorSeparator];
        btn.layer.masksToBounds = YES;
        btn.frame = CGRectMake(DWDScreenW/2-150/2, 10, 150, 35);
        btn.layer.cornerRadius = btn.frame.size.height/2;
        [self.notificationTypeCell.contentView addSubview:btn]; 
        
        NSIndexSet *set = [[NSIndexSet alloc]initWithIndex:0];
        [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationNone];
        NSIndexSet *set2 = [[NSIndexSet alloc]initWithIndex:2];
        [self.tableView reloadSections:set2 withRowAnimation:UITableViewRowAnimationNone];

        

    }];
    
    UIAlertAction *action_2 = [UIAlertAction actionWithTitle:@"模式二" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        // add dictParams
        [self.dictParams setObject:@2 forKey:@"type"];
        
        self.labNotificationType.text = @"模式二";
        
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
    if ([self.tvContent.text isEqualToString:@""] || [self.tvContent.text isEqualToString:@"请输入通知正文"]) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"没输入通知内容，你想干嘛呢" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if (self.originalId) [self.dictParams setObject:self.originalId forKey:@"originalId"];
    
    [self.dictParams setObject:self.tfTitle.text forKey:@"title"];
    [self.dictParams setObject:self.tvContent.text forKey:@"content"];
    
    [[DWDRequestServerClassNotification sharedDWDRequestServerClassNotification] requestServerClassAddEntityDictParams:self.dictParams success:^(id responseObject) {
        
        
        UIViewController *vc = [self.navigationController.viewControllers objectAtIndex:5];
        [self.navigationController popToViewController:vc animated:YES];
        
    } failure:^(NSError *error) {
        
    }];
     
}


@end
