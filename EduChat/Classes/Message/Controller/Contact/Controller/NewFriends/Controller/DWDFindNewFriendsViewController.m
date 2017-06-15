//
//  DWDFindNewFriendsViewController.m
//  EduChat
//
//  Created by apple on 12/9/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "DWDFindNewFriendsViewController.h"
#import "DWDPersonDataViewController.h"
#import "DWDQRCodeViewController.h"
#import "DWDNavViewController.h"

#import "DWDQRImageView.h"

#import "NSString+extend.h"
#import "DWDAccountClient.h"

#import "DWDPersonDataBiz.h"//测试

@interface DWDFindNewFriendsViewController () <UITextFieldDelegate>

@property (strong, nonatomic) UITextField *field;
@property (nonatomic) CGFloat sectionHeight;
@property (strong, nonatomic) UILabel *sectionTitleLabel;

@property (strong, nonatomic) DWDQRImageView *QRImv; //二维码
@end

@implementation DWDFindNewFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self. navigationItem.title = @"添加朋友";
    
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    self.tableView.separatorColor = DWDColorSeparator;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = DWDColorBackgroud;
    
    _sectionTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _sectionTitleLabel.font = DWDFontContent;
    _sectionTitleLabel.textColor = DWDColorContent;
    _sectionTitleLabel.text = [NSString stringWithFormat:@"我的多维度号:%@",[DWDCustInfo shared].custEduchatAccount ? [DWDCustInfo shared].custEduchatAccount : @"未设置"];
    _sectionTitleLabel.numberOfLines = 0;
    
    CGSize titleSize = [_sectionTitleLabel.text boundingRectWithSize:CGSizeMake(DWDScreenW - 32, 99999)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:_sectionTitleLabel.font}
                                                     context:nil].size;
    
    _sectionTitleLabel.frame = CGRectMake(15, 0, titleSize.width, titleSize.height);
    self.sectionHeight = titleSize.height + 30;
}

#pragma mark Getter
- (DWDQRImageView *)QRImv
{
    if (!_QRImv) {
        NSString *info = [[DWDCustInfo shared].custId stringValue];
        _QRImv = [[DWDQRImageView alloc] initWithQRImageForString:info];
        _QRImv.frame = CGRectMake(DWDScreenW/2 - 150, DWDScreenH/2 - 150, 300, 300);
        
    }
    return _QRImv;
}

#pragma mark - TableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 35;
    } else {
        return 50;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    } else {
        return self.sectionHeight;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *header;
    if (section == 0) {
        header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, 10)];
        
    } else {
        
        header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, self.sectionHeight)];
        
        UIButton *action = [[UIButton alloc] initWithFrame:header.frame];
        [action addTarget:self action:@selector(showQrCode:) forControlEvents:UIControlEventTouchUpInside];
        
       
        self.sectionTitleLabel.center = CGPointMake(self.sectionTitleLabel.center.x, header.center.y);
       
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(self.sectionTitleLabel.frame.origin.x + self.sectionTitleLabel.frame.size.width + 10, 5, 22, 22)];
        icon.image = [UIImage imageNamed:@"ic_qr_code_my_information_normal"];
        icon.center = CGPointMake(icon.center.x, header.center.y);
        [header addSubview:self.sectionTitleLabel];
        [header addSubview:icon];
        [header addSubview:action];
    }
    header.backgroundColor = DWDColorBackgroud;
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"FindFriendCell"];
    cell.textLabel.font = DWDFontBody;
    cell.detailTextLabel.font = DWDFontMin;
    cell.detailTextLabel.textColor = DWDColorContent;
    
    if (indexPath.section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageView.image = [UIImage imageNamed:@"ic_search"];
        _field = [[UITextField alloc] initWithFrame:CGRectMake(40, 0, DWDScreenW - 10 * 2 - 20 - 10, 35)];
        self.field.font = DWDFontContent;
        self.field.placeholder = NSLocalizedString(@"InputNumber", nil);
        self.field.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        self.field.returnKeyType = UIReturnKeyDone;
        self.field.enablesReturnKeyAutomatically = YES;
        
        self.field.delegate = self;
        [cell.contentView addSubview:self.field];
        
    } else {
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        if (indexPath.row == 0) {
            //隐藏面对面加群功能
//            cell.imageView.image = [UIImage imageNamed:@"ic_establish_group"];
//            cell.textLabel.text = NSLocalizedString(@"ScanDetail", nil);
//            cell.detailTextLabel.text = NSLocalizedString(@"F2FCreateGroup", nil);
//        } else {
            cell.imageView.image = [UIImage imageNamed:@"ic_sweep"];
            cell.textLabel.text = NSLocalizedString(@"Scan", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"ScanDetail", nil);
        }
    }
    
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 0) {
        DWDQRCodeViewController *vc = [[DWDQRCodeViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];

    }
}
#pragma mark - uiscrollview delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.field resignFirstResponder];
}

#pragma mark - uitextfield delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ((textField.text.length + string.length - range.length) > 16) {
        if (range.length) {
            textField.text = [textField.text substringToIndex:16];
        }
        return NO;
        
    } else {
        
        return YES;
        
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    //request
    [self requestGetUserInfoAccout:textField.text];
    
    return YES;
}

/** 显示二维码 */
- (void)showQrCode:(UIButton *)sender {
    
    UIView *bgView = [[UIView alloc] init];
    bgView.frame = [UIApplication sharedApplication].keyWindow.bounds;
    [[UIApplication sharedApplication].keyWindow addSubview:bgView];
    
    //bgBtn
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = bgView.bounds;
    [btn setBackgroundColor:[UIColor colorWithWhite:0 alpha:.5]];
    [btn addTarget:self action:@selector(removeSelf:) forControlEvents:UIControlEventTouchDown];
    [bgView addSubview:btn];
    
    //QR imv
    [bgView addSubview:self.QRImv];
    
}

/** 移除二维码 */
- (void)removeSelf:(UIButton *)sender
{
    [sender.superview removeFromSuperview];
    sender = nil;
}

#pragma mark - Request
- (void)requestGetUserInfoAccout:(NSString *)accout
{
    WEAKSELF;
    
    DWDProgressHUD *hud = [DWDProgressHUD showHUDWithTarget:self.view];
    
    //调 getUserInfo 接口
    [[DWDAccountClient sharedAccountClient]
     getUserInfo:[DWDCustInfo shared].custId
     accountNo:accout
     success:^(NSDictionary *info) {
         
         [hud hideHud];
         
         DWDPersonDataViewController *vc = [[DWDPersonDataViewController alloc] init];
         vc.custId = info[@"friendCustId"];
         
         //申请来源类型
         if ([NSString isValidatePhone:self.field.text])
         {
             vc.sourceType = DWDSourceTypePhoneSearch;
         }
         else
         {
             vc.sourceType = DWDSourceTypeEduchatSearch;
         }
         [weakSelf.navigationController pushViewController:vc animated:YES];
         
     }
     failure:^(NSError *error) {
         
         [hud showText:error.localizedFailureReason afterDelay:DefaultTime];
         
     }];
}



@end

