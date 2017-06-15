//
//  DWDClassGagSelectViewController.m
//  EduChat
//
//  Created by Beelin on 16/11/15.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDClassGagSelectViewController.h"

@interface DWDClassGagSelectViewController ()
@property (nonatomic, strong) UIButton *allParentBtn;
@property (nonatomic, strong) UIButton *allTeacherBtn;

@property (nonatomic, strong) NSMutableArray *selectParentArray;
@property (nonatomic, strong) NSMutableArray *selectTeacherArray;
@end

@implementation DWDClassGagSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.type == DWDSelectContactTypeAddEntity) {
        self.title = @"新增禁言成员";
    }else{
         self.title = @"解除禁言";
    }
    [self createControls];
    self.tableView.frame = CGRectMake(0,35, DWDScreenW, DWDScreenH - DWDTopHight - 35);
    self.tableView.backgroundColor = DWDColorBackgroud;
}

#pragma mark - Create
- (void)createControls{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, 35)];
    headerView.backgroundColor = DWDColorBackgroud;
    [self.view insertSubview:headerView aboveSubview:self.tableView];
    
    CGFloat btnW = 82;
    CGFloat btnH = 34;
    [headerView addSubview:({
        _allParentBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(DWDScreenW/2 - 13 - btnW, 10, btnW, btnH);
            [btn setTitle:@"全部家长" forState:UIControlStateNormal];
            [btn setTitleColor:DWDColorMain forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            
            [btn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageWithColor:DWDColorMain] forState:UIControlStateSelected];
            
            btn.adjustsImageWhenHighlighted = NO;
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = btn.h/2;
            btn.layer.borderColor = DWDColorMain.CGColor;
            btn.layer.borderWidth = 1;
            [btn addTarget:self action:@selector(checkAllParentAction:) forControlEvents:UIControlEventTouchDown];
            btn;
        });
    })];
    [headerView addSubview:({
        _allTeacherBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
             btn.frame = CGRectMake(DWDScreenW/2 + 13 , 10, btnW, btnH);
            [btn setTitle:@"全部老师" forState:UIControlStateNormal];
            [btn setTitleColor:DWDColorMain forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [btn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageWithColor:DWDColorMain] forState:UIControlStateSelected];
            
            btn.adjustsImageWhenHighlighted = NO;
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            btn.layer.masksToBounds = YES;
            btn.layer.cornerRadius = btn.h/2;
            btn.layer.borderColor = DWDColorMain.CGColor;
            btn.layer.borderWidth = 1;
             [btn addTarget:self action:@selector(checkAllTeacherAction:) forControlEvents:UIControlEventTouchUpInside];
            btn;
        });
    })];
}

#pragma mark - Getter
- (NSMutableArray *)selectParentArray{
    if (!_selectParentArray) {
        _selectParentArray = [NSMutableArray array];
    }
    return _selectParentArray;
}
- (NSMutableArray *)selectTeacherArray{
    if (!_selectTeacherArray) {
        _selectTeacherArray = [NSMutableArray array];
    }
    return _selectTeacherArray;
}

#pragma mark - Event Response
- (void)checkAllParentAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        //clean array
        [self.selectParentArray removeAllObjects];
    
        for (int i = 0; i < self.contactsGroupData.count; i ++) {
            NSArray *dataSection = self.contactsGroupData[i];
            for (int j = 0; j < dataSection.count; j ++) {
                @autoreleasepool {
                    NSMutableDictionary *contact = dataSection[j];
                    if ([contact[@"isManager"] isEqualToNumber:@0]) {
                        [contact setValue:@1 forKey:@"isSelect"];
                        [self.selectParentArray addObject:contact[@"custId"]];
                    }
                }
            }
        }
        
        if (self.selectParentArray.count || self.selectTeacherArray.count) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }else{
        
        for (int i = 0; i < self.contactsGroupData.count; i ++) {
            NSArray *dataSection = self.contactsGroupData[i];
            for (int j = 0; j < dataSection.count; j ++) {
                @autoreleasepool {
                    NSMutableDictionary *contact = dataSection[j];
                    if ([contact[@"isManager"] isEqualToNumber:@0]) {
                        [contact setValue:@0 forKey:@"isSelect"];
                    }
                }
            }
        }
        [self.selectParentArray removeAllObjects];
        
        if (self.selectParentArray.count == 0 && self.selectTeacherArray.count == 0) {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
    
    [self.tableView reloadData];
    
}
- (void)checkAllTeacherAction:(UIButton *)sender{
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        //clean array
        [self.selectTeacherArray removeAllObjects];
        
        for (int i = 0; i < self.contactsGroupData.count; i ++) {
            NSArray *dataSection = self.contactsGroupData[i];
            for (int j = 0; j < dataSection.count; j ++) {
                @autoreleasepool {
                    NSMutableDictionary *contact = dataSection[j];
                    if ([contact[@"isManager"] isEqualToNumber:@1]) {
                        [contact setValue:@1 forKey:@"isSelect"];
                        [self.selectTeacherArray addObject:contact[@"custId"]];
                    }
                }
            }
        }
        
        if (self.selectParentArray.count || self.selectTeacherArray.count) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }else{
        for (int i = 0; i < self.contactsGroupData.count; i ++) {
            NSArray *dataSection = self.contactsGroupData[i];
            for (int j = 0; j < dataSection.count; j ++) {
                @autoreleasepool {
                    NSMutableDictionary *contact = dataSection[j];
                    if ([contact[@"isManager"] isEqualToNumber:@1]) {
                        [contact setValue:@0 forKey:@"isSelect"];
                    }
                }
            }
        }
        [self.selectTeacherArray removeAllObjects];
        
        if (self.selectParentArray.count == 0 && self.selectTeacherArray.count == 0) {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
    
    [self.tableView reloadData];
}

-(void)dismissViewControllerActoin:(UIBarButtonItem*)sender
{
    if ([sender.title isEqualToString:@"确定"]) {
        NSMutableArray *contacts = [NSMutableArray array];
        [contacts addObjectsFromArray:self.selectTeacherArray];
        [contacts addObjectsFromArray:self.selectParentArray];
    
        if (contacts.count > 0) {
           NSString *alertStr = self.type == DWDSelectContactTypeAddEntity ? @"已选择的成员不允许在班级里发言" : @"已选择的成员将允许在班级里发言";
             UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:alertStr preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(contactSelectViewControllerDidSelectContactsForIds:selectContactType:)]) {
                    
                    [self.delegate contactSelectViewControllerDidSelectContactsForIds:contacts selectContactType:self.type];
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }
                
            }];
            UIAlertAction *cancleaction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                return ;
            }];
            [alertVc addAction:action];
            [alertVc addAction:cancleaction];
            
            [self presentViewController:alertVc animated:YES completion:nil];
        }
        
    }else{
        //取消
         [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}


#pragma mark - TableView DataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DWDContactCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDContactCell class])];
    
    NSMutableDictionary *contact = self.contactsGroupData[indexPath.section][indexPath.row];
    [cell.avatarView sd_setImageWithURL:[NSURL URLWithString:contact[@"photoKey"]] placeholderImage:DWDDefault_MeBoyImage];
    
    NSString *remarkName = [[DWDPersonDataBiz new] checkoutExistRemarkName:contact[@"remarkName"] nickname:contact[@"nickname"]];
    cell.nicknameLable.text = remarkName;
    
    if ([contact[@"isManager"] isEqualToNumber:@1]) {
        cell.identityLabel.text = @"老师";
        cell.identityLabel.backgroundColor = UIColorFromRGB(0x05c9e7);
    }else{
        cell.identityLabel.text = @"家长";
        cell.identityLabel.backgroundColor = UIColorFromRGB(0xffc000);
    }
    
    if ([contact[@"isSelect"] isEqualToNumber:@1] ) {
        cell.isMultEditingSelected = YES;
    }else{
        cell.isMultEditingSelected = NO;
    }
    
    cell.status = DWDContactCellStatusDefault;
    
    cell.actionDelegate = self;
    cell.indexPath = indexPath;
    
    return cell;
}


#pragma mark - ContactCell Delegate
- (void)contactCellDidMutlEditingSelectedAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *contact = self.contactsGroupData[indexPath.section][indexPath.row];
    [contact setValue:@1 forKey:@"isSelect"];
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    if ([contact[@"isManager"] isEqualToNumber:@1]) {
        //add selectTeacherArray select object
        [self.selectTeacherArray addObject:contact[@"custId"]];
        //当allTeacherBtn 是选中状态，要设置为不选中状态
        if (self.allTeacherBtn.selected) {
            self.allTeacherBtn.selected = NO;
        }
    }else{
        //add selectParentArray select object
        [self.selectParentArray addObject:contact[@"custId"]];
        //当allParentBtn 是选中状态，要设置为不选中状态
        if (self.allParentBtn.selected) {
            self.allParentBtn.selected = NO;
        }
    }
}

- (void)contactCellDidMutlEditingDisselectedAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *contact = self.contactsGroupData[indexPath.section][indexPath.row];
    [contact setValue:@0 forKey:@"isSelect"];
    
    if ([contact[@"isManager"] isEqualToNumber:@1]) {
        //remove selectTeacherArray cancle object
        [self.selectTeacherArray removeObject:contact[@"custId"]];
        //当allTeacherBtn 是选中状态，要设置为不选中状态
        if (self.allTeacherBtn.selected) {
            self.allTeacherBtn.selected = NO;
        }
    }else{
        //remove selectParentArray cancle object
        [self.selectParentArray removeObject:contact[@"custId"]];
        //当allParentBtn 是选中状态，要设置为不选中状态
        if (self.allParentBtn.selected) {
            self.allParentBtn.selected = NO;
        }
    }
    
    //禁止“确定”按钮不交互
    if (self.selectTeacherArray.count == 0 && self.selectParentArray.count == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

@end
