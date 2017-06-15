//
//  DWDHomeWorkDetailViewController.m
//  EduChat
//
//  Created by apple on 12/30/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>
#import "DWDHomeWorkDetailViewController.h"
#import "DWDHomeWorkDetailCell.h"
#import "DWDHomeWorkCompletenessCell.h"
#import "DWDHomeWorkClient.h"

@interface DWDHomeWorkDetailViewController ()

@property (strong, nonatomic) DWDHomeWorkClient *homeWorkClient;
@property (strong, nonatomic) NSDictionary *homeWorkDatas;
@end

@implementation DWDHomeWorkDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[DWDHomeWorkDetailCell class] forCellReuseIdentifier:NSStringFromClass([DWDHomeWorkDetailCell class])];
    [self.tableView registerClass:[DWDHomeWorkCompletenessCell class] forCellReuseIdentifier:NSStringFromClass([DWDHomeWorkCompletenessCell class])];
    self.tableView.backgroundColor = DWDColorBackgroud;
    UIView *footer = [UIView new];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
    
    self.title = @"作业详情";
    
    _homeWorkClient = [[DWDHomeWorkClient alloc] init];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = NSLocalizedString(@"Loading", nil);
    [self.homeWorkClient fetchHomeWorkBy:[DWDCustInfo shared].custId
                                 classId:self.classId
                              homeWorkId:self.homeWorkId
                                 success:^(NSDictionary *homeWork) {
                                     
                                     self.homeWorkDatas = homeWork;
                                     
                                     [hud hide:YES afterDelay:1];
                                     
                                     [self.tableView reloadData];
                                     
                                 } failure:^(NSError *error) {
                                     
                                     hud.mode = MBProgressHUDModeText;
                                     hud.labelText = NSLocalizedString(@"LoadingFail", nil);
                                     [hud hide:YES afterDelay:1];
                                 }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height;
    
    if (indexPath.row == 0) {
        DWDHomeWorkDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDHomeWorkDetailCell class])];
        
        [self fillCell:cell];
        [cell layoutIfNeeded];
        height = [cell getHeight];
    }
    
    else {
        
        if (indexPath.row == 1) {
            NSArray *finished = self.homeWorkDatas[@"finished"];
            if (finished.count == 0) {
                height = 50;
            } else {
                DWDHomeWorkCompletenessCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDHomeWorkCompletenessCell class])];
                [self fillCompCell:cell forFinish:indexPath.row == 1];
                [cell layoutIfNeeded];
                height = [cell getHeight];
            }
        } else {
        
            DWDHomeWorkCompletenessCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDHomeWorkCompletenessCell class])];
            [self fillCompCell:cell forFinish:indexPath.row == 1];
            [cell layoutIfNeeded];
            height = [cell getHeight];
        }
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *lastCell;
    
    if (indexPath.row == 0) {
        DWDHomeWorkDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDHomeWorkDetailCell class])];
        [self fillCell:cell];
        lastCell = cell;
    }
    
    else {
        DWDHomeWorkCompletenessCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DWDHomeWorkCompletenessCell class])];
        [self fillCompCell:cell forFinish:indexPath.row == 1];
        
        lastCell = cell;
    }
    
    
    return lastCell;
}

- (void)fillCompCell:(DWDHomeWorkCompletenessCell *)cell forFinish:(BOOL)finish {
    
    NSString *title;
    NSArray *pepoles;
    
    if (finish) {
        title = @"已完成";
        pepoles = self.homeWorkDatas[@"finished"];
    } else {
        title = @"未完成";
        pepoles = self.homeWorkDatas[@"unfinish"];
    }
    
    cell.titleLabel.text = title;
    cell.countLabel.text = [NSString stringWithFormat:@"(%zd)", pepoles.count];
    cell.peoples = pepoles;

}

- (void)fillCell:(DWDHomeWorkDetailCell *) cell {
    
    NSDictionary *homeWork = self.homeWorkDatas[@"homework"];
    NSDictionary *author = self.homeWorkDatas[@"author"];
    
    cell.titleLabel.text = homeWork[@"title"];
    cell.subjectLabel.text = homeWork[@"subject"];
    cell.dateLabel.text = author[@"addTime"];
    cell.contentTitleLabel.text = @"作业内容";
    cell.contentLabel.text = homeWork[@"content"];
    cell.deadlineLabel.text = homeWork[@"collectTime"];
    cell.deadlineTitleLabel.text = @"上交时间：";
    cell.fromTitleLabel.text = @"发布者：";
    cell.fromLabel.text = author[@"name"];
    
    cell.attachmentPaths = homeWork[@"attachment"];
}

@end
