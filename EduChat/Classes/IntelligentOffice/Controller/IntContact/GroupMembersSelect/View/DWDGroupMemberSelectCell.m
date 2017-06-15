//
//  DWDGroupMemberSelectCell.m
//  EduChat
//
//  Created by KKK on 16/12/5.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDGroupMemberSelectCell.h"
#import "DWDSchoolGroupModel.h"

#import <Masonry.h>

@interface DWDGroupMemberSelectCell ()
@property (nonatomic, weak) UIButton *checkButton;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, strong) DWDSchoolGroupMemberModel *model;
@end

@implementation DWDGroupMemberSelectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
//    //偏移
//    [self setLayoutMargins:UIEdgeInsetsMake(0, 40, 0, 0)];
    
    //选中背景色
    UIView *selectedBackgroundView = [UIView new];
    selectedBackgroundView.backgroundColor = [UIColor clearColor];
    [self setSelectedBackgroundView:selectedBackgroundView];
    
    //控件
    UIButton *checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [checkButton addTarget:self action:@selector(checkButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [checkButton setImage:[UIImage imageNamed:@"class_group_member_select_normal"] forState:UIControlStateNormal];
    [checkButton setImage:[UIImage imageNamed:@"class_group_member_select_selected"] forState:UIControlStateSelected];
//    [checkButton setSize:(CGSize){80, 80}];
    [self.contentView addSubview:checkButton];
    [checkButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(40);
        make.centerY.mas_equalTo(0);
    }];
    _checkButton = checkButton;
    
    UILabel *nameLabel = [UILabel new];
    nameLabel.font = [UIFont systemFontOfSize:16];
    nameLabel.textColor = DWDRGBColor(102, 102, 102);
    [self.contentView addSubview:nameLabel];
    [nameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(checkButton.right).offset(8);
        make.centerY.mas_equalTo(self.contentView);
    }];
    _nameLabel = nameLabel;
    
    // 分割线
    UIView *lineView = [UIView new];
    lineView.backgroundColor = UIColorFromRGB(0xdddddd);
    lineView.frame = (CGRect){40, 43, DWDScreenW - 15, 1};
    [self.contentView addSubview:lineView];
    
    return self;
}

- (void)checkButtonDidClick:(UIButton *)button {
    _model.checked = !_model.checked;
    if (_eventDelegate && [_eventDelegate respondsToSelector:@selector(groupMemberSelectCellDidClickCheckButton:)]) {
        [_eventDelegate groupMemberSelectCellDidClickCheckButton:self];
    }
}

- (void)setCellData:(DWDSchoolGroupMemberModel *)model {
    _model = model;
    [_checkButton setSelected:model.checked];
    NSString *memberName = model.memberName;
#if DEBUG
    if (memberName.length == 0 || memberName == nil) {
        memberName = @"返回数据没有名字";
    }
#else
#endif
    _nameLabel.text = memberName;
}


- (void)dealloc {
    DWDLog(@"%@:%s",self, __func__);
}

@end
