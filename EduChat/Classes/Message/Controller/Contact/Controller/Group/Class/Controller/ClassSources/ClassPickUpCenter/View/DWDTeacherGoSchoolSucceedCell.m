//
//  DWDTeacherGoSchoolSucceedCell.m
//  EduChat
//
//  Created by KKK on 16/3/15.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDTeacherGoSchoolSucceedCell.h"
#import "DWDTeacherGoSchoolStudentDetailModel.h"
#import "DWDTeacherGoSchoolSucceedDetailView.h"

#import <Masonry.h>

@interface DWDTeacherGoSchoolSucceedCell ()

@property (nonatomic, strong) DWDTeacherGoSchoolSucceedDetailView *leftView;
@property (nonatomic, strong) DWDTeacherGoSchoolSucceedDetailView *rightView;

@end

@implementation DWDTeacherGoSchoolSucceedCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - private method
- (void)setTwoViews:(NSArray *)dataArray {
    [self.leftView removeFromSuperview];
    [self.rightView removeFromSuperview];
    self.leftView.dataModel = dataArray[0];
    self.rightView.dataModel = dataArray[1];
    //left
    [self.contentView addSubview:self.leftView];
    [self.leftView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(pxToW(20));
        make.top.equalTo(self.contentView).offset(pxToH(20));
        make.bottom.equalTo(self.contentView).offset(-pxToH(20));
    }];
    //right
    [self.contentView addSubview:self.rightView];
    [self.rightView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftView.right).offset(pxToW(22));
        make.top.equalTo(self.contentView).offset(pxToH(20));
        make.right.equalTo(self.contentView).offset(-pxToW(20));
        make.bottom.equalTo(self.contentView).offset(-pxToH(20));
    }];
    [super updateConstraints];
}

- (void)setSingleView:(DWDTeacherGoSchoolStudentDetailModel *)dataModel {
    [self.leftView removeFromSuperview];
    [self.rightView removeFromSuperview];
    self.leftView.dataModel = dataModel;
    //only left
    [self.contentView addSubview:self.leftView];
    [self.leftView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(pxToW(20));
        make.top.equalTo(self.contentView).offset(pxToH(20));
        make.bottom.equalTo(self.contentView).offset(-pxToH(20));
    }];
    [super updateConstraints];
}

#pragma mark - setter / getter
- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    
    switch (dataArray.count) {
        case 2:
            [self setTwoViews:dataArray];
            break;
        case 1:
            [self setSingleView:dataArray[0]];
            break;
        default:
            break;
    }
}

- (DWDTeacherGoSchoolSucceedDetailView *)leftView {
    if (!_leftView) {
        DWDTeacherGoSchoolSucceedDetailView *leftView = [[DWDTeacherGoSchoolSucceedDetailView alloc] init];
        _leftView = leftView;
    }
    return _leftView;
}

- (DWDTeacherGoSchoolSucceedDetailView *)rightView {
    if (!_rightView) {
        DWDTeacherGoSchoolSucceedDetailView *rightView = [[DWDTeacherGoSchoolSucceedDetailView alloc] init];
        _rightView = rightView;
    }
    return _rightView;
}

@end
