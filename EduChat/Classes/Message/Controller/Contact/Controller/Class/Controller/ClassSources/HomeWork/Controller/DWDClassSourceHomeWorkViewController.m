//
//  DWDClassSourceHomeWorkViewController.m
//  EduChat
//
//  Created by Superman on 15/11/26.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>
#import "DWDClassSourceHomeWorkViewController.h"
#import "DWDHomeWorkCell.h"
#import "DWDClassSetHomeWorkViewController.h"
#import "DWDHomeWorkClient.h"
#import "DWDHomeWorkDetailViewController.h"

@interface DWDClassSourceHomeWorkViewController () <UITableViewDataSource, UITableViewDelegate, DWDHomeWorkCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;

@property (strong, nonatomic) NSMutableArray *homeWorks;
@property (strong, nonatomic) NSMutableDictionary *multiEideStatus;
@property (strong, nonatomic) DWDHomeWorkClient *homeWorkCient;

@property (strong, nonatomic) NSNumber *page;
@property (strong, nonatomic) NSNumber *pageCount;
@property (nonatomic) BOOL hasNextPage;

@property (strong, nonatomic) MBProgressHUD *hud;
@property (nonatomic) BOOL isMultiEditing;


@end

@implementation DWDClassSourceHomeWorkViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"作业";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithImage:[UIImage imageNamed:@"ic_delete_dialogue_within_the_page_normal"]
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(rightBarBtnClick)];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DWDHomeWorkCell class]) bundle:nil]  forCellReuseIdentifier:NSStringFromClass([DWDHomeWorkCell class])];
    self.tableView.estimatedRowHeight = 61;
    self.view.backgroundColor = DWDColorBackgroud;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    _homeWorkCient = [[DWDHomeWorkClient alloc] init];
    __unsafe_unretained __typeof(self) weakSlef = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSlef reloadHomeWorks];
    }];
    [self.tableView.mj_header beginRefreshing];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reloadHomeWorks)
     name:DWDNeedUpateHomeWorkList
     object:nil];
}

- (void)rightBarBtnClick{
   
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    if (self.tableView.editing) {
        [self.bottomBtn setBackgroundImage:[UIImage imageNamed:@"btn_delete_homework_normal"] forState:UIControlStateNormal];
        [self.bottomBtn setTitle:@"删除作业" forState:UIControlStateNormal];
    }
    else {
        [self.bottomBtn setBackgroundImage:[UIImage imageNamed:@"btn_contacts_added"] forState:UIControlStateNormal];
        [self.bottomBtn setTitle:@"布置作业" forState:UIControlStateNormal];
    }
}

- (void)deleteHomeWorks {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    hud.labelText = NSLocalizedString(@"Sending", nil);
    
    NSArray *needDeleteKeys = self.multiEideStatus.allKeys;
    if (needDeleteKeys.count > 0) {
        NSMutableArray *deleteIds = [NSMutableArray arrayWithCapacity:needDeleteKeys.count];
        for (NSString *key in needDeleteKeys) {
            NSArray *indexPath = [key componentsSeparatedByString:@"-"];
            int section = [indexPath[0] intValue];
            int row = [indexPath[1] intValue];
            NSNumber *deleteHomeWorkId = self.homeWorks[section][@"homeworks"][row][@"id"];
            [deleteIds addObject:deleteHomeWorkId];
        }
        [self.homeWorkCient deleteHomeWorkBy:[DWDCustInfo shared].custId classId:self.classId homeWorkIds:deleteIds success:^{
            
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"SendingSuccess", nil);
            [hud hide:YES afterDelay:1];
            
            [self.bottomBtn setBackgroundImage:[UIImage imageNamed:@"btn_contacts_added"] forState:UIControlStateNormal];
            [self.bottomBtn setTitle:@"布置作业" forState:UIControlStateNormal];
            [self.tableView setEditing:NO animated:YES];
            
        } failure:^(NSError *error) {
            
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"SendingFail", nil);
            [hud hide:YES afterDelay:1];

        }];
    }

}

- (IBAction)bottomBtnClick:(id)sender {
    
    if (self.tableView.editing) {
        
        [self deleteHomeWorks];
    }
    
    else {
    
        DWDClassSetHomeWorkViewController *setHomeWorkVc = [[UIStoryboard storyboardWithName:NSStringFromClass([DWDClassSetHomeWorkViewController class]) bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([DWDClassSetHomeWorkViewController class])];
        setHomeWorkVc.classId = self.classId;
        [self.navigationController pushViewController:setHomeWorkVc animated:YES];
        
    }
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.homeWorks.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *dayHomeWorks = self.homeWorks[section][@"homeworks"];
    return dayHomeWorks.count;
}

- (DWDHomeWorkCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dayHomeWorks = self.homeWorks[indexPath.section];
    NSArray *homeWorks = dayHomeWorks[@"homeworks"];
    NSDictionary *rowData = homeWorks[indexPath.row];
    
    DWDHomeWorkCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDHomeWorkCell class])];
    cell.actionDelegate = self;
    cell.indexPath = indexPath;
    
    int subject = [rowData[@"subject"] intValue];
    switch (subject) {
        case 0:
            cell.iconView.image = [UIImage imageNamed:@"ic_chinese_operation_normal"];
            cell.homeWorkSubjectLabel.text = @"语文";
            
            break;
        
        case 1:
            cell.iconView.image = [UIImage imageNamed:@"ic_mathematics_operation_normal"];
            cell.homeWorkSubjectLabel.text = @"数学";
            
            break;
        
        case 2:
            cell.iconView.image = [UIImage imageNamed:@"ic_english_operation_normal"];
            cell.homeWorkSubjectLabel.text = @"英语";
            
            break;
            
        default:
            break;
    }
    cell.homeWorkLabel.text = rowData[@"title"];
    
    int status = [rowData[@"status"] intValue];
    if (status == 1) {
        cell.homeWorkLabel.textColor = DWDColorContent;
        cell.homeWorkSubjectLabel.textColor = DWDColorContent;
    }
    
    BOOL isMultiSelected =  [[self.multiEideStatus objectForKey:[NSString stringWithFormat:@"%zd-%zd", indexPath.section, indexPath.row]] boolValue];
    cell.isMultiSelected = isMultiSelected;
    
    return cell;
}
#pragma mark - <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *data = self.homeWorks[indexPath.section][@"homeworks"];
    NSNumber *homeWorkId = data[indexPath.row][@"homeworkId"];
    
    DWDLog(@"%@", homeWorkId);
    
    DWDHomeWorkDetailViewController *vc = [[DWDHomeWorkDetailViewController alloc] init];
    vc.homeWorkId = homeWorkId;
    vc.classId = self.classId;
    
    DWDLog(@"%@", self.classId);
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIImage *backImg;
    NSString *title;
    NSDictionary *dayHomeWorks = self.homeWorks[section];
    NSString *date = dayHomeWorks[@"date"];
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    fmt.dateFormat = @"YYYY-MM-dd";
    NSString *nowStr = [fmt stringFromDate:[NSDate date]];
    
    if ([nowStr isEqualToString:date]) {
        backImg = [UIImage imageNamed:@"bg_show_time_operation_today"];
        title = date;
    }
    else {
        backImg = [UIImage imageNamed:@"bg_show_time_operation_past"];
        title = date;
    }
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectZero];
    header.backgroundColor = [UIColor clearColor];
    
    UIImageView *backImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    UIImageView *dotImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    dotImgView.image = [UIImage imageNamed:@"point_work"];
    
    backImgView.image = backImg;
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.font = DWDFontContent;
    label.text = title;
    CGSize size = [label.text boundingRectWithSize:CGSizeMake(150, 99999)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName:label.font}
                                           context:nil].size;
    
    header.frame = CGRectMake(0, 0, DWDScreenW, size.height + 10 + 4);
    backImgView.frame = CGRectMake(0, 10, 150, size.height + 4);
    dotImgView.frame = CGRectMake(18, 0, 4, 4);
    label.frame = CGRectMake(30, 0, size.width, size.height);
    label.center = CGPointMake(label.center.x, backImgView.center.y);
    dotImgView.center = CGPointMake(dotImgView.center.x, backImgView.center.y);
    
    [header addSubview:backImgView];
    [header addSubview:dotImgView];
    [header addSubview:label];
    
    return header;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

#pragma mark - home work cell delegate
- (void)homeWorkCellDidMultiSelectAtIndexPath:(NSIndexPath *)indexPath {
    [self.multiEideStatus setObject:@1 forKey:[NSString stringWithFormat:@"%zd-%zd", indexPath.section, indexPath.row]];
}

- (void)homeWorkCellDidMultiDisselectAtIndexPath:(NSIndexPath *)indexPath {
    [self.multiEideStatus setObject:@0 forKey:[NSString stringWithFormat:@"%zd-%zd", indexPath.section, indexPath.row]];
}

#pragma mark - private methods
- (void)reloadHomeWorks {
    
    if (self.isMultiEditing) {
        [self.tableView.mj_header endRefreshing];
        return;
    }
    
    self.hud.labelColor = [UIColor whiteColor];
    self.hud.labelText = NSLocalizedString(@"Loading", nil);
    [self.hud show:YES];
    
    _page = @1;
    _pageCount = @10;
    _hasNextPage = NO;
    
    [self.homeWorkCient fetchHomeWorksBy:[DWDCustInfo shared].custId
                                classId:self.classId
                                   type:@0
                                   page:self.page
                              pageCount:self.pageCount
     
                                success:^(NSArray *homeWorks, BOOL hasNextPage) {
                                    
                                    self.hasNextPage = hasNextPage;
                                    if (self.hasNextPage) {
                                        if (!self.tableView.mj_footer) {
                                            __unsafe_unretained __typeof(self) weakSelf = self;
                                            self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                                                [weakSelf loadMoreHomeWorks];
                                            }];
                                        } else {
                                            self.tableView.mj_footer = nil;
                                        }
                                    }
                                    
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                        [self.hud hide:YES];
                                        [self.tableView.mj_header endRefreshing];
                                        self.homeWorks = [NSMutableArray arrayWithArray:homeWorks];
                                        
                                        [self.tableView reloadData];
                                    });

                                    
                                } failure:^(NSError *error) {
                                    
                                    self.hud.labelText = NSLocalizedString(@"LoadFail", nil);
                                    [self.hud hide:YES afterDelay:1];
                                    [self.tableView.mj_header endRefreshing];
                                }];
    
}

- (void)loadMoreHomeWorks {
    
    if (self.isMultiEditing) {
        [self.tableView.mj_footer endRefreshing];
        return;
    }
    
    if (self.hasNextPage) {
        
        self.page = [NSNumber numberWithInt:[self.page intValue] + 1];
        
        [self.homeWorkCient fetchHomeWorksBy:[DWDCustInfo shared].custId
                                    classId:@1 type:@1
                                       page:self.page
                                  pageCount:self.pageCount
                                    success:^(NSArray *homeWorks, BOOL hasNextPage) {
                                        
                                        if (homeWorks.count > 0) {
                                            self.hasNextPage = hasNextPage;
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [self.homeWorks addObjectsFromArray:homeWorks];
                                                [self.tableView.mj_footer endRefreshing];
                                                [self.tableView reloadData];
                                            });
                                        }

                                        
                                    } failure:^(NSError *error) {
                                        
                                        [self.hud show:YES];
                                        self.hud.labelText = NSLocalizedString(@"LoadFail", nil);
                                        self.hud.mode = MBProgressHUDModeText;
                                        [self.hud hide:YES afterDelay:1];

                                        
                                    }];
    }

}

@end
