//
//  DWDIntAnnouncementsViewController.m
//  EduChat
//
//  Created by Catskiy on 2016/12/27.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDIntAnnouncementsViewController.h"
#import "DWDIntAnnouncementsViewCell.h"

static NSString *cellAnnounceIdentifier = @"DWDIntAnnouncementsViewCell";

@interface DWDIntAnnouncementsViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *announcementTableView;

@property (nonatomic, strong) NSArray *announceArray;

@end

@implementation DWDIntAnnouncementsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"通知公告";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.announcementTableView];
}

#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.announceArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DWDIntAnnouncementsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellAnnounceIdentifier forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Getter
- (UITableView *)announcementTableView {
    if (!_announcementTableView) {
        _announcementTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DWDScreenW, DWDScreenH-49) style:UITableViewStyleGrouped];
        _announcementTableView.delegate = self;
        _announcementTableView.dataSource = self;
        _announcementTableView.backgroundColor = [UIColor clearColor];
        
        /** cell */
        [self.announcementTableView registerClass:[DWDIntAnnouncementsViewCell class] forCellReuseIdentifier:cellAnnounceIdentifier];
    }
    return _announcementTableView;
}

-(NSArray *)announceArray {
    if (!_announceArray) {
        _announceArray = @[@"",@"",@""];
    }
    return _announceArray;
}

#pragma mark - Memory
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
