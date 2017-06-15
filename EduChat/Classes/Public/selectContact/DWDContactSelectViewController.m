//
//  DWDContactSelectAddViewController.m
//  EduChat
//
//  Created by Gatlin on 15/12/17.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDContactSelectViewController.h"

#import "DWDContactsDatabaseTool.h"
#import "DWDGroupClient.h"

#import "DWDClassMember.h"
#import "DWDGroupCustEntity.h"

#import "DWDLocalizedIndexedCollation.h"

#import <YYModel/YYModel.h>
@interface DWDContactSelectViewController ()

@property (strong, nonatomic) DWDContactsDatabaseTool *client;
@property (strong, nonatomic) DWDLocalizedIndexedCollation *collation;  //字母索引封装类


@end


@implementation DWDContactSelectViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"选择联系人";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithTitle:@"取消"
                                             style:UIBarButtonItemStylePlain
                                             target:self
                                             action:@selector(dismissViewControllerActoin:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@"确定"
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(dismissViewControllerActoin:)];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, DWDScreenH - DWDTopHight) style:UITableViewStylePlain];
    [self.tableView registerClass:[DWDContactCell class] forCellReuseIdentifier:NSStringFromClass([DWDContactCell class])];
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [[UIView alloc]init];
    [self.tableView setEditing:YES animated:YES];
    self.tableView.delegate= self;
    self.tableView.dataSource = self;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = DWDColorMain;
    [self.view addSubview:self.tableView];
    
    _client = [[DWDContactsDatabaseTool alloc] init];
    
    self.contactsGroupData = [NSMutableArray arrayWithCapacity:27];
    self.collation.arrDataSource = self.dataSource;
    self.contactsGroupData = self.collation.arrSectionsArray;


}

#pragma mark - Getter

-(NSMutableDictionary *)selectContacts
{
    if (!_selectContacts) {
        _selectContacts = [NSMutableDictionary dictionary];
    }
    return _selectContacts;
}
- (DWDLocalizedIndexedCollation *)collation
{
    if (!_collation) {
        _collation = [DWDLocalizedIndexedCollation currentCollation];
    }
    return _collation;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.contactsGroupData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [self.contactsGroupData[section] count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DWDContactCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDContactCell class])];
    
    NSDictionary *contact = self.contactsGroupData[indexPath.section][indexPath.row];
    
    [cell.avatarView sd_setImageWithURL:[NSURL URLWithString:contact[@"photoKey"]] placeholderImage:DWDDefault_MeBoyImage];
   
    NSString *remarkName = [[DWDPersonDataBiz new] checkoutExistRemarkName:contact[@"remarkName"] nickname:contact[@"nickname"]];
    
    cell.nicknameLable.text = remarkName;
    
    cell.status = DWDContactCellStatusDefault;
    
    NSNumber *selectId = [self.selectContacts objectForKey:[NSString stringWithFormat:@"%zd-%zd", indexPath.section, indexPath.row]];
    if (selectId) {
        cell.isMultEditingSelected = YES;
    }
    else {
        cell.isMultEditingSelected = NO;
    }
    
    cell.actionDelegate = self;
    cell.indexPath = indexPath;
    
    return cell;
}




- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return NO;
}
#pragma mark - TableView Delegate

/** 修改这里 设置分区高度、无数据的区设置为0 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([[self.contactsGroupData objectAtIndex:section] count] == 0)
    {
        return 0;
    }
    else{
        return 22;
    }
}

/** 设置区头名 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.collation.localizedIndexedCollation sectionTitles][section];
}

//设置区头颜色
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
    v.backgroundView.backgroundColor = DWDColorBackgroud;
}


/** 过滤无数据索引字母 */
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    //右边索引、这里去掉没有数据的索引字线
    NSMutableArray * existTitles = [NSMutableArray array];
    //section数组为空的title过滤掉，不显示
    for (int i = 0; i < [[self.collation.localizedIndexedCollation sectionTitles] count]; i++) {
        if ([[self.contactsGroupData objectAtIndex:i] count] > 0) {
            [existTitles addObject:[[self.collation.localizedIndexedCollation sectionTitles] objectAtIndex:i]];
        }
    }
    return existTitles;
    
}

/** 选择索引触发事件 */
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return [self.collation.localizedIndexedCollation sectionForSectionIndexTitleAtIndex:index];
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

#pragma mark - ContactCell Delegate
- (void)contactCellDidMutlEditingSelectedAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *contact = self.contactsGroupData[indexPath.section][indexPath.row];
    [self.selectContacts setObject:contact[@"custId"] forKey:[NSString stringWithFormat:@"%zd-%zd", indexPath.section, indexPath.row]];
   
     self.navigationItem.rightBarButtonItem.enabled = YES;
    DWDLog(@"select contacts : %@", [self.selectContacts allValues]);
}

- (void)contactCellDidMutlEditingDisselectedAtIndexPath:(NSIndexPath *)indexPath {
    [self.selectContacts removeObjectForKey:[NSString stringWithFormat:@"%zd-%zd", indexPath.section, indexPath.row]];
    
    //禁止“确定”按钮不交互
    if (self.selectContacts.allValues.count == 0) {
         self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark - private methods
-(void)dismissViewControllerActoin:(UIBarButtonItem*)sender
{
    if ([sender.title isEqualToString:@"确定"]) {
        
        if ([self.selectContacts allValues].count > 0) {
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(contactSelectViewControllerDidSelectContactsForIds:selectContactType:)]) {
                
                [self.delegate contactSelectViewControllerDidSelectContactsForIds:self.selectContacts.allValues selectContactType:self.type];
               
            }
        }

    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
