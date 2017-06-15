//
//  DWDPickUpCenterChildTimeLineViewController.m
//  EduChat
//
//  Created by KKK on 16/3/30.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDPickUpCenterChildTimeLineViewController.h"
#import "DWDPickUpCenterCalendarDateButton.h"

#import "CLWeeklyCalendarView.h"
#import "DWDPickUpCenterBackgroundContainerView.h"

#import "DWDPickUpCenterChildCell.h"
#import "DWDPickUpCenterChildNoLiveCell.h"

#import "DWDPickUpCenterDataBaseModel.h"

#import "DWDPickUpCenterDatabaseTool.h"
#import "DWDContactsDatabaseTool.h"
#import "DWDRecentChatDatabaseTool.h"

#import "NSString+extend.h"

#define calendarViewHeight 80

@interface DWDPickUpCenterChildTimeLineViewController () <UITableViewDelegate, UITableViewDataSource, CLWeeklyCalendarViewDelegate, DWDPickUpCenterCalendarDateButtonDelegate>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, weak) CLWeeklyCalendarView *calendarView;

@property (nonatomic, weak) DWDPickUpCenterCalendarDateButton *titleButton;

@property (nonatomic, weak) DWDPickUpCenterBackgroundContainerView *blankView;

@property (nonatomic, weak) UITableView *tableView;

@end

@implementation DWDPickUpCenterChildTimeLineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = DWDColorBackgroud;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 70, 0);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.tableView.frame.origin.y, DWDScreenW, DWDScreenH - self.tableView.frame.origin.y)];
    bgImgView.image = [UIImage imageNamed:@"msg_tf_bj"];
    [self.tableView.superview insertSubview:bgImgView belowSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([DWDPickUpCenterChildNoLiveCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ChildNoLiveCell"];
    [self.tableView registerClass:[DWDPickUpCenterChildCell class] forCellReuseIdentifier:@"ChildCell"];
    
    self.tableView.estimatedRowHeight = 300;
}

//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    
//    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
//    [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] clearBadgeCountWithFriendId:@1001 myCusId:[DWDCustInfo shared].custId success:^{
//    } failure:^{
//    }];
//    
//    [DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool].currentOperationFriendId = @1001;
//}

//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    [[DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool] clearBadgeCountWithFriendId:@1001 myCusId:[DWDCustInfo shared].custId success:^{
//    } failure:^{
//    }];
//    [DWDRecentChatDatabaseTool sharedRecentChatDatabaseTool].currentOperationFriendId = nil;
//}


#pragma mark - Private Method

- (NSString *)dateToTitleButtonString:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(kCFCalendarUnitYear | kCFCalendarUnitMonth) fromDate:date];
    NSInteger year = [components year];
    NSInteger month = [components month];
    return [NSString stringWithFormat:@"%zd年%zd月", year, month];
}

- (void)dateDidChange:(NSDate *)date {
    [self.titleButton setTitle:[self dateToTitleButtonString:date] forState:UIControlStateNormal];
    [self.titleButton sizeToFit];
    
    NSString *dateTimeStr = [NSString stringFromDateWithYYYYMMddHHmmss:date];
    NSString *dateStr = [NSString stringFormatYYYYMMddHHmmssDateToYYYYMMddString:dateTimeStr withFormatSymbol:@"-"];
    self.dataArray = [[DWDPickUpCenterDatabaseTool sharedManager] selectWhichDate:dateStr ChildDataBaseWithClassId:self.classId];
    [self.tableView reloadData];
}

#pragma mark - Event Response
- (void)titleButtonDidClick:(DWDPickUpCenterCalendarDateButton *)sender {
    DWDMarkLog(@"titleButtonClick");
    if (sender.isFirstResponder)
        [sender resignFirstResponder];
    else
        [sender becomeFirstResponder];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = self.dataArray.count;
    
    if (count == 0) {
        [self.blankView setNeedsDisplay];
    } else {
        [self.blankView removeFromSuperview];
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DWDPickUpCenterDataBaseModel *dataBaseModel = self.dataArray[indexPath.row];
    
    if ([dataBaseModel.contextual isEqualToString:@"OffAfterschoolBus"] || [dataBaseModel.contextual isEqualToString:@"Getoutschool"]) {
        DWDPickUpCenterChildNoLiveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChildNoLiveCell"];
        cell.dataModel = dataBaseModel;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    } else {
        DWDPickUpCenterChildCell *cell = [DWDPickUpCenterChildCell cellWithTableView:tableView ID:@"ChildCell"];
        cell.dataBaseModel = dataBaseModel;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
}

#pragma mark - UITableViewDelegate

#pragma mark - CLWeeklyCalendarViewDelegate
- (NSDictionary *)CLCalendarBehaviorAttributes{
    return @{
             CLCalendarWeekStartDay : @7,
             CLCalendarDayTitleTextColor : [UIColor whiteColor],
             //             CLCalendarSelectedDatePrintFontSize : DWDFontContent,
             CLCalendarBackgroundImageColor : DWDRGBColor(90, 136, 231),
             };
}

-(void)dailyCalendarViewDidSelect:(NSDate *)date{
    
    [self dateDidChange:date];

}
#pragma mark - DWDPickUpCenterCalendarDateButtonDelegate
- (void)dateButton:(DWDPickUpCenterCalendarDateButton *)button DidClickDate:(NSDate *)date {
    [button resignFirstResponder];
    
    [self.calendarView redrawToDate:date];
    
    [self dateDidChange:date];
}

#pragma mark - Setter / Getter

- (CLWeeklyCalendarView *)calendarView {
    if (!_calendarView) {
        CLWeeklyCalendarView *calendarView = [[CLWeeklyCalendarView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, calendarViewHeight)];
        calendarView.delegate = self;
        [self.view addSubview:calendarView];
        _calendarView = calendarView;
    }
    return _calendarView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] init];
        CGRect frame = CGRectMake(0, CGRectGetMaxY(self.calendarView.frame), DWDScreenW, DWDScreenH - CGRectGetMaxY(self.calendarView.frame));
        tableView.frame = frame;
        self.tableView = tableView;
        [self.view addSubview:tableView];
    }
    return _tableView;
}

- (NSArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [[DWDPickUpCenterDatabaseTool sharedManager] selectWhichDate:[NSString getTodayDateStr] ChildDataBaseWithClassId:self.classId];
    }
    return _dataArray;
}

- (DWDPickUpCenterBackgroundContainerView *)blankView {
    if (!_blankView) {
        DWDPickUpCenterBackgroundContainerView *blankView = [DWDPickUpCenterBackgroundContainerView new];
        [blankView.backgroundImageView setImage:[UIImage imageNamed:@"MSG_TF_No_Message"]];
        [blankView.infoLabel setText:@"暂无接送消息"];
        blankView.frame = CGRectMake(DWDScreenW * 0.5 - pxToW(316) * 0.5, pxToH(330), pxToW(316), pxToH(377));
        [self.tableView addSubview:blankView];
        _blankView = blankView;
    }
    return _blankView;
}

- (DWDPickUpCenterCalendarDateButton *)titleButton {
    if (!_titleButton) {
        DWDPickUpCenterCalendarDateButton *titleButton = [DWDPickUpCenterCalendarDateButton buttonWithType:UIButtonTypeCustom];
        [titleButton setCenter:titleButton.superview.center];
        [titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [titleButton addTarget:self action:@selector(titleButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        titleButton.delegate = self;
        
        NSString *titleStr = [self dateToTitleButtonString:[NSDate date]];
        [_titleButton setTitle:titleStr forState:UIControlStateNormal];
        self.navigationItem.titleView = titleButton;
        _titleButton = titleButton;
    }
    return _titleButton;
}

@end
