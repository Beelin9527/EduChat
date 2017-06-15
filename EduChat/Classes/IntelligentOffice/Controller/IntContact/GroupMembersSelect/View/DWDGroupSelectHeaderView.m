//
//  DWDGroupSelectHeaderView.m
//  EduChat
//
//  Created by KKK on 16/12/5.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDGroupSelectHeaderView.h"

#import "DWDSchoolGroupModel.h"

#import <Masonry.h>

@interface DWDGroupSelectHeaderView ()

@property (nonatomic, weak) UIButton *selectButton;

@property (nonatomic, weak) UILabel *groupNameLabel;

@property (nonatomic, weak) UIButton *expandButton;

@property (nonatomic, strong) DWDSchoolGroupModel *model;

@end

@implementation DWDGroupSelectHeaderView

#pragma mark - Public Method
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    // 背景view
    UIView *bgView = [UIView new];
    bgView.backgroundColor = [UIColor whiteColor];
    self.backgroundView = bgView;
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    // 选择按钮
    UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectButton setImage:[UIImage imageNamed:@"class_group_member_select_normal"] forState:UIControlStateNormal];
    [selectButton setImage:[UIImage imageNamed:@"class_group_member_select_selected"] forState:UIControlStateSelected];
    [selectButton setSelected:NO];
    [selectButton addTarget:self action:@selector(selectAllButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:selectButton];
    [selectButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(self);
//        make.height.width.mas_equalTo(44);
    }];
    _selectButton = selectButton;
    
    // 组名label
    UILabel *groupNameLabel = [UILabel new];
    groupNameLabel.userInteractionEnabled = YES;
    groupNameLabel.font = [UIFont systemFontOfSize:16];
    groupNameLabel.textColor = DWDRGBColor(51, 51, 51);
    [self.contentView addSubview:groupNameLabel];
    [groupNameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(selectButton.right).offset(8);
        make.centerY.mas_equalTo(self);
    }];
    _groupNameLabel = groupNameLabel;
    
    //扩展按钮
    UIButton *expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [expandButton setImage:[UIImage imageNamed:@"icon_pulldown"] forState:UIControlStateNormal];
    [expandButton setImage:[UIImage imageNamed:@"icon_packup"] forState:UIControlStateSelected];
    [expandButton setSelected:NO];
    [expandButton addTarget:self action:@selector(expandButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:expandButton];
    [expandButton makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.centerY.mas_equalTo(self);
//        make.height.width.mas_equalTo(44);
    }];
    _expandButton = expandButton;
    
    // 分割线 
    UIView *lineView = [UIView new];
    lineView.backgroundColor = UIColorFromRGB(0xdddddd);
    lineView.frame = (CGRect){15, 43, DWDScreenW - 15, 1};
    [self.contentView addSubview:lineView];
    
    return self;
}

- (void)setHeaderData:(DWDSchoolGroupModel *)model {
    _model = model;
    [_selectButton setSelected:model.checked];
    [_expandButton setSelected:model.expanded];
    _groupNameLabel.text = model.groupName;
}

// 刷新页面的两个button state
- (void)reloadView {
    [_selectButton setSelected:_model.checked];
    [_expandButton setSelected:_model.expanded];
    _groupNameLabel.text = _model.groupName;
    [self setNeedsDisplay];
}

#pragma mark - Private Method
- (void)selectAllButtonClick:(UIButton *)button {
    [button setSelected:![button isSelected]];
    _model.checked = [button isSelected];
    for (DWDSchoolGroupMemberModel *memberModel in _model.groupMembers) {
        if ([button isSelected]) {
            memberModel.checked = YES;
        } else {
            memberModel.checked = NO;
        }
    }
    if (_eventDelegate &&[_eventDelegate respondsToSelector:@selector(groupSelectHeaderView:shouldAllSelectInSection:)]) {
        [_eventDelegate groupSelectHeaderView:self shouldAllSelectInSection:_section];
    }
}

- (void)expandButtonClick:(UIButton *)button {
    [button setSelected:![button isSelected]];
    _model.expanded = [button isSelected];
    if (_eventDelegate &&[_eventDelegate respondsToSelector:@selector(groupSelectHeaderView:shouldChangeExpandStateInSection:)]) {
        [_eventDelegate groupSelectHeaderView:self shouldChangeExpandStateInSection:_section];
    }
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint newPoint = [self convertPoint:point toView:self.contentView];
    
    // 判断点在不在按钮上
    if ([self.contentView pointInside:newPoint withEvent:event]) {
//        DWDLog(@"event:%zd", event.type);
        // 点在按钮上
        CGFloat checkX =DWDScreenW * 0.5;
        DWDLog(@"\ntouch point:  %f\nmaxWordLength:%f\n", newPoint.x, checkX);
        if (newPoint.x < checkX) {
            DWDLog(@"select");
            return _selectButton;
        }
        else if (newPoint.x >= checkX && newPoint.x <= DWDScreenW) {
            DWDLog(@"expand");
            return _expandButton;
        }
        else {
            DWDLog(@"geigei");
            return [super hitTest:point withEvent:event];
        }
    } else
        return [super hitTest:point withEvent:event];
}


@end
