//
//  DWDClassInnerGroupViewController.m
//  EduChat
//
//  Created by apple on 12/31/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "DWDClassInnerGroupViewController.h"
#import "DWDClassInnerGroupDetailViewController.h"

#import "DWDClassInnerGroupClient.h"

#import "DWDContactModel.h"
@interface DWDClassInnerGroupViewController ()

@property (strong, nonatomic) DWDClassInnerGroupClient *client;
@property (strong, nonatomic) NSArray *datas;

@end

@implementation DWDClassInnerGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *footer = [UIView new];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"InnerGourpCell"];
    
    self.title = @"我的班内群组";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"新建"
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(newInnerGroup:)];
    [self.tableView setContentInset:UIEdgeInsetsMake(10,0,0,0)];
    self.tableView.backgroundColor = DWDColorBackgroud;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reloadInnerGroupData)
     name:DWDNeedUpdateClassInnerGroup object:nil];
    
    _client = [[DWDClassInnerGroupClient alloc] init];
    [self reloadInnerGroupData];
}

- (void)reloadInnerGroupData {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = NSLocalizedString(@"Loading", nil);
    
    [self.client fetchClassInnerGroupBy:[DWDCustInfo shared].custId
                                classId:self.classId
                                success:^(NSArray *innerGroups) {
                                    
                                    _datas = innerGroups;
                                    [hud hide:YES];
                                    [self.tableView reloadData];
                                } failure:^(NSError *error) {
                                    
                                    hud.mode = MBProgressHUDModeText;
                                    hud.labelText = NSLocalizedString(@"LoadingFail", nil);
                                    [hud hide:YES afterDelay:1];
                                }];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *rowData = self.datas[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InnerGourpCell" forIndexPath:indexPath];
    cell.textLabel.textColor = DWDColorContent;
    cell.textLabel.font = DWDFontContent;
    cell.textLabel.text = [NSString stringWithFormat:@"%@（%d）人", rowData[@"name"], [rowData[@"memberNum"] intValue]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = NSLocalizedString(@"Loading", nil);
    
    NSDictionary *rowData = self.datas[indexPath.row];
    
    [self.client fetchClassInnerGroupMembersBy:[DWDCustInfo shared].custId
                                       classId:self.classId
                                       groupId:rowData[@"groupId"]
                                       success:^(NSArray *members) {
                                           
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               if (!members.count) {
                                                   [hud hide:YES];
                                                   return;
                                               }
                                               
                                               NSMutableArray *contacts = [NSMutableArray arrayWithCapacity:10];
                                               for (NSDictionary *dicMember in members) {
                                                   DWDContactModel *contact = [[DWDContactModel alloc] init];
                                                   contact.nickname = dicMember[@"nickname"];
                                                   contact.custId = dicMember[@"custId"];
                                                   contact.photoKey = dicMember[@"photoKey"];
                                                   [contacts addObject:contact];
                                               }
                                               [hud hide:YES];
                                               DWDClassInnerGroupDetailViewController *vc = [[DWDClassInnerGroupDetailViewController alloc] init];
                                                vc.memberDataSource = contacts;
                                               vc.groupName = rowData[@"name"];
                                               vc.groupId = rowData[@"groupId"];
                                               vc.classId = self.classId;
                                               [self.navigationController pushViewController:vc animated:YES];
                                           });
                                           
                                       } failure:^(NSError *error) {
                                           
                                           hud.mode = MBProgressHUDModeText;
                                           hud.labelText = NSLocalizedString(@"LoadFail", nil);
                                           [hud hide:YES afterDelay:1];
                                       }];
    
   
}

- (void)newInnerGroup:(UIBarButtonItem *)sender {
    DWDClassInnerGroupDetailViewController *vc = [[DWDClassInnerGroupDetailViewController alloc] init];
    vc.isForCreate = YES;
    vc.classId = self.classId;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
