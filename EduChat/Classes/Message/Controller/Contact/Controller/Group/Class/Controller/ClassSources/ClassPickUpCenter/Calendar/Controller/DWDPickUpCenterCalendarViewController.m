//
//  DWDPickUpCenterCalendarViewController.m
//  EduChat
//
//  Created by KKK on 16/3/18.
//  Copyright © 2016年 dwd. All rights reserved.
//

#define kCalendarViewHeight 80

#import "DWDPickUpCenterCalendarViewController.h"
#import "DWDPickUpCenterTimeLineTableViewController.h"

#import "DWDPickUpCenterDatabaseTool.h"

#import "CLWeeklyCalendarView.h"
#import "DWDPickUpCenterCalendarDateButton.h"



@interface DWDPickUpCenterCalendarViewController () <CLWeeklyCalendarViewDelegate, DWDPickUpCenterCalendarDateButtonDelegate>

@property (nonatomic, weak) DWDPickUpCenterCalendarDateButton *titleButton;

@property (nonatomic, weak) CLWeeklyCalendarView *calendarView;
@property (nonatomic, strong) DWDPickUpCenterTimeLineTableViewController *timeLineController;

@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSArray *totalStudentsArray;

@end

@implementation DWDPickUpCenterCalendarViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = DWDRGBColor(247, 247, 247);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.timeState ? @"上学详情":@"放学详情" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonDidClick:)];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // create TopDetailView
//    [self.view addSubview:self.calendarView];
    
    
    
    //titile button
    DWDPickUpCenterCalendarDateButton *titleButton = [DWDPickUpCenterCalendarDateButton buttonWithType:UIButtonTypeCustom];
//    [titleButton setCenter:titleButton.superview.center];
    [titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [titleButton addTarget:self action:@selector(titleButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    titleButton.delegate = self;
    
    NSString *titleStr = [self dateToTitleButtonString:[NSDate date]];
    [titleButton setTitle:titleStr forState:UIControlStateNormal];
    self.navigationItem.titleView = titleButton;
    _titleButton = titleButton;
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [[DWDPickUpCenterDatabaseTool sharedManager] badgeNumberNeedSub];
    
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[DWDPickUpCenterDatabaseTool sharedManager] badgeNumberDontNeedSub];
}

#pragma mark - Private Method

- (void)rightBarButtonDidClick:(UIBarButtonItem *)sender {
    //0 上学 1 放学
    if (self.timeState == 0) {
        self.timeState = 1;
        [sender setTitle:@"上学详情"];
    } else {
        self.timeState = 0;
        [sender setTitle:@"放学详情"];
    }
    [self dateDidChange:_selectedDate];
}

- (NSString *)dateToTitleButtonString:(NSDate *)date {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay) fromDate:date];
    NSInteger year = [components year];
    NSInteger month = [components month];
    return [NSString stringWithFormat:@"%ld年%ld月", (long)year, (long)month];
}

- (void)dateDidChange:(NSDate *)date {
    _selectedDate = date;
    [self.titleButton setTitle:[self dateToTitleButtonString:date] forState:UIControlStateNormal];
    [self.titleButton sizeToFit];
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"YYYY-MM-dd";
        formatter.locale = [NSLocale currentLocale];
    });
    NSString *dateStr = [formatter stringFromDate:date];
    
    self.timeLineController.requestSucceed = NO;
    [self.timeLineController reloadDataWithDate:dateStr];
}



#pragma mark - Event Response
- (void)titleButtonDidClick:(DWDPickUpCenterCalendarDateButton *)sender {
    DWDMarkLog(@"titleButtonClick");
    if (sender.isFirstResponder)
        [sender resignFirstResponder];
    else
        [sender becomeFirstResponder];
}

#pragma mark - CLWeeklyCalendarViewDelegate
-(NSDictionary *)CLCalendarBehaviorAttributes {
    
    // Keys for customize the calendar behavior
//    extern NSString *const CLCalendarWeekStartDay;    //The Day of weekStart from 1 - 7 - Default: 1
//    extern NSString *const CLCalendarDayTitleTextColor; //Day Title text color,  Mon, Tue, etc label text color
//    extern NSString *const CLCalendarSelectedDatePrintFormat;   //Selected Date print format,  - Default: @"EEE, d MMM yyyy"
//    extern NSString *const CLCalendarSelectedDatePrintColor;    //Selected Date print text color -Default: [UIColor whiteColor]
//    extern NSString *const CLCalendarSelectedDatePrintFontSize; //Selected Date print font size - Default : 13.f
//    extern NSString *const CLCalendarBackgroundImageColor;      //BackgroundImage color - Default : see applyCustomDefaults.
    return @{
             CLCalendarWeekStartDay : @7,
             CLCalendarDayTitleTextColor : [UIColor whiteColor],
//             CLCalendarSelectedDatePrintFontSize : DWDFontContent,
             CLCalendarBackgroundImageColor : DWDRGBColor(90, 136, 231),
             };
}

-(void)dailyCalendarViewDidSelect: (NSDate *)date {
    [self dateDidChange:date];
}

#pragma mark - DWDPickUpCenterCalendarDateButtonDelegate

- (void)dateButton:(DWDPickUpCenterCalendarDateButton *)button DidClickDate:(NSDate *)date {
    [button resignFirstResponder];
    [self.calendarView redrawToDate:date];
}

#pragma mark - Setter / Getter
- (CLWeeklyCalendarView *)calendarView {
    if (!_calendarView) {
        CLWeeklyCalendarView *calendarView = [[CLWeeklyCalendarView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, kCalendarViewHeight)];
        calendarView.delegate = self;
        [self.view addSubview:calendarView];
        _calendarView = calendarView;
    }
    return _calendarView;
}

- (DWDPickUpCenterTimeLineTableViewController *)timeLineController {
    if (!_timeLineController) {
        DWDPickUpCenterTimeLineTableViewController *vc = [[DWDPickUpCenterTimeLineTableViewController alloc] init];
        vc.requestSucceed = NO;
        vc.classId = self.classId;
        vc.state = self.timeState;
        CGRect frame = self.view.bounds;
        frame.origin.y = CGRectGetMaxY(self.calendarView.frame);
        frame.size.height = self.view.bounds.size.height - self.calendarView.frame.size.height;
        vc.tableView.frame = frame;
        [self.view addSubview:vc.tableView];
        [self addChildViewController:vc];
        [vc didMoveToParentViewController:self];
        _timeLineController = vc;
    }
    return _timeLineController;
}

- (void)setTimeState:(NSInteger)timeState {
    
    _timeState = timeState;
    self.timeLineController.state = timeState;
}

@end
