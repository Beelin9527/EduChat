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
#import "DWDHomeworksDetailViewController.h"
#import "DWDClassModel.h"
#import "DWDHomeWorkListCell.h"

#import "DWDIntelligentOfficeDataHandler.h"

@interface DWDClassSourceHomeWorkViewController () <UITableViewDataSource, UITableViewDelegate, DWDHomeWorkCellDelegate>
@property (weak, nonatomic) IBOutlet UIView *backgroundLineView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *bottomBtn;

@property (nonatomic, strong) UIBarButtonItem *rightBarButtonItem;
@property (nonatomic, weak) UIImageView *blankBackgroundImageView;

@property (strong, nonatomic) NSMutableArray *homeWorks;
@property (strong, nonatomic) NSMutableDictionary *multiEideStatus;
@property (strong, nonatomic) DWDHomeWorkClient *homeWorkCient;

@property (strong, nonatomic) NSNumber *page;
@property (strong, nonatomic) NSNumber *pageCount;
@property (nonatomic) BOOL hasNextPage;

@property (strong, nonatomic) MBProgressHUD *hud;
@property (nonatomic) BOOL isMultiEditing;
@property (nonatomic, assign) BOOL isCanSelected;
@property (nonatomic, strong) UIButton *deleBtn;

@end

@implementation DWDClassSourceHomeWorkViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"作业";
    
    //区分权限
    if([DWDCustInfo shared].isTeacher){
        //底部View
        self.bottomView.hidden = NO;
    }else{
        self.bottomView.hidden = YES;
    }
    
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
//    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DWDHomeWorkCell class]) bundle:nil]  forCellReuseIdentifier:NSStringFromClass([DWDHomeWorkCell class])];
//    self.tableView.estimatedRowHeight = 61;
    self.tableView.rowHeight = 61;
    self.view.backgroundColor = DWDColorBackgroud;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    _homeWorkCient = [[DWDHomeWorkClient alloc] init];
    __unsafe_unretained __typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf reloadHomeWorks];
    }];
    [self.tableView.mj_header beginRefreshing];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(reloadHomeWorks)
     name:DWDNeedUpateHomeWorkList
     object:nil];
    
    //检测此菜单功能是否点击过,key为menuCode
    NSString *key = [NSString stringWithFormat:@"%@-%@", [DWDCustInfo shared].custId, kDWDIntMenuCodeClassManagementHomework];
    NSString *obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (!obj) {
        [self requestGetAlertWithMenuCode:kDWDIntMenuCodeClassManagementHomework];
    }
}

- (void)rightBarBtnClick:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    
    self.isCanSelected = sender.selected;
    NSNumber *flag = sender.selected ? @1 : @0;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeEditStatus" object:nil userInfo:@{@"canSeleted" : flag, @"reset": @0}];
    if (self.isCanSelected) {
        [self.bottomBtn setBackgroundImage:[UIImage imageNamed:@"btn_delete_homework_normal"] forState:UIControlStateNormal];
        [self.bottomBtn setTitle:@"删除作业" forState:UIControlStateNormal];
    }
    else {
        [self.bottomBtn setBackgroundImage:[UIImage imageNamed:@"btn_contacts_added"] forState:UIControlStateNormal];
        [self.bottomBtn setTitle:@"布置作业" forState:UIControlStateNormal];
    }
}

- (void)deleteHomeWorks {
    
    DWDProgressHUD *hud = [DWDProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSMutableArray *needDeleteKeys = [NSMutableArray arrayWithCapacity:0];
    
    for (NSString *key in self.multiEideStatus.allKeys) {
        if ([_multiEideStatus[key] boolValue]) {
            [needDeleteKeys addObject:key];
        }
    }
    
    if (needDeleteKeys.count > 0) {
        
        hud.labelText = @"正在删除...";
        NSMutableArray *deleteIds = [NSMutableArray arrayWithCapacity:needDeleteKeys.count];
        for (NSString *key in needDeleteKeys) {
            NSArray *indexPath = [key componentsSeparatedByString:@"-"];
            int section = [indexPath[0] intValue];
            int row = [indexPath[1] intValue];
            NSNumber *deleteHomeWorkId = self.homeWorks[section][@"homeworks"][row][@"homeworkId"];
            [deleteIds addObject:deleteHomeWorkId];
        }
        [self.homeWorkCient deleteHomeWorkBy:[DWDCustInfo shared].custId classId:self.classId homeWorkIds:deleteIds success:^{
            
            // hud提示
            hud.mode = MBProgressHUDModeText;
            hud.labelText = NSLocalizedString(@"删除成功", nil);
            [hud hide:YES afterDelay:1];
            
            // 回到默认状态
            self.deleBtn.selected = NO;
            self.isCanSelected = NO;
            [self.multiEideStatus removeAllObjects];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeEditStatus" object:nil userInfo:@{@"canSeleted" : @0, @"reset": @1}];

            [self.bottomBtn setBackgroundImage:[UIImage imageNamed:@"btn_contacts_added"] forState:UIControlStateNormal];
            [self.bottomBtn setTitle:@"布置作业" forState:UIControlStateNormal];
            [self.tableView.mj_header beginRefreshing];
            
        } failure:^(NSError *error) {
            
            // hud提示
            hud.mode = MBProgressHUDModeText;
            hud.labelText = error.localizedFailureReason;
            [hud hide:YES afterDelay:1];
            
            // 回到默认状态
            self.deleBtn.selected = NO;
            self.isCanSelected = NO;
            [self.multiEideStatus removeAllObjects];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeEditStatus" object:nil userInfo:@{@"canSeleted" : @0, @"reset": @1}];
            
            [self.bottomBtn setBackgroundImage:[UIImage imageNamed:@"btn_contacts_added"] forState:UIControlStateNormal];
            [self.bottomBtn setTitle:@"布置作业" forState:UIControlStateNormal];

        }];
    }else {
        hud.labelText = @"请选择您要删除的作业!";
        [hud hide:YES afterDelay:0.5];
    }

}

- (IBAction)bottomBtnClick:(id)sender {
    
    if (self.isCanSelected) {
        
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
    
    if (!self.homeWorks.count) {
        [self.blankBackgroundImageView setNeedsDisplay];
        self.backgroundLineView.hidden = YES;
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        [self.blankBackgroundImageView removeFromSuperview];
        self.backgroundLineView.hidden = NO;
        if ([DWDCustInfo shared].isTeacher) {
            self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
        }
    }
    return self.homeWorks.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *dayHomeWorks = self.homeWorks[section][@"homeworks"];
    if (!dayHomeWorks.count) {
        [self.blankBackgroundImageView setNeedsDisplay];
        self.backgroundLineView.hidden = YES;
        self.navigationItem.rightBarButtonItem = nil;
    } else {
        [self.blankBackgroundImageView removeFromSuperview];
        self.backgroundLineView.hidden = NO;
        if ([DWDCustInfo shared].isTeacher) {
            self.navigationItem.rightBarButtonItem = self.rightBarButtonItem;
        }
    }
    return dayHomeWorks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *dayHomeWorks = self.homeWorks[indexPath.section];
    NSArray *homeWorks = dayHomeWorks[@"homeworks"];
    NSDictionary *rowData = homeWorks[indexPath.row];
    
//    DWDHomeWorkCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDHomeWorkCell class])];
//    cell.actionDelegate = self;
//    cell.indexPath = indexPath;
    
    static NSString *ID = @"homeWorkListCell";
    DWDHomeWorkListCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[DWDHomeWorkListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.actionDelegate = self;
    cell.indexPath = indexPath;
    int subject = [rowData[@"subject"] intValue];
    switch (subject) {
        case 1:
            cell.iconView.image = [UIImage imageNamed:@"ic_chinese_operation_normal"];
            cell.homeWorkSubjectLabel.text = @"语文";
            break;
        case 2:
            cell.iconView.image = [UIImage imageNamed:@"ic_mathematics_operation_normal"];
            cell.homeWorkSubjectLabel.text = @"数学";
            break;
        case 3:
            cell.iconView.image = [UIImage imageNamed:@"ic_english_operation_normal"];
            cell.homeWorkSubjectLabel.text = @"英语";
            break;
        case 4:
            cell.iconView.image = [UIImage imageNamed:@"ic_art_operation_normal"];
            cell.homeWorkSubjectLabel.text = @"美术";
            break;
        case 5:
            cell.iconView.image = [UIImage imageNamed:@"ic_music_operation_normal"];
            cell.homeWorkSubjectLabel.text = @"音乐";
            break;
        case 6:
            cell.iconView.image = [UIImage imageNamed:@"ic_other_operation_normal"];
            cell.homeWorkSubjectLabel.text = @"其他";
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
    cell.selectBtn.selected = isMultiSelected;
    cell.canSelected = self.isCanSelected;
    return cell;
}
#pragma mark - <UITableViewDelegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *data = self.homeWorks[indexPath.section][@"homeworks"];
    NSNumber *homeWorkId = data[indexPath.row][@"homeworkId"];
    
    NSDictionary *dayHomeWorks = self.homeWorks[indexPath.section];
    NSArray *homeWorks = dayHomeWorks[@"homeworks"];
    NSDictionary *rowData = homeWorks[indexPath.row];

    WEAKSELF;
    DWDHomeworksDetailViewController *vc = [[DWDHomeworksDetailViewController alloc] init];
    vc.homeWorkId = homeWorkId;
    vc.classId = self.classId;
    vc.classModel = self.classModel;
    vc.subject = rowData[@"subject"];
    vc.popBlock = ^{
        [weakSelf reloadHomeWorks];
    };
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

//- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
//    return NO;
//}

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewCellEditingStyleNone;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == self.homeWorks.count - 1) {
        return 10;
    }
    return 0.000001;
}

#pragma mark - home work cell delegate
- (void)homeWorkCellDidMultiSelectAtIndexPath:(NSIndexPath *)indexPath {
    [self.multiEideStatus setObject:@1 forKey:[NSString stringWithFormat:@"%zd-%zd", indexPath.section, indexPath.row]];
}

- (void)homeWorkCellDidMultiDisselectAtIndexPath:(NSIndexPath *)indexPath {
    [self.multiEideStatus setObject:@0 forKey:[NSString stringWithFormat:@"%zd-%zd", indexPath.section, indexPath.row]];
}

- (NSMutableDictionary *)multiEideStatus
{
    if (!_multiEideStatus) {
        _multiEideStatus = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _multiEideStatus;
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
                                    [self.homeWorks addObjectsFromArray:homeWorks];
                                    self.hasNextPage = hasNextPage;
                                    if (self.hasNextPage) {
                                        if (!self.tableView.mj_footer) {
                                            __unsafe_unretained __typeof(self) weakSelf = self;
                                            self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
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
//                                    self.homeWorks = nil;
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self.tableView reloadData];
                                    });
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
                                    classId:self.classId
                                        type:@0
                                       page:self.page
                                  pageCount:self.pageCount
                                    success:^(NSArray *homeWorks, BOOL hasNextPage) {
                                        
                                        if (homeWorks.count > 0) {
                                            self.hasNextPage = hasNextPage;
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                for (NSDictionary *homeworkDic in homeWorks) {
                                                    if ([(NSArray *)homeworkDic[@"homeworks"] count] > 0) {
                                                        [self.homeWorks addObject:homeworkDic];
                                                    }
                                                }
//                                                [self.homeWorks addObjectsFromArray:homeWorks];
                                                [self.tableView.mj_footer endRefreshing];
                                                [self.tableView reloadData];
                                            });
                                        }

                                        
                                    } failure:^(NSError *error) {
                                        
                                        [self.hud show:YES];
                                        self.hud.labelText = NSLocalizedString(@"LoadFail", nil);
                                        self.hud.mode = MBProgressHUDModeText;
                                        [self.hud hide:YES afterDelay:1];
                                        
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [self.tableView reloadData];
                                        });
                                        
                                    }];
    }else {
        [self.tableView.mj_footer endRefreshing];
    }

}

- (UIImageView *)blankBackgroundImageView {
    if (!_blankBackgroundImageView) {
        UIImageView *blankBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"msg_task_no_data"]];
        
        blankBackgroundImageView.frame = CGRectMake(DWDScreenW * 0.5 - pxToW(316) * 0.5, pxToH(330), pxToW(316), pxToH(377));
        [self.view addSubview:blankBackgroundImageView];
        _blankBackgroundImageView = blankBackgroundImageView;
    }
    return _blankBackgroundImageView;
}

- (UIBarButtonItem *)rightBarButtonItem {
    if (!_rightBarButtonItem) {
        
        UIButton *deleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleBtn setImage:[UIImage imageNamed:@"ic_delete_dialogue_within_the_page_normal"] forState:UIControlStateNormal];
        [deleBtn addTarget:self action:@selector(rightBarBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        deleBtn.frame = CGRectMake(0, 0, 30, 35);
        _deleBtn = deleBtn;
        _rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:deleBtn];
    }
    return _rightBarButtonItem;
}

#pragma mark - Request Data
- (void)requestGetAlertWithMenuCode:(NSString *)code{
    [DWDIntelligentOfficeDataHandler requestGetAlertWithCid:[DWDCustInfo shared].custId sid:self.classModel.schoolId mncd:code sta:nil targetController:self success:^{
        
    } failure:^(NSError *error) {
        
    }];
}
@end
