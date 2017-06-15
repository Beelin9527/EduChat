//
//  DWDLeaveSchoolWaitDetailView.m
//  EduChat
//
//  Created by KKK on 16/3/16.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDLeaveSchoolWaitDetailView.h"

#import "DWDTeacherGoSchoolStudentDetailModel.h"

#import <Masonry.h>
#import <UIImageView+WebCache.h>

@interface DWDLeaveSchoolWaitDetailView ()

@property (nonatomic, weak) UIImageView *studentImageView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UIButton *detailButton;

@end


@implementation DWDLeaveSchoolWaitDetailView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    UIImageView *studentImageView = [UIImageView new];
    [self addSubview:studentImageView];
    self.studentImageView = studentImageView;
    
    CGFloat picWidth = (DWDScreenW - pxToW(60)) / 4.0;
    CGFloat picHeight = picWidth;
    [studentImageView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self);
        make.right.equalTo(self);
        make.width.mas_equalTo(picWidth);
        make.height.mas_equalTo(picHeight);
    }];
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.font = DWDFontContent;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:nameLabel];
    self.nameLabel = nameLabel;
    [nameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(studentImageView.bottom).offset(pxToH(12));
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    return self;
}

#pragma mark - Setter / Getter
- (void)setDataModel:(DWDTeacherGoSchoolStudentDetailModel *)dataModel {
    _dataModel = dataModel;
    
    [_studentImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.photohead.photoKey]
                         placeholderImage:[UIImage imageNamed:@"ME_User_HP_Boy"]];
    _nameLabel.text = dataModel.name;
    
    [super updateConstraints];
}

@end
