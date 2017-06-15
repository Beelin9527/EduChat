//
//  DWDPickUpCenterTimeLineTableViewController.m
//  EduChat
//
//  Created by KKK on 16/3/18.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPickUpCenterTimeLineTableViewController.h"
#import "DWDPickUpCenterTimeLineModalDetailViewController.h"
#import "DWDPickUpCenterTimeLineTransitionDelegate.h"


#import "DWDPickUpCenterTimeLineGoSchoolCell.h"
#import "DWDPickUpCenterTimeLineLeaveSchoolCell.h"
#import "DWDPickUpCenterBackgroundContainerView.h"
#import "DWDPickUpCenterTimeLineHeaderView.h"

#import "DWDPUCLoadingView.h"

#import "DWDPickUpCenterDatabaseTool.h"
#import "DWDTeacherGoSchoolInfoModel.h"
#import "DWDTeacherGoSchoolStudentDetailModel.h"
#import "DWDPickUpCenterStudentsCountModel.h"

#import "NSString+extend.h"
#import "NSDictionary+dwd_extend.h"
#import "NSDate+dwd_dateCategory.h"

#import <YYModel.h>

#define windowWH pxToW(120)

@interface DWDPickUpCenterTimeLineTableViewController () <DWDPickUpCenterTimeLineModalDetailViewControllerDelegate, DWDPUCLoadingViewDelegate>

@property (nonatomic, weak) UIView *lineView;

@property (nonatomic, weak) DWDPickUpCenterBackgroundContainerView *blankView;

@property (nonatomic, strong) NSArray *goSchoolArray;

@property (nonatomic, strong) NSArray *displayGoSchoolArray;

@property (nonatomic, strong) NSArray *leaveSchoolArray;

@property (nonatomic, strong) NSArray *displayLeaveSchoolArray;

@property (nonatomic, strong) NSArray *totalStudentsArray;

@property (nonatomic, copy) NSString *currentDate;


@property (nonatomic, weak) UIView *totalStudentsView;
@property (nonatomic, strong) UILabel *totalStudentsLabel;

@property (nonatomic, weak) DWDPUCLoadingView *loadingView;

@end

@implementation DWDPickUpCenterTimeLineTableViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //register cell
    [self.tableView registerClass:[DWDPickUpCenterTimeLineGoSchoolCell class]
           forCellReuseIdentifier:@"DWDPickUpCenterTimeLineGoSchoolCell"];
    [self.tableView registerClass:[DWDPickUpCenterTimeLineLeaveSchoolCell class]
           forCellReuseIdentifier: @"DWDPickUpCenterTimeLineLeaveSchoolCell"];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(modalDetailViewWithNotification:) name:@"modalDetailViewWithNotification"
                                               object:nil];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _totalStudentsView.frame = CGRectMake(self.view.superview.bounds.size.width - windowWH - pxToW(30), self.view.superview.bounds.size.height - windowWH - pxToW(30), windowWH, windowWH);
    _totalStudentsView.hidden = NO;
    _totalStudentsLabel.hidden = NO;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _totalStudentsLabel.center = CGPointMake(windowWH / 2.0f, windowWH / 2.0f);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //    _totalStudentsView.hidden = YES;
    //    _totalStudentsLabel.hidden = YES;
    //    
    //    [_totalStudentsView removeFromSuperview];
    //    [_totalStudentsLabel removeFromSuperview];
    //    
    //    _totalStudentsView = nil;
    //    _totalStudentsLabel = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"modalDetailViewWithNotification" object:nil];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Method
- (void)reloadDataWithDate:(NSString *)dateStr {
    
    [self postRequestStudentWithDate:(NSString *)dateStr];
}

#pragma mark - Private Method
- (void)postRequestStudentWithDate:(NSString *)dateStr {
    _currentDate = dateStr;
//    [[HttpClient sharedClient] cancelTaskWithApi:@"ClassRestService/getAttendancerate"];
    
    //    - 从数据库中取数据
    //      - 有数据 给数据<数组>
    //          - 直接展示
    //      - 数据库中没数据
    //          - 发请求 然后判断是不是当天
    //              - 是当天
    //                  - 直接展示
    //              - 不是当天
    //                  - 存到数据库 然后展示
    
    NSArray *array = [[DWDPickUpCenterDatabaseTool sharedManager] selectCalendarWithDate:dateStr withClassId:self.classId];
    DWDPUCLoadingView *loadingView;
    if (array != nil) {
        //    if (0) {
        [_loadingView removeFromSuperview];
        [self calculateDataWithArray:array dataStr:dateStr];
        _loadingView = nil;
        _requestSucceed = YES;
    } else {
        
        if (_loadingView == nil) {
            [_blankView removeFromSuperview];
            //310 * 271
            loadingView = [[DWDPUCLoadingView alloc] initWithFrame:(CGRect){(DWDScreenW - 310 * 0.5) * 0.5, (DWDScreenH - 271 + 20 +46 * 0.5) * 0.5 - 64, 310 * 0.5, 271 + 20 + 46 * 0.5}];
            loadingView.delegate = self;
            //        loadingView.center = self.tableView.center;
            [self.tableView insertSubview:loadingView aboveSubview:self.tableView];
            loadingView.layer.zPosition = MAXFLOAT;
            _loadingView = loadingView;
        }
        
        NSDictionary *params = @{
                                 @"classId" : self.classId,
                                 @"custId" : [DWDCustInfo shared].custId,
                                 @"date" : dateStr
                                 };
        WEAKSELF;
        [[HttpClient sharedClient] getPickUpCenterTimeLineStudentsStatusWithParams:params success:^(NSURLSessionDataTask *task, id responseObject) {
            DWDMarkLog(@"punch timeline student Succeed");
            [weakSelf.loadingView removeFromSuperview];
            weakSelf.requestSucceed = YES;
            weakSelf.loadingView = nil;
            NSArray *ar = [NSArray yy_modelArrayWithClass:[DWDPickUpCenterStudentsCountModel class]
                                                     json:responseObject[@"data"]];
            //              - 不是当天
            //                  - 存到数据库
            NSDateFormatter *formatter = [NSDateFormatter new];
            formatter.locale = [NSLocale currentLocale];
            formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
            NSDate *selectDate = [formatter dateFromString:[dateStr stringByAppendingString:@" 00:00:00"]];
            if ([selectDate compare:[NSDate date]] == NSOrderedAscending//NSOrderedDescending
                ) {
                //存到数据库
                if (![selectDate isToday]) {
                    [[DWDPickUpCenterDatabaseTool sharedManager] insertCalendarRequest:ar
                                                                                  date:dateStr
                                                                           withClassId:weakSelf.classId];
                }
            }
            [weakSelf calculateDataWithArray:ar dataStr:dateStr];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            DWDMarkLog(@"punch timeline student Failed");
            weakSelf.requestSucceed = NO;

            if (weakSelf.state == 0) {
                weakSelf.displayGoSchoolArray = nil;
            } else {
                weakSelf.displayLeaveSchoolArray = nil;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                //            [weakSelf caculateInfoModelWithTotalArray:ar];
                if ([weakSelf.loadingView respondsToSelector:@selector(changeToFailedView)]) {
                    [weakSelf.loadingView changeToFailedView];
                }
                [weakSelf.tableView reloadData];
            });
        }];
    }
}
- (void)calculateDataWithArray:(NSArray *)array dataStr:(NSString *)dateStr {
    [self setupBottomView];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (self.state == 0) {
            //上学
            self.goSchoolArray = [[DWDPickUpCenterDatabaseTool sharedManager] selectTimelineWhichDate:dateStr type:@1 teacherDataBaseWithClassId:self.classId];
            self.displayGoSchoolArray = [self formatDisplayArrayWithArray:self.goSchoolArray];
        } else {
            //放学
            self.leaveSchoolArray = [[DWDPickUpCenterDatabaseTool sharedManager] selectTimelineWhichDate:dateStr type:@2 teacherDataBaseWithClassId:self.classId];
            self.displayLeaveSchoolArray = [self formatDisplayArrayWithArray:self.leaveSchoolArray];
        }
        if (array.count) {
            DWDPickUpCenterStudentsCountModel *model = array[0];
            _totalStudentsLabel.text = [NSString stringWithFormat:@"%zd人\n总人数", model.memberNum];
        } else {
            _totalStudentsLabel.text = @"0人\n总人数";
        }
        
        self.totalStudentsArray = [self totalArrayRemoveSpecialObjects:array];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.totalStudentsLabel sizeToFit];
            [self.totalStudentsLabel setNeedsDisplay];
            [self.tableView reloadData];
        });
        
    });
}

- (void)setupBottomView {
    if (!_totalStudentsView) {
        UIView *totalStudentsView = [[UIView alloc] initWithFrame:CGRectMake(self.view.superview.bounds.size.width - windowWH - pxToW(30), self.view.superview.bounds.size.height - windowWH - pxToW(30), windowWH, windowWH)];
        self.totalStudentsView = totalStudentsView;
        [self.view.superview insertSubview:totalStudentsView aboveSubview:self.view];
        totalStudentsView.backgroundColor = DWDRGBColor(0, 187, 157);
        totalStudentsView.layer.opacity = 0.9;
        totalStudentsView.layer.cornerRadius = windowWH / 2.0;
        totalStudentsView.layer.masksToBounds = YES;
        totalStudentsView.layer.zPosition = MAXFLOAT;
        
        UILabel *totalStudentsLabel = [UILabel new];
        totalStudentsLabel.font = [UIFont systemFontOfSize:14];
        totalStudentsLabel.textColor = [UIColor whiteColor];
        totalStudentsLabel.numberOfLines = 0;
        totalStudentsLabel.preferredMaxLayoutWidth = sqrt((windowWH / 2.0) * (windowWH / 2.0) * 2);
        totalStudentsLabel.textAlignment = NSTextAlignmentCenter;
        self.totalStudentsLabel = totalStudentsLabel;
        [totalStudentsView addSubview:totalStudentsLabel];
        [totalStudentsView bringSubviewToFront:totalStudentsLabel];
        
    }
}

- (NSArray *)totalArrayRemoveSpecialObjects:(NSArray *)array {
    NSMutableArray *mAr = [NSMutableArray array];
    NSArray *currentArray;
    if (_state == 0) {
        currentArray = self.displayGoSchoolArray;
    } else {
        currentArray = self.displayLeaveSchoolArray;
    }
    if (!currentArray.count) {
        return mAr;
    }
    
    for (int i = 0; i < array.count; i ++) {
        DWDTeacherGoSchoolStudentDetailModel *detailModel = array[i];
        for (NSArray *modelArray in currentArray) {
            DWDPickUpCenterDataBaseModel *model = [modelArray[0] allValues][0][0];
            if ([model.index isEqualToNumber:detailModel.index]) {
                [mAr addObject:array[i]];
                break;
            }
        }
    }
    return mAr;
    
}

- (NSArray *)formatIndexArrayWithDataBaseArray:(NSArray *)array {
    NSMutableArray *resultArray = [NSMutableArray new];
    
    NSArray *groups = [array valueForKeyPath:@"index"];
    for (NSNumber *index in groups) {
        
        NSMutableDictionary *entry = [NSMutableDictionary new];
        NSArray *grouNames = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"index = %@", index]];
        
        BOOL exists = NO;
        for (NSDictionary *dict in resultArray) {
            if ([dict containsKey:index.stringValue]) {
                exists = YES;
                break;
            }
        }
        if (!exists) {
            [entry setValue:grouNames forKey:index.stringValue];
            [resultArray addObject:entry];
        }
    }
    return [self sortIndexArray:resultArray];
}

- (NSArray *)formatDisplayArrayWithArray:(NSArray *)array {
    NSMutableArray *resultArray = [NSMutableArray new];
    for (NSDictionary *sectionDict in [self formatIndexArrayWithDataBaseArray:array]) {
        NSMutableArray *eachResultArray = [NSMutableArray new];
        NSArray *groups = [sectionDict[([sectionDict allKeys][0])] valueForKeyPath:@"formatTime"];
        for (NSString *time in groups)
        {
            NSMutableDictionary *entry = [NSMutableDictionary new];
            NSArray *groupNames = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"formatTime = %@", time]];
            //            NSMutableArray *sameTimeAr = [NSMutableArray new];
            //            for (int i = 0; i < groupNames.count; i++)
            //            {
            //                [sameTimeAr addObject:groupNames[i]];
            //            }
            BOOL exists = 0;
            for (NSDictionary *dict in eachResultArray) {
                if ([dict containsKey:time]) {
                    exists = YES;
                    break;
                }
            }
            if (!exists) {
                [entry setValue:groupNames forKey:time];
                [eachResultArray addObject:entry];
            }
        }
        [resultArray addObject:[self sortDisplayArray:eachResultArray]];
    }
    return resultArray;
}

- (NSArray *)sortDisplayArray:(NSArray *)array {
    
    NSArray *sortArray = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDictionary *dic1 = obj1;
        NSDictionary *dic2 = obj2;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale currentLocale];
        formatter.dateFormat = @"HH:mm";
        NSString *str1 = [dic1 allKeys][0];
        NSString *str2 = [dic2 allKeys][0];
        NSDate *date1 = [formatter dateFromString:str1];
        NSDate *date2 = [formatter dateFromString:str2];
        return [date2 compare:date1];
    }];
    
    return sortArray;
}

- (NSArray *)sortIndexArray:(NSArray *)array {
    NSArray *sortArray = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDictionary *dict1 = obj1;
        NSDictionary *dict2 = obj2;
        
        NSString *str1 = [dict1 allKeys][0];
        NSString *str2 = [dict2 allKeys][0];
        
        NSInteger num1 = [str1 integerValue];
        NSInteger num2 = [str2 integerValue];
        //       NSOrderedAscending = -1L, NSOrderedSame, NSOrderedDescending 
        if (num1 > num2)        return NSOrderedAscending;
        else if (num1 == num2)  return NSOrderedSame;
        else                    return NSOrderedDescending;
    }];
    
    return sortArray;
}

#pragma mark - Event Response
- (void)modalDetailViewWithNotification:(NSNotification *)notification {
    DWDPickUpCenterDataBaseModel *model = notification.userInfo[@"dataModel"];
    DWDPickUpCenterTimeLineModalDetailViewController *vc = [DWDPickUpCenterTimeLineModalDetailViewController new];
    //    vc.presentationController = [DWDPickUpCenterDetailPresentationController new];
    vc.dataModel = model;
    vc.delegate = self;
    
    vc.modalPresentationStyle = UIModalPresentationCustom;
    DWDPickUpCenterTimeLineTransitionDelegate *transDelegate = [[DWDPickUpCenterTimeLineTransitionDelegate alloc] init];
    
    self.transitioningDelegate = transDelegate;
    vc.transitioningDelegate = transDelegate;
    
    
    [self presentViewController:vc
                       animated:YES
                     completion:^{}
     ];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    //后端无数据
    if (!self.totalStudentsArray.count) {
        self.lineView.hidden = YES;
        if (_requestSucceed == YES) {
            [self.blankView setNeedsDisplay];
        }
        return 0;
    }
    
    //上学
    if (self.state == 0) {
        if (!self.displayGoSchoolArray.count) {
            self.lineView.hidden = YES;
            if (_requestSucceed == YES) {
                [self.blankView setNeedsDisplay];
            }
            return 0;
        } else {
            self.lineView.hidden = NO;
            [_blankView removeFromSuperview];
            //处理后端数据bug
            return MIN(self.totalStudentsArray.count, self.displayGoSchoolArray.count);
        }
        //放学
    } else {
        if (!self.displayLeaveSchoolArray.count) {
            self.lineView.hidden = YES;
            if (_requestSucceed == YES) {
                [self.blankView setNeedsDisplay];
            }
            return 0;
        } else {
            self.lineView.hidden = NO;
            [_blankView removeFromSuperview];
            //处理后端数据bug
            return MIN(self.totalStudentsArray.count, self.displayLeaveSchoolArray.count);
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.totalStudentsArray.count) {
        self.lineView.hidden = YES;
        if (_requestSucceed == YES) {
            [self.blankView setNeedsDisplay];
        }
        return 0;
    }
    
    if (self.state == 0) {
        if (self.displayGoSchoolArray.count == 0) {
            self.lineView.hidden = YES;
            if (_requestSucceed == YES) {
                [self.blankView setNeedsDisplay];
            }
            return 0;
        }
        else {
            [_blankView removeFromSuperview];
            self.lineView.hidden = NO;
            return [self.displayGoSchoolArray[section] count];
        }
    }
    else
    {
        if (self.displayLeaveSchoolArray.count == 0 || self.displayLeaveSchoolArray == nil) {
            self.lineView.hidden = YES;
            if (_requestSucceed == YES) {
                [self.blankView setNeedsDisplay];
            }
            return 0;
        }
        else {
            self.lineView.hidden = NO;
            [_blankView removeFromSuperview];
            return [self.displayLeaveSchoolArray[section] count];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.state == 0) {
        //shangxue
        NSArray *cellArray = [self.displayGoSchoolArray[indexPath.section][indexPath.row] allValues][0];
        NSInteger count = cellArray.count / 4 + 1;
        if (!(cellArray.count % 4)) {
            count -= 1;
        }
        return (DWDScreenW - pxToW(136) + pxToW(50))/4.0 * count + pxToW(40) * (count + 1);
    }
    else {
        //fangxue
        NSArray *cellArray = [self.displayLeaveSchoolArray[indexPath.section][indexPath.row] allValues][0];
        NSInteger count = cellArray.count / 4 + 1;
        if (!(cellArray.count % 4)) {
            count -= 1;
        }
        //        return count * ((DWDScreenW - pxToW(136))/4.0 + pxToW(100));
        return (DWDScreenW - pxToW(136) + pxToW(50))/4.0 * count + pxToW(40) * (count + 1);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.state == 0) {
        //上学
        DWDPickUpCenterTimeLineGoSchoolCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DWDPickUpCenterTimeLineGoSchoolCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.dataDictionary = self.displayGoSchoolArray[indexPath.section][indexPath.row];
        return cell;
    } else {
        //放学
        DWDPickUpCenterTimeLineLeaveSchoolCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DWDPickUpCenterTimeLineLeaveSchoolCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.dataDictionary = self.displayLeaveSchoolArray[indexPath.section][indexPath.row];
        return cell;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DWDPickUpCenterStudentsCountModel *model = self.totalStudentsArray[section];
    DWDPickUpCenterTimeLineHeaderView *headerView = [[DWDPickUpCenterTimeLineHeaderView alloc] initWithFrame:CGRectMake(0, pxToW(20), DWDScreenW, pxToH(136))];
    headerView.backgroundColor = [UIColor whiteColor];
    [headerView setLabelsTextWithTime:self.state ? model.afterSchool : model.toSchool
                                 type:self.state
                         succeedCount:model.attendanceNum
                          vacateCount:model.noteNum
                     notCompleteCount:model.memberNum - model.noteNum - model.attendanceNum];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return pxToH(136);
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect frame = self.lineView.frame;
    if (scrollView.contentOffset.y < 0) {
        frame.origin.y = ABS(scrollView.contentOffset.y) + self.tableView.frame.origin.y;
    } else {
        frame.origin.y = self.tableView.frame.origin.y;
    }
    self.lineView.frame = frame;
}

#pragma mark - DWDPUCLoadingViewDelegate
- (void)loadingViewDidClickReloadButton:(DWDPUCLoadingView *)view {
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
    _requestSucceed = NO;
    [self postRequestStudentWithDate:_currentDate];
}

#pragma mark - DWDPickUpCenterTimeLineModalDetailViewControllerDelegate
- (void)controllerShouldDismiss:(DWDPickUpCenterTimeLineModalDetailViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Setter / Getter

- (void)setState:(NSInteger)state {
    _state = state;
    if (_state == 0) {
        if (_blankView) {
            self.blankView.infoLabel.text = @"暂无到校的学生";
        }
    } else {
        if (_blankView) {
            self.blankView.infoLabel.text = @"暂无离校的学生";
        }
    }
    //    [self caculateInfoModelWithTotalArray:self.totalStudentsArray];
    [self.tableView reloadData];
}

//- (NSArray *)displayGoSchoolArray {
//    if (!_displayGoSchoolArray) {
//        NSArray *displayGoSchoolArray = [NSArray arrayWithArray:[self formatDisplayArrayWithArray:self.goSchoolArray]];
//        _displayGoSchoolArray = displayGoSchoolArray;
//    }
//    return _displayGoSchoolArray;
//}
//
//- (NSArray *)displayLeaveSchoolArray {
//    if (!_displayLeaveSchoolArray) {
//        NSArray *displayLeaveSchoolArray = [NSArray arrayWithArray:[self formatDisplayArrayWithArray:self.leaveSchoolArray]];
//        _displayLeaveSchoolArray = displayLeaveSchoolArray;
//    }
//    return _displayLeaveSchoolArray;
//}
//
//- (NSArray *)goSchoolArray {
//    if (!_goSchoolArray) {
//        NSArray *goSchoolArray = [NSArray arrayWithArray:[[DWDPickUpCenterDatabaseTool sharedManager]
//                                                          selectTimelineWhichDate:[NSString getTodayDateStr]
//                                                          type:@1
//                                                          teacherDataBaseWithClassId:self.classId]];
//        _goSchoolArray = goSchoolArray;
//    }
//    return _goSchoolArray;
//}
//
//- (NSArray *)leaveSchoolArray {
//    if (!_leaveSchoolArray) {
//        NSArray *leaveSchoolArray = [NSArray arrayWithArray:[[DWDPickUpCenterDatabaseTool sharedManager]
//                                                             selectTimelineWhichDate:[NSString getTodayDateStr]
//                                                             type:@2
//                                                             teacherDataBaseWithClassId:self.classId]];
//        
//        _leaveSchoolArray = leaveSchoolArray;
//    }
//    return _leaveSchoolArray;
//}

- (UIView *)lineView {
    if (!_lineView) {
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(pxToW(136), self.tableView.frame.origin.y, 1, DWDScreenH)];
        lineView.backgroundColor = UIColorFromRGB(0xcccccc);
        //        [self.tableView addSubview:lineView];
        //        [self.tableView sendSubviewToBack:lineView];
        [self.tableView.superview insertSubview: lineView belowSubview: self.tableView];
        self.tableView.backgroundColor = [UIColor clearColor];
        _lineView = lineView;
    }
    return _lineView;
}

- (DWDPickUpCenterBackgroundContainerView *)blankView {
    if (!_blankView) {
        DWDPickUpCenterBackgroundContainerView *blankView = [DWDPickUpCenterBackgroundContainerView new];
        blankView.backgroundImageView.image = [UIImage imageNamed:@"MSG_TF_no_Student"];
        blankView.frame = CGRectMake(DWDScreenW * 0.5 - pxToW(316) * 0.5, pxToH(330), pxToW(316), pxToH(377));
        [self.view addSubview:blankView];
        if (self.state == 0) {
            blankView.infoLabel.text = @"暂无到校的学生";
        } else {
            blankView.infoLabel.text = @"暂无离校的学生";
        }
        _blankView = blankView;
    }
    return _blankView;
}

@end
