//
//  DWDTeacherLeaverSchoolGateController.m
//  EduChat
//
//  Created by KKK on 16/3/16.
//  Copyright © 2016年 dwd. All rights reserved.
//
#define kCellID @"gateCellId"

#import "DWDTeacherLeaverSchoolGateController.h"
#import "DWDTeacherLeaveSchoolGateCell.h"

#import "DWDPickUpCenterBackgroundContainerView.h"

@interface DWDTeacherLeaverSchoolGateController ()

@property (nonatomic, weak) DWDPickUpCenterBackgroundContainerView *bgImgView;

@end

@implementation DWDTeacherLeaverSchoolGateController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 200;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    self.tableView.backgroundColor = UIColorFromRGB(0xf5f5f5);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerClass:[DWDTeacherLeaveSchoolGateCell class] forCellReuseIdentifier:kCellID];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger count = self.dataArray.count / 2;
    if (!(self.dataArray.count % 2 == 0)) {
        count += 1;
    }
    if (count == 0) {
        if (_isFirstRequest == NO && _requestFailed == NO) {
            [self.bgImgView setNeedsDisplay];
        }
    } else {
        [self.bgImgView removeFromSuperview];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DWDTeacherLeaveSchoolGateCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    cell.backgroundColor = [UIColor whiteColor];
    
    NSRange range = NSMakeRange(indexPath.row * 2, 2);
    if (((indexPath.row +1) * 2) > self.dataArray.count) {
        range.length = 1;
    }
    cell.dataArray = [self.dataArray subarrayWithRange:range];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - Setter / Getter

- (DWDPickUpCenterBackgroundContainerView *)bgImgView {
    if (!_bgImgView) {
        DWDPickUpCenterBackgroundContainerView *bgImgView = [DWDPickUpCenterBackgroundContainerView new];
        [bgImgView.backgroundImageView setImage:[UIImage imageNamed:@"MSG_TF_NO_Data_Door"]];
        [bgImgView.infoLabel setText:@"暂无已到校门的家长"];
        bgImgView.frame = CGRectMake(DWDScreenW * 0.5 - pxToW(316) * 0.5, pxToH(330), pxToW(316), pxToH(377));
        [self.view addSubview:bgImgView];
        _bgImgView = bgImgView;
    }
    return _bgImgView;
}


@end
