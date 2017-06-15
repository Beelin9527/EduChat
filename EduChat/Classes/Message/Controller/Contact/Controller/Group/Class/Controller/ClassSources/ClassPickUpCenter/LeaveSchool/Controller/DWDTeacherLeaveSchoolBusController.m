//
//  DWDTeacherLeaveSchoolBusController.m
//  EduChat
//
//  Created by KKK on 16/3/16.
//  Copyright © 2016年 dwd. All rights reserved.
//
#define kCellID @"busCellId"

#import "DWDTeacherLeaveSchoolBusController.h"
#import "DWDTeacherLeaveSchoolBusCell.h"

#import "DWDPickUpCenterBackgroundContainerView.h"

@interface DWDTeacherLeaveSchoolBusController ()

@property (nonatomic, weak) DWDPickUpCenterBackgroundContainerView *bgImgView;

@end

@implementation DWDTeacherLeaveSchoolBusController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 200;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 74, 0);
    self.tableView.backgroundColor = UIColorFromRGB(0xf5f5f5);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerClass:[DWDTeacherLeaveSchoolBusCell class] forCellReuseIdentifier:kCellID];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = self.dataArray.count / 4;
    if (!(self.dataArray.count % 4 == 0)) {
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
    
    DWDTeacherLeaveSchoolBusCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    cell.backgroundColor = [UIColor whiteColor];
    
    NSRange range = NSMakeRange(indexPath.row * 4, 4);
    NSInteger value = (indexPath.row + 1) * 4 - self.dataArray.count;
    switch (value) {
        case 3:
            range.length = 1;
            break;
        case 2:
            range.length = 2;
            break;
        case 1:
            range.length = 3;
            break;
            
        default:
            range.length = 4;
            break;
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
        [bgImgView.backgroundImageView setImage:[UIImage imageNamed:@"MSG_TF_no_parent_bus"]];
        [bgImgView.infoLabel setText:@"暂无已到校车的家长"];
        bgImgView.frame = CGRectMake(DWDScreenW * 0.5 - pxToW(316) * 0.5, pxToH(330), pxToW(316), pxToH(377));
        [self.view addSubview:bgImgView];
        _bgImgView = bgImgView;
    }
    return _bgImgView;
}


@end
