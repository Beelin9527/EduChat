//
//  DWDContactsViewController.m
//  EduChat
//
//  Created by apple on 11/5/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDContactsViewController.h"
#import "DWDContactsClient.h"
#import "DWDContactCell.h"
#import "DWDContactHeaderCell.h"
#import "DWDContactHeaderDetailViewController.h"


@interface DWDContactsViewController () <UITableViewDataSource, UITableViewDelegate, DWDContactHeaderCellDelegate>

@property (strong, nonatomic) DWDContactsClient *client;
@property (strong, nonatomic) NSArray *contactsGroupData;

@property (strong, nonatomic) UIBarButtonItem *addContactItem;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DWDContactsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
   
    [self setupNavigation];
    [self setupTableView];
    
    _client = [[DWDContactsClient alloc] init];
    _contactsGroupData = [self.client getGroupedContacts:[DWDCustInfo shared].custId];
    
    [self reloadContacts:nil];
    
    [self.client updateContactsByCustemId:[DWDCustInfo shared].custId success:^{
        
         _contactsGroupData = [self.client getGroupedContacts:[DWDCustInfo shared].custId];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
    }];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reloadContacts:)
     name:DWDNeedReloadContactsNotification
     object:nil];
}
#pragma mark - Setup
- (void)setupNavigation
{
    self.navigationItem.rightBarButtonItem = [self buildPublicNavBarItem];
    
    self.navigationItem.title = NSLocalizedString(@"Contacts", nil);

}

- (void)setupTableView
{
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self.tableView registerClass:[DWDContactCell class] forCellReuseIdentifier:NSStringFromClass([DWDContactCell class])];
    [self.tableView registerClass:[DWDContactHeaderCell class] forCellReuseIdentifier:NSStringFromClass([DWDContactHeaderCell class])];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorColor = DWDColorSeparator;
    self.tableView.backgroundColor = DWDColorBackgroud;
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.contactsGroupData.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return 1;
        
    } else {
        
        NSDictionary *group = self.contactsGroupData[section - 1];
        NSArray *contacts = [[group allValues] lastObject];
        return contacts.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *lastCell;
    
    if (indexPath.section == 0) {
        
        DWDContactHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDContactHeaderCell class])];
        
        cell.actionDelegate = self;
        
        lastCell = cell;
        
    } else {
        
        DWDContactCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDContactCell class]) forIndexPath:indexPath];
        
        NSDictionary *group = self.contactsGroupData[indexPath.section - 1];
        
        NSDictionary *contact = [[group allValues] lastObject][indexPath.row];
        
        cell.avatarView.image = [UIImage imageNamed:@"AvatarOther"];
        
        NSString *remark = contact[@"remark"];
        if (remark) {
            cell.nicknameLable.text = remark;
        }
        else {
            cell.nicknameLable.text = contact[@"nickname"];
        }
        
        cell.status = DWDContactCellStatusDefault;
        
        lastCell = cell;
    }
    
    return lastCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 80;
    } else {
        return 60;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else {
        return 20;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return nil;
    } else {
        
        NSString *title = [[self.contactsGroupData[section - 1] allKeys] lastObject];
        
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, 20)];
        header.backgroundColor = DWDColorBackgroud;
        
        UILabel *headerLable = [[UILabel alloc] init];
        headerLable.frame = CGRectMake(10, 0, 20, 20);
        headerLable.font = DWDFontContent;
        headerLable.textColor = DWDColorContent;
        
        [header addSubview:headerLable];
        
        headerLable.text = title;
        
        return header;
    }
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //NSDictionary *currentLineData = self.datas[indexPath.row];
    // 备注
    UITableViewRowAction *remarksAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Remarks", nil) handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        DWDLog(@"do remarks");
    }];
    
    return @[remarksAction];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 ? NO : YES;
}

// we need this void method, you maybe want to konw why, i gone to tell you "i do not konw"
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}


- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:3];
    [result addObject:@"*"];
    
    for (NSDictionary *dic in self.contactsGroupData) {
        [result addObject:[[dic allKeys] lastObject]];
    }
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    if (indexPath.section != 0) {
//        
//        NSDictionary *group = self.contactsGroupData[indexPath.section - 1];
//        NSArray *contacts = [[group allValues] lastObject];
//        DWDContactsViewController *vc = [[DWDContactsViewController alloc] init];
//        
//        NSString *remark = [NSString stringWithFormat:@"%d",(int)[contacts lastObject][@"remark"]];
//        if (remark) {
//            vc.navigationItem.title = remark;
//        }
//        else {
//            vc.navigationItem.title = [NSString stringWithFormat:@"%d",(int)[contacts lastObject][@"nickname"]];
//        }
//        
//        [self.navigationController pushViewController:vc animated:YES];
//    }
   
}

#pragma mark - DWDContactHeaderCellDelegate methods
- (void)contactHeaderCellDidShowNewFriendsWithTitle:(NSString *)title {
    [self showDetailControllerByType:DWDContactHeaderShowTypeNewFriends withNavTitle:title];
}

- (void)contactHeaderCellDidShowGroupsWithTitle:(NSString *)title  {
    [self showDetailControllerByType:DWDContactHeaderShowTypeGroups withNavTitle:title];
}

- (void)contactHeaderCellDidShowClassesWithTitle:(NSString *)title  {
    [self showDetailControllerByType:DWDContactHeaderShowTypeClassed withNavTitle:title];
}

#pragma mark - private methods
- (void)showDetailControllerByType:(DWDContactHeaderShowType)type withNavTitle:(NSString *)title {
    DWDContactHeaderDetailViewController *vc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDContactHeaderDetailViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDContactHeaderDetailViewController class])];
    vc.showType = type;
    vc.navigationItem.title = title;
    [self.navigationController pushViewController:vc animated:YES];
}



- (void)reloadContacts:(NSNotification *)notification {
  _contactsGroupData = [self.client getGroupedContacts:[DWDCustInfo shared].custId];
  [self.tableView reloadData];
}
@end
