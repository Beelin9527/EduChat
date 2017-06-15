//
//  DWDTeacherLeaveSchoolWaitCell.m
//  EduChat
//
//  Created by KKK on 16/3/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDTeacherLeaveSchoolWaitCell.h"
#import "DWDLeaveSchoolWaitDetailView.h"

#import <Masonry.h>

@interface DWDTeacherLeaveSchoolWaitCell ()

@property (nonatomic, strong) DWDLeaveSchoolWaitDetailView *firstView;
@property (nonatomic, strong) DWDLeaveSchoolWaitDetailView *secondView;
@property (nonatomic, strong) DWDLeaveSchoolWaitDetailView *thirdView;
@property (nonatomic, strong) DWDLeaveSchoolWaitDetailView *fourthView;

@end

@implementation DWDTeacherLeaveSchoolWaitCell

#pragma mark - Private Method
- (void)setSubViews:(NSArray *)dataArray {
    [self.firstView removeFromSuperview];
    [self.secondView removeFromSuperview];
    [self.thirdView removeFromSuperview];
    [self.fourthView removeFromSuperview];
    
    
    [self.contentView addSubview:self.firstView];
    self.firstView.dataModel = dataArray[0];
    [self.firstView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(pxToH(20));
        make.bottom.equalTo(self.contentView).offset(-pxToW(20));
        make.left.equalTo(self.contentView).offset(pxToW(12));
        
    }];
    if (dataArray.count > 1) {
        
        [self.contentView addSubview:self.secondView];
        self.secondView.dataModel = dataArray[1];
        [self.secondView makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self.contentView).offset(pxToH(20));
            make.bottom.equalTo(self.contentView).offset(-pxToW(20));
            make.left.equalTo(self.firstView.right).offset(pxToW(12));
        }];
        
    }
    if (dataArray.count > 2) {
        
        [self.contentView addSubview:self.thirdView];
        self.thirdView.dataModel = dataArray[2];
        [self.thirdView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(pxToH(20));
            make.bottom.equalTo(self.contentView).offset(-pxToW(20));
            make.left.equalTo(self.secondView.right).offset(pxToW(12));
        }];
        
    }
    if (dataArray.count > 3) {
        [self.contentView addSubview:self.fourthView];
        self.fourthView.dataModel = dataArray[3];
        [self.fourthView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(pxToH(20));
            make.bottom.equalTo(self.contentView).offset(-pxToW(20));
            make.left.equalTo(self.thirdView.right).offset(pxToW(12));
            
            make.right.equalTo(self.contentView).offset(-pxToW(12));
        }];
        
    }
    [super updateConstraints];
}


#pragma mark - setter /getter
- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    [self setSubViews:dataArray];
}

- (DWDLeaveSchoolWaitDetailView *)firstView {
    if (!_firstView) {
        DWDLeaveSchoolWaitDetailView *view = [[DWDLeaveSchoolWaitDetailView alloc] init];
        _firstView = view;
    }
    return _firstView;
}

- (DWDLeaveSchoolWaitDetailView *)secondView {
    if (!_secondView) {
        DWDLeaveSchoolWaitDetailView *view = [[DWDLeaveSchoolWaitDetailView alloc] init];
        _secondView = view;
    }
    return _secondView;
}

- (DWDLeaveSchoolWaitDetailView *)thirdView {
    if (!_thirdView) {
        DWDLeaveSchoolWaitDetailView *view = [[DWDLeaveSchoolWaitDetailView alloc] init];
        _thirdView = view;
    }
    return _thirdView;
}

- (DWDLeaveSchoolWaitDetailView *)fourthView {
    if (!_fourthView) {
        DWDLeaveSchoolWaitDetailView *view = [[DWDLeaveSchoolWaitDetailView alloc] init];
        _fourthView = view;
    }
    return _fourthView;
}

@end
