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

#import "DWDContactModel.h"

#import "DWDClassDataBaseTool.h"

#import <YYModel/YYModel.h>

@interface DWDClassInnerGroupDetailViewController () <UITextFieldDelegate, DWDHeaderImgSortControlDelegate, DWDContactSelectViewControllerDelegate>

@property (strong, nonatomic) UITextField *field;
@property (strong, nonatomic) DWDHeaderImgSortControl *headerImgSortControl;
@property (strong, nonatomic) DWDClassInnerGroupClient *client;
@property (nonatomic, strong) UIAlertController *backAlertController;

@property (strong, nonatomic) NSMutableArray *selectArrayFlag;
@end

@implementation DWDClassInnerGroupDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popCurrentController) name:@"ClassInnerSaveButtonClick" object:nil];
    
    //非创建
    if (!self.isForCreate) {
        for (DWDContactModel *model in self.memberDataSource) {
            [self.selectArrayFlag addObject:model.custId];
        }
    }
   
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
   
    
}

- (void)popCurrentController {
    
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
            for ( DWDContactModel *contact in self.headerImgSortControl.arrItems) {
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

#pragma mark - Getter
- (NSMutableArray *)selectArrayFlag
{
    if (!_selectArrayFlag) {
        _selectArrayFlag = [NSMutableArray arrayWithCapacity:40];
    }
    return _selectArrayFlag;
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
        self.headerImgSortControl.arrItems = self.memberDataSource;
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
        headerImgSortControl.arrItems = self.memberDataSource;
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
    

   NSArray *classMembers = [[DWDClassDataBaseTool sharedClassDataBase] getClassMemberWithExcludeByMembersId:self.selectArrayFlag ClassId:self.classId myCustId:[DWDCustInfo shared].custId];
   
    vc.dataSource = classMembers;
    
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
    
    vc.dataSource = self.memberDataSource;
    
    DWDNavViewController *naviVC = [[DWDNavViewController alloc] initWithRootViewController:vc];
    [self.navigationController presentViewController:naviVC animated:YES completion:nil];
}


- (void)contactSelectViewControllerDidSelectContactsForIds:(NSArray *)contactsIds selectContactType:(DWDSelectContactType)type
{
    if (type == DWDSelectContactTypeAddEntity) {
        
        [self.selectArrayFlag addObjectsFromArray:contactsIds];
        
    }else if (type == DWDSelectContactTypeDeleteEntity){
        
        [self.selectArrayFlag removeObjectsInArray:contactsIds];
    }
    
    NSMutableArray *contactMedelMArray = [NSMutableArray arrayWithCapacity:40];
    //array 返回的是DWDClassMemberModel 模块
    NSArray *array = [[DWDClassDataBaseTool sharedClassDataBase] getClassMemberWithByMembersId:self.selectArrayFlag ClassId:self.classId myCustId:[DWDCustInfo shared].custId includeMian:@YES];
    
    //将DWDClassMemberModel 转成 DWDContactModel 模块
    NSArray *arrayJson =[array yy_modelToJSONObject];
    for (NSDictionary *dict in arrayJson) {
       DWDContactModel *contactModel = [DWDContactModel yy_modelWithDictionary:dict];
        [contactMedelMArray addObject:contactModel];

    }
    //赋值
    self.memberDataSource = contactMedelMArray;
    
    if (type == DWDSelectContactTypeAddEntity) {
        
        if (self.isForCreate) {
            [self.tableView reloadData];
        }else{
            
            //request 添加成员
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            
            __weak typeof(self) weakSelf = self;
            
            [self.client addMembersToClassInnerGroup:self.groupId
                                             classId:self.classId
                                              byUser:[DWDCustInfo shared].custId
                                         addContacts:contactsIds
                                             success:^{
                                                 
                                                 hud.mode = MBProgressHUDModeText;
                                                 hud.labelText = @"添加成功";
                                                 [hud hide:YES afterDelay:1];
                                                 
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                            
                                                     [weakSelf.tableView reloadData];
                                                     [[NSNotificationCenter defaultCenter]
                                                      postNotificationName:DWDNeedUpdateClassInnerGroup
                                                      object:nil];
                                                 });
                                             }
             
                                             failure:^(NSError *error) {
                                                 
                                                 hud.mode = MBProgressHUDModeText;
                                                 hud.labelText = @"添加成功";
                                                 [hud hide:YES afterDelay:1];
                                             }];
        }
        
    }else if (type == DWDSelectContactTypeDeleteEntity){
        
        if (self.isForCreate) {
            [self.tableView reloadData];
            
        }else{
            //request 删除成员
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
            __unsafe_unretained typeof(self) weakSelf = self;
            
            [self.client deleteMembersToClassInnerGroup:self.groupId
                                                classId:self.classId
                                                 byUser:[DWDCustInfo shared].custId
                                            addContacts:contactsIds
             
                                                success:^{
                                                    
                                                    hud.mode = MBProgressHUDModeText;
                                                    hud.labelText = @"删除成功";
                                                    [hud hide:YES afterDelay:1];
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        
                                                        [weakSelf.tableView reloadData];
                                                        [[NSNotificationCenter defaultCenter]
                                                         postNotificationName:DWDNeedUpdateClassInnerGroup
                                                         object:nil];
                                                    });
                                                }
             
                                                failure:^(NSError *error) {
                                                    
                                                    hud.mode = MBProgressHUDModeText;
                                                    hud.labelText = @"删除失败";
                                                    [hud hide:YES afterDelay:1];
                                                }];
 
        }
    }
    
}


#warning 保存新建编辑 待添加
#pragma mark - setter / getter
- (UIAlertController *)backAlertController {
    if (!_backAlertController) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"是否保存本次编辑?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionYes = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self rightBarButtonClick];
        }];
        UIAlertAction *actionNo = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertController addAction:actionYes];
        [alertController addAction:actionNo];
        
        _backAlertController = alertController;
    }
    return _backAlertController;
}

@end
