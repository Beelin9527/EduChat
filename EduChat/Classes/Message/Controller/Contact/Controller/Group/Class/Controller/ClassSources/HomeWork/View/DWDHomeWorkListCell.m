//
//  DWDHomeWorkListCell.m
//  EduChat
//
//  Created by Catskiy on 2016/10/24.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDHomeWorkListCell.h"

@implementation DWDHomeWorkListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setSubviews];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(changeEditStatus:)
                                                     name:@"changeEditStatus"
                                                   object:nil];
    }
    return self;
}

- (void)setSubviews
{
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _backImgV = [[UIImageView alloc] init];
    _backImgV.frame = CGRectMake(DWDPadding, DWDPadding, DWDScreenW - 2 * DWDPadding, 50);
    _backImgV.image = [[UIImage imageNamed:@"bg_operation_operation_details"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
    [self addSubview:_backImgV];
    
    _iconView = [[UIImageView alloc] init];
    _iconView.frame = CGRectMake(17, (50 - 30)/2, 30, 30);
    _iconView.contentMode = UIViewContentModeScaleAspectFit;
    [_backImgV addSubview:_iconView];
    
    _homeWorkSubjectLabel = [[UILabel alloc] init];
    _homeWorkSubjectLabel.frame = CGRectMake(_backImgV.w - 50, 0, 40, _backImgV.h);
    _homeWorkSubjectLabel.font = DWDFontBody;
    _homeWorkSubjectLabel.textColor = DWDColorBody;
    _homeWorkSubjectLabel.textAlignment = NSTextAlignmentRight;
    [_backImgV addSubview:_homeWorkSubjectLabel];

    _homeWorkLabel = [[UILabel alloc] init];
    _homeWorkLabel.frame = CGRectMake(CGRectGetMaxX(_iconView.frame) + DWDPadding, 0, _backImgV.w - 50 - CGRectGetMaxX(_iconView.frame) - DWDPadding, _backImgV.h);
    _homeWorkLabel.font = DWDFontBody;
    _homeWorkLabel.textColor = DWDColorBody;
    [_backImgV addSubview:_homeWorkLabel];
    
    _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _selectBtn.frame = CGRectMake(-40, DWDPadding, 40, 50);
    [_selectBtn setImage:[UIImage imageNamed:@"btn_point_marquee_select_contacts_normal"] forState:UIControlStateNormal];
    [_selectBtn setImage:[UIImage imageNamed:@"btn_point_marquee_select_contacts_selected"] forState:UIControlStateSelected];
    [_selectBtn addTarget:self action:@selector(selectedBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_selectBtn];
}


- (void)changeEditStatus:(NSNotification *)notification
{
    NSNumber *flag = notification.userInfo[@"canSeleted"];
    _canSelected = [flag boolValue];
    if (_canSelected) {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.x += 20;
            self.homeWorkLabel.x += 20;
            self.homeWorkLabel.w -= 20;
            self.selectBtn.x = 10;
        }];
    }else {
        [UIView animateWithDuration:0.2 animations:^{
            self.iconView.x -= 20;
            self.homeWorkLabel.x -= 20;
            self.homeWorkLabel.w += 20;
            self.selectBtn.x = -40;
        }];
    }
    
    NSNumber *rFlag = notification.userInfo[@"reset"];
    if ([rFlag boolValue]) {
        self.selectBtn.selected = NO;
        self.isMultiSelected = NO;
    }
}

- (void)setCanSelected:(BOOL)canSelected
{
    _canSelected = canSelected;
    if (_canSelected) {
        self.iconView.x = 37;
        self.homeWorkLabel.x = CGRectGetMaxX(_iconView.frame) + DWDPadding;
        self.homeWorkLabel.w = _backImgV.w - 50 - CGRectGetMaxX(_iconView.frame) - DWDPadding;
        self.selectBtn.x = 10;
    }else {
        self.iconView.x = 17;
        self.homeWorkLabel.x = CGRectGetMaxX(_iconView.frame) + DWDPadding;
        self.homeWorkLabel.w = _backImgV.w - 50 - CGRectGetMaxX(_iconView.frame) - DWDPadding;
        self.selectBtn.x = -40;
    }
}

- (void)selectedBtnAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (!self.isMultiSelected && self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(homeWorkCellDidMultiSelectAtIndexPath:)]) {
        self.isMultiSelected = YES;
        [self.actionDelegate homeWorkCellDidMultiSelectAtIndexPath:self.indexPath];
    }
    
    else if (self.isMultiSelected && self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(homeWorkCellDidMultiDisselectAtIndexPath:)]) {
        self.isMultiSelected = NO;
        [self.actionDelegate homeWorkCellDidMultiDisselectAtIndexPath:self.indexPath];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"changeEditStatus"
                                                  object:nil];
}

@end
