//
//  DWDTeacherLeaveSchoolCompleteCell.m
//  EduChat
//
//  Created by KKK on 16/3/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDTeacherLeaveSchoolCompleteCell.h"
#import "DWDLeaveSchoolCompleteDetailView.h"

#import <Masonry.h>

@interface DWDTeacherLeaveSchoolCompleteCell ()

@property (nonatomic, strong) DWDLeaveSchoolCompleteDetailView *leftView;
@property (nonatomic, strong) DWDLeaveSchoolCompleteDetailView *rightView;

@end

@implementation DWDTeacherLeaveSchoolCompleteCell

#pragma mark - private method
- (void)setViews:(NSArray *)dataArray {
    [self.leftView removeFromSuperview];
    [self.rightView removeFromSuperview];
    self.leftView.dataModel = dataArray[0];
    //left
    [self.contentView addSubview:self.leftView];
    [self.leftView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(pxToW(20));
        make.top.equalTo(self.contentView).offset(pxToH(20));
        make.bottom.equalTo(self.contentView).offset(-pxToH(20));
    }];
    //right
    if (dataArray.count > 1) {
        self.rightView.dataModel = dataArray[1];
        [self.contentView addSubview:self.rightView];
        [self.rightView makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.leftView.right).offset(pxToW(22));
            make.top.equalTo(self.contentView).offset(pxToH(20));
            make.right.equalTo(self.contentView).offset(-pxToW(20));
            make.bottom.equalTo(self.contentView).offset(-pxToH(20));
        }];
    }
    [super updateConstraints];
}
#pragma mark - setter / getter
- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    [self setViews:dataArray];
}

- (DWDLeaveSchoolCompleteDetailView *)leftView {
    if (!_leftView) {
        DWDLeaveSchoolCompleteDetailView *leftView = [[DWDLeaveSchoolCompleteDetailView alloc] init];
        _leftView = leftView;
    }
    return _leftView;
}

- (DWDLeaveSchoolCompleteDetailView *)rightView {
    if (!_rightView) {
        DWDLeaveSchoolCompleteDetailView *rightView = [[DWDLeaveSchoolCompleteDetailView alloc] init];
        _rightView = rightView;
    }
    return _rightView;
}

@end
