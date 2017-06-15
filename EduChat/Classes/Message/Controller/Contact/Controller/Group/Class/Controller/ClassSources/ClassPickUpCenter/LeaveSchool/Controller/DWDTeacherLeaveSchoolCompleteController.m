//
//  DWDTeacherLeaveSchoolCompleteController.m
//  EduChat
//
//  Created by KKK on 16/3/16.
//  Copyright © 2016年 dwd. All rights reserved.
//
#define kCellID @"completeCellId"

#import "DWDTeacherLeaveSchoolCompleteController.h"
#import "DWDTeacherLeaveSchoolCompleteCell.h"

#import "DWDPickUpCenterBackgroundContainerView.h"

@interface DWDTeacherLeaveSchoolCompleteController ()

@property (nonatomic, weak) DWDPickUpCenterBackgroundContainerView *bgImgView;

@end

@implementation DWDTeacherLeaveSchoolCompleteController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 200;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 74, 0);
    self.tableView.backgroundColor = UIColorFromRGB(0xf5f5f5);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerClass:[DWDTeacherLeaveSchoolCompleteCell class] forCellReuseIdentifier:kCellID];
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
    DWDTeacherLeaveSchoolCompleteCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    cell.backgroundColor = [UIColor whiteColor];
    
    NSRange range = NSMakeRange(indexPath.row * 2, 2);
    if (((indexPath.row +1) * 2) > self.dataArray.count) {
        range.length = 1;
    }
//    switch (value) {
//        case 2:
//            range.length = 1;
//            break;
//        case 1:
//            range.length = 2;
//            break;
////        case 1:
////            range.length = 3;
////            break;
////            
////        default:
////            range.length = 4;
////            break;
//    }
    cell.dataArray = [self.dataArray subarrayWithRange:range];
    cell.userInteractionEnabled = NO;
    
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
        [bgImgView.backgroundImageView setImage:[UIImage imageNamed:@"MSG_TF_NO_Data_Leave"]];
        [bgImgView.infoLabel setText:@"暂无已接的学生"];
        bgImgView.frame = CGRectMake(DWDScreenW * 0.5 - pxToW(316) * 0.5, pxToH(330), pxToW(316), pxToH(377));
        [self.view addSubview:bgImgView];
        _bgImgView = bgImgView;
    }
    return _bgImgView;
}


@end
