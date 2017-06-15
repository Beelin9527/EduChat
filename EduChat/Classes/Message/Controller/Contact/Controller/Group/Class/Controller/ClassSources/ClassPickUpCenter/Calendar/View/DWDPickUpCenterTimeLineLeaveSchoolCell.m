//
//  DWDPickUpCenterTimeLineLeaveSchoolCell.m
//  EduChat
//
//  Created by KKK on 16/3/19.
//  Copyright © 2016年 dwd. All rights reserved.
//

#define detailViewHeight (DWDScreenW - pxToW(236))/4.0 + pxToW(100)

#import "DWDPickUpCenterTimeLineLeaveSchoolCell.h"
#import "DWDPickUpCenterTimeLineGoSchoolCell.h"
#import "DWDPickUpCenterTimeLineLeaveSchoolDetailView.h"

@interface DWDPickUpCenterTimeLineLeaveSchoolCell ()

@property (nonatomic, weak) UIView *containerView;


@end

@implementation DWDPickUpCenterTimeLineLeaveSchoolCell

@synthesize dataDictionary = _dataDictionary;

#pragma mark - Private Method

- (void)layoutDetailViewsWithDataArray:(NSArray *)array {
    NSInteger maxRow;
    if (array.count) {
        maxRow = array.count / 4 + 1;
        if (!(array.count % 4)) {
            maxRow -= 1;
        }
    }
    else {
        maxRow = 0;
    }
    
    for (int i = 0; i < maxRow; i ++) {
        //计算每一行有多少个
        int maxCol = (array.count - i * 4) % 4;
        if ((array.count - i *4) >= 4) {
            maxCol = 4;
        }
        if (maxCol == 0) {
            maxCol = 4;
        }
        for (int j = 0; j < maxCol; j ++) {
            DWDPickUpCenterTimeLineLeaveSchoolDetailView *view = [DWDPickUpCenterTimeLineLeaveSchoolDetailView new];
//            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detailViewDidSelected:)];
//            [view addGestureRecognizer:tap];
            view.tag = i * 4 + j;
            CGRect frame = CGRectZero;
            view.dataModel = array[i * 4 + j];
            frame.origin.x = (DWDScreenW - pxToW(236))/4.0 * j + pxToW(20) * (j + 1);
            frame.origin.y = ((DWDScreenW - pxToW(236))/4.0 + pxToW(50)) * i + pxToW(20) * (i + 1);
            frame.size.width = (DWDScreenW - pxToW(236))/4.0;
            frame.size.height = (DWDScreenW - pxToW(236))/4.0 + pxToW(50);
            view.frame = frame;
            [self.containerView addSubview:view];
        }
    }
}

#pragma mark - Event Response
//- (void)detailViewDidSelected:(UITapGestureRecognizer *)tap {
//    DWDMarkLog(@"detailView Select success!!");
//}

#pragma mark - Setter / Getter

- (void)setDataDictionary:(NSDictionary *)dataDictionary {
    
    [self.containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _dataDictionary = dataDictionary;
    NSArray *dataArray = [dataDictionary allValues][0];
    NSString *key = [dataDictionary allKeysForObject:dataArray][0];
    self.timeLabel.text = [dataDictionary[key][0] formatTime];
    NSInteger count = dataArray.count / 4 + 1;
    if (!(dataArray.count % 4)) {
        count -= 1;
    }
    CGFloat containerHeight = ((DWDScreenW - pxToW(236))/4.0 + pxToW(50)) * count + pxToW(20) * (count + 1);
    //layout detailView
    [self layoutDetailViewsWithDataArray:dataArray];
    
    CGRect frame = self.containerView.frame;
    frame.size.height = containerHeight;
    self.containerView.frame = frame;
    [self.containerView setNeedsLayout];
}

- (UIView *)containerView {
    if (!_containerView) {
        //container View
        UIView *containerView = [UIView new];
        containerView.frame = CGRectMake(pxToW(136 + 9.5), pxToW(20), DWDScreenW - pxToW(136), 0);
        _containerView = containerView;
        [self.contentView addSubview:containerView];
    }
    return _containerView;
}

@end
