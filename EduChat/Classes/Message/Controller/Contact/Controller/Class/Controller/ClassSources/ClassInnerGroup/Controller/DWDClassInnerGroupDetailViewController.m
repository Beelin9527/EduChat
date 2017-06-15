//
//  DWDClassInnerGroupDetailViewController.m
//  EduChat
//
//  Created by apple on 12/31/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "DWDClassInnerGroupDetailViewController.h"
#import "DWDHeaderImgSortControl.h"
#import "DWDContactSelectViewController.h"
#import "DWDNavViewController.h"
#import "DWDClassInnerGroupClient.h"
#import "DWDCell.h"
@interface DWDClassInnerGroupDetailViewController () <UITextFieldDelegate, DWDHeaderImgSortControlDelegate, DWDContactSelectViewControllerDelegate>

@property (strong, nonatomic) UITextField *field;
@property (strong, nonatomic) DWDHeaderImgSortControl *headerImgSortControl;
@property (strong, nonatomic) DWDClassInnerGroupClient *client;

@end

@implementation DWDClassInnerGroupDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[DWDCell class] forCellReuseIdentifier:@"InnerGroupDetail"];
    UIView *footer = [UIView new];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);

    self.tableView.backgroundColor = DWDColorBackgroud;
    self.title = @"分组";
    
    NSString *btnTitlt = self.isForCreate ? @"保存" : @"删除";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:btnTitlt
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(rightBarButtonClick)];
    _client = [[DWDClassInnerGroupClient alloc] init];
    if (!self.contacts) {
        _contacts = [NSMutableArray array];
    }
}

- (void)rightBarButtonClick {
    
    if (self.isForCreate) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        self.groupName = [self.field.text trim];
        if (self.groupName.length == 0) {
            
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"请输入群组名称";
            [hud hide:YES afterDelay:1];
            
        }
        
        else if ([self.headerImgSortControl.arrItems count] == 0) {
            
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"请添加成员";
            [hud hide:YES afterDelay:1];
            
        }
        
        else {
            
            NSMutableArray *params = [NSMutableArray arrayWithCapacity:self.headerImgSortControl.arrItems.count];
            for ( DWDGroupCustEntity *contact in self.headerImgSortControl.arrItems) {
                [params addObject:contact.custId];
            }
            hud.labelText = NSLocalizedString(@"Sending", nil);
            [self.client postClassInnerGroupBy:[DWDCustInfo shared].custId
                                       classId:self.classId
                                     groupName:self.groupName
                                      contacts:params
                                       success:^{
                                           
                                           [[NSNotificationCenter defaultCenter]
                                            postNotificationName:DWDNeedUpdateClassInnerGroup
                                            object:nil];
                                           
                                           [self.navigationController popViewControllerAnimated:YES];
                                           
                                           [hud hide:YES];
                                       } failure:^(NSError *error) {
                                           
                                           hud.labelText = NSLocalizedString(@"SendingFail", nil);
                                           [hud hide:YES afterDelay:1];
                                           
                                       }];
        }
        
        
    } else {
        
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"警告"
                                    message:@"你确定要删除该分组？"
                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *agreeAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            hud.labelText = NSLocalizedString(@"Sending", nil);
            [self.client deleteClassInnerGroupBy:[DWDCustInfo shared].custId
                                         classId:self.classId
                                         groupId:self.groupId
                                         success:^{
                                             
                                             [[NSNotificationCenter defaultCenter] postNotificationName:DWDNeedUpdateClassInnerGroup object:nil];
                                             [self.navigationController popViewControllerAnimated:YES];
                                             [hud hide:YES];
                                         }
             
                                         failure:^(NSError *error) {
                                         
                                             hud.mode = MBProgressHUDModeText;
                                             
                                             hud.labelText = NSLocalizedString(@"SendingFail", nil);
                                             
                                             [hud hide:YES afterDelay:1];
                                            
                                         }];
            
        }];
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alert addAction:agreeAction];
        [alert addAction:cancleAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InnerGroupDetail"];
    
    if (indexPath.section == 0) {
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (!self.field) {
            _field = [[UITextField alloc] initWithFrame:CGRectMake(21, 0, DWDScreenW - 10 * 2 - 20 - 10, 20)];
            if (self.isForCreate) {
                self.field.placeholder = @"请输入分组名称";
                if (self.groupName && self.groupName.length > 0) {
                    self.field.text = self.groupName;
                }
                
            } else {
                self.field.text = self.groupName;
                self.field.userInteractionEnabled = NO;
            }
            self.field.center = CGPointMake(self.field.center.x, cell.center.y);
            self.field.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
            self.field.returnKeyType = UIReturnKeyDone;
            self.field.enablesReturnKeyAutomatically = YES;
            
            self.field.delegate = self;

        }
        
        [cell.contentView addSubview:self.field];
        
    } else {
        if (self.headerImgSortControl) {
            [self.headerImgSortControl removeFromSuperview];
        }
        _headerImgSortControl = [[DWDHeaderImgSortControl alloc] init];
        self.headerImgSortControl.delegate = self;
        self.headerImgSortControl.arrItems = self.contacts;
        self.headerImgSortControl.frame = CGRectMake(0, 0, DWDScreenW, self.headerImgSortControl.hight);
        
        [cell.contentView addSubview:self.headerImgSortControl];
    }
    
    return cell;
}

#pragma mark - delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 1) {
        DWDHeaderImgSortControl *headerImgSortControl = [[DWDHeaderImgSortControl alloc] init];
        headerImgSortControl.arrItems = self.contacts;
        return   headerImgSortControl.hight;
    }
    
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGSize size = [@"分组名称" boundingRectWithSize:CGSizeMake(DWDScreenW, 9999)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:DWDFontMin}
                                        context:nil].size;
    
    return size.height + 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = DWDColorBackgroud;
    UILabel *label = [[UILabel alloc] init];
    label.textColor = DWDColorContent;
    label.font = DWDFontMin;
    if (section == 0) {
        label.text = @"分组名称";
    }
    else {
        label.text = @"分组成员";
    }
    
    CGSize labelSize = [label.text boundingRectWithSize:CGSizeMake(DWDScreenW, 9999)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName:label.font}
                                                context:nil].size;
    label.frame = CGRectMake(20, 10, labelSize.width, labelSize.height);
    header.frame = CGRectMake(0, 0, DWDScreenW, 20 + labelSize.height);
    
    [header addSubview:label];
    
    return header;
}


-(void)headerImgSortControlDidSelectAddButton:(DWDHeaderImgSortControl*)headerImgSortControl {
    
    if (!self.groupName && self.isForCreate) {
        _groupName = [self.field.text trim];
    }
    
    DWDContactSelectViewController *vc = [[DWDContactSelectViewController alloc] init];
    vc.type = DWDSelectContactTypeAddEntity;
    vc.delegate = self;
    
    NSMutableArray *ids = [NSMutableArray array];
    for (DWDGroupCustEntity *contact in self.contacts) {
        [ids addObject:contact.custId];
    }
    vc.contactIdsForExclude = ids;
    
    DWDNavViewController *naviVC = [[DWDNavViewController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:naviVC animated:YES completion:nil];
}

-(void)headerImgSortControlDidSelectDeleteButton:(DWDHeaderImgSortControl*)headerImgSortControl {
    
    if (!self.groupName && self.isForCreate) {
        _groupName = [self.field.text trim];
    }
    
    DWDContactSelectViewController *vc = [[DWDContactSelectViewController alloc] init];
    vc.type = DWDSelectContactTypeDeleteEntity;
    vc.delegate = self;
    
    NSMutableArray *ids = [NSMutableArray array];
    for (DWDGroupCustEntity *contact in self.contacts) {
        [ids addObject:contact.custId];
    }
    vc.contactIdsCanDelete = ids;
    
    DWDNavViewController *naviVC = [[DWDNavViewController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:naviVC animated:YES completion:nil];
}

- (void)contactSelectViewControllerDidSelectContactsForAdd:(NSArray *)contacts {
    
    NSMutableArray *addIds = [NSMutableArray arrayWithCapacity:contacts.count];
    NSMutableArray *addEntitys = [NSMutableArray arrayWithCapacity:contacts.count];
    
    for (NSDictionary *dicContact in contacts) {
        DWDGroupCustEntity *contact = [[DWDGroupCustEntity alloc] init];
        contact.nickname = dicContact[@"nickname"];
        contact.photoKey = dicContact[@"photoKey"];
        contact.custId = dicContact[@"custId"];
        [addIds addObject:contact.custId];
        [addEntitys addObject:contact];
    }
    
    if (self.isForCreate) {
        
        [self.contacts addObjectsFromArray:addEntitys];
        [self.tableView reloadData];
    
    }
    
    else {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        hud.labelText = NSLocalizedString(@"Sending", nil);
        
        __unsafe_unretained typeof(self) weakSelf = self;
        
        [self.client addMembersToClassInnerGroup:self.groupId
                                         classId:self.classId
                                          byUser:[DWDCustInfo shared].custId
                                     addContacts:addIds
         
                                         success:^{
                                             
                                             hud.mode = MBProgressHUDModeText;
                                             hud.labelText = NSLocalizedString(@"SendingSuccess", nil);
                                             [hud hide:YES afterDelay:1];
                                             
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [weakSelf.contacts addObjectsFromArray:addEntitys];
                                                 [weakSelf.tableView reloadData];
                                                 [[NSNotificationCenter defaultCenter]
                                                  postNotificationName:DWDNeedUpdateClassInnerGroup
                                                  object:nil];
                                             });
                                         }
         
                                         failure:^(NSError *error) {
                                             
                                             hud.mode = MBProgressHUDModeText;
                                             hud.labelText = NSLocalizedString(@"SendingFail", nil);
                                             [hud hide:YES afterDelay:1];
                                         }];
    }
    
    
}

- (void)contactSelectViewControllerDidSelectContactsForDelete:(NSArray *)contacts {
    
    NSMutableArray *deleteIds = [NSMutableArray arrayWithCapacity:contacts.count];
    NSMutableArray *deleteEntitys = [NSMutableArray arrayWithCapacity:contacts.count];
    
    for (NSDictionary *dicContact in contacts) {
        for (DWDGroupCustEntity *entity in self.contacts) {
            if ([entity.custId isEqualToNumber:dicContact[@"custId"]]) {
                [deleteEntitys addObject:entity];
            }
        }
        
        [deleteIds addObject:dicContact[@"custId"]];
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = NSLocalizedString(@"Sending", nil);
    
    __unsafe_unretained typeof(self) weakSelf = self;
    
    [self.client deleteMembersToClassInnerGroup:self.groupId
                                        classId:self.classId
                                         byUser:[DWDCustInfo shared].custId
                                    addContacts:deleteIds
    
                                        success:^{
                        
                                            hud.mode = MBProgressHUDModeText;
                                            hud.labelText = NSLocalizedString(@"SendingSuccess", nil);
                                            [hud hide:YES afterDelay:1];
                                            
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [weakSelf.contacts removeObjectsInArray:deleteEntitys];
                                                [weakSelf.tableView reloadData];
                                                [[NSNotificationCenter defaultCenter]
                                                 postNotificationName:DWDNeedUpdateClassInnerGroup
                                                 object:nil];
                                            });
                                        }
    
                                        failure:^(NSError *error) {
                                            
                                            hud.mode = MBProgressHUDModeText;
                                            hud.labelText = NSLocalizedString(@"SendingFail", nil);
                                            [hud hide:YES afterDelay:1];
                                        }];
}

@end
