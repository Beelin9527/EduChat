//
//  DWDTeacherLeaveSchoolBusCell.m
//  EduChat
//
//  Created by KKK on 16/3/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDTeacherLeaveSchoolBusCell.h"
#import "DWDLeaveSchoolDetailModel.h"

#import "DWDLeaveSchoolBusDetailView.h"

#import <Masonry.h>

@interface DWDTeacherLeaveSchoolBusCell ()

@property (nonatomic, strong) DWDLeaveSchoolBusDetailView *firstView;
@property (nonatomic, strong) DWDLeaveSchoolBusDetailView *secondView;
@property (nonatomic, strong) DWDLeaveSchoolBusDetailView *thirdView;
@property (nonatomic, strong) DWDLeaveSchoolBusDetailView *fourthView;

@end

@implementation DWDTeacherLeaveSchoolBusCell


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
        make.left.equalTo(self.contentView).offset(pxToW(12));
        make.bottom.equalTo(self.contentView).offset(-pxToW(20));
        
    }];
    if (dataArray.count > 1) {
        
        [self.contentView addSubview:self.secondView];
        self.secondView.dataModel = dataArray[1];
        [self.secondView makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self.firstView);
            make.bottom.equalTo(self.firstView);
            make.left.equalTo(self.firstView.right).offset(pxToW(12));
        }];
        
    }
    if (dataArray.count > 2) {
        
        [self.contentView addSubview:self.thirdView];
        self.thirdView.dataModel = dataArray[2];
        [self.thirdView makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self.firstView);
            make.bottom.equalTo(self.firstView);
            make.left.equalTo(self.secondView.right).offset(pxToW(12));
            
        }];
        
    }
    if (dataArray.count > 3) {
        [self.contentView addSubview:self.fourthView];
        self.fourthView.dataModel = dataArray[3];
        [self.fourthView makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.equalTo(self.firstView);
            make.bottom.equalTo(self.firstView);
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

- (DWDLeaveSchoolBusDetailView *)firstView {
    if (!_firstView) {
        DWDLeaveSchoolBusDetailView *view = [[DWDLeaveSchoolBusDetailView alloc] init];
        _firstView = view;
    }
    return _firstView;
}

- (DWDLeaveSchoolBusDetailView *)secondView {
    if (!_secondView) {
        DWDLeaveSchoolBusDetailView *view = [[DWDLeaveSchoolBusDetailView alloc] init];
        _secondView = view;
    }
    return _secondView;
}

- (DWDLeaveSchoolBusDetailView *)thirdView {
    if (!_thirdView) {
        DWDLeaveSchoolBusDetailView *view = [[DWDLeaveSchoolBusDetailView alloc] init];
        _thirdView = view;
    }
    return _thirdView;
}

- (DWDLeaveSchoolBusDetailView *)fourthView {
    if (!_fourthView) {
        DWDLeaveSchoolBusDetailView *view = [[DWDLeaveSchoolBusDetailView alloc] init];
        _fourthView = view;
    }
    return _fourthView;
}


@end
